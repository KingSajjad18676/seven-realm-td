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
	var level_01 := _find_level(catalog.levels, "level_01")
	var level_02 := _find_level(catalog.levels, "level_02")
	ok = ok and level_01 != null and level_01.waves.size() == 5
	ok = ok and level_02 != null and level_02.waves.size() == 5
	ok = ok and level_02.waves[1].spawn_groups.size() >= 2
	ok = ok and BossControllerFactory.create("enemy_thirst_manifest") != null
	ok = ok and BossControllerFactory.create("enemy_azhdaha") != null
	var run := RogueliteRunState.new()
	run.generate_run()
	ok = ok and run.nodes.size() == 5
	if ok:
		print("smoke_test: PASS levels=%d fates=%d roguelite_nodes=%d" % [
			catalog.levels.size(), catalog.fate_cards.size(), run.nodes.size()
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
