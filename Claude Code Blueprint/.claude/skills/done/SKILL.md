---
name: done
description: Close out a finished task: log it, prune the active roadmap, set the next step.
when_to_use: user says "done", "finished", "ship it", "that's closed", or right after a roadmap task is completed
---

A task just got finished. Do the bookkeeping, in order:

1. Add one line to `project_brain/roadmap/roadmap_log.md`: `{{date}}: {{what got done}} ({{commit hash if any}})`. Append only.
2. Remove the finished item from `project_brain/roadmap/roadmap.md`. The active list only holds open work.
3. Overwrite `project_brain/next_step.md` with the next item (short context plus how to validate).
4. Confirm in one line what closed and what's next.

For the full end-of-session ritual (map, links, everything), use `/end`.
