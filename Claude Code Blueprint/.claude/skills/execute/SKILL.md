---
name: execute
description: Execute a written implementation plan task by task, with per-task review checkpoints (spec then code quality).
when_to_use: user says "execute the plan", "run the plan", "implement this", "build it"; or right after /writeplan produces a task list in project_brain/plan/ and the work is ready to ship
---

Execute the plan in `project_brain/plan/`. Default to subagent-driven: dispatch a fresh subagent per task, two-stage review after each. Use inline mode only when subagents are unavailable.

## Iron Laws

- Never start implementation on `main`/`master` without explicit consent. Set up isolation first (`/worktree`).
- One implementer subagent at a time. Parallel implementers conflict.
- Spec review passes (✅) before code-quality review starts. Wrong order otherwise.
- A reviewer that found issues means the task is not done. Implementer fixes, reviewer re-reviews, repeat until ✅.
- Verify with fresh evidence before claiming done (CLAUDE.md rule 4).
- Run all tasks continuously. Stop only for BLOCKED you can't resolve, genuine ambiguity, or completion. No "should I continue?" check-ins.

## Pick the mode

```dot
digraph mode {
    "Have a plan in project_brain/plan/?" [shape=diamond];
    "Subagents available?" [shape=diamond];
    "subagent-driven (default)" [shape=box];
    "inline mode" [shape=box];
    "Run /writeplan or /brainstorm first" [shape=box];

    "Have a plan in project_brain/plan/?" -> "Subagents available?" [label="yes"];
    "Have a plan in project_brain/plan/?" -> "Run /writeplan or /brainstorm first" [label="no"];
    "Subagents available?" -> "subagent-driven (default)" [label="yes"];
    "Subagents available?" -> "inline mode" [label="no"];
}
```

Subagent-driven keeps your context clean (fresh subagent per task), runs review checkpoints automatically, and iterates without waiting on a human. Inline mode runs the tasks in this session for a separate-session handoff with manual checkpoints.

---

## Subagent-driven mode (default)

Delegate each task to a fresh subagent with exactly the context it needs. Never let it inherit your session history; construct its prompt from the plan text. This preserves your context for coordination.

```dot
digraph process {
    rankdir=TB;

    "Read plan, extract all tasks with full text + context, create TodoWrite" [shape=box];
    "Set up isolation (/worktree)" [shape=box];
    "More tasks remain?" [shape=diamond];

    subgraph cluster_per_task {
        label="Per Task";
        "Dispatch implementer (./implementer-prompt.md)" [shape=box];
        "Implementer asks questions?" [shape=diamond];
        "Answer, provide context" [shape=box];
        "Implementer implements, tests, commits, self-reviews" [shape=box];
        "Dispatch spec reviewer (./spec-reviewer-prompt.md)" [shape=box];
        "Spec matches?" [shape=diamond];
        "Implementer fixes spec gaps" [shape=box];
        "Dispatch code quality reviewer (./code-quality-reviewer-prompt.md)" [shape=box];
        "Quality approved?" [shape=diamond];
        "Implementer fixes quality issues" [shape=box];
        "Mark task complete (TodoWrite), run /done" [shape=box];
    }

    "Dispatch final code reviewer for whole implementation" [shape=box];
    "Hand off: /done per task, /end at session close" [shape=box style=filled fillcolor=lightgreen];

    "Read plan, extract all tasks with full text + context, create TodoWrite" -> "Set up isolation (/worktree)";
    "Set up isolation (/worktree)" -> "More tasks remain?";
    "More tasks remain?" -> "Dispatch implementer (./implementer-prompt.md)" [label="yes"];
    "Dispatch implementer (./implementer-prompt.md)" -> "Implementer asks questions?";
    "Implementer asks questions?" -> "Answer, provide context" [label="yes"];
    "Answer, provide context" -> "Dispatch implementer (./implementer-prompt.md)";
    "Implementer asks questions?" -> "Implementer implements, tests, commits, self-reviews" [label="no"];
    "Implementer implements, tests, commits, self-reviews" -> "Dispatch spec reviewer (./spec-reviewer-prompt.md)";
    "Dispatch spec reviewer (./spec-reviewer-prompt.md)" -> "Spec matches?";
    "Spec matches?" -> "Implementer fixes spec gaps" [label="no"];
    "Implementer fixes spec gaps" -> "Dispatch spec reviewer (./spec-reviewer-prompt.md)" [label="re-review"];
    "Spec matches?" -> "Dispatch code quality reviewer (./code-quality-reviewer-prompt.md)" [label="yes"];
    "Dispatch code quality reviewer (./code-quality-reviewer-prompt.md)" -> "Quality approved?";
    "Quality approved?" -> "Implementer fixes quality issues" [label="no"];
    "Implementer fixes quality issues" -> "Dispatch code quality reviewer (./code-quality-reviewer-prompt.md)" [label="re-review"];
    "Quality approved?" -> "Mark task complete (TodoWrite), run /done" [label="yes"];
    "Mark task complete (TodoWrite), run /done" -> "More tasks remain?";
    "More tasks remain?" -> "Dispatch final code reviewer for whole implementation" [label="no"];
    "Dispatch final code reviewer for whole implementation" -> "Hand off: /done per task, /end at session close";
}
```

### Prompt templates (load when you dispatch)

- `./implementer-prompt.md`: implementer subagent
- `./spec-reviewer-prompt.md`: spec compliance reviewer
- `./code-quality-reviewer-prompt.md`: code quality reviewer

### Model selection

Use the least powerful model that handles each role, to conserve cost and speed up iteration.

| Task signal | Model |
|---|---|
| 1-2 files, complete spec, mechanical | cheap/fast |
| Multiple files, integration concerns | standard |
| Design judgment or broad codebase understanding | most capable |
| Review tasks (spec + quality) | most capable |

### Handling implementer status

The implementer reports one of four statuses.

| Status | Action |
|---|---|
| **DONE** | Proceed to spec review. |
| **DONE_WITH_CONCERNS** | Read the concerns. Correctness/scope concerns: address before review. Observations (e.g. "file getting large"): note and proceed. |
| **NEEDS_CONTEXT** | Provide the missing context, re-dispatch. |
| **BLOCKED** | Diagnose, then change something: context problem → add context, same model; needs more reasoning → re-dispatch on a more capable model; task too large → split it; plan is wrong → escalate to the user. |

Never ignore an escalation or retry the same model unchanged. If the implementer is stuck, something has to change.

---

## Inline mode (no subagents)

Run the plan in this session, with manual review checkpoints. Use for a separate-session handoff where the executor reviews the plan critically before starting.

1. Read the plan in `project_brain/plan/`. Review it critically; raise concerns with the user before starting.
2. `/worktree` for isolation if not already isolated.
3. Create TodoWrite from the tasks. For each: mark in_progress, follow the steps exactly, run the verifications, mark complete, run `/done`.
4. After all tasks pass, run `/critique` over the whole implementation.
5. Stop and ask on any blocker (missing dependency, failing verification, unclear instruction). Don't force through; don't guess.

---

## Compose with

- `/writeplan` produces the plan this skill executes (`project_brain/plan/`).
- `/worktree` ensures the isolated workspace before implementation.
- `/tdd` is how each implementer subagent writes code; `/diagnose` when a verification fails.
- `/critique` is the reviewer template for the spec and quality checkpoints.
- Finish: `/done` per task (log, prune roadmap, set next step), `/end` at session close (safety-net sweep).
- Dispatch independent work to parallel subagents (CLAUDE.md rule 2); implementers stay sequential.

## One example (subagent-driven)

```
[Read project_brain/plan/, extract 5 tasks, TodoWrite]

Task 2: Recovery modes
[Dispatch implementer with full task text + context]
Implementer: added verify/repair modes, 8/8 tests pass, committed. Status: DONE

[Dispatch spec reviewer]
Spec reviewer: ❌ missing progress reporting; extra --json flag (not requested)
[Implementer fixes] → Spec reviewer: ✅

[Dispatch code quality reviewer]
Code reviewer: Issue (Important): magic number 100
[Implementer extracts PROGRESS_INTERVAL] → Code reviewer: ✅

[Mark complete, /done] → next task
```
