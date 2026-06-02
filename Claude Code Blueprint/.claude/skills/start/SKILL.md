---
name: start
description: Read-only orientation at the start of a session. Tells you where the work stopped, touches nothing.
when_to_use: user says "start", "hi", "where were we", "catch me up", "status", or resumes work after a break
disallowed-tools: Edit, Write, Bash
---

Get oriented, read-only. This is the cheap retrieval step: rebuild context from a few high-signal docs instead of re-exploring the repo. Read in this order, stopping once you have enough:

1. `project_brain/next_step.md` for the active item.
2. `project_brain/roadmap/roadmap.md` for the current front and blockers.
3. For technical context: `project_brain/plan/plan_summary.md`.
4. Before touching code: `project_brain/code_map/map_index.md`.

Pin the model, effort, and MCP servers for the session now; switching any of them later re-bills the whole cached context. Opus 4.8 defaults to high effort; reach for `/effort xhigh` on the hardest agentic work and step down to medium/low for trivial passes.

Give the user a short recap: where we stopped, the next step, blockers if any. Stay read-only; this is orientation.
