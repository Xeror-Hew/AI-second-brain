---
name: diagnose
description: Use when hitting any bug, test failure, crash, flaky test, performance regression, build break, or unexpected behavior, before proposing a fix.
when_to_use: user says "debug", "why is this failing", "this is broken", "find the bug"; or the AI fires it on any test failure, crash, or surprising behavior before suggesting fixes, especially under time pressure or after a fix already missed.
---

# Debug

## The Iron Law

```
NO FIXES WITHOUT ROOT CAUSE INVESTIGATION FIRST
```

Find the root cause before any fix. A symptom fix is a failure. Until Phase 1 is done, propose no fixes.

Holds even when the issue looks simple, you're in a hurry, or someone wants it fixed now. Systematic beats thrashing on speed.

## The Four Phases

Complete each phase before the next.

### Phase 1: Root cause

1. Read the error and stack trace in full: line numbers, paths, codes. The fix often sits in the message.
2. Reproduce reliably. Not reproducible means gather more data, never guess.
3. Check recent changes: git diff, new deps, config, environment.
4. **Multi-component systems** (CI to build to signing, API to service to DB): instrument each boundary before fixing.
   ```
   For EACH component boundary:
     - Log what data enters the component
     - Log what data exits the component
     - Verify environment/config propagation
     - Check state at each layer
   Run once to gather evidence showing WHERE it breaks
   THEN analyze to identify the failing component
   THEN investigate that specific component
   ```
   One example, a signing pipeline, boundary by boundary:
   ```bash
   # Layer 1: Workflow
   echo "IDENTITY: ${IDENTITY:+SET}${IDENTITY:-UNSET}"
   # Layer 2: Build script
   env | grep IDENTITY || echo "IDENTITY not in environment"
   # Layer 3: Signing script
   security find-identity -v
   # Layer 4: Actual signing
   codesign --sign "$IDENTITY" --verbose=4 "$APP"
   ```
   Reveals which boundary drops the value (secrets reach the workflow, workflow to build loses it).
5. Trace the data flow backward to where the bad value originates; fix at the source. Full technique: `root-cause-tracing.md`.

### Phase 2: Pattern

Find similar working code in the codebase. Applying a reference implementation means reading it completely. List every difference between working and broken, however small. Map the dependencies, config, and assumptions involved.

### Phase 3: Hypothesis

State one hypothesis: "X is the root cause because Y." Test with the smallest possible change, one variable at a time. Worked means Phase 4. Didn't means form a new hypothesis; stack no more fixes. When you don't understand something, say so and dig in.

### Phase 4: Implementation

1. Write a failing test first: simplest reproduction, automated when possible. Use `/tdd` for the proper failing test.
2. Implement one fix for the root cause. One change, no "while I'm here" extras, no bundled refactor.
3. Verify: target test passes, nothing else broke, issue actually resolved.
4. Fix failed? STOP and count attempts. Under 3, return to Phase 1 with the new information. **At 3+, stop and question the architecture.**

### Escalation gate: 3+ failed fixes

```
3+ fixes failed  ->  STOP. Wrong architecture, not a failed hypothesis.
```

Signs: each fix exposes new shared state or coupling elsewhere, fixes demand "massive refactoring," each fix spawns new symptoms. Question fundamentals: is the pattern sound, or are you continuing through inertia? Discuss with the user before any fix #4.

## Quick reference

| Phase | Key activities | Done when |
|-------|---------------|-----------|
| **1. Root cause** | Read errors, reproduce, check changes, instrument boundaries, trace data flow | You know WHAT and WHY |
| **2. Pattern** | Find working examples, read references, list differences | Differences identified |
| **3. Hypothesis** | State one theory, test minimally | Confirmed or new hypothesis |
| **4. Implementation** | Failing test, single fix, verify | Bug resolved, tests pass |

Red flags that mean STOP and return to Phase 1: proposing a fix before tracing data flow, "quick fix now investigate later," changing several things at once, skipping the test, or "one more attempt" past two failures.

Verify with fresh evidence before claiming done.

## Reference files (load when needed)

- `root-cause-tracing.md`: trace a bug backward through the call stack to its trigger.
- `defense-in-depth.md`: add validation at multiple layers once the root cause is known.
- `condition-based-waiting.md`: replace arbitrary timeouts with condition polling for flaky timing bugs.
- `find-polluter.sh`: bisect a test suite to find the test that pollutes shared state.

## When investigation finds no root cause

Genuinely environmental, timing-dependent, or external? The process is done: document what you investigated, implement appropriate handling (retry, timeout, clear error), add logging for next time. 95% of "no root cause" cases are incomplete investigation, so suspect the investigation first.
