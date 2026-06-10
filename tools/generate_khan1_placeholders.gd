@tool
extends EditorScript

## Run: godot --headless --path . --script res://tools/generate_khan1_placeholders.gd
## Creates simple silhouette PNGs for Khan 1 entities when art is missing.

const OUT_DIR := "res://art/_placeholders/khan1/"
const ENTITIES: Dictionary = {
	"rostam": Color(0.2, 0.45, 0.85),
	"zal": Color(0.55, 0.75, 0.9),
	"sohrab": Color(0.9, 0.45, 0.25),
	"tower_archer": Color(0.2, 0.7, 0.6),
	"tower_sacred_fire": Color(1.0, 0.55, 0.2),
	"tower_heavy": Color(0.5, 0.45, 0.4),
	"tower_control": Color(0.35, 0.5, 0.85),
	"enemy_jackal": Color(0.55, 0.4, 0.25),
	"enemy_boar": Color(0.45, 0.32, 0.28),
	"enemy_corruptor": Color(0.35, 0.15, 0.45),
	"enemy_lion_boss": Color(0.85, 0.55, 0.15),
}


func _run() -> void:
	var dir := DirAccess.open("res://art/_placeholders/")
	if dir:
		dir.make_dir_recursive("khan1")
	for entity_id in ENTITIES.keys():
		var path := OUT_DIR + entity_id + ".png"
		if ResourceLoader.exists(path):
			continue
		var img := Image.create(32, 32, false, Image.FORMAT_RGBA8)
		img.fill(Color(0, 0, 0, 0))
		var c: Color = ENTITIES[entity_id]
		for y in 32:
			for x in 32:
				var dx := x - 16
				var dy := y - 16
				if dx * dx + dy * dy <= 196:
					img.set_pixel(x, y, c)
		img.save_png(ProjectSettings.globalize_path(path))
		print("Wrote ", path)
