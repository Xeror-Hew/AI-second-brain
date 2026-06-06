---
name: brainstorm
description: Turn an idea into a fully formed design before you start producing. Explores intent, requirements, and approaches, lands a spec, then hands off to /writeplan.
when_to_use: starting a real piece of work, a deliverable, or a direction change; user says "brainstorm", "let's design this", "think this through"; auto-fire before producing non-trivial work. Skip on trivial or mechanical work (CLAUDE.md outranks this skill).
---

# Brainstorm Ideas Into Designs

Turn an idea into a design through collaborative dialogue. Understand context, ask one question at a time, propose approaches, present the design, land a spec, hand off to `/writeplan`.

<GATE>
Design before producing. Do not start producing, or invoke an implementation skill, until you present a design and the user approves it. This holds for every real piece of work regardless of perceived simplicity.
</GATE>

Run this for real work. Skip it on trivial or mechanical tasks (a quick edit, a small tweak); CLAUDE.md outranks this skill.

## Process Flow

```dot
digraph brainstorm {
    "Explore project context" [shape=box];
    "Ask clarifying questions" [shape=box];
    "Propose 2-3 approaches" [shape=box];
    "Present design sections" [shape=box];
    "User approves design?" [shape=diamond];
    "Write spec to project_brain/plan/" [shape=box];
    "Spec self-review (fix inline)" [shape=box];
    "User reviews spec?" [shape=diamond];
    "Hand off to /writeplan" [shape=doublecircle];

    "Explore project context" -> "Ask clarifying questions";
    "Ask clarifying questions" -> "Propose 2-3 approaches";
    "Propose 2-3 approaches" -> "Present design sections";
    "Present design sections" -> "User approves design?";
    "User approves design?" -> "Present design sections" [label="no, revise"];
    "User approves design?" -> "Write spec to project_brain/plan/" [label="yes"];
    "Write spec to project_brain/plan/" -> "Spec self-review (fix inline)";
    "Spec self-review (fix inline)" -> "User reviews spec?";
    "User reviews spec?" -> "Write spec to project_brain/plan/" [label="changes"];
    "User reviews spec?" -> "Hand off to /writeplan" [label="approved"];
}
```

The terminal state is `/writeplan`. It folds the spec's conclusions into Vision/plan so the second brain stays canonical. Invoke no other implementation skill from here.

## The Process

**Understand the idea.** Check current state first (files, the roadmap, work map, and library, recent log). If the request spans several independent threads, flag it and decompose into sub-projects before refining details; each sub-project gets its own spec, then plan, then production. For a well-scoped project, ask one question per message, multiple-choice when it fits, focused on purpose, constraints, and success criteria.

**Explore approaches.** Propose 2-3 approaches with trade-offs. Lead with your recommendation and the reason.

**Present the design.** Scale each section to its complexity (a sentence when straightforward, up to ~300 words when nuanced). Confirm after each section. Cover the approach, the pieces, how they fit together, what could go wrong, and how you'll check it's right.

**Design for clarity.** Break the work into pieces with one clear purpose each, understandable on its own. For each: what it covers, how it's used, what it depends on. A reader should grasp a piece without digging into the rest. A file that grows large signals it is doing too much.

**In existing work.** Follow the existing style. Fold in fixes where the current material blocks the work (an overlong file, a tangled section). Skip unrelated rework.

You may sketch an ASCII mockup inline when a visual clarifies the design.

## After the Design

**Write the spec** to `project_brain/plan/<topic>-design.md`. Spec output lands in `project_brain/plan/`, never `docs/`; this blueprint has no `docs/` folder.

**Spec self-review** with fresh eyes, fix inline:
1. Placeholders: any "TBD", "TODO", or vague requirement.
2. Consistency: sections that contradict, architecture that mismatches features.
3. Scope: focused enough for one plan, or needs decomposition.
4. Ambiguity: any requirement readable two ways; pick one, make it explicit.

For a deeper pass, dispatch a reviewer subagent using `spec-document-reviewer-prompt.md`.

**User review gate.** Ask the user to review the written spec:

> "Spec written to `<path>`. Review it and tell me if you want changes before we write the plan."

Wait. On changes, fix and re-run the self-review. Only proceed once the user approves.

**Hand off to `/writeplan`** to fold the conclusions into Vision/plan. That is the only next step.

## Key Principles

- One question at a time, multiple-choice when it fits.
- YAGNI ruthlessly: cut features the design does not need.
- Always propose 2-3 approaches before settling.
- Present, then get approval before moving on.
- Go back and clarify when something does not fit.
- Verify with fresh evidence before claiming done.
- Dispatch independent work to parallel subagents.
