#!/usr/bin/env bash
# remind-map.sh: PostToolUse (Edit/Write), Unix port of remind-map.ps1.
# After a CODE file gets edited, inject a reminder (additionalContext) to update the map. Never blocks.
COOLDOWN_MIN=30

payload="$(cat)"
[ -n "$payload" ] || exit 0

fp="$(printf '%s' "$payload" | grep -oE '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed -E 's/^"file_path"[[:space:]]*:[[:space:]]*"//; s/"$//')"
[ -n "$fp" ] || exit 0
norm="${fp//\\//}"

case "$norm" in *.md) exit 0 ;; esac                                  # code only
case "$norm" in */project_brain/*|*/.claude/*|*/.obsidian/*|*/.git/*) exit 0 ;; esac

proj="${CLAUDE_PROJECT_DIR:-$PWD}"
stamp="$proj/.claude/.map_reminder.stamp"
file_mtime() { case "$(uname -s)" in Darwin) stat -f %m "$1" ;; *) stat -c %Y "$1" ;; esac; }

if [ -f "$stamp" ]; then
  age=$(( ( $(date +%s) - $(file_mtime "$stamp") ) / 60 ))
  [ "$age" -lt "$COOLDOWN_MIN" ] && exit 0
fi
date +%s > "$stamp" 2>/dev/null || true

msg="You edited code. IF it was a structural change (new module, refactor, moved/renamed file, changed flow), update project_brain/code_map/ now (skill /map) so it doesn't go stale. Small change: ignore."
printf '{"hookSpecificOutput":{"hookEventName":"PostToolUse","additionalContext":"%s"}}\n' "$msg"
exit 0
