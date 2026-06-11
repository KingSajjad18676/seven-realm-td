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
	"gordafarid": Color(0.75, 0.35, 0.65),
	"esfandiyar": Color(0.55, 0.55, 0.7),
	"enemy_mirage_shade": Color(0.6, 0.75, 0.85),
	"enemy_salt_crust_brute": Color(0.7, 0.65, 0.5),
	"enemy_thirst_manifest": Color(0.5, 0.4, 0.7),
	"enemy_canyon_serpent": Color(0.35, 0.6, 0.4),
	"enemy_scorched_hound": Color(0.55, 0.3, 0.2),
	"enemy_azhdaha": Color(0.3, 0.55, 0.35),
	"enemy_illusion_attendant": Color(0.65, 0.45, 0.75),
	"enemy_feast_shade": Color(0.45, 0.25, 0.55),
	"enemy_sorceress": Color(0.7, 0.35, 0.8),
	"enemy_mountain_raider": Color(0.5, 0.45, 0.4),
	"enemy_mountain_archer": Color(0.45, 0.5, 0.55),
	"enemy_olad_champion": Color(0.6, 0.5, 0.35),
	"enemy_div_infantry": Color(0.4, 0.35, 0.5),
	"enemy_div_brute": Color(0.35, 0.3, 0.45),
	"enemy_div_corruptor": Color(0.5, 0.2, 0.55),
	"enemy_arzhang_div": Color(0.55, 0.25, 0.6),
	"enemy_white_div_thrall": Color(0.75, 0.78, 0.85),
	"enemy_cavern_boulder_brute": Color(0.45, 0.42, 0.38),
	"enemy_white_div": Color(0.85, 0.88, 0.95),
	"enemy_zahhak_serpent_guard": Color(0.4, 0.55, 0.3),
	"enemy_chainbreaker_div": Color(0.55, 0.35, 0.45),
	"enemy_zahhak": Color(0.25, 0.15, 0.35),
}


func _run() -> void:
	var dir := DirAccess.open("res://art/_placeholders/")
	if dir:
		dir.make_dir_recursive("khan1")
	for entity_id in ENTITIES.keys():
		var path: String = OUT_DIR + entity_id + ".png"
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
