# Creates 1280x720 map placeholder PNGs with path, spawn, and gate markers.
$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Drawing

$root = Split-Path -Parent $PSScriptRoot
$outDir = Join-Path $root "art\_placeholders\maps"
New-Item -ItemType Directory -Force -Path $outDir | Out-Null

$brighten = 0.08
$pathColor = [System.Drawing.Color]::FromArgb(255, 184, 148, 97)
$spawnColor = [System.Drawing.Color]::FromArgb(255, 89, 140, 230)
$gateColor = [System.Drawing.Color]::FromArgb(255, 217, 184, 89)
$pathWidth = 12

function Brighten-Rgb($rgb) {
	return @(
		[Math]::Min(1.0, $rgb[0] + $brighten),
		[Math]::Min(1.0, $rgb[1] + $brighten),
		[Math]::Min(1.0, $rgb[2] + $brighten)
	)
}

function To-Color($rgb) {
	$bright = Brighten-Rgb $rgb
	return [System.Drawing.Color]::FromArgb(
		255,
		[int][Math]::Round($bright[0] * 255),
		[int][Math]::Round($bright[1] * 255),
		[int][Math]::Round($bright[2] * 255)
	)
}

function Draw-ThickLine($graphics, $from, $to, $color, $width) {
	$pen = New-Object System.Drawing.Pen $color, $width
	$pen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
	$pen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
	$graphics.DrawLine($pen, $from.X, $from.Y, $to.X, $to.Y)
	$pen.Dispose()
}

function Draw-Marker($graphics, $center, $color, $size) {
	$brush = New-Object System.Drawing.SolidBrush $color
	$rect = New-Object System.Drawing.Rectangle (
		[int]($center.X - $size.Width / 2),
		[int]($center.Y - $size.Height / 2),
		$size.Width,
		$size.Height
	)
	$graphics.FillRectangle($brush, $rect)
	$brush.Dispose()
}

$levels = @{
	"level_00_tutorial" = @{
		rgb = @(0.18, 0.28, 0.20)
		path = @(
			@(80, 360), @(280, 360), @(400, 260), @(640, 260),
			@(760, 360), @(980, 360), @(1180, 360)
		)
		spawn = @(80, 360)
		gate = @(1180, 360)
	}
	"level_01" = @{
		rgb = @(0.15, 0.22, 0.14)
		path = @(
			@(80, 360), @(280, 360), @(400, 260), @(640, 260),
			@(760, 360), @(980, 360), @(1180, 360)
		)
		spawn = @(80, 360)
		gate = @(1180, 360)
	}
	"level_02" = @{
		rgb = @(0.28, 0.22, 0.14)
		path = @(@(60, 380), @(300, 380), @(500, 300), @(700, 300), @(900, 380), @(1200, 380))
		spawn = @(60, 380)
		gate = @(1200, 380)
	}
	"level_03" = @{
		rgb = @(0.12, 0.20, 0.18)
		path = @(@(80, 200), @(350, 200), @(500, 360), @(700, 360), @(850, 200), @(1100, 200), @(1200, 360))
		spawn = @(80, 200)
		gate = @(1200, 360)
	}
	"level_04" = @{
		rgb = @(0.20, 0.14, 0.22)
		path = @(@(100, 360), @(350, 480), @(550, 360), @(750, 240), @(950, 360), @(1150, 360))
		spawn = @(100, 360)
		gate = @(1150, 360)
	}
	"level_05" = @{
		rgb = @(0.22, 0.18, 0.12)
		path = @(@(80, 300), @(400, 300), @(600, 450), @(800, 300), @(1000, 450), @(1250, 300))
		spawn = @(80, 300)
		gate = @(1250, 300)
	}
	"level_06" = @{
		rgb = @(0.14, 0.14, 0.20)
		path = @(@(100, 250), @(400, 250), @(550, 400), @(750, 400), @(900, 250), @(1150, 250), @(1250, 400))
		spawn = @(100, 250)
		gate = @(1250, 400)
	}
	"level_07" = @{
		rgb = @(0.20, 0.22, 0.26)
		path = @(@(120, 200), @(450, 200), @(600, 380), @(800, 380), @(950, 200), @(1200, 200), @(1280, 380))
		spawn = @(120, 200)
		gate = @(1280, 380)
	}
	"level_08_damavand" = @{
		rgb = @(0.10, 0.12, 0.18)
		path = @(@(100, 360), @(400, 360), @(600, 200), @(800, 200), @(1000, 360), @(1200, 360), @(1400, 280))
		spawn = @(100, 360)
		gate = @(1400, 280)
	}
}

$width = 1280
$height = 720

foreach ($entry in $levels.GetEnumerator()) {
	$levelId = $entry.Key
	$config = $entry.Value
	$color = To-Color $config.rgb

	$bmp = New-Object System.Drawing.Bitmap $width, $height
	$graphics = [System.Drawing.Graphics]::FromImage($bmp)
	$graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
	$brush = New-Object System.Drawing.SolidBrush $color
	$graphics.FillRectangle($brush, 0, 0, $width, $height)
	$brush.Dispose()

	$points = $config.path
	for ($i = 0; $i -lt ($points.Count - 1); $i++) {
		$from = New-Object System.Drawing.PointF $points[$i][0], $points[$i][1]
		$to = New-Object System.Drawing.PointF $points[$i + 1][0], $points[$i + 1][1]
		Draw-ThickLine $graphics $from $to $pathColor $pathWidth
	}

	$spawn = New-Object System.Drawing.PointF $config.spawn[0], $config.spawn[1]
	$gate = New-Object System.Drawing.PointF $config.gate[0], $config.gate[1]
	Draw-Marker $graphics $spawn $spawnColor ([System.Drawing.Size]::new(28, 56))
	Draw-Marker $graphics $gate $gateColor ([System.Drawing.Size]::new(40, 80))

	$graphics.Dispose()

	$path = Join-Path $outDir "$levelId.png"
	$bmp.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
	$bmp.Dispose()
	Write-Host "Wrote $path"
}

Write-Host "Map placeholders generated in $outDir"
