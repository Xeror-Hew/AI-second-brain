# A second brain for the AI

A drop-in second brain for Claude, built with Obsidian's logic.
(probably can be used with other AI models, but will need some tweaking, I'm using only Claude for now so I built specially for it)

Copy it into any project and Claude keeps the thinking organized for you: your vision, a technical plan, a roadmap, a live map of the code, and a memory that survives across sessions. A hook snapshots every living doc before it changes, so you never lose a previous version. You work normally, Claude reads and maintains the structure.

## Why this exists

I built this while developing a big project that kept outgrowing my head. Claude kept bloating with old information, outdated decisions and dead plans, poisoning it's own context and destroying the workflow. So I shaped a system to keep both my thoughts and Claude's clean, and it worked. Then I stripped out the project-specific parts and turned it into a blueprint anyone can drop into their own work.

## How it works

Two ideas do the heavy lifting:

1. **Index plus description.** Every folder has an index pointing to its files, one line each. Claude reads the index and opens only the file it needs, so it never reloads the whole brain every session (that's what rots context). You navigate the same way.
2. **Automatic history.** Before a living doc changes, a hook freezes the old version into `history/`. Claude never reads it; it's your ""git"".

Claude reads the brain as plain markdown. Two optional layers sit on top: a typed index (the brain MCP) so it pulls one section instead of a whole file, and an Obsidian layer for graph and Bases access while the app is open.

## What runs it

The work runs through skills: short commands you type (`/start`, `/done`, `/writeplan`) that Claude also fires on its own when the moment fits. The Code variant adds an execution engine forked from [superpowers](https://github.com/obra/superpowers) (by Jesse Vincent): test-first coding, root-cause debugging, code review, plan execution, worktrees. Each variant's README lists its full set.

## Variants

- **`Claude Code Blueprint/`** for software projects. Plan, roadmap, code map, memory.
- **`Claude Cowork Blueprint/`** a lighter take for non-code work.

## Before you install

You will be setting up a few things, so you know what you are getting into:

- **Obsidian**, installed, with the project folder open as a vault. It is for your own organization, mostly.
- **MCP Plugin in Obsidian** (optional). The setup offers to connect Claude to your open vault over MCP for a tighter loop. It is a bonus, not a requirement.

## Get started

Open **`Claude xxxx Blueprint/`** and follow its specific README. It walks you through the install step by step. You can also ask your own Claude for help when installing.

On install, the setup asks which language you want and translates the parts you read and edit, so you can run the whole thing in your own language. It is meant to be customized to your needs and your style, so play with it freely.

## Updating

Same move as installing. Grab the latest `Claude Code Blueprint/` folder, drop it in your project root, and run `/setup`. It notices the blueprint is already there, checks the version, and upgrades in place: it swaps in the new engine (skills, hooks, setup) and merges any rule changes into your CLAUDE.md, while leaving your project_brain and your memory alone.
