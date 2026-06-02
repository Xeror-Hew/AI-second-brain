# setup.ps1: link Claude Code's memory into this repo (junction), protect the Claude files in git,
# and install a deterministic no-AI-attribution commit-msg hook.
# Run ONCE per project, from the project root:
#     powershell -NoProfile -ExecutionPolicy Bypass -File .claude\setup.ps1
# No admin needed (junction /J doesn't require it). Idempotent: re-running only fixes what's missing.

$ErrorActionPreference = 'Stop'

# Project root = folder above .claude (where this script lives)
$projectRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$brainMemory = Join-Path $projectRoot 'project_brain\memory'

Write-Host "Project: $projectRoot"

# 1) Make sure the repo's memory folder exists (junction target = single source of truth)
if (-not (Test-Path -LiteralPath $brainMemory)) {
    New-Item -ItemType Directory -Path $brainMemory -Force | Out-Null
}

# 2) Path Claude Code expects: ~/.claude/projects/<encoded>/memory
#    <encoded> = the project's absolute path with every non-alphanumeric char turned into '-'
$encoded    = ($projectRoot -replace '[^A-Za-z0-9]', '-')
$harnessDir = Join-Path $env:USERPROFILE ".claude\projects\$encoded"
$harnessMem = Join-Path $harnessDir 'memory'
if (-not (Test-Path -LiteralPath $harnessDir)) {
    New-Item -ItemType Directory -Path $harnessDir -Force | Out-Null
}

# 3) Resolve the current state of <harness>\memory
$item = Get-Item -LiteralPath $harnessMem -ErrorAction SilentlyContinue
if ($item -and (($item.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0)) {
    # Already a junction. Check it points to the right place (it can go stale after a migration/rename).
    $target = @($item.Target)[0]
    if ($target -and ($target.TrimEnd('\') -ieq $brainMemory.TrimEnd('\'))) {
        Write-Host "OK: memory junction already points to the right place."
    } else {
        cmd /c rmdir "$harnessMem" | Out-Null   # rmdir removes only the link, never the target
        cmd /c mklink /J "$harnessMem" "$brainMemory" | Out-Null
        Write-Host "OK: junction repointed (was at '$target')."
    }
} elseif ($item) {
    # Real folder with accumulated memory: migrate it into the repo (harness wins on name clash) and remove
    Get-ChildItem -LiteralPath $harnessMem -Force -ErrorAction SilentlyContinue | ForEach-Object {
        Move-Item -LiteralPath $_.FullName -Destination $brainMemory -Force
    }
    Remove-Item -LiteralPath $harnessMem -Recurse -Force
    cmd /c mklink /J "$harnessMem" "$brainMemory" | Out-Null
    Write-Host "OK: migrated existing harness memory and created the junction."
} else {
    cmd /c mklink /J "$harnessMem" "$brainMemory" | Out-Null
    Write-Host "OK: junction created -> $brainMemory"
}

# 4) .gitignore: idempotent + conditional. If the project already versions its Claude config, leave it
#    tracked and ignore only the always-local pieces (memory junction, plugin scratch).
$gitignore = Join-Path $projectRoot '.gitignore'
$marker = '# === Claude workflow (do not version) ==='
$current = if (Test-Path -LiteralPath $gitignore) { Get-Content -LiteralPath $gitignore -Raw } else { '' }
if ($current -match [regex]::Escape($marker)) {
    Write-Host "OK: .gitignore already has the Claude block."
} else {
    if ($current -and -not $current.EndsWith("`n")) { Add-Content -LiteralPath $gitignore -Value '' }
    $tracked = (git -C "$projectRoot" ls-files .claude CLAUDE.md project_brain 2>$null)
    if ($tracked) {
        Add-Content -LiteralPath $gitignore -Value "$marker`n# (this project versions its Claude config; ignoring only the always-local pieces)`nproject_brain/memory/"
        Write-Host "NOTE: project already versions .claude/ or CLAUDE.md; left them tracked, ignored only the memory junction."
    } else {
        Add-Content -LiteralPath $gitignore -Value "$marker`n.claude/`nCLAUDE.md`nproject_brain/`n.mcp.json"
        Write-Host "OK: Claude block added to .gitignore."
    }
}

# 5) Deterministic no-AI-attribution commit-msg hook (POSIX sh; git runs it via its bundled sh on Windows).
#    Written LF + no BOM so the shebang stays valid. Respects core.hooksPath, integrates with husky,
#    chains an existing commit-msg hook (backup commit-msg.pre-blueprint), idempotent.
function Install-CommitMsgHook($root) {
    git -C "$root" rev-parse --git-dir 2>$null | Out-Null
    if ($LASTEXITCODE -ne 0) { Write-Host "skip: not a git repo (no commit-msg hook)."; return }
    if (Test-Path -LiteralPath (Join-Path $root '.husky')) {
        $hooksDir = Join-Path $root '.husky'        # husky regenerates .husky/_; the user hook lives in .husky/
    } else {
        $hooksDir = (git -C "$root" config core.hooksPath 2>$null)
        if (-not $hooksDir) {
            $hooksDir = (git -C "$root" rev-parse --git-path hooks)
            if (-not [IO.Path]::IsPathRooted($hooksDir)) { $hooksDir = Join-Path $root $hooksDir }
        } else {
            if (-not [IO.Path]::IsPathRooted($hooksDir)) {
                $hooksDir = Join-Path (git -C "$root" rev-parse --show-toplevel) $hooksDir
            }
        }
    }
    New-Item -ItemType Directory -Path $hooksDir -Force | Out-Null
    $hook   = Join-Path $hooksDir 'commit-msg'
    $marker = '# blueprint:no-ai-attribution'
    if ((Test-Path -LiteralPath $hook) -and (Select-String -LiteralPath $hook -SimpleMatch $marker -Quiet)) {
        Write-Host "OK: no-AI-attribution commit-msg hook already installed."; return
    }
    if ((Test-Path -LiteralPath $hook) -and -not (Test-Path -LiteralPath "$hook.pre-blueprint")) {
        Move-Item -LiteralPath $hook -Destination "$hook.pre-blueprint" -Force
        Write-Host "OK: chained existing commit-msg hook (backup: commit-msg.pre-blueprint)."
    }
    $body = @(
        '#!/bin/sh',
        '# blueprint:no-ai-attribution',
        '# Strip AI co-author / attribution trailers from the message, then run any chained hook.',
        'f="$1"; [ -f "$f" ] || exit 0',
        'tmp="$f.bp.$$"',
        'grep -ivE ''^[[:space:]]*co-authored-by:.*(noreply@anthropic\.com|claude\[bot\])'' "$f" | grep -ivE ''generated with \[claude code\]'' > "$tmp"',
        'mv "$tmp" "$f"',
        'd="$(dirname "$0")"',
        '[ -x "$d/commit-msg.pre-blueprint" ] && exec "$d/commit-msg.pre-blueprint" "$@"',
        'exit 0'
    ) -join "`n"
    [IO.File]::WriteAllText($hook, $body + "`n", (New-Object Text.UTF8Encoding($false)))
    Write-Host "OK: installed no-AI-attribution commit-msg hook -> $hook"
}
Install-CommitMsgHook $projectRoot

Write-Host "Setup done."
