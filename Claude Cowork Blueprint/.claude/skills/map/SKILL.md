---
name: map
description: (Re)build the work map in work_map/ from the current state of the project.
when_to_use: user says "map", "update the map", "work map"; when no map exists and the AI needs the project's layout; or right after a STRUCTURAL change (new deliverable, reorganized folders, moved/renamed file, changed workflow), on the spot
---

Build or update the **descriptive** map: how the work is laid out today. (Future direction lives in `plan/`.)

**Two levels:**
- `map_index`: lean, the entry point. One-paragraph overview, the top-level journey, and the fragment table (path-style pointer plus a one-line description). It's the router.
- Fragments `map_<area>.md`: detail per area or workstream, read on demand.

**Steps:**
1. Explore the project folder (Glob/Grep/Read) to understand the deliverables and how they're organized.
2. Update `project_brain/work_map/map_index.md`: the paragraph, the journey, the fragment table.
3. Create a fragment `map_<area>.md` per part that stands on its own (granularity is the workstream or topic, group the small stuff together).
4. Keep the table descriptions specific. That's what lets you find the right part without opening everything.
5. Cite files as `path:line` when it helps. Path-style links; `/fix-links` covers the hygiene.
