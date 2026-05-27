---
name: done
description: Close out a finished task: log it, prune the active roadmap, set the next step.
when_to_use: user says "done", "finished", "ship it", "that's closed"; the AI fires it on its own the moment a task or roadmap item is finished, before moving to the next one
---

A task just got finished. Close it out now, while you still hold the context, in order:

1. Add one line to `project_brain/roadmap/roadmap_log.md`: `{{date}}: {{what got done}} ({{commit hash if any}})`. Append only.
2. Remove the finished item from `project_brain/roadmap/roadmap.md`. The active list only holds open work.
3. **Map**: if the task changed the code's shape (new module, moved/renamed file, changed flow), update `project_brain/code_map/` now (skill `/map`) while it's fresh. A small change with no structural impact: skip.
4. Overwrite `project_brain/next_step.md` with the next item (short context plus how to validate).
5. Confirm in one line what closed and what's next.

Closing out here, per task, is what keeps the truth aligned while the context is hot. `/end` is the safety net at session close for whatever slipped.
