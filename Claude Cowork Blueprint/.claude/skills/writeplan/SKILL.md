---
name: writeplan
description: Derive or update the plan (plan/) from Vision, or turn an approved spec into a bite-sized task-list.
when_to_use: user says "write the plan", "update the plan", "plan this"; right after Vision.md changes; or after /brainstorm approves a spec and you need a task-list
---

Two jobs, one home: `project_brain/plan/`.

## Project plan (from Vision)

1. Read `project_brain/Vision.md` (the what and the why).
2. Update `project_brain/plan/`:
   - `plan_why.md`: critical read of the vision, risks, open questions.
   - `plan_tech.md`: the approach by phase, key decisions, how you'll measure success.
   - `plan_summary.md`: short overview plus pointers (the reading entry).
   - `plan_index.md`: list any extra front/phase plans you add.
3. **Stress the design**: push on the vision, surface tradeoffs and risks honestly before committing.
4. If the plan changed, update `project_brain/roadmap/roadmap.md` in the same pass.

## Task-list (from an approved spec)

When `/brainstorm` produced a spec, or the user hands you requirements for a multi-step piece of work, write a bite-sized plan to `project_brain/plan/plan_<topic>.md` and list it in `plan_index.md`.

- **Bite-sized steps** (one sitting each): gather the sources for X, draft this section, revise Y against the brief, check the numbers. Each step is something you can finish and check in one go.
- **Exact and complete**: real file paths, the actual outline or key points for each piece, and a concrete "done when..." for each step. Banned (these are plan failures): "TBD", "handle the rest", "similar to Task N", or a reference to a piece no task defines.
- **One topic per file**; pieces that change together live together.
- **Self-review** before handoff: every spec requirement maps to a task (add the task if one is missing); scan for placeholders; names stay consistent across tasks.
- Hand off to `/execute`.

Fold a `/brainstorm` spec's conclusions back into `Vision`/`plan` so the brain stays canonical.
