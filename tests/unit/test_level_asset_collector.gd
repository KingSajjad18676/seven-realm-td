extends GutTest


func test_level_01_includes_map_hero_towers_and_boss() -> void:
	var level := ContentRegistry.get_level("level_01")
	assert_not_null(level)
	var launch := BattleLaunchData.new()
	launch.level_id = "level_01"
	var paths := LevelAssetCollector.collect(level, launch)
	assert_gt(paths.size(), 0)
	assert_true(paths.has(level.map_sprite_path), "map art path")
	assert_true(_paths_include_enemy(paths, "enemy_lion_boss"))
	assert_true(_paths_include_enemy(paths, "enemy_jackal"))
	assert_true(_paths_include_hero(paths, "rostam"))
	assert_true(_paths_include_tower(paths, "tower_archer"))
	assert_true(paths.has(LevelAssetCollector.BATTLE_SCENE))


func test_level_08_wave_roster_includes_zahhak_boss_and_guard() -> void:
	var level := ContentRegistry.get_level("level_08_damavand")
	assert_not_null(level)
	var enemy_ids := _enemy_ids_from_waves(level)
	assert_true(enemy_ids.has("enemy_zahhak"))
	assert_true(enemy_ids.has("enemy_zahhak_serpent_guard"))
	var launch := BattleLaunchData.new()
	launch.level_id = "level_08_damavand"
	var paths := LevelAssetCollector.collect(level, launch)
	assert_true(paths.has(LevelAssetCollector.BATTLE_SCENE))


func test_corruptor_sprite_listed_once_for_level_01() -> void:
	var level := ContentRegistry.get_level("level_01")
	var launch := BattleLaunchData.new()
	var paths := LevelAssetCollector.collect(level, launch)
	var corruptor_path := _sprite_path_for_enemy("enemy_corruptor")
	if corruptor_path == "":
		return
	var count := 0
	for path in paths:
		if path == corruptor_path:
			count += 1
	assert_eq(count, 1)


func test_collect_dedupes_paths() -> void:
	var level := ContentRegistry.get_level("level_01")
	var launch := BattleLaunchData.new()
	var paths := LevelAssetCollector.collect(level, launch)
	var seen: Dictionary = {}
	for path in paths:
		assert_false(seen.has(path), "duplicate path: %s" % path)
		seen[path] = true


func test_run_tower_ids_override_available_towers() -> void:
	var level := ContentRegistry.get_level("level_01")
	var launch := BattleLaunchData.new()
	launch.run_tower_ids = ["tower_sacred_fire"]
	var paths := LevelAssetCollector.collect(level, launch)
	assert_true(_paths_include_tower(paths, "tower_sacred_fire"))
	assert_false(_paths_include_tower(paths, "tower_heavy"))


func _enemy_ids_from_waves(level: LevelData) -> Dictionary:
	var ids: Dictionary = {}
	for wave in level.waves:
		for group in wave.spawn_groups:
			var enemy_id := str(group.get("enemy_id", ""))
			if enemy_id != "":
				ids[enemy_id] = true
	if level.boss_enemy_id != "":
		ids[level.boss_enemy_id] = true
	return ids


func _sprite_path_for_enemy(enemy_id: String) -> String:
	var data := ContentRegistry.get_enemy(enemy_id)
	if data == null:
		return ""
	var sprite_path := data.sprite_path
	if sprite_path == "":
		sprite_path = VisualAssetLoader.khan1_sprite(enemy_id)
	return sprite_path


func _paths_include_enemy(paths: PackedStringArray, enemy_id: String) -> bool:
	var sprite_path := _sprite_path_for_enemy(enemy_id)
	if sprite_path == "":
		return false
	return paths.has(sprite_path)


func _paths_include_hero(paths: PackedStringArray, hero_id: String) -> bool:
	var data := ContentRegistry.get_hero(hero_id)
	if data == null:
		return false
	var sprite_path := data.sprite_path
	if sprite_path == "":
		sprite_path = VisualAssetLoader.khan1_sprite(hero_id)
	if sprite_path == "":
		return false
	return paths.has(sprite_path)


func _paths_include_tower(paths: PackedStringArray, tower_id: String) -> bool:
	var data := ContentRegistry.get_tower(tower_id)
	if data == null:
		return false
	var sprite_path := data.sprite_path
	if sprite_path == "":
		sprite_path = VisualAssetLoader.khan1_sprite(tower_id)
	if sprite_path == "":
		return false
	return paths.has(sprite_path)
