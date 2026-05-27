# Spec · Claude Cowork Blueprint (Desktop + MCP)

Data: 2026-05-27

## Problema e contexto

A mãe da Ana usa o **Claude Desktop** pra trabalho de escritório (PDFs, planilhas, imagens) e sofre com projetos bagunçados e perda de contexto ("o Claude tá ficando burro"). É exatamente a dor que esta blueprint resolve. A variante **Cowork** (planejada, nunca criada) vira o veículo: um "segundo cérebro" adaptado do Code blueprint, dirigido pelo Claude Desktop via MCP filesystem.

Resultado pretendido: a Ana instala uma vez por projeto; depois roda sozinho. A mãe só conversa como sempre, e por trás o cérebro se regenera a cada sessão, mantendo o contexto vivo entre conversas.

## Fatos do Desktop (verificados, mai/2026)

- **MCP filesystem auto-sobe** com o Desktop; instalável como Desktop Extension (`.mcpb`, duplo-clique) ou via `claude_desktop_config.json`. Aceita múltiplos diretórios permitidos.
- **Skills autorais** rodam no Desktop (Customize > Skills, upload de ZIP); também lê "project skills" de pasta.
- **Não há hooks** no Desktop. O snapshot automático do Code não existe aqui.
- Caveat: em conta Team, `remoteToolsDeviceName` no config pode sobrescrever silenciosamente o MCP local.

## Abordagem escolhida (B)

Espelhar o Code o máximo possível, trocando o substrato de CLI por **MCP filesystem + Project do Desktop + Skills autorais**. Setup uma vez por projeto, feito pela Ana; uso contínuo pela mãe sem fricção técnica.

## Arquitetura

Quatro peças por projeto:

1. **Pasta-cérebro** (o `project_brain/` do Code) num diretório local. Markdown puro; Obsidian opcional (só pra Ana inspecionar).
2. **MCP filesystem** apontando pra pasta-cérebro. Sobe junto com o Desktop. Dá ao Claude olhos e mãos no cérebro: ler e escrever os docs.
3. **Project do Desktop** com as instruções coladas. É o papel do `CLAUDE.md`: regras, navegação e procedimentos dos rituais. Aplica em todo chat; é o piso que funciona mesmo sem skill.
4. **Skills autorais** subidas no Desktop: os comandos do Code adaptados. Camada de reforço por cima das instruções.

## O loop de regeneração (o coração)

Todo chat novo, o Claude, guiado pelas instruções do Project, lê via MCP `next_step` + `roadmap` + `plan` + `memory`, faz o trabalho, e ao fechar atualiza esses docs. Como o cérebro vive fora da janela de conversa, abrir um chat zerado reidrata o contexto. É isso que mata o "Claude ficou burro".

## Modelo multi-projeto e install repetível

A mãe tem vários focos, um Project por foco, e cria novos como no Code (cria/tem o projeto, instala a blueprint, volta a usar). Cada foco = um Desktop Project + uma pasta-cérebro própria. As **instruções de cada Project carregam o caminho** da sua pasta-cérebro, que é como o Claude desambigua qual cérebro é o daquele Project.

Isolamento no MCP (dois caminhos documentados no setup, **decisão na execução** com a Ana):
- **Raiz-mãe única:** o MCP aponta pra uma pasta-mãe (ex.: `Claude/`); cada foco é subpasta. Criar projeto novo = nova subpasta + novo Project, sem editar JSON. Custo: o Claude tecnicamente enxerga as pastas irmãs; as instruções o escopam pro foco certo.
- **Um MCP por projeto:** cada foco tem entrada/`.mcpb` próprio, isolado de verdade. Custo: editar config (ou gerar `.mcpb`) a cada projeto novo.

## Setup: fresh, adaptar existente e upgrade

Espelha o `setup` do Code (§2 fresh / §3 upgrade / dobrar conteúdo existente), reescrito pro Desktop:

- **Fresh:** criar a pasta-cérebro, registrar/garantir o MCP, criar o Project e colar as instruções com o caminho preenchido, subir as skills, semear visão + estado iniciais, localizar PT-BR.
- **Adaptar projeto existente:** se o Project já tem conhecimento, instruções ou arquivos, **preservar e dobrar** o útil na estrutura do cérebro (visão, plano, roadmap, memória), com julgamento e confirmação, sem apagar conteúdo da usuária. Mirror do passo "existing notes" do Code.
- **Upgrade:** versão mais nova da blueprint sobre uma instalação existente — atualiza skills + instruções, preserva o `project_brain/` e a memória, re-localiza se a instalação estava em PT-BR.

## Mapeamento Code → Cowork

### Substrato
- **Hooks → some** (`.claude/hooks/` sai: snapshot, remind-map, run-hook).
- **`settings.json` → some.** Substituído por entrada de MCP filesystem + skills subidas.
- **`setup.ps1/.sh` → guia de setup do Desktop** (`setup/desktop-setup.md`), cobrindo fresh/adaptar/upgrade, multi-projeto, localização e o caveat `remoteToolsDeviceName`.
- **`CLAUDE.md` → `project_instructions.md`** (texto pra colar no Project; arquivo é a fonte canônica).

### Snapshot/histórico (decisão: skill, opção i)
- **`snapshot.ps1` → skill `snapshot`.** Antes de editar um doc vivo, o Claude copia o "antes" pra `history/<nome>/<nome> YYYY-MM-DDTHH-mm-ss.md`. Mesma lógica de cooldown (~20 min) e exclusões (`history/`, `memory/`, `roadmap/`, `notes/`), agora dirigida pelo Claude via MCP. Custo aceito: depende do Claude seguir o procedimento.

### Vocabulário (código → escritório)
- **`code_map/` → `work_map/`**: mapa dos entregáveis dela (onde estão PDFs/planilhas, por tema), não módulos. `map_index.md` lista artefatos/temas.
- **`roadmap_log`**: sem hash de commit; referencia arquivo + data.
- Regras que falam "code change" → "mudança em entregável/documento"; `check-map` → `check-work-map`.

### Skills (vocabulário + repackage como skill de Desktop)
Cada skill vira pasta `SKILL.md` zipável:
- Mantêm papel, ajustam vocabulário: `start`, `done`, `end`, `remember`, `map`, `writeplan`, `debloat`, `fix-links`, `check-plan`, `check-map`→`check-work-map`, `setup`.
- **Nova:** `snapshot` (substitui o hook).
- `remind-map` (era hook) → dobrado em `done`/`map`.

### Memória
- Sem junção de harness no Desktop. Memória = arquivos em `project_brain/memory/` lidos via MCP a cada sessão (formato `_TEMPLATE_*.md` preservado). A fonte da verdade é a pasta.

## Estrutura de `Claude Cowork Blueprint/`

```
Claude Cowork Blueprint/
├── README.md / README.pt-BR.md      ← docs de install, sabor Desktop
├── project_instructions.md          ← papel do CLAUDE.md (texto p/ colar no Project)
├── setup/
│   ├── desktop-setup.md             ← guia (MCP, Project, skills, seed, multi-projeto, PT-BR)
│   └── filesystem-mcp.json          ← snippet do claude_desktop_config / ponteiro p/ .mcpb
├── skills/
│   ├── setup/ start/ done/ end/ remember/ map/ writeplan/ debloat/ snapshot/
│   └── check-work-map/ check-plan/ fix-links/
└── project_brain/
    ├── Vision.md  context.md  next_step.md
    ├── plan/ (index, summary, why, tech)
    ├── roadmap/ (index, roadmap, log sem hash)
    ├── work_map/ (map_index + fragmentos)
    ├── history/  memory/ (MEMORY.md + _TEMPLATE_*)  notes/
```

## Reuso (não reescrever do zero)
Quase tudo sai do `Claude Code Blueprint/` por cópia + edição cirúrgica:
- `project_brain/` inteiro (só `code_map/`→`work_map/` e ajustes de texto).
- Skills: copiar os `SKILL.md`, trocar vocabulário e tokens de comando; reescrever `setup` pro Desktop.
- `CLAUDE.md` → base do `project_instructions.md`.
- `snapshot.ps1` → fonte da lógica da skill `snapshot`.
- README → reescrever seções de hook/CLI pra MCP/Project/Skills.

## Verificação (end-to-end)
1. **MCP:** instalar o filesystem Extension numa pasta-cérebro de teste; reabrir o Desktop; confirmar leitura/escrita em `project_brain/` via MCP.
2. **Instruções:** criar um Project, colar `project_instructions.md` com o caminho; chat novo confirma orientação automática (lê `next_step`, propõe ação).
3. **Multi-projeto:** criar um segundo foco; confirmar que cada Project só atua sobre a sua pasta-cérebro.
4. **Skill snapshot:** pedir edição num doc vivo; confirmar o "antes" em `history/<nome>/` com timestamp e o cooldown segurando uma segunda edição em <20 min.
5. **Loop:** rodar `done`; confirmar `roadmap`, `next_step` e `work_map` atualizados sem hash.
6. **Adaptar existente:** rodar setup num Project que já tem conhecimento; confirmar que o conteúdo foi preservado e dobrado, nada apagado.
7. **PT-BR:** rodar a localização; confirmar nomes/prosa em português, nenhum link/skill quebrado.

## Fora de escopo (YAGNI por ora)
- Watcher de SO pro snapshot (opção ii) e versionamento via git/Obsidian (iii): só se a opção i doer.
- Variante Cowork pra claude.ai web ou modo degradado multi-surface.
- Criar a pasta `Claude Cowork Blueprint/` antes da aprovação deste spec.
