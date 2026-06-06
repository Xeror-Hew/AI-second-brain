---
name: done
description: Close out a finished task: log it, prune the roadmap, set the next step, and update the work map or library when the work changed them.
when_to_use: user says "done", "finished", "that's closed"; the AI fires it the moment a task or roadmap item is finished, before moving on
---

A task just got finished. Close it out now, while you still hold the context, in order:

1. Add one line to `project_brain/roadmap/roadmap_log.md`: `{{date}}: {{what got done}}`. Append only.
2. Remove the finished item from `project_brain/roadmap/roadmap.md`. The active list only holds open work.
3. **Library**: if the task produced or reshaped a deliverable, update `project_brain/library/` now (`/library`) while it's fresh. A small in-place tweak with no new piece: skip.
4. **Work map**: if the workspace's shape changed (new area, big reorganization, moved material), update `project_brain/work_map/` now (`/work-map`). No structural change: skip.
5. Overwrite `project_brain/next_step.md` with the next item (short context plus how to tell it's done).
6. Confirm in one line what closed and what's next.

Closing out here, per task, keeps the truth aligned while the context is hot. `/end` is the safety net at session close.
