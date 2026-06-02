# Claudian: um segundo cérebro pro Claude Code

Um workflow que transforma o Claude Code num segundo cérebro que você e a IA dividem. Uma verdade só, servindo os dois: você escreve a visão; a IA escreve o plano, o roadmap, o mapa do código e o próximo passo, cada um onde o outro consegue ler. Duas inteligências operando como uma.

> 🌎 Versão canônica em inglês: [README.md](README.md). O motor fica em inglês; o `/setup` traduz pro seu idioma tudo que você lê, mais os nomes de pastas e arquivos.

É uma **pasta**, não um plugin: skills que você dispara como `/verbos` simples, hooks de snapshot, um guard de commit sem atribuição de IA, um **brain MCP** sem dependências, e o motor de execução forkado pra dentro. Joga a pasta no projeto, roda um comando, e o cérebro está vivo.

---

## 🚀 Instalar

1. Baixe este repositório (ou um release) e jogue a pasta `Claude Code Blueprint/` dentro do seu projeto.
2. Nesse projeto, rode:

```
/setup
```

O `/setup` move `CLAUDE.md`, `.claude/`, `project_brain/` e `.mcp.json` pra raiz do projeto, faz a fiação (link da memória, hook de commit-msg, `.gitignore`), pergunta seu idioma, mapeia seu código e absorve as notas que você já tem. Rode `/reload-skills` (Claude Code 2.1.152+) ou reabra a sessão pra carregar os `/verbos`.

> O brain MCP precisa de `node` no PATH. Sem ele o cérebro ainda funciona (a IA lê `project_brain/` direto); você só perde o atalho das ferramentas tipadas.

**Atualizar depois:** jogue a pasta nova e rode `/setup` de novo. Ele reconcilia as personalizações que você fez em vez de sobrescrever.

---

## 🧠 Modelo mental

`Vision` e `notes/` são a sua mente; `plan/`, `roadmap/`, `code_map/` e `next_step` são da IA. Cada um escreve onde o outro lê. Dois princípios sustentam:

1. **Índice mais descrição.** Cada pasta tem um índice que aponta pros arquivos com uma linha de descrição. A IA lê o índice e abre só o doc que precisa (ela não lê o cérebro inteiro a cada sessão). Você navega igual.
2. **Rastreia as mudanças.** Um hook congela o "antes" de cada edição em `history/`. A IA nunca lê; é a sua rede de segurança.

Os rituais são **skills**: comandos curtos que você digita (`/done`, `/end`) e que a IA também dispara sozinha quando o momento casa.

Três camadas: **L0 filesystem** (sempre ligado, headless) avança pra **L1 brain MCP** (índice tipado sobre o `project_brain/`, registrado via `.mcp.json`, roda no terminal e dentro do Claudian) e pra **L2 Obsidian MCP** (opcional, só com o Obsidian aberto, dá grafo e Bases).

---

## 🛠️ Skills

Você digita `/nome` (um verbo simples); a IA também dispara quando o contexto casa.

**Núcleo do cérebro** (o segundo cérebro, funciona em qualquer projeto):

| Comando | O que faz |
|---------|-----------|
| `/setup` | Instala ou reconcilia o cérebro num projeto. |
| `/start` | Orientação read-only: onde paramos mais o próximo passo (`brain_orient`). |
| `/done` | Fecha uma tarefa: loga, poda o roadmap, define o próximo passo, finaliza a branch quando uma está pronta. |
| `/end` | Varredura de rede de segurança no fim da sessão, pegando o que um fechamento de tarefa deixou passar. |
| `/remember` | Salva uma memória no formato certo e indexa. |
| `/writeplan` | Deriva o `plan/` da sua `Vision.md`, ou vira um spec aprovado em plano executável. |
| `/brainstorm` | Explora intenção e design antes de construir; escreve o spec no `plan/`. |
| `/debloat` | Enxuga o `project_brain/`: corta redundância, poda o obsoleto, conserta links. |

**Motor de código** (forkado do superpowers):

| Comando | O que faz |
|---------|-----------|
| `/tdd` | Red-green-refactor; nada de código de produção sem um teste falhando antes. |
| `/diagnose` | Investigação de causa raiz antes de qualquer fix. |
| `/critique` | Pede um code review (subagente revisor) e recebe um com rigor técnico. |
| `/execute` | Roda um plano do `plan/`, por subagentes ou inline com checkpoints. |
| `/worktree` | Isola o trabalho de feature num git worktree. |
| `/writeskill` | Escreve ou edita uma skill, testada antes de subir. |
| `/map` | (Re)constrói o mapa do código. |

Automáticas (a IA dispara): `check-map`, `check-plan`, `fix-links`.

Mais dois trabalhadores baratos em `.claude/agents/`: `brain-researcher` (read-only, haiku, pra discovery fora da thread principal) e `doc-scribe` (manutenção pesada de docs).

---

## 🦸 O motor, forkado pra dentro

As skills do motor de código vêm do [superpowers](https://github.com/obra/superpowers) (MIT, do Jesse Vincent), enxugadas, renomeadas pra verbos simples e fundidas com o cérebro pra que a saída caia em `project_brain/`. Não há plugin separado pra instalar nem nada pra configurar: o cérebro e o motor vêm numa pasta só, e o `CLAUDE.md` está acima de qualquer skill, então trabalho trivial pula os portões pesados. TDD, debugging, brainstorming, o pipeline de plano/execução, code review e worktrees compõem sem mudança; `/writeplan` e `/done` cuidam do plano do projeto e do roadmap. Os créditos ficam em `.claude/NOTICE.md`.

---

## 🔒 Git: nunca atribuição de IA

Commits e PRs não levam `Co-Authored-By` nem rodapé "Generated with", em projeto nenhum. O `/setup` instala um hook `commit-msg` que remove esses trailers (encadeia um hook existente, integra com husky, respeita `core.hooksPath`), o `settings.json` desliga a atribuição do próprio Claude Code, e um guard `guard-commit` bloqueia os atalhos comuns `--no-verify`/`-n`. O hook commit-msg mais esse setting são a garantia real; o guard é defesa em profundidade. O git não consegue dar hook num corpo de PR, então o `CLAUDE.md` carrega a regra pra IA seguir ali.

---

## ⚡ Por que se paga

Um segundo cérebro devolve os tokens que custa. Sem ele, toda sessão re-deriva contexto relendo e re-explorando o repo; com ele, o `brain_orient` reconstrói o contexto de um índice pequeno mais alguns docs alvo, do jeito que recuperação ganha de releitura.

A própria orientação de engenharia de contexto da Anthropic recomenda exatamente esse formato (recuperação just-in-time por identificadores leves, subagentes que devolvem resumos destilados, divulgação progressiva por metadados). Os evals de memória mais edição de contexto deles mostram até **84% menos tokens** em runs agênticos longos. O cache de prompt cobra leituras em cache por uma fração da entrada base, e o Claudian é feito pra manter o cache quente: `CLAUDE.md` fica congelado no prefixo, o que muda mora em `project_brain/` (lido sob demanda, anexado em vez de mutado), e a superfície de ferramentas fica pequena e estável. O brain MCP usa carregamento adiado: o `brain_orient` fica sempre carregado, os outros cinco carregam sob demanda. O custo sempre-ligado medido fica em torno de 1,2k tokens por sessão. O ganho cresce com o projeto.

---

## 🎨 Faça seu

O Claudian se adapta a qualquer projeto e se dobra a você. A personalidade do projeto mora no `CLAUDE.md` (regras) e no `project_brain/context.md` (stack, princípios, regras do projeto); edite à vontade. O cérebro fica local na sua máquina por padrão (gitignored), então é pessoal; pra dividir o plano e o roadmap com um time, versione o espinhaço do cérebro (o comentário no script de setup mostra a mudança de uma linha). O motor mora no `.claude/` do seu projeto (skills, hooks, o brain MCP), então é seu pra editar. Atualize jogando a pasta nova e rodando `/setup` de novo, que reconcilia o que você mudou.
