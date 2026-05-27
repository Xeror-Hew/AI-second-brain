# {{PROJECT_NAME}}

{{PROJECT_DESCRIPTION}}.

> 📖 **Start here**: [[project_brain/plan/plan_summary]] (the AI's plan, overview plus pointers) and [[project_brain/next_step]] (the concrete next action).

---

## Workflow rules

1. **≥95% before acting.** Before any change (`Edit` / `Write` / `Bash` with effect), make sure you have enough context to be 95%+ sure of the result. Short of that, use `AskUserQuestion`. Discovery (`Read` / `Grep` / `Glob`) is always fine; hold mutation to the 95% bar.

2. **Subagents in parallel.** 2+ independent tasks, dispatch them in parallel in one turn. `Explore` for targeted search, `general-purpose` for broad investigation, specialized agents when they fit. Go sequential only on a real dependency.

3. **Skills first.** If a task falls in a listed skill's scope, invoke it before improvising. When unsure, invoke and drop it if it doesn't fit.

4. **Verify before calling it done.** Run the command, read the output, confirm. No evidence means not done.

5. **Catch problems in passing.** Spot a latent issue on the way? Report it and propose a fix, even out of scope.

6. **Always optimize.** Shortest path, more parallel, less work. Keep abstraction to what the task needs.

7. **Check before you assert.** Read the doc or file that already exists before saying how something works or changing it. When unsure, go to the source.

---

## Doc rules

1. **Minimal structure** in `project_brain/`:
   - [[project_brain/Vision]]: the user's vision.
   - `plan/`: the AI's plan (index, summary, why, how). See [[project_brain/plan/plan_index]].
   - `roadmap/`: checklist plus log. See [[project_brain/roadmap/roadmap_index]].
   - [[project_brain/next_step]]: **one item**, overwritten on each completion.
   - `work_map/`: current state of the work (index plus fragments): the deliverables and where they live. See [[project_brain/work_map/map_index]].
   - `history/`: old versions, automatic snapshots. The AI never reads it.
   - `memory/`: persistent auto-memory across sessions (see rule 13).
   - `notes/`: the user's note/idea space (the AI reads it only when asked, out of the snapshot).

2. **Living files carry no date in the name.** Stable names, edited in place. If a date matters it lives in the content (frontmatter or title), so links never break and the index never churns.

3. **Versioning is automatic, by surface** (canonical rule, point here if you need it elsewhere). Before a living file is edited, its "before" is frozen into `history/<file>/` (one per file every ~20 min). Two paths, same result:
   - **Claude Code CLI / Claudian** (hooks available): the hook `.claude/hooks/snapshot.*` does it on its own.
   - **Claude Cowork** (no hooks): the `snapshot` skill does it. It reads `CLAUDE_CODE_IS_COWORK` from the environment; when set, it freezes the "before" before editing a living doc.

   Both write the same `history/<file>/<file> YYYY-MM-DDTHH-mm-ss.md` with the same ~20 min cooldown, so the same folder works across surfaces and never double-snapshots. Full detail: comments in `.claude/hooks/snapshot.*` and the `snapshot` skill.

4. **The live truth is always in the current file.** `history/` holds the automatic snapshots, the user's safety net, out of the AI's workflow.

5. **Every change to a deliverable** = one line in [[project_brain/roadmap/roadmap_log]] (date plus the file touched) plus an update to [[project_brain/roadmap/roadmap]]. Finished items leave the active list, obsolete ones get removed. How it works: [[project_brain/roadmap/roadmap_index]]. _(procedure: `/done`.)_

6. **A change in the plan (`plan/`)** means updating [[project_brain/roadmap/roadmap]] the same session.

7. **Next step is always one item.** Done? **Overwrite** [[project_brain/next_step]] with the next one. No history here, just the active item.

8. **Close out each task as you finish it, while the context is fresh.** The moment a task is done, run `/done`: log it, prune the roadmap, set the next step, and update `work_map/` if the shape of the work changed. A **structural change** (new deliverable, reorganized folders, a new workstream) updates the map on the spot _(`/map`)_, even mid-task. `/end` is the safety net at session close, sweeping the map and dead/orphan links for anything a task close missed. Waiting for session end loses the context that made the change clear.

9. **Path-style wikilinks**, always `[[project_brain/path/file]]` (vault-relative, no extension). The visible text is the path: clickable for the human, one hop for the AI. **Exception: `memory/`** (see rule 13).

10. **Link upkeep is the AI's job.** When you create/rename/remove a doc: update the right index (path-style wikilink plus a one-line description) and fix the links that pointed at the file. Keep the user out of manual link upkeep. _(procedure: `/fix-links`.)_

11. **Hub and spoke, not a dense web.** The index (hub) points to the files (spokes); each file points back to its index. Files don't cross-link densely. The AI navigates through the hub, not through chains of links.

12. **What the AI needs to read has to be real text.** It sees transclusion (`![[file]]`) and `dataview` blocks as raw syntax. Any index or table the AI uses is static text.

13. **`memory/` belongs to the auto-memory, it follows its own format, not rule 9.** On Claude Code CLI / Claudian, setup wires it with a *junction*; on Claude Cowork it lives as files the AI reads each session. Inside it: `MEMORY.md` uses `[Title](file.md)`, and cross-links use the full file basename `[[type_slug]]` (e.g. `[[feedback_estilo]]`). Obsidian resolves a wikilink against the filename, so the label must match the file exactly, `type_` prefix included.

---

## Skills / commands

> They live in `.claude/skills/`. You type `/name`; the AI also fires them on its own when the context matches (`when_to_use`). The skills carry the detailed procedure. The rules above are the short baseline, always in effect even if a skill doesn't fire.

**Rituals (you trigger, or the AI when it recognizes the moment):**
- `/setup`: onboarding. Installs the blueprint fresh, or upgrades it in place when you drop a newer version.
- `/start`: read-only orientation. Where we stopped plus the next step.
- `/done`: close out a finished task on the spot. Log it, prune the roadmap, update the map if the structure changed, set the next step.
- `/end`: safety-net sweep at session close. Map, log, roadmap, next_step, dead links, catching whatever a task close missed.
- `/remember`: save a memory in the right format plus index it.
- `/map`: (re)build the work map.
- `/writeplan`: derive or update `plan/` from [[project_brain/Vision]].
- `/debloat`: trim `project_brain/`. Cut redundancy, prune stale, fragment big files, fix links.

**Automatic (the AI fires these itself, you don't call them):**
- `snapshot`: on Claude Cowork (no hooks), freeze the "before" of a living doc before editing it. On Claude Code CLI / Claudian the hook does this instead.
- `check-work-map`: check the work map before touching an unfamiliar part of the work.
- `check-plan`: check the plan before changing direction or a settled decision.
- `fix-links`: when you create/rename/remove a doc, fix the index plus links.

---

## Project context

> Project-specific config lives outside this file, to keep `CLAUDE.md` lean:
- [[project_brain/context]]: tools/environment, principles (priority on conflict), specific rules, change policy.

---

## Navigation: where things are

- User's vision → [[project_brain/Vision]]
- The plan → [[project_brain/plan/plan_index]] (entry: [[project_brain/plan/plan_summary]])
- Checklist / what's left → [[project_brain/roadmap/roadmap]]
- State of the work → [[project_brain/work_map/map_index]]
- Next action → [[project_brain/next_step]]
- Memory from past sessions → [[project_brain/memory/MEMORY]]

> Operational files (project root): {{OPERATIONAL_FILES}}
