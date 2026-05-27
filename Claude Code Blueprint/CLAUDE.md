# {{PROJECT_NAME}}

{{PROJECT_DESCRIPTION}}.

> 📖 **Start here**: [[project_brain/plan/plan_summary]] (the AI's technical plan, overview plus pointers) and [[project_brain/next_step]] (the concrete next action).

---

## Workflow rules

1. **≥95% before acting.** Before any change (`Edit` / `Write` / `Bash` with effect), make sure you have enough context to be 95%+ sure of the result. Short of that, use `AskUserQuestion`. Discovery (`Read` / `Grep` / `Glob`) is always fine; hold mutation to the 95% bar.

2. **Subagents in parallel.** 2+ independent tasks, dispatch them in parallel in one turn. `Explore` for targeted search, `general-purpose` for broad investigation, specialized agents when they fit. Go sequential only on a real dependency.

3. **Skills first.** If a task falls in a listed skill's scope, invoke it before improvising. When unsure, invoke and drop it if it doesn't fit.

4. **Verify before calling it done.** Run the command, read the output, confirm. No evidence means not done.

5. **Catch bugs in passing.** Spot a latent problem on the way? Report it and propose a fix, even out of scope.

6. **Always optimize.** Shortest path, more parallel, less code. Keep abstraction to what the task needs.

7. **Check before you assert.** Read the code or doc that already exists before saying how a system works or changing it. When unsure, go to the source.

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

8. **End of each session**: update `code_map/` to match the code after the changes, and sweep dead/orphan links in the living docs. _(procedure: `/end`.)_ A **structural code change** (new module, refactor, moved file) updates the map on the spot, ahead of the session end _(`/map`)_.

9. **Path-style wikilinks**, always `[[project_brain/path/file]]` (vault-relative, no extension). The visible text is the path: clickable for the human, one hop for the AI. **Exception: `memory/`** (see rule 13).

10. **Link upkeep is the AI's job.** When you create/rename/remove a doc: update the right index (path-style wikilink plus a one-line description) and fix the links that pointed at the file. Keep the user out of manual link upkeep. _(procedure: `/fix-links`.)_

11. **Hub and spoke, not a dense web.** The index (hub) points to the files (spokes); each file points back to its index. Files don't cross-link densely. The AI navigates through the hub, not through chains of links.

12. **What the AI needs to read has to be real text.** It sees transclusion (`![[file]]`) and `dataview` blocks as raw syntax. Any index or table the AI uses is static text.

13. **`memory/` belongs to the harness (auto-memory), it follows its own format, not rule 9.** Linked by a *junction* (setup wires it). Inside it: `MEMORY.md` uses `[Title](file.md)`, and cross-links use the full file basename `[[type_slug]]` (e.g. `[[feedback_estilo]]`). Obsidian resolves a wikilink against the filename, so the label must match the file exactly, `type_` prefix included.

---

## Skills / commands

> They live in `.claude/skills/`. You type `/name`; the AI also fires them on its own when the context matches (`when_to_use`). The skills carry the detailed procedure. The rules above are the short baseline, always in effect even if a skill doesn't fire.

**Rituals (you trigger, or the AI when it recognizes the moment):**
- `/setup`: onboarding. Installs the blueprint fresh, or upgrades it in place when you drop a newer version.
- `/start`: read-only orientation. Where we stopped plus the next step.
- `/done`: finished a task. Log it, prune the roadmap, set the next step.
- `/end`: end of session. Map, log, roadmap, next_step, link sweep.
- `/remember`: save a memory in the right format plus index it.
- `/map`: (re)build the code map.
- `/writeplan`: derive or update `plan/` from [[project_brain/Vision]].
- `/debloat`: trim `project_brain/`. Cut redundancy, prune stale, fragment big files, fix links.

**Automatic (the AI fires these itself, you don't call them):**
- `check-map`: check the map before touching unfamiliar code.
- `check-plan`: check the technical plan before changing architecture or a settled decision.
- `fix-links`: when you create/rename/remove a doc, fix the index plus links.

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
