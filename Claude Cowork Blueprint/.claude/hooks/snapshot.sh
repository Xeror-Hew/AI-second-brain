#!/usr/bin/env bash
# snapshot.sh: PreToolUse (Edit/Write), Unix port of snapshot.ps1.
# Freezes the "before" of a living .md doc under project_brain/ into history/<base>/. Never blocks (always exit 0).
# Cooldown by mtime: cp doesn't preserve the source mtime, so the snapshot's mtime works as the clock.
COOLDOWN_MIN=20

payload="$(cat)"
[ -n "$payload" ] || exit 0

fp="$(printf '%s' "$payload" | grep -oE '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed -E 's/^"file_path"[[:space:]]*:[[:space:]]*"//; s/"$//')"
[ -n "$fp" ] || exit 0
[ -f "$fp" ] || exit 0                              # Write creating a new file = nothing to save
case "$fp" in *.md) ;; *) exit 0 ;; esac            # .md only

norm="${fp//\\//}"                                  # normalize separator
case "$norm" in */project_brain/*) ;; *) exit 0 ;; esac
devRoot="${norm%%/project_brain/*}/project_brain"

# history/ + memory/ are engine folders (canonical); roadmap/ + notes/ may be localized, their
# physical names living in project_brain/.brain.json. Resolve so the exclusion still holds.
roadmapDir=roadmap; notesDir=notes
if [ -f "$devRoot/.brain.json" ]; then
  r="$(sed -n 's/.*"roadmap"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$devRoot/.brain.json" | head -1)"
  n="$(sed -n 's/.*"notes"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$devRoot/.brain.json" | head -1)"
  [ -n "$r" ] && roadmapDir="$r"
  [ -n "$n" ] && notesDir="$n"
fi
case "$norm" in */history/*|*/memory/*|*/"$roadmapDir"/*|*/"$notesDir"/*) exit 0 ;; esac

base="$(basename "$fp")"; base="${base%.md}"
snapDir="$devRoot/history/$base"

file_mtime() { case "$(uname -s)" in Darwin) stat -f %m "$1" ;; *) stat -c %Y "$1" ;; esac; }

if [ -d "$snapDir" ]; then
  newest="$(ls -t "$snapDir"/*.md 2>/dev/null | head -1)"
  if [ -n "$newest" ]; then
    age=$(( ( $(date +%s) - $(file_mtime "$newest") ) / 60 ))
    [ "$age" -ge 0 ] && [ "$age" -lt "$COOLDOWN_MIN" ] && exit 0   # inside the cooldown (a future stamp never suppresses)
  fi
else
  mkdir -p "$snapDir"
fi

stamp="$(date -u +%Y-%m-%dT%H-%M-%S)"   # UTC, so the filename clock matches brain.mjs / snapshot-all.mjs
cp "$fp" "$snapDir/$base $stamp.md" 2>/dev/null || true
exit 0
