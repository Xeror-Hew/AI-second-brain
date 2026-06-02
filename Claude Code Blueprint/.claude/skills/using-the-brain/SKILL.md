---
name: using-the-brain
description: Use when starting any conversation - establishes the second brain (orient before acting) and how to find and use skills, requiring Skill tool invocation before any response including clarifying questions
---

<SUBAGENT-STOP>
If you were dispatched as a subagent to execute a specific task, skip this skill.
</SUBAGENT-STOP>

# Two things, every session

## 1. Orient first
Before acting on project work, know where it stopped. Call `brain_orient` (the brain MCP) for the next step, the active roadmap, and the recent log. No brain MCP on PATH? Read `project_brain/next_step.md` and `project_brain/roadmap/`. Orientation is read-only and cheap; do it before planning.

## 2. Skills are not optional
<EXTREMELY-IMPORTANT>
If there is even a 1% chance a skill applies to what you are doing, invoke it (the `Skill` tool). If it turns out wrong, drop it. Knowing the concept is not using the skill.
</EXTREMELY-IMPORTANT>

**Invoke relevant skills BEFORE any response or action**, including clarifying questions, exploring the codebase, or "just checking git." Skills tell you HOW to do those.

### Priority when several apply
1. Process skills first (`brainstorm`, `diagnose`): they set HOW to approach.
2. Implementation skills second.

"Let's build X" → `brainstorm` first. "Fix this bug" → `diagnose` first.

### Before EnterPlanMode
If you have not brainstormed yet, invoke `brainstorm` first.

### Red flags: these thoughts mean STOP, you are rationalizing
"Just a simple question" · "I need context first" · "Let me explore first" · "I'll do this one thing first" · "The skill is overkill" · "I remember this skill." Questions are tasks. Check for skills first.

## Instruction priority
1. The user's explicit instructions (`CLAUDE.md`, direct requests): highest.
2. These skills: they override default behavior where they conflict.
3. The default system prompt: lowest.

The user is in control: if `CLAUDE.md` conflicts with a skill, follow `CLAUDE.md`.

## Skill types
Rigid (`tdd`, `diagnose`): follow exactly, don't adapt away the discipline. Flexible (patterns): adapt to context. The skill says which.
