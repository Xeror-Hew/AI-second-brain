#!/usr/bin/env bash
# setup.sh: Unix port (mac/linux) of setup.ps1.
# Links Claude Code's memory into this repo via symlink + protects the Claude files in git.
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

# .gitignore: idempotent append of the Claude block (doesn't clobber the existing one)
gitignore="$projectRoot/.gitignore"
marker="# === Claude workflow (do not version) ==="
if ! grep -qF "$marker" "$gitignore" 2>/dev/null; then
  if [ -f "$gitignore" ] && [ -n "$(tail -c1 "$gitignore" 2>/dev/null)" ]; then echo "" >> "$gitignore"; fi
  printf '%s\n.claude/\nCLAUDE.md\nproject_brain/\n' "$marker" >> "$gitignore"
  echo "OK: Claude block added to .gitignore."
else
  echo "OK: .gitignore already has the Claude block."
fi

# make the hooks executable
chmod +x "$projectRoot/.claude/hooks/run-hook.cmd" "$projectRoot/.claude/hooks/"*.sh 2>/dev/null || true
echo "Setup done."
