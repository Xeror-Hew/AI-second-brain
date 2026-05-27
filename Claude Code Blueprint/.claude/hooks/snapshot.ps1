# snapshot.ps1: PreToolUse hook (Edit/Write)
# Before a living .md doc under project_brain/ gets edited, freeze the "before" into
# project_brain/history/<name>/<name> YYYY-MM-DDTHH-mm-ss.md
# Cooldown: at most 1 snapshot per file every $CooldownMinutes.
# Never blocks the edit (always exit 0); failures go to stderr.

$ErrorActionPreference = 'Stop'
$CooldownMinutes = 20   # {{TUNE_THE_THRESHOLD}}

try {
    $raw = [Console]::In.ReadToEnd()
    if (-not $raw) { exit 0 }
    $payload = $raw | ConvertFrom-Json

    $filePath = $payload.tool_input.file_path
    if (-not $filePath) { exit 0 }

    # Nothing to snapshot unless the file already exists (Write creating a new file = nothing to save)
    if (-not (Test-Path -LiteralPath $filePath)) { exit 0 }

    # Living .md docs under project_brain/ (any depth), excluding history/, memory/, roadmap/, ideas/
    # (roadmap/ keeps its own history in roadmap_log; no snapshot needed)
    if ([IO.Path]::GetExtension($filePath) -ne '.md') { exit 0 }
    $norm  = ($filePath -replace '/', '\')
    $lower = $norm.ToLower()
    $marker = '\project_brain\'
    $idx = $lower.IndexOf($marker)
    if ($idx -lt 0) { exit 0 }
    if (($lower -like '*\history\*') -or ($lower -like '*\memory\*') -or ($lower -like '*\roadmap\*') -or ($lower -like '*\ideas\*')) { exit 0 }

    $devRoot = $norm.Substring(0, $idx + $marker.Length - 1)   # ...\project_brain
    $base    = [IO.Path]::GetFileNameWithoutExtension($filePath)
    $snapDir = Join-Path (Join-Path $devRoot 'history') $base

    if (Test-Path -LiteralPath $snapDir) {
        # ISO names sort lexically = chronologically. Read the time from the NAME
        # (Copy-Item preserves the source mtime, so mtime is no clock here).
        $last = Get-ChildItem -LiteralPath $snapDir -Filter '*.md' -File -ErrorAction SilentlyContinue |
                Sort-Object Name -Descending | Select-Object -First 1
        if ($last -and $last.BaseName -match '(\d{4}-\d{2}-\d{2}T\d{2}-\d{2}-\d{2})$') {
            $lastTime = [datetime]::ParseExact($Matches[1], 'yyyy-MM-ddTHH-mm-ss', $null)
            if (((Get-Date) - $lastTime).TotalMinutes -lt $CooldownMinutes) {
                exit 0   # inside the cooldown window: skip
            }
        }
    } else {
        New-Item -ItemType Directory -Path $snapDir -Force | Out-Null
    }

    $stamp = Get-Date -Format 'yyyy-MM-ddTHH-mm-ss'   # no ':', illegal on Windows
    $dest  = Join-Path $snapDir "$base $stamp.md"
    Copy-Item -LiteralPath $filePath -Destination $dest -Force
    exit 0
}
catch {
    [Console]::Error.WriteLine("snapshot.ps1: $($_.Exception.Message)")
    exit 0
}
