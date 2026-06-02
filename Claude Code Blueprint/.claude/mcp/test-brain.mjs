// Full integration test for brain.mjs: builds a fixture vault, drives every method, asserts
// JSON-RPC responses AND filesystem side-effects. Includes the security/correctness regressions
// found in adversarial review (vault escape, ReDoS, code-fence headings, ambiguous headings, batch).
import { spawn } from 'node:child_process'
import { fileURLToPath } from 'node:url'
import { dirname, join } from 'node:path'
import { mkdirSync, writeFileSync, rmSync, readFileSync, existsSync, readdirSync } from 'node:fs'

const __dirname = dirname(fileURLToPath(import.meta.url))
const VAULT = join(__dirname, '_test_vault')
const PB = join(VAULT, 'project_brain')

rmSync(VAULT, { recursive: true, force: true })
const mk = (p, c) => { mkdirSync(dirname(p), { recursive: true }); writeFileSync(p, c) }
mk(join(PB, 'next_step.md'), '# 🎯 NEXT STEP\n\nWire the brain MCP into the plugin .mcp.json and validate.\n')
mk(join(PB, 'roadmap', 'roadmap.md'), `# ✅ Roadmap

## 🔴 BLOCKERS

- [ ] **MCP not yet wired** — finish .mcp.json

## 🟠 CURRENT FRONT (Phase 3)

- [ ] Build brain MCP
- [ ] Port hooks to plugin

## 🟡 NEXT FRONTS

- [ ] Redundancy pass
`)
mk(join(PB, 'roadmap', 'roadmap_log.md'), '# 🧾 Roadmap log\n\n> Append-only.\n\n- 2026-05-28: scaffolded plugin layout (abc1234)\n')
mk(join(PB, 'plan', 'plan_tech.md'), '# 🤖 Plan (the how)\n\n## Architecture\n\nHybrid plugin.\n\n## Open questions\n\nNone.\n')
mk(join(PB, 'Vision.md'), '# 💡 Vision\n\nA second brain that fuses user and AI.\n')
// a section whose body contains a fenced code block with a fake heading inside it
mk(join(PB, 'fence-test.md'), '# Doc\n\n## Real Section\n\nreal body before fence\n\n```md\n## Fake Heading In Fence\n```\n\nreal body after fence\n\n## Other Section\n\nother\n')
// duplicate identical headings
mk(join(PB, 'dup-test.md'), '# Doc\n\n## Same\n\nfirst\n\n## Same\n\nsecond\n')
// SECRET file OUTSIDE the vault (one level above project_brain)
mk(join(VAULT, 'secret-outside.md'), 'TOP SECRET OUTSIDE VAULT\n')
// old snapshot far in the past so append still snapshots
mk(join(PB, 'history', 'plan_tech', 'plan_tech 2020-01-01T00-00-00.md'), 'old\n')

const srv = spawn(process.execPath, [join(__dirname, 'brain.mjs')], {
  stdio: ['pipe', 'pipe', 'inherit'],
  env: { ...process.env, CLAUDE_PROJECT_DIR: VAULT },
})
const responses = []
let buf = ''
srv.stdout.setEncoding('utf8')
srv.stdout.on('data', (c) => {
  buf += c
  let nl
  while ((nl = buf.indexOf('\n')) >= 0) {
    const line = buf.slice(0, nl).trim(); buf = buf.slice(nl + 1)
    if (line) responses.push(JSON.parse(line))
  }
})
const send = (o) => srv.stdin.write(JSON.stringify(o) + '\n')
const raw = (s) => srv.stdin.write(s + '\n')
const sleep = (ms) => new Promise((r) => setTimeout(r, ms))
const byId = (id) => responses.find((r) => r.id === id)
const txt = (id) => byId(id)?.result?.content?.[0]?.text || ''
let failures = 0
const check = (cond, msg) => { if (!cond) { failures++; console.error('FAIL:', msg) } else { console.log('ok:', msg) } }

;(async () => {
  send({ jsonrpc: '2.0', id: 1, method: 'initialize', params: { protocolVersion: '2025-06-18', capabilities: {}, clientInfo: { name: 't', version: '1' } } })
  await sleep(30)
  send({ jsonrpc: '2.0', method: 'notifications/initialized' })
  await sleep(20)
  send({ jsonrpc: '2.0', id: 2, method: 'tools/list' })
  send({ jsonrpc: '2.0', id: 3, method: 'tools/call', params: { name: 'brain_orient', arguments: {} } })
  send({ jsonrpc: '2.0', id: 4, method: 'tools/call', params: { name: 'brain_search', arguments: { query: 'hooks' } } })
  send({ jsonrpc: '2.0', id: 5, method: 'tools/call', params: { name: 'brain_get', arguments: { target: 'plan_tech#Architecture' } } })
  send({ jsonrpc: '2.0', id: 6, method: 'tools/call', params: { name: 'brain_get', arguments: { target: 'note://Vision' } } })
  send({ jsonrpc: '2.0', id: 7, method: 'tools/call', params: { name: 'brain_append', arguments: { file: 'roadmap/roadmap.md', heading: 'CURRENT FRONT', text: '- [ ] Appended task' } } })
  send({ jsonrpc: '2.0', id: 8, method: 'tools/call', params: { name: 'brain_append', arguments: { file: 'plan_tech', heading: 'Architecture', text: 'Appended architecture note.' } } })
  send({ jsonrpc: '2.0', id: 9, method: 'tools/call', params: { name: 'brain_set_next', arguments: { text: 'Validate with claude plugin validate --strict.' } } })
  send({ jsonrpc: '2.0', id: 10, method: 'tools/call', params: { name: 'brain_log_done', arguments: { text: 'built and tested brain MCP', hash: 'def5678' } } })
  send({ jsonrpc: '2.0', id: 11, method: 'resources/list' })
  send({ jsonrpc: '2.0', id: 12, method: 'resources/read', params: { uri: 'note://Vision' } })
  send({ jsonrpc: '2.0', id: 13, method: 'prompts/list' })
  // --- security: vault escape attempts must be rejected ---
  send({ jsonrpc: '2.0', id: 20, method: 'tools/call', params: { name: 'brain_get', arguments: { target: '../secret-outside.md' } } })
  send({ jsonrpc: '2.0', id: 21, method: 'tools/call', params: { name: 'brain_append', arguments: { file: '../secret-outside.md', text: 'INJECTED' } } })
  send({ jsonrpc: '2.0', id: 22, method: 'resources/read', params: { uri: 'note://../secret-outside' } })
  // --- ReDoS-safe: catastrophic pattern treated literally by default, returns fast ---
  send({ jsonrpc: '2.0', id: 23, method: 'tools/call', params: { name: 'brain_search', arguments: { query: '(a+)+$' } } })
  // --- code-fence heading: real section returns full body past the fake fenced heading ---
  send({ jsonrpc: '2.0', id: 24, method: 'tools/call', params: { name: 'brain_get', arguments: { target: 'fence-test#Real Section' } } })
  // --- ambiguous heading on append must error, not silently write the first ---
  send({ jsonrpc: '2.0', id: 25, method: 'tools/call', params: { name: 'brain_append', arguments: { file: 'dup-test', heading: 'Same', text: 'X' } } })
  await sleep(60)
  // --- JSON-RPC batch array must be rejected, not silently dropped ---
  raw('[{"jsonrpc":"2.0","id":90,"method":"ping"}]')
  await sleep(60)
  srv.stdin.end()
  await sleep(120)

  check(byId(1)?.result?.protocolVersion === '2025-06-18', 'initialize echoes protocolVersion')
  const tools = byId(2)?.result?.tools || []
  check(tools.length === 6, `tools/list returns 6 tools (got ${tools.length})`)
  check(tools.find((t) => t.name === 'brain_orient')?._meta?.['anthropic/alwaysLoad'] === true, 'brain_orient alwaysLoad')

  const o = txt(3)
  check(/Wire the brain MCP/.test(o) && /BLOCKERS/.test(o) && /CURRENT FRONT/.test(o) && /Recent log/.test(o), 'orient has next/blockers/current/log')
  check(!/##\s+##/.test(o), 'orient has NO double "## ##" heading (regression)')

  check(/roadmap\.md:\d+/.test(txt(4)), 'search finds "hooks" with path:line')
  check(/## Architecture/.test(txt(5)) && /Hybrid plugin/.test(txt(5)) && !/Open questions/.test(txt(5)), 'get section is just that slice')
  check(/A second brain that fuses/.test(txt(6)), 'get note:// whole doc')

  check(/appended to/.test(txt(7)), 'append roadmap ok')
  const roadmapAfter = readFileSync(join(PB, 'roadmap', 'roadmap.md'), 'utf8')
  check(/Appended task[\s\S]*NEXT FRONTS/.test(roadmapAfter), 'append landed in CURRENT FRONT before NEXT FRONTS')
  check(/under "🟠 CURRENT FRONT/.test(txt(7)), 'append reports the RESOLVED heading (emoji title), not the requested one')

  check(/appended to/.test(txt(8)), 'append plan_tech ok')
  const snaps = existsSync(join(PB, 'history', 'plan_tech')) ? readdirSync(join(PB, 'history', 'plan_tech')).filter((f) => f.endsWith('.md')) : []
  check(snaps.length >= 2, `snapshot-before-write fired despite timezone (snaps=${snaps.length}) [UTC-Z fix]`)

  check(/next_step\.md set/.test(txt(9)) && /Validate with claude plugin/.test(readFileSync(join(PB, 'next_step.md'), 'utf8')), 'set_next overwrote')
  check(/built and tested brain MCP \(def5678\)/.test(readFileSync(join(PB, 'roadmap', 'roadmap_log.md'), 'utf8')), 'log_done appended dated+hash')

  const res = byId(11)?.result?.resources || []
  check(res.some((r) => r.uri === 'note://Vision') && !res.some((r) => r.uri.includes('history')), 'resources/list has Vision, excludes history')
  check(/A second brain/.test(byId(12)?.result?.contents?.[0]?.text || ''), 'resources/read returns text')
  check((byId(13)?.result?.prompts || []).length === 3, 'prompts/list has 3')

  // security
  check(/error: not found in vault/.test(txt(20)), 'SECURITY: brain_get ../secret-outside REJECTED')
  check(/error: not found in vault/.test(txt(21)), 'SECURITY: brain_append ../secret-outside REJECTED')
  check(readFileSync(join(VAULT, 'secret-outside.md'), 'utf8') === 'TOP SECRET OUTSIDE VAULT\n', 'SECURITY: out-of-vault file UNCHANGED (no write escaped)')
  check(byId(22)?.error || !/TOP SECRET/.test(byId(22)?.result?.contents?.[0]?.text || ''), 'SECURITY: resources/read ../secret-outside REJECTED')

  // ReDoS-safe
  check(byId(23) !== undefined, 'ReDoS: catastrophic query returned (no event-loop hang)')
  check(/no matches/.test(txt(23)), 'ReDoS: (a+)+$ treated as literal substring -> no match')

  // code-fence
  check(/real body after fence/.test(txt(24)) && /Other Section/.test(txt(24)) === false, 'code-fence: Real Section includes body past the fenced fake heading, stops at Other')

  // ambiguous
  check(/ambiguous/.test(txt(25)), 'ambiguous heading on append ERRORS instead of writing first')

  // batch
  check(byId(90) === undefined && responses.some((r) => r.error && r.error.code === -32600), 'JSON-RPC batch array rejected with -32600 (not silently dropped)')

  console.log(failures === 0 ? `\nPASS: all brain MCP checks incl. security/regression (${responses.length} responses)` : `\nFAILED: ${failures} checks`)
  process.exit(failures ? 1 : 0)
})()
