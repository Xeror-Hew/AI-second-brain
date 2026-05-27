---
name: snapshot
description: Freeze the "before" of a living project_brain/ doc into history/ before editing it, on Claude Cowork (where hooks aren't available).
when_to_use: ALWAYS right before you Edit/Write a living doc under project_brain/ (Vision, plan, roadmap, work_map, context, next_step), to preserve the previous version. On Claude Code CLI / Claudian the hook does this; this skill covers Claude Cowork.
---

This is the no-hooks path for versioning. On **Claude Code CLI / Claudian** the hook `.claude/hooks/snapshot.*` already freezes the "before" on its own. This skill covers **Claude Cowork**, which has no hooks.

1. **Surface check.** Read the environment. If `CLAUDE_CODE_IS_COWORK` is **not** set, the hook handles snapshots: do nothing. If it **is** set (Cowork), continue.
2. **Scope.** Only living `.md` docs under `project_brain/`. Skip anything in `history/`, `memory/`, `roadmap/`, `notes/` (they keep their own history or stay out), and skip when creating a brand-new file (nothing to freeze).
3. **Cooldown.** Look in `project_brain/history/<base>/` for the newest `<base> *.md` (where `<base>` is the filename without extension). If its timestamp is under ~20 minutes old, skip: a recent snapshot already exists, possibly from the hook on another surface.
4. **Freeze.** Copy the current file to `project_brain/history/<base>/<base> YYYY-MM-DDTHH-mm-ss.md` (no `:` in the name, it's illegal on Windows). Create the folder if needed.
5. Then make your edit.

Same path, timestamp format, cooldown, and exclusions as the hook, so the two never double-snapshot a folder used across surfaces.
