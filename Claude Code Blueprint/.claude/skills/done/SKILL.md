---
name: done
description: Close out a finished task: log it, prune the roadmap, set the next step, and finish the branch when one is ready.
when_to_use: user says "done", "finished", "ship it", "that's closed"; the AI fires it the moment a task or roadmap item is finished, before moving on
---

A task just got finished. Close it out now, while you still hold the context, in order:

1. Add one line to `project_brain/roadmap/roadmap_log.md`: `{{date}}: {{what got done}} ({{commit hash if any}})`. Append only.
2. Remove the finished item from `project_brain/roadmap/roadmap.md`. The active list only holds open work.
3. **Map**: if the task changed the code's shape (new module, moved/renamed file, changed flow), update `project_brain/code_map/` now (`/map`) while it's fresh. A small change with no structural impact: skip.
4. Overwrite `project_brain/next_step.md` with the next item (short context plus how to validate).
5. Confirm in one line what closed and what's next.

## Finish the branch (when this task completes one)

If the task wraps up a branch and the tests pass, decide how to integrate before moving on:

1. **Verify tests pass first.** Failing tests stop here; fix them before any merge or PR.
2. **Detect the workspace**: compare `git rev-parse --git-dir` with `--git-common-dir` (normal repo, named-branch worktree, or detached HEAD).
3. **Present the options** (exactly these, no extra prose): merge to base locally · push and open a PR · keep the branch as-is · discard. Detached HEAD drops the local-merge option.
4. **Execute the choice.** Merge before deleting anything, and verify tests on the merged result.
5. **Clean up only a worktree you created** (under `.worktrees/`, `worktrees/`, or the engine's worktree dir): `cd` to the main root first, then `git worktree remove`, then `git worktree prune`. Leave a harness-owned workspace in place. Keep the worktree alive for a PR (option 2). Require a typed "discard" confirmation before deleting work.

Closing out here, per task, keeps the truth aligned while the context is hot. `/end` is the safety net at session close.
