#!/usr/bin/env bash
# SessionStart hook (Unix): inject the using-the-brain bootstrap so skills auto-trigger and the AI
# orients before acting. Mirrors session-start.ps1. Output is JSON on stdout (Claude Code reads
# hookSpecificOutput.additionalContext). Uses printf, not a heredoc (bash 5.3+ heredoc can hang).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLUGIN_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

content=$(cat "${PLUGIN_ROOT}/skills/using-the-brain/SKILL.md" 2>/dev/null || echo "Error reading using-the-brain skill")

# Escape for JSON embedding (single C-level passes, fast).
escape_for_json() {
  local s="$1"
  s="${s//\\/\\\\}"
  s="${s//\"/\\\"}"
  s="${s//$'\n'/\\n}"
  s="${s//$'\r'/\\r}"
  s="${s//$'\t'/\\t}"
  printf '%s' "$s"
}

esc=$(escape_for_json "$content")
ctx="<EXTREMELY_IMPORTANT>\nYou have an AI second brain.\n\n**Below is your 'using-the-brain' skill: your introduction to orienting and to using skills. For all other skills, use the Skill tool:**\n\n${esc}\n</EXTREMELY_IMPORTANT>"

printf '{\n  "hookSpecificOutput": {\n    "hookEventName": "SessionStart",\n    "additionalContext": "%s"\n  }\n}\n' "$ctx"
exit 0
