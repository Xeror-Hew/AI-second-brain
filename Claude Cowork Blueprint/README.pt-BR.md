# Um segundo cérebro para o seu trabalho

Um segundo cérebro para os projetos que você pensa a fundo: escrita, planejamento, pesquisa, decisões. Joga essa pasta no projeto, configura, e o Claude mantém o raciocínio organizado: a tua visão, um plano, um roadmap, um mapa do teu workspace, uma biblioteca do teu trabalho pronto, e uma memória que sobrevive entre sessões. Você escreve no Obsidian (ou em qualquer editor); o Claude lê e mantém a estrutura, tudo em texto puro que é seu.

É pra quem pensa pra viver: redatores, gerentes de projeto, analistas, pesquisadores, consultores. Sem programar, sem ritual de configuração, sem sintaxe pra aprender.

## Onde roda

Uma pasta, três jeitos de usar. Escolhe o que te serve:

- **Claude Cowork** — o modo agêntico do app de desktop do Claude. Sem terminal, o caminho mais simples: aponta pra tua pasta e fala. É a superfície mais nova, e a ligação ao vivo com o cérebro ainda está se ajustando; onde essa ligação não estiver pronta, o Claude lê tuas notas como arquivos de texto. O jeito de trabalhar em linguagem normal vale sempre.
- **Claude Code** — o app de terminal. O caminho de potência total, toda automação ligada.
- **Claudian** — um chat do Claude dentro do Obsidian. Roda o Claude Code por baixo, então você tem tudo direto no teu vault.

Os três lêem o mesmo `CLAUDE.md` e o mesmo cérebro. É texto puro, então funciona em qualquer superfície mesmo quando a parte ao vivo não funciona.

## Instalar

1. **Instala o [Node.js](https://nodejs.org)** se você não tem. O Claude usa pra rodar o teu cérebro.
2. Pros caminhos **Claude Code** e **Claudian**, instala também o **[Claude Code](https://claude.com/claude-code)**. Pro **Cowork**, basta o app de desktop do Claude.
3. Joga a pasta `Claude Cowork Blueprint/` no teu projeto (uma pasta nova, ou um vault do Obsidian que já exista).
4. Abre o Claude com essa pasta:
   - **Cowork:** sessão agêntica na pasta. **Claude Code:** abre. **Claudian:** abre o vault.
5. Fala pro Claude, colando esta linha:
   > read and follow `Claude Blueprint`

   Ele lê esse arquivo local e roda o setup: pergunta teu idioma, põe tudo no lugar, liga a memória, e absorve as notas que você já tem. Ele **funde, sem sobrescrever** teu `CLAUDE.md` nem as configs; numa instalação que já existe, tuas customizações são reconciliadas, não apagadas. No Claude Code e no Claudian, quando terminar, roda `/reload-skills` (2.1.152+) ou reabre pra carregar os `/verbs`.

## Tua primeira sessão

Na maior parte você só fala com o Claude em linguagem normal, igual em qualquer superfície. Pra pegar o jeito:

- **Conta pro Claude no que você está trabalhando.** Ele rascunha uma visão e um plano iniciais pra você corrigir.
- **Pede algo de verdade:** "rascunha a introdução", ou "pesquisa o que se sabe sobre X e cita as fontes".
- **Na próxima vez, é só dizer "me atualiza"** e ele te conta onde você parou.

É o ciclo inteiro: você guia, o Claude produz e lembra.

## Como funciona

Você escreve a tua `Vision` e as tuas `notes/`; o Claude escreve o `plan/`, o `roadmap/`, um `work_map/` do teu workspace, a `library/` do trabalho pronto, e o `next_step`. Cada lado lê o do outro, então os dois lêem como um só.

Duas ideias sustentam:

1. **Índice mais descrição.** Toda pasta tem um índice curto que aponta pros arquivos, uma linha cada. O Claude lê o índice e abre só o que precisa, então fica rápido e nunca recarrega tudo. Você navega igual.
2. **Histórico automático.** Antes de o Claude mudar um doc do cérebro, a versão antiga vai pra `history/`, o teu desfazer pro cérebro (cobre os docs do cérebro, não todo arquivo que você produz). No Claude Code e no Claudian isso é automático. No Cowork, o Claude salva conforme escreve quando a ligação com o cérebro está disponível; se não estiver, pede pro Claude "fazer um backup" e ele copia o cérebro de lado.

## O que você pode pedir

Você não precisa decorar nada: é só falar com o Claude em palavras normais, que ele escolhe a ferramenta certa sozinho. Esse jeito em linguagem normal funciona em qualquer superfície. Esse é o cardápio, pra você saber o que dá pra fazer.

**No dia a dia:**

| Pedir | Comando |
|-------|---------|
| Me atualiza: onde paramos e o que vem agora | `/start` |
| Pensar uma coisa a fundo antes de produzir | `/brainstorm` |
| Virar uma visão ou briefing num plano passo a passo | `/writeplan` |
| Levar um texto da página em branco até pronto | `/draft` |
| Descobrir algo direito, com fontes em que dá pra confiar | `/research` |
| Feedback afiado e honesto sobre um rascunho | `/critique` |
| Fazer um slide deck (PowerPoint) | `/make-deck` |
| Montar uma planilha com fórmulas de verdade | `/make-sheet` |
| Produzir um documento Word formatado | `/make-doc` |
| Salvar algo pra levar pra próxima vez | `/remember` |
| Fechar uma tarefa terminada | `/done` |

**De vez em quando:** roda um plano tarefa por tarefa · descobre por que algo não funciona · organiza material que chega · mapeia teu workspace · indexa teu trabalho pronto · arruma o cérebro · faz backup do cérebro · fecha a sessão · cria teu próprio comando.


## O que já vem pronto

A ligação com o teu cérebro já vem pronta de fábrica, então o Claude lê e atualiza tuas notas desde a primeira sessão. No Claude Code e no Claudian, na primeira vez, o Claude mostra um aviso pedindo pra permitir; aprova, é isso que deixa o Claude trabalhar com as tuas notas. O Claude Cowork é a superfície mais nova e o suporte a essa ligação ao vivo ainda está se ajustando; se o Claude não conseguir alcançar o cérebro lá, ele ainda lê tuas notas como arquivos de texto, e você pode pedir pra ele "fazer um backup" antes de editar.

Tudo funciona sem nem o Obsidian estar aberto. Se você usa o Obsidian e quer uma ligação ao vivo com ele enquanto está aberto (pro grafo), o setup te explica; é opcional e você não precisa.

## Por baixo do capô (pra quem tem curiosidade)

Dá pra pular. Por trás, o Claude faz a escavação e a arrumação com dois ajudantes, pra tua conversa principal ficar limpa: um pesquisador barato pra olhar coisas, e um escriba pra manter os docs em ordem. Os comandos que fazem o trabalho são adaptados do [superpowers](https://github.com/obra/superpowers) (um kit open-source do Jesse Vincent, licença MIT); eles vêm dentro dessa pasta, nada a mais pra instalar. Créditos em `.claude/NOTICE.md`.

## Faça seu

As regras ficam no `CLAUDE.md`; tuas ferramentas, estilo e detalhes ficam no `project_brain/context.md`. Edita os dois à vontade. O cérebro fica na tua máquina, então é privado e teu.
