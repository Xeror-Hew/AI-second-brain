---
name: remember
description: Save a persistent memory in the right format and update the MEMORY.md index.
when_to_use: user says "remember this", "note that", "don't forget", or a fact/preference/decision worth keeping for future sessions comes up
---

Save a memory in `project_brain/memory/` (your persistent memory across sessions):

1. **Type**: pick **user** (who they are, how to collaborate), **feedback** (a correction or a confirmed approach), **project** (a decision, deadline, or context not derivable from the work), or **reference** (a pointer to an external system).
2. **File**: create it from `_TEMPLATE_<type>.md` as `<type>_<slug>.md`, with frontmatter (`name`, `description`, `type`) and a body (feedback/project carry **Why** and **How to apply**).
3. **Index**: add one line to `project_brain/memory/MEMORY.md`: `[Title](file.md): one-line hook`.
4. **Cross-links** between memories use the full file basename `[[type_slug]]` (e.g. `[[feedback_estilo]]`). Obsidian resolves a wikilink against the filename, so it has to match the file exactly, including the `type_` prefix.

Save what isn't in the files: decisions, preferences, context, pointers to external systems. (Layout, structure, and file history the AI rediscovers by reading the project folder.)
