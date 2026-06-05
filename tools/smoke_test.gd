extends SceneTree

func _init() -> void:
	var ok := true
	ok = ok and ResourceLoader.exists("res://scenes/boot/boot.tscn")
	ok = ok and ResourceLoader.exists("res://scenes/battle/battle.tscn")
	ok = ok and ResourceLoader.exists("res://scenes/roguelite_map/roguelite_map.tscn")
	ok = ok and ResourceLoader.exists("res://scenes/main_menu/kaveh_forge.tscn")
	var catalog := ContentCatalog.build_bootstrap()
	ok = ok and catalog.levels.size() >= 9
	ok = ok and catalog.fate_cards.size() >= 8
	ok = ok and catalog.heroes.size() >= 2
	ok = ok and catalog.enemies.size() >= 20
	ok = ok and catalog.towers.size() >= 6
	var enemy_ids := {}
	for e in catalog.enemies:
		if e is EnemyData:
			enemy_ids[e.enemy_id] = true
	for level in catalog.levels:
		if not (level is LevelData):
			continue
		ok = ok and level.waves.size() == 5
		for wave in level.waves:
			for group in wave.spawn_groups:
				var eid := str(group.get("enemy_id", ""))
				ok = ok and enemy_ids.has(eid)
	var level_01 := _find_level(catalog.levels, "level_01")
	var level_02 := _find_level(catalog.levels, "level_02")
	var level_08 := _find_level(catalog.levels, "level_08_damavand")
	ok = ok and level_01 != null and level_01.waves.size() == 5
	ok = ok and level_02 != null and level_02.waves.size() == 5
	ok = ok and level_02.waves[1].spawn_groups.size() >= 2
	ok = ok and level_08 != null
	ok = ok and level_08.waves[0].spawn_groups[0].get("enemy_id") == "enemy_zahhak_serpent_guard"
	ok = ok and BossControllerFactory.create("enemy_thirst_manifest") != null
	ok = ok and BossControllerFactory.create("enemy_azhdaha") != null
	ok = ok and ContentRegistry.get_tower("tower_flame_archer") != null
	var launch := BattleLaunchData.new()
	launch.is_roguelite_run = true
	ok = ok and not launch.is_campaign_mode()
	var run := RogueliteRunState.new()
	run.generate_run()
	ok = ok and run.nodes.size() == 5
	run.advance()
	ok = ok and run.current_index == 1
	if ok:
		print("smoke_test: PASS levels=%d enemies=%d fates=%d towers=%d" % [
			catalog.levels.size(), catalog.enemies.size(), catalog.fate_cards.size(), catalog.towers.size()
		])
		quit(0)
	else:
		push_error("smoke_test: FAIL")
		quit(1)


func _find_level(levels: Array, level_id: String) -> LevelData:
	for l in levels:
		if l is LevelData and l.level_id == level_id:
			return l
	return null
