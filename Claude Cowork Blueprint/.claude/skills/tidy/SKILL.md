---
name: tidy
description: Tidy up project_brain: cut redundancy, prune stale content, split oversized files, fix dead links.
when_to_use: user says "tidy", "clean it up", "trim this", "it's getting messy"; or a living doc grew too big, an index became a wall of text, or the same thing is written in several places
---

Tidy `project_brain/` while keeping the truth intact. Works on the living docs. The `history/` folder stays out; `memory/` gets reconciled against the living docs for accuracy (step 7). For the user's own content (`Vision.md`, `notes/`), confirm before cutting. To see what's costing the most, the built-in `/usage` command breaks cost down by skill, subagent, and MCP server.

1. **Oversized file**: split it (hub and spoke), a lean index plus spokes by topic. Usual suspects: a `library_index` or `plan_*` that became a wall.
2. **Redundancy**: if the same info lives in two places, keep it at the canonical source and replace the copy with a path-style pointer (`[[project_brain/...]]`).
3. **Stale**: content the current state already contradicts. Remove it. Past decisions live in the log.
4. **Bloated index**: one description line per item, keep the prose that helps you find the file.
5. **Dead/orphan link**: sweep with Grep and fix (or run `/fix-links`).
6. **A big `roadmap_log` is normal**: it's the append-only history, leave it. Only the active `roadmap` needs to stay lean.
7. **Reconcile `memory/` against the brain**: over sessions the auto-memory accumulates entries that duplicate the living docs and then drift stale. For each entry:
   - **Already in the brain** (roadmap, plan, library, context, Vision): delete it from memory; the living doc is canonical.
   - **Unique value** (preferences, incidents, gotchas, external pointers) that has since migrated into a living doc: move it to that doc first, then delete it from memory.
   - **Obsolete or superseded**: remove it.
   Update `MEMORY.md` so the index matches what's left. Leave the memory format (basename cross-links) as is; reconcile content only.

At the end, recap what you cut and why. When unsure whether to cut, ask. Prefer keeping the truth: bloat is easy to trim again, lost truth is gone.
