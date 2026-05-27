# Workflow com Obsidian · um segundo cérebro pro Claude

Uma forma de trabalhar com IA que você pluga em qualquer projeto. Copie o conteúdo desta pasta pro projeto alvo, preencha os `{{PLACEHOLDERS}}`, rode o setup, apague o que não usar.

> Este arquivo só descreve o sistema. Depois de copiar pro projeto alvo, pode apagar.
> 🌎 Speak English? See [README.md](README.md).

---

## 🧠 Modelo mental

A ideia central: uma verdade só, servindo tanto a IA quanto o usuário.

Os dois princípios que fazem funcionar:

1. **Índice + descrição** Cada pasta tem um índice que aponta pros arquivos com uma linha de descrição. A IA lê esse índice e então escolhe o arquivo certo pra abrir, em vez de ler um `.md` inteiro de uma vez. Você navega do mesmo jeito.
2. **Rastreie as mudanças** Salva o "antes" de cada edição em `history/`. A IA não lê essa pasta, ela está ali só pra você acompanhar as mudanças.

Pros rituais repetitivos (atualizar o roadmap, fechar a sessão, salvar uma memória) existem **skills**: comandos curtos que você digita (`/end`, por exemplo) e que a IA também dispara sozinha quando o momento pede.

---

## 📂 O que tem aqui

```
_BLUEPRINT_WORKFLOW/
├── README.md                       ← this file (delete it when you plug into a project)
├── README.pt-BR.md                 ← Portuguese version of this file
├── CLAUDE.md                       ← the project's work rules + the AI's starting index
├── .claude/
│   ├── settings.json               ← registers the hooks + declares the superpowers plugin
│   ├── setup.ps1 / setup.sh        ← wire memory into the repo + the .gitignore block (Windows / Mac-Linux)
│   ├── hooks/
│   │   ├── run-hook.cmd            ← cross-OS dispatcher (.ps1 on Windows, .sh on Mac/Linux)
│   │   ├── snapshot.ps1 / .sh      ← freeze the "before" into history/
│   │   └── remind-map.ps1 / .sh    ← after a code edit, nudge to update the map
│   └── skills/                     ← the workflow commands (see §5)
│       ├── start/ done/ end/ remember/ map/ writeplan/ debloat/ setup/   (you trigger)
│       └── check-map/ check-plan/ fix-links/                              (automatic)
└── project_brain/                  ← the shared brain (you + the AI)
    ├── Vision.md                   ← YOUR vision (you write, the AI reads)
    ├── context.md                  ← stack, principles, project rules (indexed by CLAUDE.md)
    ├── plan/                       ← the AI's technical plan
    │   ├── plan_index.md           ← hub (navigation only)
    │   ├── plan_summary.md         ← overview + pointers (reading entry)
    │   ├── plan_why.md             ← the what/why (critical read, open questions)
    │   └── plan_tech.md            ← the how (architecture, decisions, metrics)
    ├── roadmap/
    │   ├── roadmap_index.md        ← how the roadmap works
    │   ├── roadmap.md              ← ACTIVE checklist (only what's left)
    │   └── roadmap_log.md          ← append-only log
    ├── next_step.md                ← one active item (overwritten each time)
    ├── code_map/
    │   └── map_index.md            ← code map index (method lives in /map)
    ├── history/                    ← automatic snapshots (the AI never reads it)
    ├── ideas/                      ← your ideas (the AI reads only when you ask)
    └── memory/                     ← auto-memory (linked into Claude Code, see §7)
        ├── MEMORY.md               ← memory index
        └── _TEMPLATE_*.md          ← user / feedback / project / reference
```

---

## 🚀 1. Setup

> ⚡ **Automático:** jogue a pasta `Claude Code Blueprint/` inteira no projeto e cole:
> > *"Read `Claude Code Blueprint/.claude/skills/setup/SKILL.md` and set this up in this project, reconciling with whatever is already here and preserving my content."*
>
> A IA detecta o cenário (**limpo** / **outro workflow**), move os arquivos pra raiz, migra preservando seu conteúdo, roda o setup, pergunta qual idioma você quer e apaga a pasta da blueprint no fim. Depois reabra a sessão pros comandos (`/start`, `/end`...) carregarem.

Prefere na mão? Nesta ordem:

**1. Copie** `CLAUDE.md`, `.claude/` e `project_brain/` pra raiz do projeto alvo. (O conteúdo, não a pasta `Claude Code Blueprint/` em si. `.claude/` e `CLAUDE.md` precisam ficar na raiz, senão o Claude Code não acha.)

**2. Preencha os `{{PLACEHOLDERS}}`** em `CLAUDE.md` e `project_brain/context.md`.

**3. Rode o setup** (conecta a memória ao repo + o bloco do `.gitignore`):
   - Windows: `powershell -NoProfile -ExecutionPolicy Bypass -File .claude\setup.ps1`
   - Mac/Linux: `bash .claude/setup.sh`

**4. (Recomendado) Conecte o Obsidian via MCP** (§9). Dá olhos à IA dentro do vault.

**5. Escreva sua visão** em `project_brain/Vision.md`. O quê e o porquê, sem precisar ser técnico.

**6. Peça à IA** (ou use as skills) que gere, a partir da sua visão e de uma leitura do código: o plano técnico (`/writeplan`), o mapa do código (`/map`) e então o `roadmap`.

**7. Defina o `next_step.md`** com uma ação concreta.

**8. Confira o hook**: edite qualquer doc vivo e veja um snapshot aparecer em `project_brain/history/`.

> ⚠️ **Já tem um `CLAUDE.md` ou um workflow antigo na raiz?** Não copie por cima. Use o jeito automático acima: a pasta jogada no projeto é a área de staging, e o `/setup` mescla seu `CLAUDE.md` (mantendo placeholders e regras), migra um `desenvolvimento/` antigo pra `project_brain/`, roda o setup e faz a limpeza. Procedimento completo: `.claude/skills/setup/SKILL.md`.

> ⚠️ **Projeto existente com um `.gitignore`:** o setup acrescenta o bloco do Claude, não sobrescreve. Se seu time versiona um `CLAUDE.md`, decida se vai escondê-lo (o bloco padrão ignora `CLAUDE.md`; edite o bloco no script de setup pra mantê-lo versionado).

> 🦸 **plugin superpowers (vem declarado):** o `.claude/settings.json` já declara `superpowers@claude-plugins-official`. Quando você confiar na pasta do projeto, o Claude Code pede pra instalar o marketplace + plugin. Instalado, ele carrega a skill `using-superpowers` no início de toda sessão. Sem prompt? Rode `claude plugin install superpowers@claude-plugins-official`.

---

## 🌎 2. Idioma

A blueprint vem em **inglês**. No setup, o `/setup` pergunta qual idioma você quer e **localiza a instalação**: traduz o que você lê e edita (os docs de `project_brain/`, o `CLAUDE.md`, os gatilhos das skills) e deixa a estrutura em inglês (nomes de pasta, caminhos, código). Então sua mãe roda tudo em português, um alemão em alemão, tudo a partir de uma fonte só.

---

## 🔖 3. Placeholders

| Placeholder | O que é |
|-------------|---------|
| `{{PROJECT_NAME}}` | nome curto do projeto |
| `{{PROJECT_DESCRIPTION}}` | uma linha sobre o que o projeto faz |
| `{{USER}}` | como a IA te chama |
| `{{PRINCIPLES}}` | prioridades quando as coisas conflitam |
| `{{STACK}}` | linguagem/runtime/ambiente |
| `{{SPECIFIC_RULES}}` | regras exclusivas deste projeto |

> `STACK`, `PRINCIPLES` e `SPECIFIC_RULES` ficam em `project_brain/context.md`; o resto em `CLAUDE.md`.

---

## 🗂️ 4. Os arquivos vivos

| Arquivo | Quem escreve | Pra quê |
|---------|--------------|---------|
| `Vision.md` | Você | Sua visão: o quê e o porquê. A IA lê e deriva o plano. |
| `context.md` | Você | Stack, princípios, regras específicas do projeto. |
| `plan/plan_summary.md` | IA | Entrada do plano técnico: visão geral curta + pointers. |
| `plan/plan_why.md` | IA | Leitura crítica da sua visão, riscos, questões em aberto. |
| `plan/plan_tech.md` | IA | Arquitetura por fase, decisões técnicas, métricas. |
| `roadmap/roadmap.md` | IA | Checklist ativo, só o que falta. |
| `roadmap/roadmap_log.md` | IA | Log append-only. A IA só escreve aqui. |
| `next_step.md` | IA | Um item ativo. Concluído, é sobrescrito pelo próximo. |
| `code_map/map_index.md` | IA | Estado do código: visão de topo + pointers pros fragmentos. |
| `memory/` | IA (auto) | Memória persistente entre sessões (§7). |
| `ideas/` | Você | Seu espaço de rascunho. A IA lê só quando você pede. |
| `history/` | Hook (auto) | Versões congeladas. A IA nunca lê. |

---

## 🛠️ 5. Skills / comandos

Uma skill funciona de dois jeitos ao mesmo tempo: você digita `/nome`, e a IA dispara sozinha quando o contexto casa com o `when_to_use` dela. As skills carregam o procedimento; as regras do `CLAUDE.md` são a base curta.

**Rituais (você dispara, ou a IA quando reconhece o momento):**

| Comando | O que faz |
|---------|-----------|
| `/setup` | Onboarding: instala/migra a blueprint num projeto. Use ao plugar a pasta. |
| `/start` | Orientação read-only: onde paramos + o próximo passo. |
| `/done` | Terminou uma tarefa: registra no log, poda o roadmap, define o próximo passo. |
| `/end` | Fim de sessão: atualiza o mapa, log, roadmap, next_step, varre links mortos. |
| `/remember` | Salva uma memória no formato certo + indexa. |
| `/map` | (Re)constrói o mapa do código. |
| `/writeplan` | Deriva ou atualiza `plan/` a partir do seu `Vision.md`. |
| `/debloat` | Enxuga `project_brain/`: corta redundância, poda o obsoleto, fragmenta arquivos grandes, conserta links. |

**Automáticas (a IA dispara, você não chama):**

| Skill | Quando a IA puxa |
|-------|------------------|
| `check-map` | prestes a mexer em código que não conhece; lê o mapa antes |
| `check-plan` | prestes a mudar arquitetura ou uma decisão fechada; checa o plano antes |
| `fix-links` | acabou de criar/renomear/remover um doc; conserta o índice + links |

---

## 💾 6. Snapshot (versionamento automático)

Antes de um doc vivo ser editado, um hook congela o "antes" em `history/`:

```
project_brain/history/<file>/<file> YYYY-MM-DDTHH-mm-ss.md
```

A IA nunca lê `history/`. É sua rede de segurança pra recuperar uma versão antiga.

- Um snapshot por arquivo a cada ~20 min (ajuste no script).
- Cada arquivo ganha uma subpasta, então `history/plan_tech/` é a linha do tempo completa dele.
- Cobre `.md` em `project_brain/`. As pastas `roadmap/` e `memory/` ficam de fora.

> O hook roda via `run-hook.cmd`, que escolhe o `.ps1` no Windows e o `.sh` no Mac/Linux. Nada pra instalar em nenhum dos dois.

---

## 🧩 7. Memória

A IA mantém memória persistente como arquivos `.md` com frontmatter. Quatro tipos: **user** (quem você é, como colaborar), **feedback** (correções e abordagens confirmadas), **project** (decisões, prazos, contexto que não está no código), **reference** (pointers pra sistemas externos).

Uma memória é um arquivo mais uma linha no `MEMORY.md` (o índice). Salve com `/remember`.

> Não salve o que o código já guarda (padrões, estrutura, histórico do git). A memória é pro que não está no código.

### 🔗 Memória dentro do vault

Por padrão o Claude Code mantém a memória fora do repo. O setup a conecta em `project_brain/memory/` com uma junction (Windows) ou symlink (Mac/Linux), sem precisar de admin. Mesmos arquivos, um lugar só: edite uma memória no Obsidian e é a real. (`memory/` fica fora do snapshot, então uma exclusão ali não tem backup em `history/`.)

Dentro de `memory/` o formato é o do harness: `MEMORY.md` usa `[Title](file.md)`, cross-links usam o basename `[[slug]]`. Se o repo se mover ou for clonado, rode o setup de novo pra reapontar o link.

---

## 🔒 8. Git

O setup acrescenta este bloco ao `.gitignore` (criando-o se necessário, sem sobrescrever):

```
# === Claude workflow (do not version) ===
.claude/
CLAUDE.md
project_brain/
```

Assim você dá push e nada do workflow do Claude aparece no repo. Quer versionar `memory/` (ou `CLAUDE.md`) mesmo assim? Edite o bloco no script de setup antes de rodar.

---

## 🔌 9. MCP do Obsidian (recomendado)

O MCP dá à IA acesso direto ao seu vault aberto, então ela vê e edita notas pelo app, não só pelo filesystem.

1. No Obsidian: **Settings → Community plugins** e instale o plugin de integração com o Claude Code (repo de referência: `iansinnott/obsidian-claude-code-mcp`). Habilite. (O nome exato nos community plugins pode variar; confira o autor/descrição.)
2. Mantenha o **Obsidian aberto** com o vault deste projeto (o MCP serve por WebSocket, porta padrão `22360`).
3. No Claude Code, dentro do projeto, rode `/ide` e escolha o Obsidian.

Precisa do Obsidian rodando. App fechado, a IA cai de volta pro filesystem (que funciona bem; o MCP é um bônus). Um vault por blueprint.

---

## 🗺️ 10. No dia a dia

Ao começar uma sessão (ou `/start`), a IA segue a cola do `CLAUDE.md`: lê `CLAUDE.md`, depois `next_step.md`, e puxa `plan_tech`, `map_index`, `Vision` ou `MEMORY` conforme a necessidade.

Ao longo do trabalho, a verdade fica alinhada, principalmente via skills:
- Terminou uma tarefa → `/done`.
- Prestes a mudar arquitetura → `check-plan` dispara; se o plano mudou, atualize o roadmap.
- Criou/renomeou/removeu um doc → `fix-links` conserta os índices.
- Fechando → `/end` roda o ritual inteiro.

Você só escreve em `Vision.md` e `ideas/` quando der vontade. A IA mantém o resto.
