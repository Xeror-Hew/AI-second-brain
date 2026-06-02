# The second brain for your AI

A second brain for software projects. Drop this folder in, run `/setup`, and Claude keeps the thinking organized: your vision, a technical plan, a roadmap, a live map of the code, and a memory that survives across sessions. You write in Obsidian or any editor; Claude reads and maintains the structure, all in plain markdown.

## Install

1. Drop the `Claude Code Blueprint/` folder into your project.
2. Run `/setup` from that project.

`/setup` moves `CLAUDE.md`, `.claude/`, `project_brain/`, and `.mcp.json` to your project root, then wires the memory link, and the `.gitignore`. It asks your language, maps the code you already have, and folds in any notes lying around. Run `/reload-skills` (Claude Code 2.1.152+) or reopen the session so the commands load.

(The brain MCP needs `node` on PATH. Without it the brain still works over the filesystem, you just lose the typed-tool shortcut.)

## Update

Drop the newer folder in and run `/setup` again. It sees the existing install, checks the version, swaps in the new engine, and merges rule changes into your `CLAUDE.md`. Your `project_brain/`, your memory, and the tweaks you made stay put.

## How it works

You write `Vision` and `notes/`; Claude writes `plan/`, `roadmap/`, `code_map/`, and `next_step`. Each side reads the other's.

Two ideas carry it:

1. **Index plus description.** Every folder has an index pointing to its files, one line each. Claude reads the index and opens only the file it needs, so it never reloads the whole brain every session (that's what rots context). You navigate the same way.
2. **Automatic history.** Before a living doc changes, a hook freezes the old version into `history/`. Claude never reads it; it's your undo.

Three layers, each optional on top of the last:

- **Filesystem** (always on): plain `.md` with frontmatter and `[[wikilinks]]`. No server.
- **Brain MCP** (`.mcp.json`): a typed index over `project_brain/`, so Claude pulls one section or appends a line instead of reading whole files. Works in the terminal and in an Obsidian sidebar that runs the CLI.
- **Obsidian MCP** (optional): graph and Bases access while Obsidian is open. It goes away when you close Obsidian.

## Commands

You type `/name`; Claude also fires them on its own when the moment fits.

**Brain core** (works on any project):

| Command | What it does |
|---------|--------------|
| `/setup` | Install or update the brain in a project. |
| `/start` | Read-only orientation: where we stopped and the next step. |
| `/done` | Close a finished task: log it, prune the roadmap, set the next step, finish the branch if one's ready. |
| `/end` | Session-close sweep that catches whatever the task closes missed. |
| `/remember` | Save a memory in the right format and index it. |
| `/writeplan` | Turn your `Vision` into a technical plan, or a spec into a bite-sized one. |
| `/brainstorm` | Explore intent and design before building; write the spec into `plan/`. |
| `/debloat` | Trim `project_brain/`: cut redundancy, prune stale, fix links. |

**Code engine**:

| Command | What it does |
|---------|--------------|
| `/tdd` | Red-green-refactor; no production code without a failing test first. |
| `/diagnose` | Root-cause investigation before any fix. |
| `/critique` | Dispatch a reviewer for your work, and take feedback with technical rigor. |
| `/execute` | Run a plan from `plan/`, by subagents or inline with checkpoints. |
| `/worktree` | Isolate feature work in a git worktree. |
| `/writeskill` | Write or edit a skill, tested before it ships. |
| `/map` | (Re)build the code map. |

`check-map`, `check-plan`, and `fix-links` fire on their own. Two subagents sit in `.claude/agents/`: `brain-researcher` (read-only, cheap, for discovery that stays off the main thread) and `doc-scribe` (heavier doc upkeep).

## The engine

The code-engine commands are forked from [superpowers](https://github.com/obra/superpowers) (MIT, by Jesse Vincent), trimmed and renamed, with their output pointed at `project_brain/`. Nothing extra to install: the brain and the engine are one folder, and `CLAUDE.md` outranks any skill, so trivial work skips the gates. If you already run the superpowers plugin, the blueprint turns it off for this project alone (the engine is already here); your other projects keep it. Credit is in `.claude/NOTICE.md`.

## Git: no AI attribution

No commit or PR carries a `Co-Authored-By` or a "Generated with" line, in any project. `/setup` installs a `commit-msg` hook that strips those trailers (it chains an existing hook, handles husky and `core.hooksPath`), turns Claude Code's own attribution off in `settings.json`, and a guard blocks the `--no-verify` escape. Git can't reach a PR body, so `CLAUDE.md` carries the rule there.

## Make it yours

Rules live in `CLAUDE.md`; stack and project specifics live in `project_brain/context.md`. Edit both freely. The brain stays local by default (gitignored), so it's personal; to share the plan and roadmap with a team, commit the brain spine (the setup script comments show the one-line change). The engine sits in your `.claude/`, yours to edit.
