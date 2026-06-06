# O segundo cérebro para a sua IA

Um segundo cérebro pra projetos de software. Joga essa pasta no projeto, aponta o Claude pro arquivo de setup, e ele mantém o raciocínio organizado: a tua visão, um plano técnico, um roadmap, um mapa vivo do código, e uma memória que sobrevive entre sessões. Você escreve no Obsidian ou em qualquer editor; o Claude lê e mantém a estrutura, tudo em markdown puro.

## Instalar

1. Joga a pasta `Claude Code Blueprint/` dentro do seu projeto.
2. Abre o Claude nesse projeto (terminal, Claudian ou Cowork).
3. Fala pro Claude, colando esta linha:
   > read and follow `Claude Blueprint`

O Claude lê esse arquivo local e roda a instalação: pergunta teu idioma e coloca `CLAUDE.md`, `.claude/`, `project_brain/` e `.mcp.json` na raiz do projeto, **fundindo, sem sobrescrever**. Teu `CLAUDE.md` e teu `.claude/settings.json` ficam; as regras dele somam junto das tuas; numa instalação que já existe, tuas customizações são reconciliadas, não apagadas. Faz a fiação do link da memória e do `.gitignore`, mapeia teu código, e absorve as notas espalhadas. Quando terminar, roda `/reload-skills` (Claude Code 2.1.152+) ou reabre pra carregar os `/verbs`.


(O brain MCP precisa de `node` no PATH. Sem ele o cérebro funciona pelo filesystem mesmo, você só perde o atalho das ferramentas tipadas.)

## Atualizar

Joga a pasta nova e roda `/setup` (agora está instalado na raiz, então o comando existe). Ele checa a versão, troca o motor, e funde as mudanças de regra no teu `CLAUDE.md`. Teu `project_brain/`, tua memória e os ajustes que você fez ficam intactos.

## Como funciona

Você escreve `Vision` e `notes/`; o Claude escreve `plan/`, `roadmap/`, `code_map/` e `next_step`. Cada lado lê o do outro.

Duas ideias sustentam:

1. **Índice mais descrição.** Toda pasta tem um índice que aponta pros arquivos, uma linha cada. O Claude lê o índice e abre só o arquivo que precisa, então nunca recarrega o cérebro inteiro toda sessão (é isso que apodrece o contexto). Você navega igual.
2. **Histórico automático.** Antes de um doc vivo mudar, um hook congela a versão antiga em `history/`. O Claude nunca lê; é o teu desfazer.

Três camadas, cada uma opcional em cima da anterior:

- **Filesystem** (sempre on): `.md` puro com frontmatter e `[[wikilinks]]`. Sem servidor.
- **Brain MCP** (`.mcp.json`): um índice tipado sobre o `project_brain/`, pro Claude puxar uma seção ou anexar uma linha em vez de ler arquivo inteiro. Funciona no terminal e numa sidebar do Obsidian que roda a CLI.
- **Obsidian MCP** (opcional): acesso a grafo e Bases com o Obsidian aberto. Some quando você fecha o Obsidian.

## Comandos

Você digita `/nome`; o Claude também dispara sozinho quando o momento casa.

**Núcleo do cérebro** (funciona em qualquer projeto):

| Comando | O que faz |
|---------|-----------|
| `/setup` | Instala ou atualiza o cérebro num projeto. |
| `/start` | Orientação read-only: onde paramos e o próximo passo. |
| `/done` | Fecha uma tarefa: loga, poda o roadmap, define o próximo passo, finaliza a branch se tiver uma pronta. |
| `/end` | Varredura no fim da sessão, pegando o que os fechamentos de tarefa deixaram passar. |
| `/remember` | Salva uma memória no formato certo e indexa. |
| `/writeplan` | Vira tua `Vision` em plano técnico, ou um spec em plano executável. |
| `/brainstorm` | Explora intenção e design antes de construir; escreve o spec no `plan/`. |
| `/debloat` | Enxuga o `project_brain/`: corta redundância, poda o velho, conserta links. |

**Motor de código**:

| Comando | O que faz |
|---------|-----------|
| `/tdd` | Red-green-refactor; nada de código de produção sem um teste falhando antes. |
| `/diagnose` | Investigação de causa raiz antes de qualquer fix. |
| `/critique` | Dispara um revisor pro teu trabalho, e recebe feedback com rigor técnico. |
| `/execute` | Roda um plano do `plan/`, por subagentes ou inline com checkpoints. |
| `/worktree` | Isola o trabalho de feature num git worktree. |
| `/writeskill` | Escreve ou edita uma skill, testada antes de subir. |
| `/map` | (Re)constrói o mapa do código. |

`check-map`, `check-plan` e `fix-links` disparam sozinhos. Dois subagentes em `.claude/agents/`: `brain-researcher` (read-only, barato, pra discovery fora da thread principal) e `doc-scribe` (manutenção pesada de docs).

## O motor

Os comandos do motor são forkados do [superpowers](https://github.com/obra/superpowers) (MIT, do Jesse Vincent), enxugados e renomeados, com a saída apontada pro `project_brain/`. Nada a mais pra instalar: o cérebro e o motor são uma pasta só, e o `CLAUDE.md` está acima de qualquer skill, então trabalho trivial pula os portões. Se você já roda o plugin superpowers, a blueprint desliga ele só nesse projeto (o motor já tá aqui); teus outros projetos mantêm. Créditos em `.claude/NOTICE.md`.

## Git: sem mais atribuições de IA

Nenhum commit ou PR leva `Co-Authored-By` nem "Generated with", em projeto nenhum. O `/setup` instala um hook `commit-msg` que tira esses trailers (encadeia um hook existente, lida com husky e `core.hooksPath`), desliga a atribuição do próprio Claude Code no `settings.json`, e um guard bloqueia o atalho `--no-verify`. O git não alcança o corpo de um PR, então o `CLAUDE.md` carrega a regra ali.

## Faça seu

As regras ficam no `CLAUDE.md`; stack e detalhes do projeto ficam no `project_brain/context.md`. Edita os dois à vontade. O cérebro fica local por padrão (gitignored), então é pessoal; pra dividir o plano e o roadmap com um time, versiona o espinhaço do cérebro (os comentários do script de setup mostram a mudança de uma linha). O motor mora no teu `.claude/`, teu pra editar.
