---
name: worktree
description: Use when starting feature work that needs isolation from the current workspace, or before /execute runs a plan. Ensures an isolated workspace exists via native tools or git worktree fallback.
when_to_use: starting isolated feature work, before /execute, user says "worktree", "isolate this", "branch workspace"; the AI auto-fires it when a task should not touch the current branch.
---

Ensure work happens in an isolated workspace. Detect existing isolation first. Then native tools. Then git fallback. Never fight the harness.

## Step 0: Detect existing isolation

Check before creating anything:

```bash
GIT_DIR=$(cd "$(git rev-parse --git-dir)" 2>/dev/null && pwd -P)
GIT_COMMON=$(cd "$(git rev-parse --git-common-dir)" 2>/dev/null && pwd -P)
BRANCH=$(git branch --show-current)
```

**Submodule guard:** `GIT_DIR != GIT_COMMON` is also true inside a submodule. Confirm you are not in one before concluding "worktree":

```bash
# A path here means submodule (treat as a normal repo), so the worktree conclusion is wrong
git rev-parse --show-superproject-working-tree 2>/dev/null
```

**`GIT_DIR != GIT_COMMON` (and not a submodule):** already in a linked worktree. Skip to Step 3. Report state:
- On a branch: "Already in isolated workspace at `<path>` on branch `<name>`."
- Detached HEAD: "Already in isolated workspace at `<path>` (detached HEAD, externally managed). Branch creation needed at finish time."

**`GIT_DIR == GIT_COMMON` (or in a submodule):** normal repo checkout. Honor any declared worktree preference without asking. Otherwise ask consent:

> "Set up an isolated worktree? It protects your current branch from changes."

Declined → work in place, skip to Step 3.

## Step 1: Create isolated workspace

### 1a. Native worktree tools (preferred)

Already have a way to create a worktree (a tool like `EnterWorktree` / `WorktreeCreate`, a `/worktree` command, a `--worktree` flag)? Use it and skip to Step 3. Native tools own placement, branch creation, and cleanup; `git worktree add` over the top creates phantom state the harness can't see.

Proceed to 1b only when no native tool exists.

### 1b. Git worktree fallback

Pick the directory in this order (explicit user preference beats filesystem state):

1. Declared worktree directory in your instructions → use it.
2. Existing project-local directory:
   ```bash
   ls -d .worktrees 2>/dev/null     # preferred (hidden)
   ls -d worktrees 2>/dev/null      # alternative
   ```
   Both exist → `.worktrees` wins.
3. Existing global directory (legacy backward-compat):
   ```bash
   project=$(basename "$(git rev-parse --show-toplevel)")
   ls -d ~/.config/ai-second-brain/worktrees/$project 2>/dev/null
   ```
4. Default to `.worktrees/` at the project root.

**Safety check (project-local only): verify the directory is ignored before creating.**

```bash
git check-ignore -q .worktrees 2>/dev/null || git check-ignore -q worktrees 2>/dev/null
```

Not ignored → add to `.gitignore`, commit that change, then proceed. Skipping this tracks worktree contents into the repo. Global directories need no check.

Create it:

```bash
project=$(basename "$(git rev-parse --show-toplevel)")
# project-local: path="$LOCATION/$BRANCH_NAME"
# global:        path="~/.config/ai-second-brain/worktrees/$project/$BRANCH_NAME"
git worktree add "$path" -b "$BRANCH_NAME"
cd "$path"
```

**Sandbox fallback:** `git worktree add` fails with a permission/sandbox denial → tell the user the sandbox blocked it and you're working in the current directory. Run setup and baseline tests in place.

## Step 3: Project setup

Auto-detect and run:

```bash
[ -f package.json ]     && npm install
[ -f Cargo.toml ]       && cargo build
[ -f requirements.txt ] && pip install -r requirements.txt
[ -f pyproject.toml ]   && poetry install
[ -f go.mod ]           && go mod download
```

## Step 4: Verify clean baseline

Run the project-appropriate test command (`npm test` / `cargo test` / `pytest` / `go test ./...`).

- Tests fail → report failures, ask whether to proceed or investigate. Verify with fresh evidence before claiming done.
- Tests pass → report ready:

```
Worktree ready at <full-path>
Tests passing (<N> tests, 0 failures)
Ready to implement <feature-name>
```

## Quick reference

| Situation | Action |
|-----------|--------|
| Already in linked worktree | Skip creation (Step 0) |
| In a submodule | Treat as normal repo (Step 0 guard) |
| Native worktree tool available | Use it (Step 1a) |
| No native tool | Git fallback (Step 1b) |
| `.worktrees/` exists | Use it (verify ignored) |
| `worktrees/` exists | Use it (verify ignored) |
| Both exist | Use `.worktrees/` |
| Neither exists | Check instructions, then default `.worktrees/` |
| Global path exists | Use it (backward compat) |
| Directory not ignored | Add to `.gitignore` + commit |
| Permission error on create | Sandbox fallback, work in place |
| Tests fail during baseline | Report failures + ask |
| No package.json/Cargo.toml | Skip dependency install |

Never use `git worktree add` when a native tool exists; never create a worktree when Step 0 finds existing isolation; never skip the ignore check or the baseline test.
