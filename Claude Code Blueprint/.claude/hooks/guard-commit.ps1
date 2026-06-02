# guard-commit.ps1: PreToolUse (Bash) on Windows.
# Denies a git commit that skips hooks (--no-verify / -n / -nm / inline core.hooksPath), so the
# deterministic no-AI-attribution commit-msg hook can never be bypassed. Allows everything else.
# Message text is de-quoted first, so a commit message that mentions these flags never trips it.
$ErrorActionPreference = 'Stop'
try {
    $raw = [Console]::In.ReadToEnd()
    if (-not $raw) { exit 0 }
    $cmd = ($raw | ConvertFrom-Json).tool_input.command
    if (-not $cmd) { exit 0 }
    # drop double- and single-quoted spans (message text)
    $dq = [regex]::Replace($cmd, '"[^"]*"', ' Q ')
    $dq = [regex]::Replace($dq, "'[^']*'", ' Q ')
    $deny = $false
    foreach ($seg in ($dq -split '[;|&]')) {
        if ($seg -match 'git' -and $seg -match '(^|\s)commit(\s|$|")' -and
            $seg -match '(--no-verify|(^|\s)-[A-Za-z]*n|core\.hooksPath)') { $deny = $true }
    }
    if (-not $deny) { exit 0 }
    $reason = "Blocked: this git commit skips hooks (--no-verify/-n or an inline core.hooksPath), which would bypass the no-AI-attribution commit-msg hook. Commit normally; the hook strips any AI co-author trailer for you."
    @{ hookSpecificOutput = @{
        hookEventName            = "PreToolUse"
        permissionDecision       = "deny"
        permissionDecisionReason = $reason
    } } | ConvertTo-Json -Compress | Write-Output
    exit 0
}
catch { exit 0 }
