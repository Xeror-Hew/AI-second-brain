---
name: library
description: (Re)build the library index in library/ from the deliverables this project holds.
when_to_use: user says "library", "update the library", "index my work", "what do we have"; when no library exists and the AI needs to know what already exists; or right after you produce or substantially reshape a deliverable, on the spot
---

Build or update the **library**: the inventory of finished work this project holds, so you know what exists before producing something new (and never duplicate or contradict it). (Where the work is going lives in `plan/`; the lay of the workspace lives in `work_map/`.)

**Two levels:**
- `library_index`: lean, the entry point. One-paragraph overview of the body of work, and the table of deliverables (path-style pointer plus a one-line description of each). It's the router.
- Fragments `library_<area>.md`: detail for an area that holds many pieces, read on demand. Small areas group together.

**Steps:**
1. Scan the vault (Glob/Read) for the deliverables: the finished documents, briefs, decks, analyses. Skip `project_brain/`, `.obsidian/`, and scratch in `notes/`.
2. Update `project_brain/library/library_index.md`: the overview paragraph and the deliverable table.
3. Create a fragment `library_<area>.md` per area that stands on its own (granularity is the area or theme, group the small stuff together).
4. Keep the table descriptions specific. That's what lets you find the right piece without opening everything.
5. Path-style links; `/fix-links` covers the hygiene.
