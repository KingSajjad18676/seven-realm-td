$ErrorActionPreference = "Stop"
$LevelIds = @(
    "level_02", "level_03", "level_04", "level_05",
    "level_06", "level_07", "level_08_damavand"
)
$Paths = @{
    "level_02" = @(@(60,380),@(300,380),@(500,300),@(700,300),@(900,380),@(1200,380))
    "level_03" = @(@(80,200),@(350,200),@(500,360),@(700,360),@(850,200),@(1100,200),@(1200,360))
    "level_04" = @(@(100,360),@(350,480),@(550,360),@(750,240),@(950,360),@(1150,360))
    "level_05" = @(@(80,300),@(400,300),@(600,450),@(800,300),@(1000,450),@(1250,300))
    "level_06" = @(@(100,250),@(400,250),@(550,400),@(750,400),@(900,250),@(1150,250),@(1250,400))
    "level_07" = @(@(120,200),@(450,200),@(600,380),@(800,380),@(950,200),@(1200,200),@(1280,380))
    "level_08_damavand" = @(@(100,360),@(400,360),@(600,200),@(800,200),@(1000,360),@(1200,360),@(1400,280))
}
$Margin = 48
$ViewW = 1280
$ViewH = 720
$OutDir = Join-Path $PSScriptRoot "..\resources\data\levels"

function Scale-Path($points) {
    $xs = $points | ForEach-Object { $_[0] }
    $ys = $points | ForEach-Object { $_[1] }
    $minX = ($xs | Measure-Object -Minimum).Minimum
    $maxX = ($xs | Measure-Object -Maximum).Maximum
    $minY = ($ys | Measure-Object -Minimum).Minimum
    $maxY = ($ys | Measure-Object -Maximum).Maximum
    $sw = [Math]::Max($maxX - $minX, 1)
    $sh = [Math]::Max($maxY - $minY, 1)
    $dw = $ViewW - 2 * $Margin
    $dh = $ViewH - 2 * $Margin
    $s = [Math]::Min($dw / $sw, $dh / $sh)
    $scaled = @()
    foreach ($p in $points) {
        $scaled += ,@(
            [Math]::Round($Margin + ($p[0] - $minX) * $s, 1),
            [Math]::Round($Margin + ($p[1] - $minY) * $s, 1)
        )
    }
    return $scaled
}

function Pads-Along-Path($path, $count) {
    $pads = @()
    for ($i = 0; $i -lt $count; $i++) {
        $t = ($i + 1) / ($count + 1)
        $idx = [Math]::Min([int]($t * ($path.Count - 1)), $path.Count - 1)
        $side = if ($i % 2 -eq 0) { 1 } else { -1 }
        $px = $path[$idx][0] + 40 * $side
        $py = $path[$idx][1] - 60
        $pads += ,@([Math]::Round($px, 1), [Math]::Round($py, 1))
    }
    return $pads
}

function Vec2List($points) {
    return (($points | ForEach-Object { "Vector2($($_[0]), $($_[1]))" }) -join ", ")
}

foreach ($lid in $LevelIds) {
    $khan = [array]::IndexOf($LevelIds, $lid) + 2
    $scaled = Scale-Path $Paths[$lid]
    $padCount = if ($khan -le 4) { 6 } else { 8 }
    $pads = Pads-Along-Path $scaled $padCount
    $gate = @([Math]::Round($scaled[-1][0] + 20, 1), [Math]::Round($scaled[-1][1] - 10, 1))
    $spawn = @([Math]::Round($scaled[0][0] - 20, 1), $scaled[0][1])
    $routes = @(@{ id = "route_main"; points = $scaled })
    $spawns = @(@{ id = "spawn_main"; pos = $spawn; route = "route_main" })
    if ($khan -ge 3) {
        $lateral = if ($khan -lt 5) { 70 } else { 90 }
        $fork = @()
        foreach ($p in $scaled) {
            $fork += ,@(
                [Math]::Round($p[0] + $lateral * 0.35, 1),
                [Math]::Round($p[1] + $lateral, 1)
            )
        }
        $routes += @{ id = "route_2"; points = $fork }
        $spawns += @{ id = "spawn_2"; pos = @([Math]::Round($fork[0][0] - 20, 1), $fork[0][1]); route = "route_2" }
    }

    $sb = New-Object System.Text.StringBuilder
    [void]$sb.AppendLine('[gd_resource type="Resource" script_class="LevelData" load_steps=4 format=3]')
    [void]$sb.AppendLine('')
    [void]$sb.AppendLine('[ext_resource type="Script" path="res://scripts/data/level_data.gd" id="1"]')
    [void]$sb.AppendLine('[ext_resource type="Script" path="res://scripts/data/path_route_data.gd" id="2"]')
    [void]$sb.AppendLine('[ext_resource type="Script" path="res://scripts/data/spawn_point_data.gd" id="3"]')
    [void]$sb.AppendLine('')
    for ($i = 0; $i -lt $routes.Count; $i++) {
        [void]$sb.AppendLine("[sub_resource type=`"Resource`" id=`"Route_$i`"]")
        [void]$sb.AppendLine('script = ExtResource("2")')
        [void]$sb.AppendLine("route_id = `"$($routes[$i].id)`"")
        [void]$sb.AppendLine("points = Array[Vector2]([$(Vec2List $routes[$i].points)])")
        [void]$sb.AppendLine('')
    }
    for ($i = 0; $i -lt $spawns.Count; $i++) {
        $sp = $spawns[$i]
        [void]$sb.AppendLine("[sub_resource type=`"Resource`" id=`"Spawn_$i`"]")
        [void]$sb.AppendLine('script = ExtResource("3")')
        [void]$sb.AppendLine("spawn_id = `"$($sp.id)`"")
        [void]$sb.AppendLine("position = Vector2($($sp.pos[0]), $($sp.pos[1]))")
        [void]$sb.AppendLine("route_id = `"$($sp.route)`"")
        [void]$sb.AppendLine('')
    }
    $routeRefs = (0..($routes.Count - 1) | ForEach-Object { "SubResource(`"Route_$_`")" }) -join ", "
    $spawnRefs = (0..($spawns.Count-1) | ForEach-Object { "SubResource(`"Spawn_$_`")" }) -join ", "
    [void]$sb.AppendLine('[resource]')
    [void]$sb.AppendLine('script = ExtResource("1")')
    [void]$sb.AppendLine("level_id = `"$lid`"")
    if ($lid -eq "level_02") {
        [void]$sb.AppendLine('starting_gold = 175')
        [void]$sb.AppendLine('starting_sacred_fire = 6')
        [void]$sb.AppendLine('default_objective_id = "obj_cleanse_twice"')
    }
    [void]$sb.AppendLine("path_routes = Array[ExtResource(`"2`")]([$routeRefs])")
    [void]$sb.AppendLine("spawn_points = Array[ExtResource(`"3`")]([$spawnRefs])")
    [void]$sb.AppendLine("build_spot_positions = Array[Vector2]([$(Vec2List $pads)])")
    [void]$sb.AppendLine("path_points = Array[Vector2]([$(Vec2List $scaled)])")
    [void]$sb.AppendLine("gate_position = Vector2($($gate[0]), $($gate[1]))")
    [void]$sb.AppendLine("spawn_position = Vector2($($spawn[0]), $($spawn[1]))")
    [void]$sb.AppendLine("map_sprite_path = `"res://art/_placeholders/maps/$lid.png`"")
    [void]$sb.AppendLine('')
    $outPath = Join-Path $OutDir "$lid.tres"
    Set-Content -Path $outPath -Value $sb.ToString() -Encoding utf8
    Write-Host "Wrote $outPath"
}
