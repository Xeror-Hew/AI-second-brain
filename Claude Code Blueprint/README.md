# Claudian: a second brain for Claude Code

A drop-in workflow that turns Claude Code into a second brain you and the AI share. One truth, serving both: you write the vision, the AI writes the plan, the roadmap, the code map, and the next step, each where the other can read it. Two intelligences working as one.

> 🌎 Não fala inglês? Veja [README.pt-BR.md](README.pt-BR.md). The engine stays English; `/setup` localizes everything you read, plus the folder and file names, into your language.

It is a **folder**, not a plugin: skills you fire as bare `/verbs`, snapshot hooks, a no-AI-attribution commit guard, a zero-dependency **brain MCP**, and a forked-in execution engine. Drop the folder into any project, run one command, and the brain is live.

---

## 🚀 Install

1. Download this repo (or a release) and drop the `Claude Code Blueprint/` folder into your project.
2. From that project, run:

```
/setup
```

`/setup` moves `CLAUDE.md`, `.claude/`, `project_brain/`, and `.mcp.json` to your project root, wires the memory link plus the commit-msg hook plus `.gitignore`, asks your language, maps your code, and folds in any notes you already have. Run `/reload-skills` (Claude Code 2.1.152+) or reopen the session so the bare `/verbs` load.

> The brain MCP needs `node` on PATH. Without it the brain still works (Claude reads `project_brain/` directly); you only lose the typed-tool shortcut.

**Update later:** drop the newer folder in and run `/setup` again. It reconciles the customizations you made instead of overwriting them.

---

## 🧠 Mental model

`Vision` and `notes/` are your mind; `plan/`, `roadmap/`, `code_map/`, and `next_step` are the AI's. Each writes where the other can read.

Two principles carry it:

1. **Index plus description.** Each folder has an index that points to its files with one description line. The AI reads the index, then opens only the one doc it needs (it does not read the whole brain each session, the way a context-rot-prone "read everything" memory bank does). You navigate the same way.
2. **Track the changes.** A hook freezes the "before" of every edit into `history/`. The AI never reads it; it is your safety net.

Rituals are **skills**: short commands you type (`/done`, `/end`) that the AI also fires on its own when the moment fits.

### Three layers, progressive enhancement

- **Layer 0, filesystem (always on).** The brain is plaintext `.md` plus YAML frontmatter plus `[[wikilinks]]`. Works headless, no setup, no server.
- **Layer 1, the brain MCP (registered via `.mcp.json`).** A typed index over `project_brain/`: `brain_orient` (where work stopped, in one call), `brain_search`, `brain_get`, `brain_append`, `brain_set_next`, `brain_log_done`. Retrieval instead of reading whole files; markdown stays the source of truth. It runs in the terminal and inside Claudian (the Obsidian sidebar that wraps the Claude Code CLI).
- **Layer 2, Obsidian MCP (optional, live only).** For sessions where Obsidian is open and you want graph and Bases access. An enhancement, never a dependency (it dies when Obsidian closes).

---

## 🛠️ Skills

You type `/name` (a bare verb); the AI also fires them when the context matches.

**Brain core** (the second brain, works on any project):

| Command | What it does |
|---------|--------------|
| `/setup` | Scaffold or reconcile the brain in a project. |
| `/start` | Read-only orientation: where we stopped plus the next step (`brain_orient`). |
| `/done` | Close a finished task: log, prune the roadmap, set the next step, finish the branch when one is ready. |
| `/end` | Session-close safety-net sweep, catching what a task close missed. |
| `/remember` | Save a persistent memory in the right format plus index it. |
| `/writeplan` | Derive `plan/` from your `Vision.md`, or turn an approved spec into a bite-sized plan. |
| `/brainstorm` | Explore intent and design before building; write the spec into `plan/`. |
| `/debloat` | Trim `project_brain/`: cut redundancy, prune stale, fix links. |

**Code engine** (forked from superpowers):

| Command | What it does |
|---------|--------------|
| `/tdd` | Red-green-refactor; no production code without a failing test first. |
| `/diagnose` | Root-cause investigation before any fix. |
| `/critique` | Request a review (reviewer subagent) and receive one with technical rigor. |
| `/execute` | Run a plan from `plan/`, subagent-driven or inline with checkpoints. |
| `/worktree` | Isolate feature work in a git worktree. |
| `/writeskill` | Author or edit a skill, tested before it ships. |
| `/map` | (Re)build the code map. |

Automatic (the AI fires them): `check-map`, `check-plan`, `fix-links`.

Plus two cheap workers in `.claude/agents/`: `brain-researcher` (read-only, haiku, for discovery that stays off the main thread) and `doc-scribe` (heavier doc upkeep).

---

## 🦸 The engine, forked in

The code-engine skills are vendored from [superpowers](https://github.com/obra/superpowers) (MIT, by Jesse Vincent), then trimmed, renamed to bare verbs, and fused with the brain so their output lands in `project_brain/`. There is no separate plugin to install and nothing to wire: the brain and the engine ship as one folder, and `CLAUDE.md` outranks any skill so trivial work skips the heavy gates. TDD, debugging, brainstorming, the plan/execute pipeline, code review, and worktrees compose unchanged; `/writeplan` and `/done` own the project plan and the roadmap. Credit lives in `.claude/NOTICE.md`. If you have the external superpowers plugin installed globally, the blueprint disables it for this project alone via `settings.json` (the engine is already here, so it would only duplicate the skills); your other projects keep it.

---

## 🔒 Git: no AI attribution, ever

Commits and PRs carry no `Co-Authored-By` and no "Generated with" footer, in any project. `/setup` installs a `commit-msg` hook that strips such trailers (it chains an existing hook, integrates with husky, respects `core.hooksPath`), `settings.json` turns Claude Code's own attribution off, and a `guard-commit` hook blocks the common `--no-verify`/`-n` skips. The commit-msg hook plus that setting are the real guarantee; the guard is defense-in-depth. Git cannot hook a PR body, so `CLAUDE.md` carries the rule for the AI to follow there.

---

## ⚡ Why it pays for itself

A second brain earns back its tokens. Without one, every session re-derives context by re-reading and re-exploring the repo; with one, `brain_orient` rebuilds context from a small index plus a few targeted docs, the way retrieval beats replay.

This is not hand-waving. Anthropic's own context-engineering guidance recommends exactly this shape (just-in-time retrieval via lightweight identifiers, subagents that return distilled summaries, progressive disclosure via metadata). Their memory plus context-editing evals show up to **84% fewer tokens** on long agentic runs. Prompt caching bills cached reads at a fraction of base input, and Claudian keeps the cache warm: `CLAUDE.md` stays frozen in the cached prefix, everything that changes lives in `project_brain/` (read on demand, appended not mutated), and the tool surface stays small and stable. The brain MCP leans on deferred tool-loading: `brain_orient` is always loaded so orientation is one call, the other five load on demand. Measured always-on cost is about 1.2k tokens per session. The win grows with the project.

---

## 🎨 Make it yours

Claudian adapts to any project and bends to you. Project-level personality lives in `CLAUDE.md` (rules) and `project_brain/context.md` (stack, principles, project rules); edit them freely. The brain stays local to your machine by default (gitignored), so it is personal; to share the plan and roadmap with a team, commit the brain spine (the setup script's comment shows the one-line change). The engine lives in your project's `.claude/` (skills, hooks, the brain MCP), so it is yours to edit outright. Update by dropping a newer folder and re-running `/setup`, which reconciles what you changed.
