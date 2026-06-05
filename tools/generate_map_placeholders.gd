extends SceneTree

## Generate map placeholder PNGs (1280×720) under art/_placeholders/maps/.
##
## From repo root (Godot on PATH):
##   godot --headless --path . --script res://tools/generate_map_placeholders.gd
##
## Or run: powershell -File tools/generate_map_placeholders.ps1


const LEVEL_IDS: Array[String] = [
	"level_00_tutorial",
	"level_01",
	"level_02",
	"level_03",
	"level_04",
	"level_05",
	"level_06",
	"level_07",
	"level_08_damavand",
]


func _init() -> void:
	var dir := "res://art/_placeholders/maps/"
	var abs_dir := ProjectSettings.globalize_path(dir)
	var mkdir_err := DirAccess.make_dir_recursive_absolute(abs_dir)
	if mkdir_err != OK:
		push_error("Failed to create %s (error %d)" % [dir, mkdir_err])
		quit(1)
		return

	for level_id in LEVEL_IDS:
		var img := Image.create(1280, 720, false, Image.FORMAT_RGBA8)
		img.fill(VisualAssetLoader.map_terrain_color(level_id))
		var path := dir + level_id + ".png"
		var save_err := img.save_png(ProjectSettings.globalize_path(path))
		if save_err != OK:
			push_error("Failed to write %s (error %d)" % [path, save_err])
			quit(1)
			return
		print("Wrote ", path)
	print("Map placeholders generated.")
	quit(0)
