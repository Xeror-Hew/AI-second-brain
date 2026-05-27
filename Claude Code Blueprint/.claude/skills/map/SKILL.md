---
name: map
description: (Re)build the code map in code_map/ from the current state of the repo.
when_to_use: user says "map", "update the map", "code map"; when no map exists and the AI needs the project's structure; or right after a STRUCTURAL code change (new module, refactor, moved/renamed file, changed flow), on the spot
---

Build or update the **descriptive** map: how the code works today. (Future direction lives in `plan/`.)

**Two levels:**
- `map_index`: lean, the entry point. One-paragraph overview, the top-level journey, and the fragment table (path-style pointer plus a one-line description). It's the router.
- Fragments `map_<module>.md`: detail per module or subsystem, read on demand.

**Steps:**
1. Explore the code (Glob/Grep/Read) to understand modules and flows.
2. Update `project_brain/code_map/map_index.md`: the paragraph, the journey, the fragment table.
3. Create a fragment `map_<module>.md` per part that stands on its own (granularity is the subsystem, group the small stuff together).
4. Keep the table descriptions specific. That's what lets you find the right part without opening everything.
5. Cite code as `path:line` when it helps. Path-style links; `/fix-links` covers the hygiene.
