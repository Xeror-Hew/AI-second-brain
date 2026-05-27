---
name: end
description: End-of-session ritual: update the map, log, roadmap, next step, and sweep dead links.
when_to_use: user says "end", "wrap up", "we're stopping", "that's it for today", or closes out the day's work
---

Run the end-of-session ritual, in order:

1. **Map**: update `project_brain/code_map/` to reflect the session's code changes (index plus affected fragments).
2. **Log**: record finished items and changes in `project_brain/roadmap/roadmap_log.md` (one line each plus hash). Append only.
3. **Roadmap**: prune `project_brain/roadmap/roadmap.md`. Drop finished and obsolete items. The active list only holds real open work.
4. **Next step**: overwrite `project_brain/next_step.md` with the next item.
5. **Links**: sweep dead and orphan links across the living docs with Grep and fix them (index plus path-style description).
6. **Recap**: close with two lines, what changed and what's next.

Works on the living docs in `project_brain/`. The `history/` and `memory/` folders stay out.
