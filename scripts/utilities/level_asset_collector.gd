class_name LevelAssetCollector
extends RefCounted

const BATTLE_SCENE := "res://scenes/battle/battle.tscn"

const LABOUR_EXTRA_ENEMIES := {
	"mode_lion": ["enemy_jackal"],
	"mode_thirst": ["enemy_mirage_shade"],
	"mode_demons": ["enemy_mountain_raider", "enemy_div_infantry"],
	"mode_temptress": ["enemy_illusion_attendant", "enemy_feast_shade"],
	"mode_zahhak": ["enemy_zahhak_serpent_guard"],
}


static func collect(level: LevelData, launch: BattleLaunchData) -> PackedStringArray:
	if level == null:
		return PackedStringArray()
	var seen: Dictionary = {}
	var ordered: Array[String] = []

	_add_path(ordered, seen, level.map_sprite_path)
	_add_path(ordered, seen, VisualAssetLoader.loading_sprite(level.level_id))

	var enemy_ids := _collect_enemy_ids(level)
	for enemy_id in enemy_ids:
		_add_path(ordered, seen, _enemy_sprite_path(enemy_id))

	_add_path(ordered, seen, _hero_sprite_path(level.hero_id))

	var tower_ids := launch.run_tower_ids if launch and not launch.run_tower_ids.is_empty() else level.available_tower_ids
	for tower_id in tower_ids:
		_add_path(ordered, seen, _tower_sprite_path(tower_id))

	_add_path(ordered, seen, BATTLE_SCENE)
	return PackedStringArray(ordered)


static func _collect_enemy_ids(level: LevelData) -> Array[String]:
	var ids: Dictionary = {}
	for wave in level.waves:
		for group in wave.spawn_groups:
			var enemy_id := str(group.get("enemy_id", ""))
			if enemy_id != "":
				ids[enemy_id] = true
	if level.boss_enemy_id != "":
		ids[level.boss_enemy_id] = true
	var mini_boss := ContentCatalog.mini_boss_for(level.level_id)
	if mini_boss != "":
		ids[mini_boss] = true
	var extras: Array = LABOUR_EXTRA_ENEMIES.get(level.labour_mode_id, [])
	for extra_id in extras:
		ids[str(extra_id)] = true
	return Array(ids.keys(), TYPE_STRING, "", null)


static func _enemy_sprite_path(enemy_id: String) -> String:
	if ContentRegistry == null:
		return ""
	var data := ContentRegistry.get_enemy(enemy_id)
	if data == null:
		return ""
	var path := data.sprite_path
	if path == "":
		path = VisualAssetLoader.khan1_sprite(enemy_id)
	return path


static func _hero_sprite_path(hero_id: String) -> String:
	if ContentRegistry == null or hero_id == "":
		return ""
	var data := ContentRegistry.get_hero(hero_id)
	if data == null:
		return ""
	var path := data.sprite_path
	if path == "":
		path = VisualAssetLoader.khan1_sprite(hero_id)
	return path


static func _tower_sprite_path(tower_id: String) -> String:
	if ContentRegistry == null or tower_id == "":
		return ""
	var data := ContentRegistry.get_tower(tower_id)
	if data == null:
		return ""
	var path := data.sprite_path
	if path == "":
		path = VisualAssetLoader.khan1_sprite(tower_id)
	return path


static func _add_path(ordered: Array[String], seen: Dictionary, path: String) -> void:
	if path == "" or seen.has(path):
		return
	if not ResourceLoader.exists(path):
		return
	seen[path] = true
	ordered.append(path)
