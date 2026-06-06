#!/usr/bin/env bash
# remind-library.sh: PostToolUse (Edit/Write), Unix port of remind-library.ps1.
# After a deliverable file gets edited (outside the brain's managed folders), nudge (additionalContext):
# close out the task with /done if finished, and update the library if you produced/reshaped a deliverable.
# Never blocks.
COOLDOWN_MIN=30

payload="$(cat)"
[ -n "$payload" ] || exit 0

fp="$(printf '%s' "$payload" | grep -oE '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed -E 's/^"file_path"[[:space:]]*:[[:space:]]*"//; s/"$//')"
[ -n "$fp" ] || exit 0
norm="${fp//\\//}"

case "$norm" in */project_brain/*|*/.claude/*|*/.obsidian/*|*/.git/*) exit 0 ;; esac   # skip the brain's managed folders

proj="${CLAUDE_PROJECT_DIR:-$PWD}"
stamp="$proj/.claude/.library_reminder.stamp"
file_mtime() { case "$(uname -s)" in Darwin) stat -f %m "$1" ;; *) stat -c %Y "$1" ;; esac; }

if [ -f "$stamp" ]; then
  age=$(( ( $(date +%s) - $(file_mtime "$stamp") ) / 60 ))
  [ "$age" -lt "$COOLDOWN_MIN" ] && exit 0
fi
date +%s > "$stamp" 2>/dev/null || true

msg="You edited a deliverable. If that finished a task, close it out now with /done (log it, prune the roadmap, set the next step, and update the library if you produced or reshaped a deliverable) while the context is fresh. A small in-progress tweak: ignore."
printf '{"hookSpecificOutput":{"hookEventName":"PostToolUse","additionalContext":"%s"}}\n' "$msg"
exit 0
