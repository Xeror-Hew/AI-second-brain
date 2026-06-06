#!/usr/bin/env node
/*
 * brain.mjs — the second-brain MCP server (zero dependencies).
 *
 * A typed index over the project_brain/ vault: the model calls compact tools instead of
 * reading whole markdown files, and pulls notes as resources on demand. Markdown stays the
 * source of truth; this server only reads and surgically writes it, never outside the vault.
 *
 * Transport: stdio, newline-delimited JSON-RPC 2.0 (one JSON object per line). No framing.
 * Locates the vault via CLAUDE_PROJECT_DIR (set by Claude Code), falling back to cwd.
 * Logs only to stderr; stdout carries protocol traffic only.
 */

import { readFileSync, writeFileSync, renameSync, readdirSync, statSync, existsSync, mkdirSync, copyFileSync } from 'node:fs'
import { join, basename, dirname, extname, relative, resolve, sep } from 'node:path'

const PROTOCOL_VERSION = '2025-06-18'
const SNAPSHOT_COOLDOWN_MIN = 20
const EXCLUDED_DIRS = new Set(['history', 'memory', '.obsidian', '.git'])
const SEARCH_MAX_HITS = 30
const SNIPPET_CHARS = 160
const MAX_QUERY_CHARS = 200
const MAX_DOC_CHARS = 24000 // keep whole-doc returns under the MCP token budget

const PROJECT_DIR = resolve(process.env.CLAUDE_PROJECT_DIR || process.cwd())
const BRAIN = resolve(PROJECT_DIR, 'project_brain')

// Localization manifest: project_brain/.brain.json maps canonical names -> the localized folder/file
// (and roadmap section) names the user sees. The engine speaks canonical; N()/S() resolve to the
// physical name. Missing or invalid manifest = identity (English). project_brain, history, and memory
// stay canonical and are never remapped.
const MANIFEST = (() => {
  try { return JSON.parse(readFileSync(join(BRAIN, '.brain.json'), 'utf8')) || {} } catch { return {} }
})()
const NAMES = MANIFEST.names || {}
const SECTIONS = MANIFEST.sections || {}
const N = (canonical) => NAMES[canonical] || canonical
const S = (canonical) => SECTIONS[canonical] || canonical

const log = (...a) => process.stderr.write('[brain] ' + a.join(' ') + '\n')

/* ---------- vault helpers ---------- */

function listDocs() {
  const out = []
  const walk = (dir) => {
    let entries
    try { entries = readdirSync(dir, { withFileTypes: true }) } catch { return }
    for (const e of entries) {
      if (e.isDirectory()) {
        if (!EXCLUDED_DIRS.has(e.name)) walk(join(dir, e.name))
      } else if (extname(e.name) === '.md') {
        out.push(join(dir, e.name))
      }
    }
  }
  walk(BRAIN)
  return out
}

function readFileSafe(p) {
  try { return readFileSync(p, 'utf8') } catch { return null }
}

// True only if an absolute path is the vault root or sits inside it (sep-aware, so a sibling
// like project_brain-foo is NOT considered inside).
function withinVault(rp) {
  return rp === BRAIN || rp.startsWith(BRAIN + sep)
}

// Resolve a tool target to an absolute path INSIDE the vault. Accepts note://name,
// section://file#heading, a vault-relative path, or a bare basename. Absolute or `..`
// targets that escape project_brain/ are rejected (return null) — no read or write can leave the vault.
function resolveDoc(target) {
  if (!target) return { path: null, heading: null }
  let t = String(target).replace(/^note:\/\//, '').replace(/^section:\/\//, '')
  let heading = null
  if (t.includes('#')) { heading = t.slice(t.indexOf('#') + 1); t = t.slice(0, t.indexOf('#')) }
  t = t.trim()
  const names = t.toLowerCase().endsWith('.md') ? [t] : [t, t + '.md']
  for (const n of names) {
    const rp = resolve(BRAIN, n) // an absolute n would escape, but withinVault rejects it
    if (withinVault(rp) && existsSync(rp) && statSync(rp).isFile()) return { path: rp, heading }
  }
  // basename fallback across the vault (listDocs only yields paths already inside BRAIN)
  const bare = t.toLowerCase().endsWith('.md') ? t : t + '.md'
  for (const d of listDocs()) if (basename(d).toLowerCase() === basename(bare).toLowerCase()) return { path: d, heading }
  return { path: null, heading }
}

// Heading blocks over the lines array, code-fence aware (a `#` line inside ``` / ~~~ is not a heading).
function headingMap(lines) {
  const heads = []
  let inFence = false
  for (let i = 0; i < lines.length; i++) {
    if (/^\s*(```|~~~)/.test(lines[i])) { inFence = !inFence; continue }
    if (inFence) continue
    const m = /^(#{1,6})\s+(.*)$/.exec(lines[i])
    if (m) heads.push({ level: m[1].length, title: m[2].trim(), line: i })
  }
  return heads
}

// Locate a heading: prefer a single exact (case-insensitive) match; flag ambiguity on duplicates;
// else fall back to a WORD-BOUNDARY match (so "open" never matches "Reopened", but "BLOCKERS"
// still matches the emoji-prefixed "🔴 BLOCKERS"). Returns {idx, ambiguous}.
function findHeading(heads, heading) {
  const want = heading.toLowerCase().replace(/^#+\s*/, '').trim()
  const exact = heads.map((h, i) => ({ h, i })).filter((x) => x.h.title.toLowerCase() === want)
  if (exact.length === 1) return { idx: exact[0].i, ambiguous: false }
  if (exact.length > 1) return { idx: exact[0].i, ambiguous: true, candidates: exact.map((x) => x.h.title) }
  let wb
  try { wb = new RegExp('\\b' + want.replace(/[.*+?^${}()|[\]\\]/g, '\\$&') + '\\b', 'i') } catch { wb = null }
  const byWord = heads.findIndex((h) => (wb ? wb.test(h.title) : h.title.toLowerCase().includes(want)))
  return { idx: byWord, ambiguous: false }
}

// Section under a heading: from the heading line to the next heading of same-or-higher level (or EOF).
function getSection(content, heading) {
  const lines = content.split('\n')
  if (!heading) return content
  const heads = headingMap(lines)
  const { idx } = findHeading(heads, heading)
  if (idx < 0) return null
  const start = heads[idx].line
  const level = heads[idx].level
  let end = lines.length
  for (let j = idx + 1; j < heads.length; j++) { if (heads[j].level <= level) { end = heads[j].line; break } }
  return lines.slice(start, end).join('\n').trim()
}

function cap(text) {
  if (text.length <= MAX_DOC_CHARS) return text
  return text.slice(0, MAX_DOC_CHARS) + `\n\n... [truncated: ${text.length - MAX_DOC_CHARS} more chars; request a specific #heading]`
}

/* ---------- snapshot-before-write (keeps the history/ safety net intact for MCP writes) ---------- */

function isSnapshotEligible(p) {
  const norm = p.split(sep).join('/').toLowerCase()
  if (!norm.includes('/project_brain/')) return false
  if (extname(p) !== '.md') return false
  // history/ and memory/ are engine folders (canonical); roadmap/ and notes/ may be localized.
  const skip = ['history', 'memory', N('roadmap'), N('notes')].map((d) => '/' + String(d).toLowerCase() + '/')
  return !skip.some((d) => norm.includes(d))
}

function snapshotIfEligible(p) {
  try {
    if (!isSnapshotEligible(p) || !existsSync(p)) return
    const base = basename(p, '.md')
    const snapDir = join(BRAIN, 'history', base)
    if (existsSync(snapDir)) {
      const prev = readdirSync(snapDir).filter((f) => f.endsWith('.md')).sort()
      const last = prev[prev.length - 1]
      const m = last && /(\d{4}-\d{2}-\d{2}T\d{2}-\d{2}-\d{2})/.exec(last)
      if (m) {
        // stamp is UTC; reparse as UTC (append 'Z') so age isn't skewed by the local timezone
        const t = m[1].replace(/T(\d{2})-(\d{2})-(\d{2})/, 'T$1:$2:$3') + 'Z'
        const ageMin = (Date.now() - new Date(t).getTime()) / 60000
        if (ageMin >= 0 && ageMin < SNAPSHOT_COOLDOWN_MIN) return // future-looking stamp never suppresses the snapshot
      }
    } else {
      mkdirSync(snapDir, { recursive: true })
    }
    const stamp = new Date().toISOString().replace(/:/g, '-').replace(/\..+$/, '')
    copyFileSync(p, join(snapDir, `${base} ${stamp}.md`))
  } catch (e) { log('snapshot skipped:', e.message) }
}

function atomicWrite(p, content) {
  mkdirSync(dirname(p), { recursive: true })
  const tmp = p + '.brain.' + process.pid + '.tmp'
  writeFileSync(tmp, content)
  renameSync(tmp, p)
}

/* ---------- tool implementations ---------- */

function toolOrient() {
  const parts = []
  const next = readFileSafe(join(BRAIN, N('next_step') + '.md'))
  parts.push(next ? next.trim() : '## NEXT STEP\n(next_step not found)')

  const roadmap = readFileSafe(join(BRAIN, N('roadmap'), N('roadmap') + '.md'))
  if (roadmap) {
    const blockers = getSection(roadmap, S('BLOCKERS'))
    const current = getSection(roadmap, S('CURRENT FRONT'))
    if (blockers && /- \[/.test(blockers)) parts.push(blockers)   // section already carries its own heading
    if (current) parts.push(current)
    if (!current && !blockers) parts.push('## ROADMAP\n' + roadmap.trim().slice(0, 600))
  } else {
    parts.push('## ROADMAP\n(roadmap not found)')
  }

  const logRaw = readFileSafe(join(BRAIN, N('roadmap'), N('roadmap') + '_log.md'))
  if (logRaw) {
    const logLines = logRaw.split('\n').filter((l) => /^[-*]\s|\d{4}-\d{2}-\d{2}/.test(l))
    const recent = logLines.slice(-6)
    if (recent.length) parts.push('## Recent log\n' + recent.join('\n'))
  }
  return parts.join('\n\n')
}

function toolSearch(query, useRegex) {
  if (!query) return 'error: query required'
  if (query.length > MAX_QUERY_CHARS) return `error: query too long (max ${MAX_QUERY_CHARS} chars)`
  // Default: literal case-insensitive substring (no ReDoS surface). Regex only on explicit opt-in.
  let matches
  if (useRegex) {
    let re
    try { re = new RegExp(query, 'i') } catch { return 'error: invalid regex' }
    matches = (line) => re.test(line)
  } else {
    const q = query.toLowerCase()
    matches = (line) => line.toLowerCase().includes(q)
  }
  const hits = []
  for (const p of listDocs()) {
    const content = readFileSafe(p)
    if (!content) continue
    const lines = content.split('\n')
    const heads = headingMap(lines)
    for (let i = 0; i < lines.length; i++) {
      if (matches(lines[i])) {
        let heading = ''
        for (let j = heads.length - 1; j >= 0; j--) { if (heads[j].line <= i) { heading = heads[j].title; break } }
        hits.push({ path: relative(PROJECT_DIR, p).split(sep).join('/'), line: i + 1, heading, snippet: lines[i].trim().slice(0, SNIPPET_CHARS) })
        if (hits.length >= SEARCH_MAX_HITS) break
      }
    }
    if (hits.length >= SEARCH_MAX_HITS) break
  }
  if (!hits.length) return `no matches for "${query}" in project_brain/`
  return hits.map((h) => `${h.path}:${h.line}  [${h.heading}]  ${h.snippet}`).join('\n')
}

function toolGet(target) {
  const { path, heading } = resolveDoc(target)
  if (!path) return `error: not found in vault: ${target}`
  const content = readFileSafe(path)
  if (content == null) return `error: unreadable: ${target}`
  if (heading) {
    const sec = getSection(content, heading)
    return sec != null ? cap(sec) : `error: heading not found: #${heading} in ${basename(path)}`
  }
  return cap(content.trim())
}

function toolAppend(file, heading, text) {
  if (!file || !text) return 'error: file and text required'
  const { path } = resolveDoc(file)
  if (!path) return `error: not found in vault: ${file}`
  let content = readFileSafe(path)
  if (content == null) return `error: unreadable: ${file}`
  snapshotIfEligible(path)
  let where = ''
  if (!heading) {
    content = content.replace(/\s*$/, '') + '\n' + text.trim() + '\n'
    where = ' (end)'
  } else {
    const lines = content.split('\n')
    const heads = headingMap(lines)
    const { idx, ambiguous, candidates } = findHeading(heads, heading)
    if (ambiguous) return `error: heading "${heading}" is ambiguous (${candidates.length} matches: ${candidates.join(' | ')}); use a more specific heading`
    if (idx < 0) return `error: heading not found: ${heading}`
    const level = heads[idx].level
    let end = lines.length
    for (let j = idx + 1; j < heads.length; j++) { if (heads[j].level <= level) { end = heads[j].line; break } }
    let insertAt = end
    while (insertAt > heads[idx].line + 1 && lines[insertAt - 1].trim() === '') insertAt--
    lines.splice(insertAt, 0, text.trim())
    content = lines.join('\n')
    where = ' under "' + heads[idx].title + '"' // report the heading actually resolved, not the one requested
  }
  atomicWrite(path, content)
  return `appended to ${relative(PROJECT_DIR, path).split(sep).join('/')}${where}`
}

function toolSetNext(text) {
  if (!text) return 'error: text required'
  const p = join(BRAIN, N('next_step') + '.md')
  snapshotIfEligible(p)
  const body = `# 🎯 NEXT STEP\n\n> One active item. Overwritten when it's done.\n\n${text.trim()}\n`
  atomicWrite(p, body)
  return 'next_step.md set'
}

function toolLogDone(text) {
  if (!text) return 'error: text required'
  const p = join(BRAIN, N('roadmap'), N('roadmap') + '_log.md')
  let content = readFileSafe(p)
  if (content == null) content = '# 🧾 Roadmap log\n\n> Append-only. One line per shipped change.\n'
  const date = new Date().toISOString().slice(0, 10)
  const line = `- ${date}: ${text.trim()}`
  content = content.replace(/\s*$/, '') + '\n' + line + '\n'
  atomicWrite(p, content)
  return `logged: ${line}`
}

/* ---------- resources & prompts ---------- */

function listResources() {
  return listDocs().map((p) => ({
    uri: 'note://' + basename(p, '.md'),
    name: basename(p, '.md'),
    description: relative(PROJECT_DIR, p).split(sep).join('/'),
    mimeType: 'text/markdown',
  }))
}

function readResource(uri) {
  const { path, heading } = resolveDoc(uri)
  if (!path) return null
  const content = readFileSafe(path)
  if (content == null) return null
  const text = heading ? (getSection(content, heading) ?? content) : content
  return { uri, mimeType: 'text/markdown', text: cap(text) }
}

const PROMPTS = {
  start: {
    description: 'Orient at session start: read where work stopped via the brain, touch nothing.',
    text: 'Call brain_orient to see the next step, active roadmap, and blockers. Then read only the one doc you need (brain_get or @brain:note://...). Stay read-only; give a short recap of where we stopped and what is next.',
  },
  done: {
    description: 'Close out a finished task through the brain.',
    text: 'A task just finished. Call brain_log_done with what shipped, prune the finished item from the roadmap, and call brain_set_next with the next concrete action. If you produced or reshaped a deliverable, update the library; if the workspace shape changed, update the work map.',
  },
  set_next: {
    description: 'Set the single active next step.',
    text: 'Call brain_set_next with one concrete next action plus how to validate it.',
  },
}

/* ---------- JSON-RPC plumbing ---------- */

const TOOLS = [
  {
    name: 'brain_orient',
    description: 'Where work stopped: the active next step, open roadmap items, blockers, and recent log. Call at session start instead of reading multiple docs.',
    inputSchema: { type: 'object', properties: {}, additionalProperties: false },
    _meta: { 'anthropic/alwaysLoad': true },
  },
  {
    name: 'brain_search',
    description: 'Search the project_brain vault. Returns ranked path:line [heading] snippet hits. Literal substring by default; set regex:true for a pattern. Use to find where something lives before reading.',
    inputSchema: { type: 'object', properties: { query: { type: 'string' }, regex: { type: 'boolean', description: 'treat query as a regular expression (default false)' } }, required: ['query'], additionalProperties: false },
  },
  {
    name: 'brain_get',
    description: 'Read one section or a whole brain doc. Target: note://file, file#heading, a vault path, or a basename. Stays inside the vault.',
    inputSchema: { type: 'object', properties: { target: { type: 'string' } }, required: ['target'], additionalProperties: false },
  },
  {
    name: 'brain_append',
    description: 'Append text under a heading in a brain doc (atomic; snapshots the doc first). Omit heading to append at end. Errors on an ambiguous heading.',
    inputSchema: { type: 'object', properties: { file: { type: 'string' }, heading: { type: 'string' }, text: { type: 'string' } }, required: ['file', 'text'], additionalProperties: false },
  },
  {
    name: 'brain_set_next',
    description: 'Overwrite next_step.md with the single active next action.',
    inputSchema: { type: 'object', properties: { text: { type: 'string' } }, required: ['text'], additionalProperties: false },
  },
  {
    name: 'brain_log_done',
    description: 'Append a dated line to roadmap_log.md recording a shipped change.',
    inputSchema: { type: 'object', properties: { text: { type: 'string' } }, required: ['text'], additionalProperties: false },
  },
]

const SERVER_INSTRUCTIONS =
  'The second brain over project_brain/. Use brain_orient to get oriented at session start; ' +
  'brain_search/brain_get to retrieve on demand instead of reading whole files; ' +
  'brain_append/brain_set_next/brain_log_done to record progress. Markdown stays the source of truth.'

function ok(id, result) { send({ jsonrpc: '2.0', id, result }) }
function rpcErr(id, code, message) { send({ jsonrpc: '2.0', id, error: { code, message } }) }
function send(obj) { process.stdout.write(JSON.stringify(obj) + '\n') }
function textResult(s) { return { content: [{ type: 'text', text: String(s) }] } }

function callTool(name, args) {
  switch (name) {
    case 'brain_orient': return textResult(toolOrient())
    case 'brain_search': return textResult(toolSearch(args.query, args.regex === true))
    case 'brain_get': return textResult(toolGet(args.target))
    case 'brain_append': return textResult(toolAppend(args.file, args.heading, args.text))
    case 'brain_set_next': return textResult(toolSetNext(args.text))
    case 'brain_log_done': return textResult(toolLogDone(args.text))
    default: return null
  }
}

function handle(msg) {
  if (Array.isArray(msg)) return rpcErr(null, -32600, 'batch requests are not supported') // JSON-RPC batch: reject explicitly, never silently drop
  const { id, method, params } = msg
  switch (method) {
    case 'initialize':
      return ok(id, {
        protocolVersion: (params && params.protocolVersion) || PROTOCOL_VERSION,
        capabilities: { tools: {}, resources: {}, prompts: {} },
        serverInfo: { name: 'brain', version: '2.0.1' },
        instructions: SERVER_INSTRUCTIONS,
      })
    case 'notifications/initialized':
    case 'initialized':
    case 'notifications/cancelled':
      return
    case 'ping':
      return ok(id, {})
    case 'tools/list':
      return ok(id, { tools: TOOLS })
    case 'tools/call': {
      const res = callTool(params?.name, params?.arguments || {})
      if (res === null) return rpcErr(id, -32602, `unknown tool: ${params?.name}`)
      return ok(id, res)
    }
    case 'resources/list':
      return ok(id, { resources: listResources() })
    case 'resources/templates/list':
      return ok(id, { resourceTemplates: [
        { uriTemplate: 'note://{name}', name: 'note', description: 'A living brain doc by basename', mimeType: 'text/markdown' },
        { uriTemplate: 'section://{file}#{heading}', name: 'section', description: 'One heading section of a brain doc', mimeType: 'text/markdown' },
      ] })
    case 'resources/read': {
      const r = readResource(params?.uri)
      if (!r) return rpcErr(id, -32602, `resource not found in vault: ${params?.uri}`)
      return ok(id, { contents: [r] })
    }
    case 'prompts/list':
      return ok(id, { prompts: Object.entries(PROMPTS).map(([name, p]) => ({ name, description: p.description })) })
    case 'prompts/get': {
      const p = PROMPTS[params?.name]
      if (!p) return rpcErr(id, -32602, `unknown prompt: ${params?.name}`)
      return ok(id, { description: p.description, messages: [{ role: 'user', content: { type: 'text', text: p.text } }] })
    }
    default:
      if (id !== undefined && id !== null) rpcErr(id, -32601, `method not found: ${method}`)
  }
}

let buf = ''
process.stdin.setEncoding('utf8')
process.stdin.on('data', (chunk) => {
  buf += chunk
  let nl
  while ((nl = buf.indexOf('\n')) >= 0) {
    const line = buf.slice(0, nl).trim()
    buf = buf.slice(nl + 1)
    if (!line) continue
    try { handle(JSON.parse(line)) } catch (e) { rpcErr(null, -32700, 'parse error: ' + e.message) }
  }
})
process.stdin.on('end', () => process.exit(0))
log('brain MCP ready; vault =', BRAIN)
