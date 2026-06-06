# {{PROJECT_NAME}}

{{PROJECT_DESCRIPTION}}.

> 📖 **Start here**: [[project_brain/plan/plan_summary]] (the plan, overview plus pointers) and [[project_brain/next_step]] (the concrete next action).

> 🧠 **Shared brain.** `Vision` and `notes/` are the user's mind; `plan/`, `roadmap/`, `work_map/`, `library/`, and `next_step` are yours. Keep your reasoning written where the user can see it, and read theirs, so the two read as one.

> 🖥️ **Three surfaces, one folder.** This brain runs on **Claude Code** (terminal), **Claudian** (the Obsidian plugin, which embeds Claude Code), and **Claude Cowork** (the Desktop app's agentic mode, no terminal needed). Markdown is the source of truth, so the brain works on all three even when the live tooling doesn't. Claude Code and Claudian get the full set (hooks, the brain MCP, the `/verb` skills). **Claude Cowork is newer and its support for a local MCP and for the skills is still settling**: where the brain MCP loads, write brain docs through it so they version; where it doesn't, the docs are plain files, so make a backup first (`/snapshot`, or copy the doc aside) before editing one by hand. The session-start primer also rides on a hook (Code/Claudian only), so on Cowork orient yourself first (read [[project_brain/next_step]] and `roadmap/`, or `brain_orient` if the MCP is up) and treat skills as not optional, before acting.

---

## Workflow rules

1. **≥95% before acting.** Before any change (`Edit` / `Write` / `Bash` with effect), make sure you have enough context to be 95%+ sure of the result. Short of that, use `AskUserQuestion`. Discovery (`Read` / `Grep` / `Glob`) is always fine; hold mutation to the 95% bar.

2. **Subagents in parallel.** 2+ independent tasks, dispatch them in parallel in one turn. `Explore` for targeted search, `general-purpose` for broad investigation, specialized agents when they fit. Go sequential only on a real dependency.

3. **Skills first.** If a task falls in a listed skill's scope, invoke it before improvising. When unsure, invoke and drop it if it doesn't fit.

4. **Verify before calling it done.** Check the result, read it back, confirm. No evidence means not done.

5. **Catch problems in passing.** Spot a latent issue on the way? Report it and propose a fix, even out of scope.

6. **Always optimize.** Shortest path, more parallel, less busywork. Keep structure to what the task needs.

7. **Check before you assert.** Read the work or doc that already exists before saying how something stands or changing it. When unsure, go to the source.

8. **Keep the cache warm.** Session cost is dominated by prompt-cache reuse. Pin model, effort, and MCP servers at the start; switching mid-session re-bills the whole context. Treat `CLAUDE.md` as frozen during a session (it's read once at start); anything that changes goes in `project_brain/`, read on demand, cache-safe. Compact only at task boundaries. Send verbose discovery to a subagent so it stays out of the main thread (keeping the prefix cached), and run cheap high-volume passes on a smaller model.

9. **Push back, don't flatter.** Skip performative agreement; when something is off, say so with the reason. State confirmed-good and confirmed-wrong both plainly.

---

## Doc rules

1. **Minimal structure** in `project_brain/`:
   - [[project_brain/Vision]]: the user's vision.
   - `plan/`: the AI's plan (index, summary, why, how). See [[project_brain/plan/plan_index]].
   - `roadmap/`: checklist plus log. See [[project_brain/roadmap/roadmap_index]].
   - [[project_brain/next_step]]: **one item**, overwritten on each completion.
   - `work_map/`: the lay of your workspace, areas, materials, sources (index plus fragments). See [[project_brain/work_map/work_map_index]].
   - `library/`: the finished work this project holds (index plus fragments). See [[project_brain/library/library_index]].
   - `history/`: old versions, automatic snapshots. The AI never reads it.
   - `memory/`: persistent auto-memory across sessions (harness-managed, see rule 13).
   - `notes/`: the user's note/idea space (the AI reads it only when asked, out of the snapshot).

2. **Living files carry no date in the name.** Stable names, edited in place. If a date matters it lives in the content (frontmatter or title), so links never break and the index never churns.

3. **Versioning is automatic, two ways** (canonical rule, point here if you need it elsewhere). On Claude Code and Claudian the hook `.claude/hooks/snapshot.*` freezes the "before" of a living doc into `history/<file>/` ahead of a raw edit. Wherever the brain MCP is loaded (always on Code/Claudian; on Cowork when it's available), it snapshots a doc before it writes, so edits routed through `brain_append`/`brain_set_next` version themselves even without a hook. So **prefer the brain MCP for brain-doc writes**: it keeps versioning surface-independent wherever it runs. Either path: one snapshot per file every ~20 min, `roadmap/` and `notes/` excepted (roadmap keeps its own history in `roadmap_log`; `notes/` is the user's scratch space). Editing a brain doc by hand where neither a hook nor the MCP caught it (a Cowork build without the MCP)? Run `/snapshot` first, or copy the doc aside. Full detail: the comments in `.claude/hooks/snapshot.*` and `.claude/hooks/snapshot-all.mjs`.

4. **The live truth is always in the current file.** `history/` holds the automatic snapshots, the user's safety net, out of the AI's workflow.

5. **Every change you ship** = one line in [[project_brain/roadmap/roadmap_log]] plus an update to [[project_brain/roadmap/roadmap]]. Finished items leave the active list, obsolete ones get removed. How it works: [[project_brain/roadmap/roadmap_index]]. _(procedure: `/done`.)_

6. **A change in the plan (`plan/`)** means updating [[project_brain/roadmap/roadmap]] the same session.

7. **Next step is always one item.** Done? **Overwrite** [[project_brain/next_step]] with the next one. No history here, just the active item.

8. **Close out each task as you finish it, while the context is fresh.** The moment a task is done, run `/done`: log it, prune the roadmap, set the next step, update `library/` if you produced or reshaped a deliverable, and `work_map/` if the workspace's shape changed. A **new or reshaped deliverable** updates the library on the spot _(`/library`)_; a **change in the workspace's shape** updates the work map _(`/work-map`)_, even mid-task. `/end` is the safety net at session close, sweeping the work map, the library, and dead/orphan links for anything a task close missed. Waiting for session end loses the context that made the change clear.

9. **Path-style wikilinks**, always `[[project_brain/path/file]]` (vault-relative, no extension). The visible text is the path: clickable for the human, one hop for the AI. **Exception: `memory/`** (see rule 13).

10. **Link upkeep is the AI's job.** When you create/rename/remove a doc: update the right index (path-style wikilink plus a one-line description) and fix the links that pointed at the file. Keep the user out of manual link upkeep. _(procedure: `/fix-links`.)_

11. **Hub and spoke.** The index (hub) points to the files (spokes); each file points back to its index. The AI navigates through the hub.

12. **What the AI needs to read has to be real text.** It sees transclusion (`![[file]]`) and `dataview` blocks as raw syntax. Any index or table the AI uses is static text.

13. **`memory/` belongs to the harness (auto-memory), it follows its own format, not rule 9.** Linked by a *junction* (setup wires it). Inside it: `MEMORY.md` uses `[Title](file.md)`, and cross-links use the full file basename `[[type_slug]]` (e.g. `[[feedback_estilo]]`). Obsidian resolves a wikilink against the filename, so the label must match the file exactly, `type_` prefix included.

---

## Skills / commands

> They live in `.claude/skills/`. You type `/name` (a bare verb); the AI also fires them on its own when the context matches (`when_to_use`). The skills carry the detailed procedure. The rules above are the short baseline, always in effect even if a skill doesn't fire.

**Brain core** (the second brain, works on any project):
- `/setup`: onboarding. Installs the blueprint fresh, or upgrades it in place when you drop a newer version.
- `/start`: read-only orientation. Where we stopped plus the next step.
- `/done`: close out a finished task on the spot. Log it, prune the roadmap, update the library if you produced something, set the next step.
- `/end`: safety-net sweep at session close. Library, log, roadmap, next_step, dead links, catching whatever a task close missed.
- `/remember`: save a memory in the right format plus index it.
- `/writeplan`: derive `plan/` from [[project_brain/Vision]], or turn an approved spec into a bite-sized task-list.
- `/brainstorm`: explore intent and design before producing; write the spec into `plan/`, then hand to `/writeplan`.
- `/tidy`: trim `project_brain/`. Cut redundancy, prune stale, split big files, fix links.

**Engine** (the production discipline):
- `/draft`: take a written deliverable from blank page to finished (outline, draft, revise, critique).
- `/research`: find something out properly (gather, verify against a second source, synthesize with citations).
- `/critique`: request a review (reviewer subagent) and receive one with technical rigor.
- `/execute`: run a written plan from `plan/`, subagent-driven or inline with checkpoints.
- `/diagnose`: root-cause investigation before any fix.
- `/triage`: sort, rename, deduplicate, and surface incoming or scattered material, safely (never deletes).
- `/work-map`: (re)build the work map, the lay of your workspace and materials.
- `/library`: (re)build the library of finished work.
- `/writeskill`: author or edit a skill, tested before it ships.
- `/snapshot`: manually freeze the brain into `history/` when no hook is running (Claude Cowork).

**Office** (produce office files over permissive libraries; on Cowork they augment the native capability):
- `/make-deck`: a polished PowerPoint (.pptx) deck from a brief.
- `/make-sheet`: an Excel (.xlsx) sheet with real formulas, no hard-coded numbers.
- `/make-doc`: a formatted Word (.docx) document from finished prose.

**Automatic (the AI fires these itself, you don't call them):**
- `check-work-map`: check the work map before working in an unfamiliar part of the workspace.
- `check-library`: check the library before producing or referencing work you don't already know.
- `check-plan`: check the plan before changing the approach or a settled decision.
- `fix-links`: when you create/rename/remove a doc, fix the index plus links.

---

## Engine: one system

The engine skills are the blueprint's own, vendored from [superpowers](https://github.com/obra/superpowers) (MIT, by Jesse Vincent; credit in `.claude/NOTICE.md`). There is no separate plugin to install and nothing to wire: the brain and the engine ship as one, and `settings.json` turns the external superpowers plugin off for this project (if it is installed globally) so the forked skills are not duplicated and the session injection is not doubled. `CLAUDE.md` outranks any skill, so trivial work skips the heavy gates. These rules settle the overlaps:

- **Plan → produce**: `/brainstorm` writes a design spec into `plan/`; `/writeplan` turns it into a bite-sized task-list (or derives the project plan from `Vision`); `/execute` runs it; `/done` logs what shipped. Run `/brainstorm` on real work, skip it on mechanical tasks.
- **Production discipline**: `/draft` and `/research` are how you produce; `/diagnose` when something isn't working. `/critique` runs before you finalize; `/done` records the result.
- **Finish**: `/done` (per task) and `/end` (session) own the brain upkeep. Close out each task as you finish it.
- **Skill groups**: brain core (orient, plan, remember, finish), the engine (`/draft /research /critique /execute /diagnose /triage /work-map /library /writeskill`), and the office skills (`/make-deck /make-sheet /make-doc`). Fire a skill when it fits the moment; rules 1 (≥95% then act) and 8 (keep the cache warm) hold throughout.

---

## Project context

> Project-specific config lives outside this file, to keep `CLAUDE.md` lean:
- [[project_brain/context]]: tools/environment, principles (priority on conflict), specific rules.

---

## Navigation: where things are

- User's vision → [[project_brain/Vision]]
- Plan → [[project_brain/plan/plan_index]] (entry: [[project_brain/plan/plan_summary]])
- Checklist / what's left → [[project_brain/roadmap/roadmap]]
- Workspace map → [[project_brain/work_map/work_map_index]]
- What exists → [[project_brain/library/library_index]]
- Next action → [[project_brain/next_step]]
- Memory from past sessions → [[project_brain/memory/MEMORY]]

> Operational files (project root): {{OPERATIONAL_FILES}}
