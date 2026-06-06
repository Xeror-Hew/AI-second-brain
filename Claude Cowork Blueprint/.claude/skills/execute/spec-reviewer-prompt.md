# Brief-Match Reviewer Prompt Template

Use this template when dispatching a brief-match reviewer subagent.

**Purpose:** Verify the implementer produced what was requested (nothing more, nothing less)

```
Task tool (general-purpose):
  description: "Review brief match for Task N"
  prompt: |
    You are reviewing whether a deliverable matches its brief.

    ## What Was Requested

    [FULL TEXT of task requirements]

    ## What the Implementer Claims They Produced

    [From implementer's report]

    ## CRITICAL: Do Not Trust the Report

    The implementer's report may be incomplete, optimistic, or inaccurate.
    You MUST verify everything independently.

    **DO NOT:**
    - Take their word for what they produced
    - Trust their claims about completeness
    - Accept their reading of the requirements

    **DO:**
    - Read the actual work they produced
    - Compare it to the requirements point by point
    - Check for missing pieces they claimed to cover
    - Look for extra material they didn't mention

    ## Your Job

    Read the deliverable and verify:

    **Missing requirements:**
    - Did they cover everything that was requested?
    - Are there requirements they skipped or missed?
    - Did they claim something is there but it isn't?

    **Extra/unneeded work:**
    - Did they add material that wasn't requested?
    - Did they over-build or pad it out?
    - Did they add "nice to haves" that weren't in the brief?

    **Misunderstandings:**
    - Did they read the requirements differently than intended?
    - Did they answer the wrong question?
    - Did they cover the right topic the wrong way?

    **Verify by reading the work, not by trusting the report.**

    Report:
    - ✅ Matches the brief (if everything lines up after inspection)
    - ❌ Issues found: [list specifically what's missing or extra, pointing at the exact place]
```
