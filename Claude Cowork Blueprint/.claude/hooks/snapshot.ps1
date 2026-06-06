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

    # Living .md docs under project_brain/ (any depth), excluding history/, memory/, roadmap/, notes/
    # (roadmap/ keeps its own history in roadmap_log; no snapshot needed)
    if ([IO.Path]::GetExtension($filePath) -ne '.md') { exit 0 }
    $norm  = ($filePath -replace '/', '\')
    $lower = $norm.ToLower()
    $marker = '\project_brain\'
    $idx = $lower.IndexOf($marker)
    if ($idx -lt 0) { exit 0 }

    $devRoot = $norm.Substring(0, $idx + $marker.Length - 1)   # ...\project_brain

    # history/ and memory/ are engine folders (canonical); roadmap/ and notes/ may be localized,
    # their physical names living in project_brain/.brain.json. Resolve so the exclusion still holds.
    $roadmapDir = 'roadmap'; $notesDir = 'notes'
    $manifestPath = Join-Path $devRoot '.brain.json'
    if (Test-Path -LiteralPath $manifestPath) {
        try {
            $names = (Get-Content -LiteralPath $manifestPath -Raw -ErrorAction Stop | ConvertFrom-Json).names
            if ($names.roadmap) { $roadmapDir = [string]$names.roadmap }
            if ($names.notes)   { $notesDir   = [string]$names.notes }
        } catch {}
    }
    if (($lower -like '*\history\*') -or ($lower -like '*\memory\*') -or `
        ($lower -like "*\$($roadmapDir.ToLower())\*") -or ($lower -like "*\$($notesDir.ToLower())\*")) { exit 0 }

    $base    = [IO.Path]::GetFileNameWithoutExtension($filePath)
    $snapDir = Join-Path (Join-Path $devRoot 'history') $base

    if (Test-Path -LiteralPath $snapDir) {
        # ISO names sort lexically = chronologically. Read the time from the NAME
        # (Copy-Item preserves the source mtime, so mtime is no clock here).
        $last = Get-ChildItem -LiteralPath $snapDir -Filter '*.md' -File -ErrorAction SilentlyContinue |
                Sort-Object Name -Descending | Select-Object -First 1
        if ($last -and $last.BaseName -match '(\d{4}-\d{2}-\d{2}T\d{2}-\d{2}-\d{2})$') {
            # Stamp is UTC (matches brain.mjs / snapshot-all.mjs); parse as UTC and compare to UtcNow,
            # so the cooldown clock is shared across all writers regardless of the local timezone.
            $lastTime = [datetime]::ParseExact($Matches[1], 'yyyy-MM-ddTHH-mm-ss', [Globalization.CultureInfo]::InvariantCulture, [Globalization.DateTimeStyles]::AssumeUniversal -bor [Globalization.DateTimeStyles]::AdjustToUniversal)
            $ageMin = ([datetime]::UtcNow - $lastTime).TotalMinutes
            if ($ageMin -ge 0 -and $ageMin -lt $CooldownMinutes) {
                exit 0   # inside the cooldown window: skip (a future-dated stamp never suppresses)
            }
        }
    } else {
        New-Item -ItemType Directory -Path $snapDir -Force | Out-Null
    }

    $stamp = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH-mm-ss')   # UTC (matches brain.mjs); no ':', illegal on Windows
    $dest  = Join-Path $snapDir "$base $stamp.md"
    Copy-Item -LiteralPath $filePath -Destination $dest -Force
    # Copy-Item preserves the source mtime; reset it to now so the snapshot's mtime equals its creation
    # time. snapshot.sh keys its cooldown off mtime, so this keeps the shared clock honest when one
    # history/ is touched by both a PowerShell and a bash surface.
    (Get-Item -LiteralPath $dest).LastWriteTime = Get-Date
    exit 0
}
catch {
    [Console]::Error.WriteLine("snapshot.ps1: $($_.Exception.Message)")
    exit 0
}
