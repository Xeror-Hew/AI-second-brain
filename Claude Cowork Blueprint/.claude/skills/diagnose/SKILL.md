---
name: diagnose
description: Use when something isn't working - a plan stalls, a piece keeps getting rejected, a process breaks, a result comes out wrong - before proposing a fix.
when_to_use: user says "why isn't this working", "this keeps failing", "figure out what's wrong"; or the AI fires it on any surprising or repeated failure before suggesting fixes, especially under time pressure or after a fix already missed.
---

# Diagnose

## The Iron Law

```
NO FIXES WITHOUT FINDING THE ROOT CAUSE FIRST
```

Find the real cause before any fix. Treating the symptom is a failure. Until Phase 1 is done, propose no fixes.

This holds even when the problem looks simple, you're in a hurry, or someone wants it fixed now. Systematic beats thrashing.

## The Four Phases

Complete each phase before the next.

### Phase 1: Root cause

1. Read the problem in full: the exact error, the actual feedback, the wrong result. Don't paraphrase it away. The cause is often right there.
2. Reproduce it. Can you make it happen again on purpose? Not reproducible means gather more data, never guess.
3. Check what recently changed: a new input, a different source, a changed step, a new constraint.
4. **Multi-step processes** (research → draft → review → send; intake → analysis → decision): check each step before fixing.
   ```
   For EACH step:
     - Note what goes IN to the step
     - Note what comes OUT
     - Check the handoff to the next step
   Go through once to see WHERE it breaks
   THEN focus on that step
   ```
   One example, a proposal that keeps getting rejected, step by step:
   ```
   Brief:   what did the client actually ask for?
   Draft:   does the draft answer that brief?
   Review:  what did the feedback say each round?
   Send:    did the final version match what was approved?
   ```
   Reveals which step drops the ball (the brief was misread, or an approved change never made it in).
5. Trace it backward to where the problem first enters, and fix it there, not where it shows up.

### Phase 2: Pattern

Find a similar case that worked. Read it completely. List every difference between the working case and the broken one, however small. Note the inputs, assumptions, and conditions involved.

### Phase 3: Hypothesis

State one hypothesis: "X is the cause because Y." Test it with the smallest possible change, one thing at a time. Worked means Phase 4. Didn't means form a new hypothesis; don't stack fixes. When you don't understand something, say so and dig in.

### Phase 4: Fix

1. Set up the smallest reproduction or check you can, so you'll know when it's actually fixed.
2. Make one fix, at the root cause. One change, no "while I'm here" extras.
3. Verify: the problem is gone, and nothing else broke.
4. Fix failed? STOP and count attempts. Under 3, return to Phase 1 with the new information. **At 3+, stop and question the whole approach.**

### Escalation gate: 3+ failed fixes

```
3+ fixes failed  ->  STOP. The approach is wrong, not just the last attempt.
```

Signs: each fix exposes a new problem elsewhere, fixes demand redoing everything, each fix spawns new symptoms. Question the fundamentals: is the approach sound, or are you continuing out of inertia? Discuss with the user before fix #4.

## Quick reference

| Phase | Key activities | Done when |
|-------|---------------|-----------|
| **1. Root cause** | Read the problem, reproduce, check changes, check each step, trace backward | You know WHAT and WHY |
| **2. Pattern** | Find a working case, read it, list differences | Differences identified |
| **3. Hypothesis** | State one theory, test minimally | Confirmed or new hypothesis |
| **4. Fix** | Smallest check, single fix, verify | Problem resolved |

Red flags that mean STOP and return to Phase 1: proposing a fix before tracing it backward, "quick fix now, look into it later," changing several things at once, skipping the check, or "one more attempt" past two failures.

Verify with fresh evidence before claiming done.

## When investigation finds no root cause

Genuinely external or out of your control? The process is done: write down what you investigated, put sensible handling in place (a fallback, a clear note, a retry), and leave a trail for next time. 95% of "no root cause" cases are incomplete investigation, so suspect the investigation first.
