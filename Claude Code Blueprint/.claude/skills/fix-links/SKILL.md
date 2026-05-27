---
name: fix-links
description: Keep indexes and wikilinks consistent when you create, rename, or remove a doc.
when_to_use: ALWAYS when you create, rename, or remove a file in project_brain/ (memory, map fragment, plan, doc), in the same pass as the change
---

When you create, rename, or remove a doc in `project_brain/`:

1. **Index**: add or update the pointer in the right index (`map_index`, `plan_index`, `roadmap_index`, or `MEMORY.md`) with a path-style wikilink (`[[project_brain/...]]`) plus a one-line description. The description is what lets the AI find it without opening everything.
2. **Back-links**: if you renamed or removed, fix every link that pointed at the file. Grep to find them.
3. **`memory/` exception**: there the format is the harness's. `MEMORY.md` uses `[Title](file.md)`, and cross-links use the full file basename `[[type_slug]]` (e.g. `[[feedback_estilo]]`). Obsidian resolves the wikilink against the filename, so the label has to match the file exactly, `type_` prefix included.

Keep the user out of manual link upkeep. `/end` does the full sweep at session close; this is the on-the-spot fix.
