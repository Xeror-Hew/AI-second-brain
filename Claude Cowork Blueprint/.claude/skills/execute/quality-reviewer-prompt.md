# Quality Reviewer Prompt Template

Use this template when dispatching a quality reviewer subagent.

**Purpose:** Verify the deliverable is well-made (clear, supported, ready to share)

**Only dispatch after the brief-match review passes.**

```
Task tool (general-purpose):
  Use template at ../critique/reviewer.md
  Brief-match was already verified in the prior pass — skip the brief-alignment section and focus on quality: substance, structure, clarity, and support.

  DESCRIPTION: [task summary, from implementer's report]
  REQUIREMENTS: Task N from [plan-file]
  TARGET: [the deliverable file path(s) produced for this task]
```

**In addition to the standard quality concerns, the reviewer should check:**
- Does each file cover one clear thing?
- Is the deliverable following the structure from the plan?
- Did this task create files that are already overlong, or significantly grow existing ones? (Don't flag pre-existing length — focus on what this task added.)
- Are new claims supported, with a source where it matters?

**Reviewer returns:** Strengths, Issues (Critical/Important/Minor), Assessment
