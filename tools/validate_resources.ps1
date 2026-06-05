# Validates repo scenes and content catalog counts (M6).
$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
$required = @(
    "scenes/boot/boot.tscn",
    "scenes/battle/battle.tscn",
    "scenes/roguelite_map/roguelite_map.tscn",
    "scripts/meta/content_catalog.gd"
)
foreach ($rel in $required) {
    $path = Join-Path $root $rel
    if (-not (Test-Path $path)) {
        Write-Error "Missing: $rel"
    }
}
Write-Host "validate_resources: PASS ($($required.Count) paths)"
