# Spec · Claude Cowork Blueprint

Data: 2026-05-27 (revisado na mesma data após corrigir a premissa)

## Problema e contexto

A mãe da Ana faz trabalho de escritório (PDFs, planilhas, imagens) e sofre com projetos bagunçados e perda de contexto ("o Claude tá ficando burro"). É a dor que esta blueprint resolve. A variante **Cowork** vira o veículo: o "segundo cérebro" do Code blueprint adaptado pro trabalho de conhecimento.

Resultado: instalação tão turnkey quanto o Code, uso diário mais leve, e o cérebro se regenerando sozinho a cada sessão.

## Premissa corrigida

Uma primeira rodada desenhou o Cowork como app de chat passivo, exigindo MCP filesystem, edição de `claude_desktop_config.json` e upload de ZIP de skill. Isso tornou a variante "simples" mais difícil que o Code. **Premissa errada.** Claude Cowork é **agêntico** (acessa pastas locais, roda shell numa VM, faz o próprio setup) e compartilha mecânica com o Claude Code: lê `CLAUDE.md` por projeto e auto-carrega skills de `.claude/skills/`. Logo o Cowork blueprint é o **Code blueprint com vocabulário de escritório**, não outro sistema.

## Três superfícies, uma pasta

A mesma pasta roda em três superfícies agênticas, escolhidas por sessão:
- **Claude Code CLI** (terminal): motor base. Lê `CLAUDE.md`, `.claude/skills/`, hooks.
- **Claudian** (plugin de Obsidian que embute o Claude Code CLI): mesmo motor, hooks funcionam. Requer Obsidian 1.7.2+, o CLI no PATH e o plugin.
- **Claude Cowork** (modo agêntico do Desktop): embutido, sem instalar. Lê `CLAUDE.md` + skills, sem hooks.

As três rodam shell/código, então geram office de verdade (openpyxl→xlsx, python-pptx→pptx, PIL/matplotlib→imagem) e fazem o setup agenticamente.

## Snapshot surface-aware por env

Versionamento funciona em todas com convenção de `history/` compartilhada:
- **CLI / Claudian** (`CLAUDECODE=1`, `CLAUDE_CODE_ENTRYPOINT=cli`): o hook `.claude/hooks/snapshot.*` dispara sozinho.
- **Cowork** (`CLAUDE_CODE_IS_COWORK` setado): a skill `snapshot` lê o env e, quando no Cowork, congela o "antes" antes de editar um doc vivo.

A skill decide agir lendo a superfície (proxy de "tem hook ou não"), não tentando observar o hook. Mesmo path `history/<nome>/<nome> YYYY-MM-DDTHH-mm-ss.md`, mesmo cooldown (~20 min) e exclusões (`history/`, `memory/`, `roadmap/`, `notes/`), então a mesma pasta entre superfícies nunca duplica. Ponto residual: no Cowork a execução depende do modelo seguir o procedimento (sem garantia dura de hook).

## Diferenças vs Code (só isto muda)

1. **Vocabulário código → escritório:** `code_map/` → `work_map/` (mapa dos entregáveis por tema); "code change" → "mudança em entregável"; `roadmap_log` por arquivo + data, sem hash; `check-map` → `check-work-map`.
2. **Snapshot surface-aware:** mantém o hook; adiciona a skill `snapshot` + procedimento no `CLAUDE.md` que detecta `CLAUDE_CODE_IS_COWORK`.
3. **Setup surface-agnostic:** detecta a superfície via env; instala tudo numa pasta só sem travar; junction de memória só no CLI/Claudian, no Cowork a memória vive como arquivos em `project_brain/memory/`.
4. **Textos:** `CLAUDE.md` e READMEs ganham a seção de superfícies e a nota de snapshot surface-aware. Seção de Obsidian MCP mantida: o vault é a mesma pasta do brain, então o MCP segue útil (sobretudo pro CLI no terminal).

Tudo o mais é igual ao Code: `.claude/skills/` auto-carregadas, `.claude/hooks/` (valem no CLI/Claudian), `project_brain/` como vault Obsidian, setup agêntico por projeto, instalação "dropar + rodar prompt".

## Instalação (por projeto, como o Code)

Cada projeto tem seu próprio brain. Abrir o projeto, dropar a blueprint na pasta dele, rodar o prompt de setup; o agente monta `project_brain`, preenche placeholders, escreve `CLAUDE.md`, semeia visão + estado, localiza PT-BR. Depois está setado. Novo foco = repetir.

## Estrutura de `Claude Cowork Blueprint/`

```
Claude Cowork Blueprint/
├── README.md / README.pt-BR.md
├── CLAUDE.md
├── .claude/
│   ├── settings.json            ← hooks mantidos (valem no CLI/Claudian)
│   ├── setup.ps1 / setup.sh
│   ├── hooks/  snapshot.* remind-map.* run-hook.cmd
│   └── skills/  setup start done end remember map writeplan debloat snapshot
│                check-work-map check-plan fix-links
└── project_brain/
    ├── Vision.md  context.md  next_step.md
    ├── plan/  roadmap/ (log sem hash)  work_map/
    ├── history/  memory/ (MEMORY.md + _TEMPLATE_*)  notes/
```

## Verificação (mesma pasta, várias superfícies)

1. **CLI/Claudian:** rodar setup; `project_brain` montado, `/start` lê o estado, editar um doc vivo dispara o hook (snapshot em `history/`).
2. **Cowork:** abrir a pasta; a skill `snapshot` cobre o "antes" (sem hook).
3. **Interop:** a skill lê `CLAUDE_CODE_IS_COWORK` certo em cada app; editar entre superfícies não duplica `history/` e respeita o cooldown.
4. **Office:** pedir xlsx e pptx; geração via código nas três.
5. **Loop:** `/done` atualiza `roadmap`, `next_step`, `work_map` sem hash.
6. **Multi-projeto:** 2º foco com brain próprio, isolado.
7. **Adaptar existente:** setup numa pasta com docs prévios preserva e dobra.
8. **PT-BR:** localização sem link/skill quebrado.

## Fora de escopo (YAGNI)

- Watcher de SO / git pro snapshot.
- Variante pro Claude "Chat" não-agêntico.
