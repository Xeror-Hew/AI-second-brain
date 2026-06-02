#!/usr/bin/env bash
# setup.sh: Unix port (mac/linux) of setup.ps1.
# Links Claude Code's memory into this repo via symlink, protects the Claude files in git,
# and installs a deterministic no-AI-attribution commit-msg hook.
# Run ONCE per project, from the root:   bash .claude/setup.sh
# On Unix the symlink needs no admin. Idempotent.

projectRoot="$(cd "$(dirname "$0")/.." && pwd)"
brainMemory="$projectRoot/project_brain/memory"
echo "Project: $projectRoot"
mkdir -p "$brainMemory"

# <encoded> = the project's absolute path with every non-alphanumeric char turned into '-'
encoded="$(printf '%s' "$projectRoot" | sed 's/[^A-Za-z0-9]/-/g')"
harnessDir="$HOME/.claude/projects/$encoded"
harnessMem="$harnessDir/memory"
mkdir -p "$harnessDir"

if [ -L "$harnessMem" ]; then
  target="$(readlink "$harnessMem")"
  if [ "$target" = "$brainMemory" ]; then
    echo "OK: memory symlink already points to the right place."
  else
    rm "$harnessMem"
    ln -s "$brainMemory" "$harnessMem"
    echo "OK: symlink repointed (was at '$target')."
  fi
elif [ -d "$harnessMem" ]; then
  # real folder with accumulated memory: migrate into the repo and swap for a symlink
  ( shopt -s dotglob 2>/dev/null; mv "$harnessMem"/* "$brainMemory"/ 2>/dev/null ) || true
  rmdir "$harnessMem" 2>/dev/null || rm -rf "$harnessMem"
  ln -s "$brainMemory" "$harnessMem"
  echo "OK: migrated existing memory and created the symlink."
else
  ln -s "$brainMemory" "$harnessMem"
  echo "OK: symlink created -> $brainMemory"
fi

# .gitignore: idempotent, and conditional. If the project already versions its Claude config,
# leave it tracked and ignore only the always-local pieces (memory junction, plugin scratch).
gitignore="$projectRoot/.gitignore"
marker="# === Claude workflow (do not version) ==="
if grep -qF "$marker" "$gitignore" 2>/dev/null; then
  echo "OK: .gitignore already has the Claude block."
else
  if [ -f "$gitignore" ] && [ -n "$(tail -c1 "$gitignore" 2>/dev/null)" ]; then echo "" >> "$gitignore"; fi
  if [ -n "$(git -C "$projectRoot" ls-files .claude CLAUDE.md project_brain 2>/dev/null)" ]; then
    printf '%s\n# (this project versions its Claude config; ignoring only the always-local pieces)\nproject_brain/memory/\n' "$marker" >> "$gitignore"
    echo "NOTE: project already versions .claude/ or CLAUDE.md; left them tracked, ignored only the memory junction."
  else
    printf '%s\n.claude/\nCLAUDE.md\nproject_brain/\n.mcp.json\n' "$marker" >> "$gitignore"
    echo "OK: Claude block added to .gitignore."
  fi
fi

# make the hooks executable
chmod +x "$projectRoot/.claude/hooks/run-hook.cmd" "$projectRoot/.claude/hooks/"*.sh 2>/dev/null || true

# Deterministic no-AI-attribution commit-msg hook: strips any AI co-author / "Generated with [Claude Code]"
# trailer from every commit, in any project. Respects core.hooksPath, integrates with husky, chains an
# existing commit-msg hook (backup commit-msg.pre-blueprint), idempotent.
install_commit_msg_hook() {
  git -C "$projectRoot" rev-parse --git-dir >/dev/null 2>&1 || { echo "skip: not a git repo (no commit-msg hook)."; return 0; }
  if [ -d "$projectRoot/.husky" ]; then
    hooksDir="$projectRoot/.husky"                # husky regenerates .husky/_; the user hook lives in .husky/
  else
    hooksDir="$(git -C "$projectRoot" config core.hooksPath 2>/dev/null || true)"
    if [ -z "$hooksDir" ]; then
      hooksDir="$(git -C "$projectRoot" rev-parse --git-path hooks)"
      case "$hooksDir" in /*|?:*) ;; *) hooksDir="$projectRoot/$hooksDir" ;; esac
    else
      case "$hooksDir" in /*|?:*) ;; *) hooksDir="$(git -C "$projectRoot" rev-parse --show-toplevel)/$hooksDir" ;; esac
    fi
  fi
  mkdir -p "$hooksDir"
  hook="$hooksDir/commit-msg"
  marker="# blueprint:no-ai-attribution"
  if [ -f "$hook" ] && grep -qF "$marker" "$hook" 2>/dev/null; then
    echo "OK: no-AI-attribution commit-msg hook already installed."; return 0
  fi
  if [ -f "$hook" ] && [ ! -f "$hook.pre-blueprint" ]; then
    mv "$hook" "$hook.pre-blueprint"; chmod +x "$hook.pre-blueprint" 2>/dev/null || true
    echo "OK: chained existing commit-msg hook (backup: commit-msg.pre-blueprint)."
  fi
  cat > "$hook" <<'EOF'
#!/bin/sh
# blueprint:no-ai-attribution
# Strip AI co-author / attribution trailers from the message, then run any chained hook.
f="$1"; [ -f "$f" ] || exit 0
tmp="$f.bp.$$"
grep -ivE '^[[:space:]]*co-authored-by:.*(noreply@anthropic\.com|claude\[bot\])' "$f" | grep -ivE 'generated with \[claude code\]' > "$tmp"
mv "$tmp" "$f"
d="$(dirname "$0")"
[ -x "$d/commit-msg.pre-blueprint" ] && exec "$d/commit-msg.pre-blueprint" "$@"
exit 0
EOF
  chmod +x "$hook"
  echo "OK: installed no-AI-attribution commit-msg hook -> $hook"
}
install_commit_msg_hook

echo "Setup done."
