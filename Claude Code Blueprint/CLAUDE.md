# {{PROJECT_NAME}}

{{PROJECT_DESCRIPTION}}.

> 📖 **Start here**: [[project_brain/plan/plan_summary]] (the AI's technical plan, overview plus pointers) and [[project_brain/next_step]] (the concrete next action).

> 🧠 **Shared brain.** `Vision` and `notes/` are the user's mind; `plan/`, `roadmap/`, `code_map/`, and `next_step` are yours. Keep your reasoning written where the user can see it, and read theirs, so the two read as one.

---

## Workflow rules

1. **≥95% before acting.** Before any change (`Edit` / `Write` / `Bash` with effect), make sure you have enough context to be 95%+ sure of the result. Short of that, use `AskUserQuestion`. Discovery (`Read` / `Grep` / `Glob`) is always fine; hold mutation to the 95% bar.

2. **Subagents in parallel.** 2+ independent tasks, dispatch them in parallel in one turn. `Explore` for targeted search, `general-purpose` for broad investigation, specialized agents when they fit. Go sequential only on a real dependency.

3. **Skills first.** If a task falls in a listed skill's scope, invoke it before improvising. When unsure, invoke and drop it if it doesn't fit.

4. **Verify before calling it done.** Run the command, read the output, confirm. No evidence means not done.

5. **Catch bugs in passing.** Spot a latent problem on the way? Report it and propose a fix, even out of scope.

6. **Always optimize.** Shortest path, more parallel, less code. Keep abstraction to what the task needs.

7. **Check before you assert.** Read the code or doc that already exists before saying how a system works or changing it. When unsure, go to the source.

8. **No AI attribution on commits or PRs, in any project, ever.** No `Co-Authored-By` line, no "Generated with" footer, no AI co-author. The commit path is enforced deterministically (setup installs a `commit-msg` hook that strips such trailers, `settings.json` turns Claude Code's own attribution off, and a guard blocks `--no-verify`); commit normally and never reach for `--no-verify`/`-n`. Git can't hook a PR body, so write none yourself there.

9. **Keep the cache warm.** Session cost is dominated by prompt-cache reuse. Pin model, effort, and MCP servers at the start; switching mid-session re-bills the whole context. Treat `CLAUDE.md` as frozen during a session (it's read once at start); anything that changes goes in `project_brain/`, read on demand, cache-safe. Compact only at task boundaries. Send verbose discovery to a subagent so it stays out of the main thread (keeping the prefix cached), and run cheap high-volume passes on a smaller model.

10. **Push back, don't flatter.** Skip performative agreement; when something is off, say so with the technical reason. State confirmed-good and confirmed-wrong both plainly.

---

## Doc rules

1. **Minimal structure** in `project_brain/`:
   - [[project_brain/Vision]]: the user's vision.
   - `plan/`: the AI's technical plan (index, summary, why, tech). See [[project_brain/plan/plan_index]].
   - `roadmap/`: checklist plus log. See [[project_brain/roadmap/roadmap_index]].
   - [[project_brain/next_step]]: **one item**, overwritten on each completion.
   - `code_map/`: current state of the code (index plus fragments). See [[project_brain/code_map/map_index]].
   - `history/`: old versions, automatic snapshots. The AI never reads it.
   - `memory/`: persistent auto-memory across sessions (harness-managed, see rule 13).
   - `notes/`: the user's note/idea space (the AI reads it only when asked, out of the snapshot).

2. **Living files carry no date in the name.** Stable names, edited in place. If a date matters it lives in the content (frontmatter or title), so links never break and the index never churns.

3. **Versioning is automatic** (canonical rule, point here if you need it elsewhere). The hook `.claude/hooks/snapshot.*` freezes the "before" of each living file into `history/<file>/` ahead of an edit (one per file every ~20 min). Nobody moves anything by hand. Full detail: the comments in `.claude/hooks/snapshot.*`.

4. **The live truth is always in the current file.** `history/` holds the automatic snapshots, the user's safety net, out of the AI's workflow.

5. **Every code change** = one line in [[project_brain/roadmap/roadmap_log]] (with hash) plus an update to [[project_brain/roadmap/roadmap]]. Finished items leave the active list, obsolete ones get removed. How it works: [[project_brain/roadmap/roadmap_index]]. _(procedure: `/done`.)_

6. **A change in the technical plan (`plan/`)** means updating [[project_brain/roadmap/roadmap]] the same session.

7. **Next step is always one item.** Done? **Overwrite** [[project_brain/next_step]] with the next one. No history here, just the active item.

8. **Close out each task as you finish it, while the context is fresh.** The moment a task is done, run `/done`: log it, prune the roadmap, set the next step, and update `code_map/` if the code's shape changed. A **structural code change** updates the map on the spot _(`/map`)_, even mid-task. `/end` is the safety net at session close, sweeping the map and dead/orphan links for anything a task close missed. Waiting for session end loses the context that made the change clear.

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
- `/done`: close out a finished task on the spot. Log it, prune the roadmap, update the map if the structure changed, set the next step, finish the branch when one is ready.
- `/end`: safety-net sweep at session close. Map, log, roadmap, next_step, dead links, catching whatever a task close missed.
- `/remember`: save a memory in the right format plus index it.
- `/writeplan`: derive `plan/` from [[project_brain/Vision]], or turn an approved spec into a bite-sized implementation plan.
- `/brainstorm`: explore intent and design before building; write the spec into `plan/`, then hand to `/writeplan`.
- `/debloat`: trim `project_brain/`. Cut redundancy, prune stale, fragment big files, fix links.

**Code engine** (the execution discipline):
- `/tdd`: red-green-refactor; no production code without a failing test first.
- `/diagnose`: root-cause investigation before any fix.
- `/critique`: request a code review (reviewer subagent) and receive one with technical rigor.
- `/execute`: run a written plan from `plan/`, subagent-driven or inline with checkpoints.
- `/worktree`: isolate feature work in a git worktree (native tool first).
- `/writeskill`: author or edit a skill, tested before it ships.
- `/map`: (re)build the code map.

**Automatic (the AI fires these itself, you don't call them):**
- `check-map`: check the map before touching unfamiliar code.
- `check-plan`: check the technical plan before changing architecture or a settled decision.
- `fix-links`: when you create/rename/remove a doc, fix the index plus links.

---

## Engine: one system

The code-engine skills are the blueprint's own, vendored from [superpowers](https://github.com/obra/superpowers) (MIT, by Jesse Vincent; credit in `.claude/NOTICE.md`). There is no separate plugin to install and nothing to wire: the brain and the execution engine ship as one, and `settings.json` turns the external superpowers plugin off for this project (if it is installed globally) so the forked skills are not duplicated and the session injection is not doubled. `CLAUDE.md` outranks any skill, so trivial work skips the heavy gates. These rules settle the overlaps:

- **Plan → execute**: `/brainstorm` writes a design spec into `plan/`; `/writeplan` turns it into a bite-sized task-list (or derives the project plan from `Vision`); `/execute` runs it; `/done` logs what shipped with the hash. Run `/brainstorm` on a real feature, skip it on mechanical work.
- **Build discipline**: `/tdd` and `/diagnose` compose unchanged. `/critique` runs before the integration decision; `/done` records the result.
- **Finish**: `/done` (per task) and `/end` (session) own both the brain upkeep and the merge/PR/keep decision. On a docs-only or test-less project, skip the test gate and make the call directly.
- **Two groups, one seam**: brain core (orient, plan, remember, finish) works on any project; the code engine (`/tdd /diagnose /critique /execute /worktree /map /writeskill`) is the part a non-code variant would swap. Fire a skill when it fits the moment; rules 1 (≥95% then act) and 9 (keep the cache warm) hold throughout.

---

## Project context

> Project-specific config lives outside this file, to keep `CLAUDE.md` lean:
- [[project_brain/context]]: stack/environment, principles (priority on conflict), specific rules, commit policy.

---

## Navigation: where things are

- User's vision → [[project_brain/Vision]]
- Technical plan → [[project_brain/plan/plan_index]] (entry: [[project_brain/plan/plan_summary]])
- Checklist / what's left → [[project_brain/roadmap/roadmap]]
- Code state → [[project_brain/code_map/map_index]]
- Next action → [[project_brain/next_step]]
- Memory from past sessions → [[project_brain/memory/MEMORY]]

> Operational files (project root): {{OPERATIONAL_FILES}}
