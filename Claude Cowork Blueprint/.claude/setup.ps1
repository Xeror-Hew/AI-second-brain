# setup.ps1: link Claude Code's memory into this project (junction).
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

# 4) .gitignore: only if this is a git repo. Most knowledge-work projects have no git, so there is
#    nothing to ignore; if the project does version its Claude config, ignore only the always-local
#    pieces (the memory junction).
$hasGit = [bool](Get-Command git -ErrorAction SilentlyContinue)
$isRepo = $false
if ($hasGit) {
    git -C "$projectRoot" rev-parse --git-dir 2>$null | Out-Null
    $isRepo = ($LASTEXITCODE -eq 0)
}
if ($isRepo) {
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
} else {
    Write-Host "OK: no git repo; skipped .gitignore (nothing to ignore)."
}

Write-Host "Setup done."
