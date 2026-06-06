# SessionStart hook (Windows): inject the using-the-brain bootstrap as additionalContext JSON, so
# skills auto-trigger and the AI orients before acting. Mirrors session-start.sh. ConvertTo-Json
# handles string escaping.
$ErrorActionPreference = 'Stop'

$pluginRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$skillPath  = Join-Path $pluginRoot 'skills\using-the-brain\SKILL.md'
$content = if (Test-Path -LiteralPath $skillPath) {
    Get-Content -LiteralPath $skillPath -Raw -Encoding UTF8
} else {
    'Error reading using-the-brain skill'
}

$intro = "<EXTREMELY_IMPORTANT>`nYou have an AI second brain.`n`n**Below is your 'using-the-brain' skill: your introduction to orienting and to using skills. For all other skills, use the Skill tool:**`n`n" + $content + "`n</EXTREMELY_IMPORTANT>"

$out = @{
    hookSpecificOutput = @{
        hookEventName     = 'SessionStart'
        additionalContext = $intro
    }
} | ConvertTo-Json -Compress -Depth 5

Write-Output $out
exit 0
