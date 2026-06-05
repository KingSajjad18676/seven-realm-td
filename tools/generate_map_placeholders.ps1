# Creates 1280x720 map placeholder PNGs (no Godot required).
$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Drawing

$root = Split-Path -Parent $PSScriptRoot
$outDir = Join-Path $root "art\_placeholders\maps"
New-Item -ItemType Directory -Force -Path $outDir | Out-Null

$levels = @{
	"level_00_tutorial" = @(0.18, 0.28, 0.20)
	"level_01"          = @(0.15, 0.22, 0.14)
	"level_02"          = @(0.28, 0.22, 0.14)
	"level_03"          = @(0.12, 0.20, 0.18)
	"level_04"          = @(0.20, 0.14, 0.22)
	"level_05"          = @(0.22, 0.18, 0.12)
	"level_06"          = @(0.14, 0.14, 0.20)
	"level_07"          = @(0.20, 0.22, 0.26)
	"level_08_damavand" = @(0.10, 0.12, 0.18)
}

$width = 1280
$height = 720

foreach ($entry in $levels.GetEnumerator()) {
	$levelId = $entry.Key
	$rgb = $entry.Value
	$color = [System.Drawing.Color]::FromArgb(
		255,
		[int][Math]::Round($rgb[0] * 255),
		[int][Math]::Round($rgb[1] * 255),
		[int][Math]::Round($rgb[2] * 255)
	)

	$bmp = New-Object System.Drawing.Bitmap $width, $height
	$graphics = [System.Drawing.Graphics]::FromImage($bmp)
	$brush = New-Object System.Drawing.SolidBrush $color
	$graphics.FillRectangle($brush, 0, 0, $width, $height)
	$graphics.Dispose()
	$brush.Dispose()

	$path = Join-Path $outDir "$levelId.png"
	$bmp.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
	$bmp.Dispose()
	Write-Host "Wrote $path"
}

Write-Host "Map placeholders generated in $outDir"
