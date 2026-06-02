---
name: writeplan
description: Derive or update the technical plan (plan/) from Vision, or turn an approved spec into a bite-sized implementation plan.
when_to_use: user says "write the plan", "update the plan", "technical plan"; right after Vision.md changes; or after /brainstorm approves a spec and you need an execution task-list
---

Two jobs, one home: `project_brain/plan/`.

## Project plan (from Vision)

1. Read `project_brain/Vision.md` (the what and the why).
2. Update `project_brain/plan/`:
   - `plan_why.md`: critical read of the vision, risks, open questions.
   - `plan_tech.md`: architecture by phase, technical decisions, metrics.
   - `plan_summary.md`: short overview plus pointers (the reading entry).
   - `plan_index.md`: list any extra front/phase plans you add.
3. **Stress the design**: push on the vision, surface tradeoffs and risks honestly before committing.
4. If the plan changed, update `project_brain/roadmap/roadmap.md` in the same pass.

## Execution task-list (from an approved spec)

When `/brainstorm` produced a spec, or the user hands you requirements for a multi-step build, write a bite-sized implementation plan to `project_brain/plan/plan_<feature>.md` and list it in `plan_index.md`.

- **Bite-sized steps** (2-5 min each): write the failing test, run it red, write the minimal code, run it green, commit.
- **Exact and complete**: real file paths, the actual code in every code step, exact commands with their expected output. Banned (these are plan failures): "TBD", "handle edge cases", "similar to Task N", or a reference to a type/function no task defines.
- **One responsibility per file**; files that change together live together.
- **Self-review** before handoff: every spec requirement maps to a task (add the task if one is missing); scan for placeholders; names and signatures stay consistent across tasks.
- Hand off to `/execute`.

Fold a `/brainstorm` spec's conclusions back into `Vision`/`plan` so the brain stays canonical.
