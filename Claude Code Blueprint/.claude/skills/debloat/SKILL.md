---
name: debloat
description: Trim project_brain: cut redundancy, prune stale content, fragment oversized files, fix dead links.
when_to_use: user says "debloat", "trim this", "clean it up", "it's bloated"; or a living doc grew too big, an index became a wall of text, or content is repeated across files
---

Trim `project_brain/` while keeping the truth intact. Works on the living docs. The `history/` and `memory/` folders stay out. For user content (`Vision.md`, `ideas/`), confirm before cutting.

1. **Oversized file**: fragment it (hub and spoke), a lean index plus spokes by topic. Usual suspects: a `map_index` or `plan_*` that became a wall.
2. **Redundancy**: if the same info lives in two places, keep it at the canonical source and replace the copy with a path-style pointer (`[[project_brain/...]]`).
3. **Stale**: content the current state already contradicts. Remove it. Historical decisions live in the log.
4. **Bloated index**: one description line per item, cut prose that doesn't help the AI find the file.
5. **Dead/orphan link**: sweep with Grep and fix (or run `/fix-links`).
6. **A big `roadmap_log` is normal**: it's the append-only history, leave it. Only the active `roadmap` needs to stay lean.

At the end, recap what you cut and why. When unsure whether to cut, ask. Bloat comes back, lost truth doesn't.
