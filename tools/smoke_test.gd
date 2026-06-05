extends SceneTree

func _init() -> void:
	var ok := true
	ok = ok and ResourceLoader.exists("res://scenes/boot/boot.tscn")
	ok = ok and ResourceLoader.exists("res://scenes/battle/battle.tscn")
	ok = ok and ResourceLoader.exists("res://scenes/roguelite_map/roguelite_map.tscn")
	ok = ok and ResourceLoader.exists("res://scenes/main_menu/kaveh_forge.tscn")
	var catalog := ContentCatalog.build_bootstrap()
	var validation_errors := ContentValidator.validate(catalog)
	for err in validation_errors:
		push_error("smoke_test: %s" % err)
	ok = ok and validation_errors.is_empty()
	ok = ok and _catalog_has_tower(catalog, "tower_flame_archer")
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


func _catalog_has_tower(catalog: BootstrapContent, tower_id: String) -> bool:
	for t in catalog.towers:
		if t is TowerData and t.tower_id == tower_id:
			return true
	return false
