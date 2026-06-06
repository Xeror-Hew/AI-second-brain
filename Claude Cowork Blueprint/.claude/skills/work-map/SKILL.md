---
name: work-map
description: (Re)build the work map in work_map/ from the current shape of your workspace and materials.
when_to_use: user says "map my work", "work map", "what's in here"; when no map exists and the AI needs the lay of the workspace; or right after the workspace's shape changes (new area, big reorganization, moved or renamed material), on the spot
---

Build or update the **descriptive** map: how the workspace is laid out today, the territory you work in. (Where the work is going lives in `plan/`; the finished pieces are inventoried in `library/`.)

**Two levels:**
- `work_map_index`: lean, the entry point. One-paragraph overview, the typical workflow at a high level, and the fragment table (path-style pointer plus a one-line description). It's the router.
- Fragments `work_map_<area>.md`: detail per area or theme, read on demand. Small areas group together.

**Steps:**
1. Look through the workspace (Glob/Read) to understand the areas, materials, and sources, and how work moves through them.
2. Update `project_brain/work_map/work_map_index.md`: the paragraph, the workflow, the fragment table.
3. Create a fragment `work_map_<area>.md` per area that stands on its own (granularity is the area, group the small stuff together).
4. Keep the table descriptions specific. That's what lets you find the right area without opening everything.
5. Path-style links; `/fix-links` covers the hygiene.
