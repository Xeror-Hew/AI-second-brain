// Localization test for brain.mjs: a vault whose folders/files are renamed (Portuguese) with a
// project_brain/.brain.json manifest. Proves the engine resolves canonical -> localized names:
// brain_orient reads the localized next_step/roadmap and the localized section headings;
// set_next/log_done write to the localized paths; snapshot-exclusion follows the localized roadmap.
import { spawn } from 'node:child_process'
import { fileURLToPath } from 'node:url'
import { dirname, join } from 'node:path'
import { mkdirSync, writeFileSync, rmSync, readFileSync, existsSync, readdirSync } from 'node:fs'

const __dirname = dirname(fileURLToPath(import.meta.url))
const VAULT = join(__dirname, '_test_vault_loc')
const PB = join(VAULT, 'project_brain')

rmSync(VAULT, { recursive: true, force: true })
const mk = (p, c) => { mkdirSync(dirname(p), { recursive: true }); writeFileSync(p, c) }

mk(join(PB, '.brain.json'), JSON.stringify({
  schema: 1, language: 'pt-BR',
  names: { Vision: 'Visao', context: 'contexto', next_step: 'proximo_passo', plan: 'plano', roadmap: 'roteiro', code_map: 'mapa_codigo', notes: 'notas' },
  sections: { BLOCKERS: 'BLOQUEIOS', 'CURRENT FRONT': 'FRENTE ATUAL' },
}))
mk(join(PB, 'proximo_passo.md'), '# 🎯 PROXIMO PASSO\n\nValidar a resolucao localizada do manifesto.\n')
mk(join(PB, 'roteiro', 'roteiro.md'), `# ✅ Roteiro

## 🔴 BLOQUEIOS

- [ ] **bloqueio de exemplo**

## 🟠 FRENTE ATUAL

- [ ] tarefa atual
`)
mk(join(PB, 'roteiro', 'roteiro_log.md'), '# 🧾 Log do roteiro\n\n> Append-only.\n\n- 2026-06-01: primeiro registro (aaa1111)\n')
mk(join(PB, 'plano', 'plano_tech.md'), '# 🤖 Plano (tecnico)\n\n## Arquitetura\n\nModelo de pasta.\n')

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
const sleep = (ms) => new Promise((r) => setTimeout(r, ms))
const byId = (id) => responses.find((r) => r.id === id)
const txt = (id) => byId(id)?.result?.content?.[0]?.text || ''
let failures = 0
const check = (cond, msg) => { if (!cond) { failures++; console.error('FAIL:', msg) } else { console.log('ok:', msg) } }

;(async () => {
  send({ jsonrpc: '2.0', id: 1, method: 'initialize', params: { protocolVersion: '2025-06-18', capabilities: {}, clientInfo: { name: 't', version: '1' } } })
  await sleep(40)
  send({ jsonrpc: '2.0', method: 'notifications/initialized' })
  await sleep(20)
  send({ jsonrpc: '2.0', id: 3, method: 'tools/call', params: { name: 'brain_orient', arguments: {} } })
  send({ jsonrpc: '2.0', id: 4, method: 'tools/call', params: { name: 'brain_set_next', arguments: { text: 'Passo seguinte localizado.' } } })
  send({ jsonrpc: '2.0', id: 5, method: 'tools/call', params: { name: 'brain_log_done', arguments: { text: 'tarefa localizada concluida', hash: 'bbb2222' } } })
  send({ jsonrpc: '2.0', id: 6, method: 'tools/call', params: { name: 'brain_append', arguments: { file: 'plano/plano_tech.md', heading: 'Arquitetura', text: 'Nota de arquitetura.' } } })
  send({ jsonrpc: '2.0', id: 7, method: 'tools/call', params: { name: 'brain_append', arguments: { file: 'roteiro/roteiro.md', heading: 'FRENTE ATUAL', text: '- [ ] outra tarefa' } } })
  await sleep(120)
  srv.stdin.end()
  await sleep(120)

  const o = txt(3)
  check(/Validar a resolucao localizada/.test(o), 'orient reads localized next_step (proximo_passo.md)')
  check(/BLOQUEIOS/.test(o) && /bloqueio de exemplo/.test(o), 'orient resolves localized BLOCKERS section (BLOQUEIOS)')
  check(/FRENTE ATUAL/.test(o) && /tarefa atual/.test(o), 'orient resolves localized CURRENT FRONT section (FRENTE ATUAL)')
  check(/primeiro registro/.test(o), 'orient reads localized roadmap log (roteiro_log.md)')

  check(/next_step\.md set/.test(txt(4)) && /Passo seguinte localizado/.test(readFileSync(join(PB, 'proximo_passo.md'), 'utf8')), 'set_next wrote to localized proximo_passo.md')
  check(!existsSync(join(PB, 'next_step.md')), 'set_next did NOT create a canonical next_step.md')

  check(/tarefa localizada concluida \(bbb2222\)/.test(readFileSync(join(PB, 'roteiro', 'roteiro_log.md'), 'utf8')), 'log_done appended to localized roteiro/roteiro_log.md')

  check(/appended to/.test(txt(6)), 'append to localized plano_tech ok')
  check(existsSync(join(PB, 'history', 'plano_tech')) && readdirSync(join(PB, 'history', 'plano_tech')).some((f) => f.endsWith('.md')), 'snapshot fired for localized plan file (eligible)')

  check(/appended to/.test(txt(7)), 'append to localized roteiro ok')
  check(!existsSync(join(PB, 'history', 'roteiro')), 'snapshot SKIPPED for localized roadmap folder (roteiro excluded via manifest)')

  rmSync(VAULT, { recursive: true, force: true })
  console.log(failures === 0 ? `\nPASS: localization resolution checks (${responses.length} responses)` : `\nFAILED: ${failures} checks`)
  process.exit(failures ? 1 : 0)
})()
