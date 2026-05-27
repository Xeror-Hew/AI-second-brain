---
name: end
description: Safety-net sweep at session close: catch up the map, log, roadmap, next step, and dead links that per-task closes missed.
when_to_use: user says "end", "wrap up", "we're stopping", "that's it for today", or closes out the day's work
---

Per-task `/done` closes should already have done most of this. This is the safety net at session close: catch whatever slipped, in order:

1. **Map**: update `project_brain/work_map/` to reflect the session's changes (index plus affected fragments).
2. **Log**: record finished items and changes in `project_brain/roadmap/roadmap_log.md` (one line each plus the file touched). Append only.
3. **Roadmap**: prune `project_brain/roadmap/roadmap.md`. Drop finished and obsolete items. The active list only holds real open work.
4. **Next step**: overwrite `project_brain/next_step.md` with the next item.
5. **Links**: sweep dead and orphan links across the living docs with Grep and fix them (index plus path-style description).
6. **Recap**: close with two lines, what changed and what's next.

Works on the living docs in `project_brain/`. The `history/` and `memory/` folders stay out.
