#!/usr/bin/env bash
# guard-commit.sh: PreToolUse (Bash), Unix port of guard-commit.ps1.
# Denies a git commit that skips hooks (--no-verify / -n / -nm / inline core.hooksPath), so the
# deterministic no-AI-attribution commit-msg hook can never be bypassed. Allows everything else.
# Message text is de-quoted first, so a commit message that mentions these flags never trips it.
payload="$(cat)"
[ -n "$payload" ] || exit 0
# drop double- and single-quoted spans (message text) so flags inside a message don't fire
dq="$(printf '%s' "$payload" | sed -e 's/\\"[^\\]*\\"/ Q /g' -e "s/'[^']*'/ Q /g")"
# scope to the commit segment: split on shell separators, keep git-commit segments, test those for hook-skipping
echo "$dq" | tr ';|&' '\n\n\n' \
  | grep -E 'git' \
  | grep -E '(^|[[:space:]])commit([[:space:]]|$|")' \
  | grep -qE -- '--no-verify|(^|[[:space:]])-[A-Za-z]*n|core\.hooksPath' || exit 0
reason="Blocked: this git commit skips hooks (--no-verify/-n or an inline core.hooksPath), which would bypass the no-AI-attribution commit-msg hook. Commit normally; the hook strips any AI co-author trailer for you."
printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"%s"}}\n' "$reason"
exit 0
