#!/usr/bin/env node
/*
 * snapshot-all.mjs — manual snapshot fallback for surfaces without the PreToolUse hook (Claude Cowork).
 *
 * Freezes the "before" of every living brain doc into project_brain/history/<base>/<base> <stamp>.md,
 * using the SAME eligibility, cooldown, and naming as the brain MCP (brain.mjs) and the snapshot hook,
 * so the three writers share one history/ and one 20-minute cooldown clock.
 *
 * Run it via /snapshot, or directly: node .claude/hooks/snapshot-all.mjs
 * Locates the vault via CLAUDE_PROJECT_DIR, falling back to cwd.
 */
import { readFileSync, readdirSync, existsSync, mkdirSync, copyFileSync } from 'node:fs'
import { join, basename, extname, resolve, sep } from 'node:path'

const SNAPSHOT_COOLDOWN_MIN = 20
const EXCLUDED_DIRS = new Set(['history', 'memory', '.obsidian', '.git'])
const PROJECT_DIR = resolve(process.env.CLAUDE_PROJECT_DIR || process.cwd())
const BRAIN = resolve(PROJECT_DIR, 'project_brain')

// Localization manifest: resolve canonical roadmap/notes names to whatever the user renamed them to.
const MANIFEST = (() => {
  try { return JSON.parse(readFileSync(join(BRAIN, '.brain.json'), 'utf8')) || {} } catch { return {} }
})()
const NAMES = MANIFEST.names || {}
const N = (c) => NAMES[c] || c

function listDocs() {
  const out = []
  const walk = (dir) => {
    let entries
    try { entries = readdirSync(dir, { withFileTypes: true }) } catch { return }
    for (const e of entries) {
      if (e.isDirectory()) { if (!EXCLUDED_DIRS.has(e.name)) walk(join(dir, e.name)) }
      else if (extname(e.name) === '.md') out.push(join(dir, e.name))
    }
  }
  walk(BRAIN)
  return out
}

// Same rule as brain.mjs isSnapshotEligible: living .md under project_brain/, minus roadmap/ and notes/
// (roadmap keeps its own log; notes is the user's scratch). history/ and memory/ are filtered by the walk.
function isEligible(p) {
  const norm = p.split(sep).join('/').toLowerCase()
  if (!norm.includes('/project_brain/')) return false
  if (extname(p) !== '.md') return false
  const skip = ['history', 'memory', N('roadmap'), N('notes')].map((d) => '/' + String(d).toLowerCase() + '/')
  return !skip.some((d) => norm.includes(d))
}

function snapshot(p) {
  if (!isEligible(p) || !existsSync(p)) return false
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
      if (ageMin >= 0 && ageMin < SNAPSHOT_COOLDOWN_MIN) return false // inside the cooldown window
    }
  } else {
    mkdirSync(snapDir, { recursive: true })
  }
  const stamp = new Date().toISOString().replace(/:/g, '-').replace(/\..+$/, '')
  copyFileSync(p, join(snapDir, `${base} ${stamp}.md`))
  return true
}

let n = 0
for (const p of listDocs()) { if (snapshot(p)) { n++; console.log('snapshot:', basename(p)) } }
console.log(n ? `\n${n} snapshot(s) written to project_brain/history/` : '\nnothing to snapshot (all within the 20-min cooldown, or no eligible docs)')
