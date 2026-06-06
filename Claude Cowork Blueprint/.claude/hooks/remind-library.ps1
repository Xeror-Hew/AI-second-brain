# remind-library.ps1: PostToolUse hook (Edit/Write)
# After a deliverable file gets edited (outside the brain's managed folders), inject a reminder
# (does NOT block): close out the task with /done if it's finished, and update the library if you
# produced or reshaped a deliverable. Cooldown avoids nagging on every edit. Always exit 0.
# The reminder reaches the AI via hookSpecificOutput.additionalContext.

$ErrorActionPreference = 'Stop'
$CooldownMinutes = 30   # {{TUNE_THE_THRESHOLD}}

try {
    $raw = [Console]::In.ReadToEnd()
    if (-not $raw) { exit 0 }
    $payload = $raw | ConvertFrom-Json

    $filePath = $payload.tool_input.file_path
    if (-not $filePath) { exit 0 }
    $lower = ($filePath -replace '/', '\').ToLower()

    # Deliverables only: skip the brain's own managed/infra folders (those have their own upkeep).
    if (($lower -like '*\project_brain\*') -or ($lower -like '*\.claude\*') -or
        ($lower -like '*\.obsidian\*') -or ($lower -like '*\.git\*')) { exit 0 }

    # Cooldown via stamp file (mtime is reliable: we write the stamp right now).
    $projectDir = $env:CLAUDE_PROJECT_DIR
    if (-not $projectDir) { $projectDir = (Get-Location).Path }
    $stamp = Join-Path $projectDir '.claude\.library_reminder.stamp'
    if (Test-Path -LiteralPath $stamp) {
        $age = ((Get-Date) - (Get-Item -LiteralPath $stamp).LastWriteTime).TotalMinutes
        if ($age -lt $CooldownMinutes) { exit 0 }
    }
    Set-Content -LiteralPath $stamp -Value (Get-Date -Format 'o') -Force

    $msg = "You edited a deliverable. If that finished a task, close it out now with /done (log it, prune the roadmap, set the next step, and update the library if you produced or reshaped a deliverable) while the context is fresh. A small in-progress tweak: ignore."
    $out = @{
        hookSpecificOutput = @{
            hookEventName     = "PostToolUse"
            additionalContext = $msg
        }
    } | ConvertTo-Json -Compress
    Write-Output $out
    exit 0
}
catch {
    [Console]::Error.WriteLine("remind-library.ps1: $($_.Exception.Message)")
    exit 0
}
