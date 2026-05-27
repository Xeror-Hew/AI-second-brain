---
name: debloat
description: Trim project_brain: cut redundancy, prune stale content, fragment oversized files, fix dead links.
when_to_use: user says "debloat", "trim this", "clean it up", "it's bloated"; or a living doc grew too big, an index became a wall of text, or content is repeated across files
---

Trim `project_brain/` while keeping the truth intact. Works on the living docs. The `history/` folder stays out; `memory/` gets reconciled against the living docs for accuracy (step 7). For user content (`Vision.md`, `notes/`), confirm before cutting.

1. **Oversized file**: fragment it (hub and spoke), a lean index plus spokes by topic. Usual suspects: a `map_index` or `plan_*` that became a wall.
2. **Redundancy**: if the same info lives in two places, keep it at the canonical source and replace the copy with a path-style pointer (`[[project_brain/...]]`).
3. **Stale**: content the current state already contradicts. Remove it. Historical decisions live in the log.
4. **Bloated index**: one description line per item, keep the prose that helps the AI find the file.
5. **Dead/orphan link**: sweep with Grep and fix (or run `/fix-links`).
6. **A big `roadmap_log` is normal**: it's the append-only history, leave it. Only the active `roadmap` needs to stay lean.
7. **Reconcile `memory/` against the second brain**: over sessions the auto-memory accumulates entries that duplicate the living docs and then drift stale. For each entry:
   - **Already in the second brain** (roadmap, plan, code_map, context, Vision): delete it from memory; the living doc is canonical.
   - **Unique value** (preferences, incidents, environment gotchas, external pointers) that has since migrated into a living doc: move it to that doc first, then delete it from memory.
   - **Obsolete or superseded**: remove it.
   Update `MEMORY.md` so the index matches what's left. Leave the memory format (basename cross-links) as is; reconcile content only.

At the end, recap what you cut and why. When unsure whether to cut, ask. Prefer keeping the truth: bloat is easy to trim again, lost truth is gone.
