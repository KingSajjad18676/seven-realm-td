@tool
extends EditorScript

## Run: godot --headless --path . --script res://tools/generate_map_placeholders.gd

const MAP_DIR := "res://art/_placeholders/maps/"
const LOADING_DIR := "res://art/_placeholders/loading/"
const LEVEL_IDS: Array[String] = [
	"level_00_tutorial", "level_01", "level_02", "level_03", "level_04",
	"level_05", "level_06", "level_07", "level_08_damavand",
]


func _run() -> void:
	var root := DirAccess.open("res://art/_placeholders/")
	if root:
		root.make_dir_recursive("maps")
		root.make_dir_recursive("loading")
	for level_id in LEVEL_IDS:
		var tint := VisualAssetLoader.map_terrain_color(level_id)
		_write_map_png(MAP_DIR + level_id + ".png", tint, false)
		_write_map_png(LOADING_DIR + level_id + ".png", tint.lightened(0.15), true)
		print("Wrote placeholders for ", level_id)


func _write_map_png(path: String, base: Color, loading: bool) -> void:
	if ResourceLoader.exists(path):
		return
	var w := 640 if loading else 1280
	var h := 360 if loading else 720
	var img := Image.create(w, h, false, Image.FORMAT_RGBA8)
	for y in h:
		for x in w:
			var t := float(y) / float(h)
			var c := base.lerp(base.darkened(0.25), t)
			if loading:
				c = c.lerp(Color(0.08, 0.1, 0.14), 0.35)
			img.set_pixel(x, y, c)
	img.save_png(ProjectSettings.globalize_path(path))
