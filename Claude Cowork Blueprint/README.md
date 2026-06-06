# A second brain for your work

A second brain for the projects you think through: writing, planning, research, decisions. Drop this folder in, set it up, and Claude keeps your thinking organized: your vision, a plan, a roadmap, a map of your workspace, a library of your finished work, and a memory that carries across sessions. You write in Obsidian (or any editor); Claude reads it and keeps the structure tidy, all in plain text you own.

It's for anyone who thinks for a living: writers, project managers, analysts, researchers, consultants. No coding, no setup rituals, no syntax to learn.

## Where it runs

One folder, three ways to use it. Pick whichever fits:

- **Claude Cowork** — the agentic mode of the Claude desktop app. No terminal, the simplest path: point it at your folder and talk. It's the newest surface, and its live brain connection is still settling; where that connection isn't ready, Claude falls back to reading your notes as plain files. The plain-language way of working always holds.
- **Claude Code** — the terminal app. The full-power path, every automation on.
- **Claudian** — a Claude chat inside Obsidian. It runs Claude Code under the hood, so you get the full thing right in your vault.

All three read the same `CLAUDE.md` and the same brain. It's plain text, so it works on every surface even when the live tooling doesn't.

## Install

1. **Install [Node.js](https://nodejs.org)** if you don't have it. Claude uses it to run your brain; without it the brain still reads as plain files, but the automatic parts (like saved history) won't run.
2. For the **Claude Code** and **Claudian** paths, also install **[Claude Code](https://claude.com/claude-code)**. For **Cowork**, you just need the Claude desktop app.
3. Drop the `Claude Cowork Blueprint/` folder into your project (a new folder, or an existing Obsidian vault).
4. Open Claude with that folder:
   - **Cowork:** an agentic session on the folder. **Claude Code:** open it. **Claudian:** open the vault.
5. Tell Claude, pasting this line:
   > read and follow `Claude Blueprint`

   It reads that local file and runs setup: asks your language, puts everything in place, links the memory, and folds in any notes you already have. It **merges, never overwrites** your `CLAUDE.md` or settings; on an existing install your customizations are reconciled, not wiped. On Claude Code and Claudian, when it's done, run `/reload-skills` (2.1.152+) or reopen so the `/verbs` load.

## Your first session

You mostly just talk to Claude in plain language, the same on every surface. To get a feel for it:

- **Tell Claude what you're working on.** It drafts a starting vision and plan you can correct.
- **Ask it to do something real:** "draft the intro section", or "research what's known about X and cite it".
- **Next time, just say "catch me up"** and it tells you where you left off.

That's the whole loop: you steer, Claude produces and remembers.

## How it works

You write your `Vision` and your `notes/`; Claude writes the `plan/`, the `roadmap/`, a `work_map/` of your workspace, the `library/` of finished work, and the `next_step`. Each side reads the other's, so the two read as one.

Two ideas carry it:

1. **Index plus description.** Every folder has a short index pointing to its files, one line each. Claude reads the index and opens only what it needs, so it stays fast and never reloads everything. You navigate the same way.
2. **Automatic history.** Before Claude changes one of its brain docs, the old version is saved to `history/`, your undo button for the brain (it covers the brain's own docs, not every file you produce). On Claude Code and Claudian this is automatic. On Cowork, Claude saves it as it writes when the brain connection is available; if it isn't, ask Claude to "make a backup" and it copies the brain aside.

## What you can ask for

You don't have to memorize anything: just talk to Claude in plain words, and it picks the right tool on its own. That plain-language way works on every surface. This is the menu, so you know what's possible.

**Everyday:**

| Ask for | Command |
|---------|---------|
| Catch me up: where we left off and what's next | `/start` |
| Think something through before producing it | `/brainstorm` |
| Turn a vision or brief into a step-by-step plan | `/writeplan` |
| Take a piece of writing from blank page to finished | `/draft` |
| Find something out properly, with sources you can trust | `/research` |
| Sharp, honest feedback on a draft | `/critique` |
| Make a slide deck (PowerPoint) | `/make-deck` |
| Build a spreadsheet with real formulas | `/make-sheet` |
| Produce a formatted Word document | `/make-doc` |
| Save something to carry into next time | `/remember` |
| Wrap up a finished task | `/done` |

**Now and then:** run a plan task by task · figure out why something isn't working · sort and organize incoming material · map your workspace · index your finished work · clean up the brain · back up the brain · wrap up a session · add your own command.

## What's already set up

The connection to your brain comes ready out of the box, so Claude reads and updates your notes from the first session. On Claude Code and Claudian, the first time, Claude shows a one-time prompt to allow it; approve it, that's what lets Claude work with your notes. Claude Cowork is the newest surface and its support for this live connection is still settling; if Claude can't reach the brain there, it still reads your notes as plain files, and you can ask it to "make a backup" before it edits one.

Everything works without Obsidian even being open. If you use Obsidian and want a live link to it while it's open (for the graph view), setup can walk you through that; it's optional and you don't need it.

## Under the hood (for the curious)

You can skip this. Behind the scenes, Claude does the digging and tidying with two helpers so your main chat stays clean: a cheap researcher for looking things up, and a scribe for keeping the docs in order. The commands that do the work are adapted from [superpowers](https://github.com/obra/superpowers) (an open-source toolkit by Jesse Vincent, MIT-licensed); they ship inside this folder, nothing extra to install. Credit is in `.claude/NOTICE.md`.

## Make it yours

The rules live in `CLAUDE.md`; your tools, style, and specifics live in `project_brain/context.md`. Edit both freely. The brain stays on your machine, so it's private and yours.
