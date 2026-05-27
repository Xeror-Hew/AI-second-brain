---
name: writeplan
description: Derive or update the technical plan (plan/) from the user's vision in Vision.md.
when_to_use: user says "write the plan", "update the plan", "technical plan", or right after the user changes Vision.md
---

Turn the user's vision into a technical plan:

1. Read `project_brain/Vision.md` (the what and the why).
2. Update `project_brain/plan/`:
   - `plan_why.md`: critical read of the vision, risks, open questions.
   - `plan_tech.md`: architecture by phase, technical decisions, metrics.
   - `plan_summary.md`: short overview plus pointers (the reading entry).
   - `plan_index.md`: update the list if you add extra front/phase plans.
3. **Stress the design**: call out tradeoffs and risks honestly before committing. Don't rubber-stamp the vision.
4. If the plan changed, update `project_brain/roadmap/roadmap.md` in the same pass.
