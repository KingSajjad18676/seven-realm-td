extends SceneTree

## Generate map placeholder PNGs (1280×720) under art/_placeholders/maps/.
##
## From repo root (Godot on PATH):
##   godot --headless --path . --script res://tools/generate_map_placeholders.gd
##
## Or run: powershell -File tools/generate_map_placeholders.ps1

const BRIGHTEN_AMOUNT := 0.08
const PATH_COLOR := Color(0.72, 0.58, 0.38, 1.0)
const PATH_WIDTH := 12
const SPAWN_COLOR := Color(0.35, 0.55, 0.9, 1.0)
const GATE_COLOR := Color(0.85, 0.72, 0.35, 1.0)


func _init() -> void:
	var dir := "res://art/_placeholders/maps/"
	var abs_dir := ProjectSettings.globalize_path(dir)
	var mkdir_err := DirAccess.make_dir_recursive_absolute(abs_dir)
	if mkdir_err != OK:
		push_error("Failed to create %s (error %d)" % [dir, mkdir_err])
		quit(1)
		return

	for level in ContentCatalog.build_levels():
		var img := _build_map_image(level)
		var path := dir + level.level_id + ".png"
		var save_err := img.save_png(ProjectSettings.globalize_path(path))
		if save_err != OK:
			push_error("Failed to write %s (error %d)" % [path, save_err])
			quit(1)
			return
		print("Wrote ", path)
	print("Map placeholders generated.")
	quit(0)


func _build_map_image(level: LevelData) -> Image:
	var base := VisualAssetLoader.map_terrain_color(level.level_id)
	var img := Image.create(1280, 720, false, Image.FORMAT_RGBA8)
	img.fill(_brighten(base))
	_draw_path(img, level.path_points)
	_draw_marker(img, level.spawn_position, SPAWN_COLOR, Vector2i(28, 56))
	_draw_marker(img, level.gate_position, GATE_COLOR, Vector2i(40, 80))
	return img


func _brighten(color: Color) -> Color:
	return Color(
		clampf(color.r + BRIGHTEN_AMOUNT, 0.0, 1.0),
		clampf(color.g + BRIGHTEN_AMOUNT, 0.0, 1.0),
		clampf(color.b + BRIGHTEN_AMOUNT, 0.0, 1.0),
		1.0
	)


func _draw_path(img: Image, points: Array[Vector2]) -> void:
	if points.size() < 2:
		return
	for i in range(points.size() - 1):
		_draw_thick_line(img, points[i], points[i + 1], PATH_COLOR, PATH_WIDTH)


func _draw_thick_line(img: Image, from: Vector2, to: Vector2, color: Color, width: int) -> void:
	var steps := int(from.distance_to(to))
	for step in range(steps + 1):
		var t := float(step) / float(maxi(1, steps))
		var point := from.lerp(to, t)
		var half := width / 2
		img.fill_rect(
			Rect2i(int(point.x - half), int(point.y - half), width, width),
			color
		)


func _draw_marker(img: Image, center: Vector2, color: Color, size: Vector2i) -> void:
	var top_left := Vector2i(
		int(center.x - size.x / 2),
		int(center.y - size.y / 2)
	)
	img.fill_rect(Rect2i(top_left, size), color)
