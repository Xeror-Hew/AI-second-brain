# A second brain for the AI

A drop-in second brain for Claude, built in Obsidian.
(probably can be used with other AI models, but will need some tweaking, I'm using only Claude for now so I built specially for it)

Copy it into any project and Claude keeps the thinking organized for you: your vision, a technical plan, a roadmap, a live map of the code, and a memory that survives across sessions. A hook snapshots every living doc before it changes, so you never lose a previous version. You work in Obsidian, Claude reads and maintains the structure.

## Why this exists

I built this while developing a big project that kept outgrowing my head. The changes in plan, forgetting to debug this, build that, and the worst of all, Claude was getting bloated with old information, outdated decisions and plans, the accumulated trash started destroying the development. Then I started shaping a system to try to organize both my thoughts and get Claude's thoughts clean from the trash, and it ended up working very well. So I refined it, stripped out the project-specific parts, and turned it into a blueprint anyone can drop into their own work.

## Variants

- **`Claude Code Blueprint/`** (ready): for software projects. Plan, roadmap, code map, organize memories
- **`Claude Cowork Blueprint/`** (coming soon): a lighter take for non-code work, derived from the Code one once it is solid.

## Before you install

You will be setting up a few things, so you know what you are getting into:

- **Obsidian**, installed, with the project folder open as a vault. The whole system lives in Obsidian.
- The **superpowers** plugin. It ships auto-declared, so you accept one trust prompt the first time you open the project. The skills lean on it (and the plugin is very good overall).
- **MCP** (optional). The setup offers to connect Claude to your open vault over MCP for a tighter loop. It is a bonus, not a requirement; skip it and everything still works over the filesystem.

## Get started

Open **`Claude Code Blueprint/`** and follow its specific README. It walks you through the install step by step. You can also ask your own Claude for help when installing.

On install, `/setup` asks which language you want and translates the parts you read and edit into it, so you can run the whole thing in your own language. The whole thing is supposed to be customizable to fit your needs and your style, so feel free to play with it. (I dont know about using other AI models with this, but I think it is possible)

## Updating

Same move as installing. Grab the latest `Claude Code Blueprint/` folder, drop it in your project root, and run `/setup` again. It notices the blueprint is already there, checks the version, and upgrades in place: it swaps in the new engine (skills, hooks, setup) and merges any rule changes into your CLAUDE.md, while leaving your project_brain and your memory alone. Then it cleans up the folder it came in. Your notes and your history stay exactly where they were.
