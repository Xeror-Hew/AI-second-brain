# Workflow com Obsidian · um segundo cérebro pro Claude (trabalho de escritório)

Uma forma de trabalhar com IA que você pluga em qualquer projeto. Copie o conteúdo desta pasta pro projeto alvo, preencha os `{{PLACEHOLDERS}}`, rode o setup, apague o que não usar. Feito pra **trabalho de escritório e de conhecimento** (relatórios, planilhas, apresentações, imagens), o irmão mais leve da blueprint Code.

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

## 🖥️ Superfícies

A mesma pasta roda em três superfícies agênticas do Claude. Você escolhe por sessão, sem reconfigurar nada:

- **Claude Code CLI** (terminal): o motor base. Lê `CLAUDE.md`, `.claude/skills/`, hooks.
- **Claudian** (o plugin de Obsidian `YishenTu/claudian`): o CLI numa sidebar bonita, com o vault como pasta de trabalho. Mesmo motor, então os hooks também funcionam. Instala uma vez: Obsidian 1.7.2+, o Claude Code CLI no PATH, o plugin.
- **Claude Cowork** (o modo agêntico do app Desktop): embutido, nada pra instalar. Lê `CLAUDE.md` e skills, não tem hooks.

As três rodam shell e código, então produzem entregáveis de verdade (xlsx, pptx, imagens) e fazem o próprio setup. A única diferença é como o versionamento dispara: um hook no CLI/Claudian, a skill `snapshot` no Cowork (veja §6).

---

## 📂 O que tem aqui

```
_BLUEPRINT_WORKFLOW/
├── README.md                       ← this file (delete it when you plug into a project)
├── README.pt-BR.md                 ← Portuguese version of this file
├── CLAUDE.md                       ← the project's work rules + the AI's starting index
├── .claude/
│   ├── settings.json               ← registers the hooks + declares the superpowers plugin
│   ├── setup.ps1 / setup.sh        ← wire memory into the repo + the .gitignore block (CLI/Claudian)
│   ├── hooks/
│   │   ├── run-hook.cmd            ← cross-OS dispatcher (.ps1 on Windows, .sh on Mac/Linux)
│   │   ├── snapshot.ps1 / .sh      ← freeze the "before" into history/ (CLI/Claudian)
│   │   └── remind-map.ps1 / .sh    ← after a deliverable edit, nudge to update the map
│   └── skills/                     ← the workflow commands (see §5)
│       ├── start/ done/ end/ remember/ map/ writeplan/ debloat/ setup/   (you trigger)
│       └── snapshot/ check-work-map/ check-plan/ fix-links/              (automatic)
└── project_brain/                  ← the shared brain (you + the AI)
    ├── Vision.md                   ← YOUR vision (you write, the AI reads)
    ├── context.md                  ← tools, principles, project rules (indexed by CLAUDE.md)
    ├── plan/                       ← the AI's plan
    │   ├── plan_index.md           ← hub (navigation only)
    │   ├── plan_summary.md         ← overview + pointers (reading entry)
    │   ├── plan_why.md             ← the what/why (critical read, open questions)
    │   └── plan_tech.md            ← the how (approach, decisions, metrics)
    ├── roadmap/
    │   ├── roadmap_index.md        ← how the roadmap works
    │   ├── roadmap.md              ← ACTIVE checklist (only what's left)
    │   └── roadmap_log.md          ← append-only log
    ├── next_step.md                ← one active item (overwritten each time)
    ├── work_map/
    │   └── map_index.md            ← work map index: deliverables and where they live (method lives in /map)
    ├── history/                    ← automatic snapshots (the AI never reads it)
    ├── notes/                      ← your notes/scratch space (the AI reads only when you ask)
    └── memory/                     ← auto-memory (see §7)
        ├── MEMORY.md               ← memory index
        └── _TEMPLATE_*.md          ← user / feedback / project / reference
```

---

## 🚀 1. Setup

> ⚡ **Automático:** jogue a pasta `Claude Cowork Blueprint/` inteira no projeto e cole:
> > *"Read `Claude Cowork Blueprint/.claude/skills/setup/SKILL.md` and set this up in this project, reconciling with whatever is already here and preserving my content."*
>
> A IA instala do zero (ou atualiza no lugar, se já tiver uma versão lá), detecta a superfície, move os arquivos pra raiz, roda o setup, pergunta qual idioma você quer e apaga a pasta da blueprint no fim. O que já estava no seu projeto fica onde está. Depois reabra a sessão pros comandos (`/start`, `/end`...) carregarem.

Prefere na mão? Nesta ordem:

**1. Copie** `CLAUDE.md`, `.claude/` e `project_brain/` pra raiz do projeto alvo. (O conteúdo, não a pasta `Claude Cowork Blueprint/` em si.)

**2. Preencha os `{{PLACEHOLDERS}}`** em `CLAUDE.md` e `project_brain/context.md`.

**3. No Claude Code CLI / Claudian, rode o setup** (conecta a memória ao repo + o bloco do `.gitignore`):
   - Windows: `powershell -NoProfile -ExecutionPolicy Bypass -File .claude\setup.ps1`
   - Mac/Linux: `bash .claude/setup.sh`

   No **Claude Cowork**: pule a junction de memória (a memória vive como arquivos em `project_brain/memory/`); ainda adicione o bloco do `.gitignore`.

**4. (Opcional) Conecte o Obsidian via MCP** (§9). Mais útil pro CLI no terminal; Claudian e Cowork já leem a pasta nativamente.

**5. Escreva sua visão** em `project_brain/Vision.md`. O quê e o porquê, sem precisar ser técnico.

**6. Peça à IA** (ou use as skills) que gere, a partir da sua visão e de uma leitura do trabalho: o plano (`/writeplan`), o mapa do trabalho (`/map`) e então o `roadmap`.

**7. Defina o `next_step.md`** com uma ação concreta.

**8. Confira o versionamento**: edite qualquer doc vivo e veja um snapshot aparecer em `project_brain/history/`. No CLI/Claudian o hook faz; no Cowork a skill `snapshot` faz.

> ⚠️ **Já tem suas próprias notas ou uma pasta de workflow antiga?** Ela fica onde está, o setup não encosta. Depois de instalar, é só pedir pro Claude ler e incorporar as partes úteis na estrutura (visão, plano, roadmap, memória). Ele adapta o conteúdo com seu OK, sem mapeamento rígido. Procedimento completo: `.claude/skills/setup/SKILL.md`.

> ⚠️ **Projeto existente com um `.gitignore`:** o setup acrescenta o bloco do Claude, não sobrescreve.

> 🦸 **plugin superpowers (vem declarado):** o `.claude/settings.json` já declara `superpowers@claude-plugins-official`. No Claude Code CLI / Claudian, confiar na pasta do projeto oferece a instalação em um clique. No Cowork, instale pelo marketplace de plugins em Customize. Sem prompt? Rode `claude plugin install superpowers@claude-plugins-official`.

---

## 🌎 2. Idioma

A blueprint vem em **inglês**. No setup, o `/setup` pergunta qual idioma você quer e **localiza a instalação**: traduz a prosa que você lê e edita (os docs de `project_brain/`, o `CLAUDE.md`, os gatilhos das skills) e também os nomes de pasta, arquivo e comando, reescrevendo cada referência pra links e hooks continuarem funcionando. Um punhado de nomes que o Claude Code e o motor exigem fica em inglês (`.claude/`, os scripts de hook, o `settings.json`, a pasta `memory/`, a variável de ambiente `CLAUDE_CODE_IS_COWORK`). Então sua mãe roda tudo em português, um alemão em alemão, tudo a partir de uma fonte só.

---

## 🔖 3. Placeholders

| Placeholder | O que é |
|-------------|---------|
| `{{PROJECT_NAME}}` | nome curto do projeto |
| `{{PROJECT_DESCRIPTION}}` | uma linha sobre o que o projeto faz |
| `{{USER}}` | como a IA te chama |
| `{{PRINCIPLES}}` | prioridades quando as coisas conflitam |
| `{{STACK}}` | ferramentas/ambiente |
| `{{SPECIFIC_RULES}}` | regras exclusivas deste projeto |

> `STACK`, `PRINCIPLES` e `SPECIFIC_RULES` ficam em `project_brain/context.md`; o resto em `CLAUDE.md`.

---

## 🗂️ 4. Os arquivos vivos

| Arquivo | Quem escreve | Pra quê |
|---------|--------------|---------|
| `Vision.md` | Você | Sua visão: o quê e o porquê. A IA lê e deriva o plano. |
| `context.md` | Você | Ferramentas, princípios, regras específicas do projeto. |
| `plan/plan_summary.md` | IA | Entrada do plano: visão geral curta + pointers. |
| `plan/plan_why.md` | IA | Leitura crítica da sua visão, riscos, questões em aberto. |
| `plan/plan_tech.md` | IA | Abordagem por fase, decisões, métricas. |
| `roadmap/roadmap.md` | IA | Checklist ativo, só o que falta. |
| `roadmap/roadmap_log.md` | IA | Log append-only. A IA só escreve aqui. |
| `next_step.md` | IA | Um item ativo. Concluído, é sobrescrito pelo próximo. |
| `work_map/map_index.md` | IA | Estado do trabalho: visão de topo + pointers pros fragmentos. |
| `memory/` | IA (auto) | Memória persistente entre sessões (§7). |
| `notes/` | Você | Seu espaço de notas/rascunho. A IA lê só quando você pede. |
| `history/` | Hook ou skill `snapshot` (auto) | Versões congeladas. A IA nunca lê. |

---

## 🛠️ 5. Skills / comandos

Uma skill funciona de dois jeitos ao mesmo tempo: você digita `/nome`, e a IA dispara sozinha quando o contexto casa com o `when_to_use` dela. As skills carregam o procedimento; as regras do `CLAUDE.md` são a base curta.

**Rituais (você dispara, ou a IA quando reconhece o momento):**

| Comando | O que faz |
|---------|-----------|
| `/setup` | Onboarding: instala/migra a blueprint num projeto. Use ao plugar a pasta. |
| `/start` | Orientação read-only: onde paramos + o próximo passo. |
| `/done` | Fecha uma tarefa terminada na hora: registra no log, poda o roadmap, atualiza o mapa se a estrutura mudou, define o próximo passo. |
| `/end` | Varredura de rede de segurança no fim da sessão: mapa, log, roadmap, next_step, links mortos. |
| `/remember` | Salva uma memória no formato certo + indexa. |
| `/map` | (Re)constrói o mapa do trabalho. |
| `/writeplan` | Deriva ou atualiza `plan/` a partir do seu `Vision.md`. |
| `/debloat` | Enxuga `project_brain/`: corta redundância, poda o obsoleto, fragmenta arquivos grandes, conserta links. |

**Automáticas (a IA dispara, você não chama):**

| Skill | Quando a IA puxa |
|-------|------------------|
| `snapshot` | no Claude Cowork, antes de editar um doc vivo; congela o "antes" (no CLI/Claudian o hook faz) |
| `check-work-map` | prestes a mexer numa parte do trabalho que não conhece; lê o mapa antes |
| `check-plan` | prestes a mudar de direção ou uma decisão fechada; checa o plano antes |
| `fix-links` | acabou de criar/renomear/remover um doc; conserta o índice + links |

---

## 💾 6. Snapshot (versionamento automático)

Antes de um doc vivo ser editado, o "antes" dele é congelado em `history/`:

```
project_brain/history/<file>/<file> YYYY-MM-DDTHH-mm-ss.md
```

A IA nunca lê `history/`. É sua rede de segurança pra recuperar uma versão antiga. Dois caminhos, mesmo resultado:

- **Claude Code CLI / Claudian** (com hooks): o hook `.claude/hooks/snapshot.*` faz sozinho, via `run-hook.cmd` (o `.ps1` no Windows, o `.sh` no Mac/Linux).
- **Claude Cowork** (sem hooks): a skill `snapshot` faz. Ela lê `CLAUDE_CODE_IS_COWORK` e, quando setado, congela o "antes" antes de editar um doc vivo.

Os dois compartilham o mesmo caminho, o mesmo cooldown de ~20 min e as mesmas exclusões (`roadmap/`, `memory/`, `notes/` ficam de fora), então a mesma pasta funciona entre superfícies e nunca duplica o snapshot. Um snapshot por arquivo a cada ~20 min; cada arquivo ganha uma subpasta, então `history/plan_tech/` é a linha do tempo completa dele.

---

## 🧩 7. Memória

A IA mantém memória persistente como arquivos `.md` com frontmatter. Quatro tipos: **user** (quem você é, como colaborar), **feedback** (correções e abordagens confirmadas), **project** (decisões, prazos, contexto que não está no trabalho), **reference** (pointers pra sistemas externos).

Uma memória é um arquivo mais uma linha no `MEMORY.md` (o índice). Salve com `/remember`.

> Não salve o que os arquivos já guardam (layout, estrutura, histórico de arquivo). A memória é pro que não está no trabalho.

### 🔗 Memória dentro do vault

No **Claude Code CLI / Claudian**, o Claude Code mantém a memória fora do repo por padrão; o setup a conecta em `project_brain/memory/` com uma junction (Windows) ou symlink (Mac/Linux), sem precisar de admin. No **Claude Cowork**, a memória vive direto como arquivos em `project_brain/memory/` que a IA lê a cada sessão. De um jeito ou de outro é um lugar só: edite uma memória no Obsidian e é a real. Como `project_brain/` está no gitignore, ela fica só local e fora do snapshot.

Dentro de `memory/` o formato é o da auto-memória: `MEMORY.md` usa `[Title](file.md)`, cross-links usam o basename completo do arquivo `[[type_slug]]` (ex.: `[[feedback_estilo]]`), que é o que o Obsidian resolve. Se o repo se mover ou for clonado, rode o setup de novo pra reapontar o link (CLI/Claudian).

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

## 🔌 9. MCP do Obsidian (opcional)

O vault é a mesma pasta do cérebro, então Claudian e Cowork já leem e editam nativamente. O MCP do Obsidian é mais útil pro **Claude Code CLI** puro (terminal), pra dar olhos a ele dentro do vault aberto por cima do filesystem.

Duas coisas diferentes levam o nome "Obsidian + Claude". Separe as duas:

- **Um servidor MCP que expõe o vault** (esta seção): um plugin roda um servidor MCP dentro do Obsidian, e o Claude Code se conecta a ele.
- **Claudian** (`YishenTu/claudian`): o plugin que embute o Claude Code CLI como sidebar. É uma das três superfícies (§Superfícies), não um MCP.

Pra expor o vault por MCP:

1. No Obsidian: **Settings → Community plugins**, instale o **Obsidian MCP** (`aaronsb/obsidian-mcp-plugin`, listado como "Semantic Notes Vault MCP"). Habilite.
2. Abra a aba de settings dele, gere uma **API key**, e anote a porta (padrão `3001`).
3. Mantenha o **Obsidian aberto no vault deste projeto**. O servidor roda de dentro do app, então Obsidian fechado significa MCP simplesmente ausente (a IA cai de volta pro filesystem, que funciona bem).
4. No Claude Code, da raiz do projeto, registre uma vez:
   ```
   claude mcp add --transport http obsidian http://localhost:3001/mcp --header "Authorization: Bearer <sua-api-key>"
   ```

Persiste entre sessões: registra uma vez e daí em diante conecta sempre que o Obsidian estiver aberto no vault. Um vault por blueprint.

---

## 🗺️ 10. No dia a dia

Ao começar uma sessão (ou `/start`), a IA segue a cola do `CLAUDE.md`: lê `CLAUDE.md`, depois `next_step.md`, e puxa `plan_tech`, `map_index`, `Vision` ou `MEMORY` conforme a necessidade.

A regra de bolso: atualize ao concluir, com o contexto quente. Fechar cada tarefa na hora mantém os docs verdadeiros enquanto a IA ainda segura o contexto; o `/end` é o backstop. Ao longo do trabalho, a verdade fica alinhada, principalmente via skills:
- Terminou uma tarefa → `/done`, na hora (registra no log, poda o roadmap, atualiza o mapa se a estrutura mudou, define o próximo passo).
- Prestes a mudar de direção → `check-plan` dispara; se o plano mudou, atualize o roadmap.
- Criou/renomeou/removeu um doc → `fix-links` conserta os índices.
- Fechando → `/end`, a varredura de rede de segurança que pega o que um fechamento de tarefa deixou passar.

Você só escreve em `Vision.md` e `notes/` quando der vontade. A IA mantém o resto.
