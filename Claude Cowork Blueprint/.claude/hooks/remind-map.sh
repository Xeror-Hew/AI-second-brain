#!/usr/bin/env bash
# remind-map.sh: PostToolUse (Edit/Write), Unix port of remind-map.ps1.
# After a work file (a deliverable) gets edited, nudge (additionalContext): close out the task with /done
# if finished, and update the work map if the change was structural. Never blocks.
COOLDOWN_MIN=30

payload="$(cat)"
[ -n "$payload" ] || exit 0

fp="$(printf '%s' "$payload" | grep -oE '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed -E 's/^"file_path"[[:space:]]*:[[:space:]]*"//; s/"$//')"
[ -n "$fp" ] || exit 0
norm="${fp//\\//}"

case "$norm" in *.md) exit 0 ;; esac                                  # work files only
case "$norm" in */project_brain/*|*/.claude/*|*/.obsidian/*|*/.git/*) exit 0 ;; esac

proj="${CLAUDE_PROJECT_DIR:-$PWD}"
stamp="$proj/.claude/.map_reminder.stamp"
file_mtime() { case "$(uname -s)" in Darwin) stat -f %m "$1" ;; *) stat -c %Y "$1" ;; esac; }

if [ -f "$stamp" ]; then
  age=$(( ( $(date +%s) - $(file_mtime "$stamp") ) / 60 ))
  [ "$age" -lt "$COOLDOWN_MIN" ] && exit 0
fi
date +%s > "$stamp" 2>/dev/null || true

msg="You edited a deliverable. If that finished a task, close it out now with /done (log, roadmap, next step, plus the map if the structure changed) while the context is fresh. If it was a structural change but the task isn't done, update project_brain/work_map/ now (/map). A small in-progress tweak: ignore."
printf '{"hookSpecificOutput":{"hookEventName":"PostToolUse","additionalContext":"%s"}}\n' "$msg"
exit 0
