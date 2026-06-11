extends GutTest


func test_get_tower_flame_archer() -> void:
	var tower := ContentRegistry.get_tower("tower_flame_archer")
	assert_not_null(tower)
	assert_eq(tower.tower_id, "tower_flame_archer")


func test_get_enemy_lion_boss() -> void:
	var enemy := ContentRegistry.get_enemy("enemy_lion_boss")
	assert_not_null(enemy)
	assert_true(enemy.is_boss)


func test_get_level_01_has_campaign_waves() -> void:
	var level := ContentRegistry.get_level("level_01")
	assert_not_null(level)
	assert_eq(level.waves.size(), ContentCatalog.wave_count_for("level_01"))


func test_get_level_01_merges_map_override() -> void:
	var level := ContentRegistry.get_level("level_01")
	assert_not_null(level)
	assert_eq(level.map_sprite_path, "res://art/maps/campaign/khan_01_map.png")


func test_get_tutorial_merges_map_override() -> void:
	var level := ContentRegistry.get_level("level_00_tutorial")
	assert_not_null(level)
	assert_eq(level.map_sprite_path, "res://art/maps/tutorial/toturial_map.png")
	assert_true(level.is_tutorial)


func test_get_rostam_has_anim_data() -> void:
	var hero := ContentRegistry.get_hero("rostam")
	assert_not_null(hero)
	assert_not_null(hero.anim_data)
	assert_true(hero.anim_data.has_strips())
	assert_eq(hero.anim_data.portrait_path, "res://art/heroes/rostam/rostam_circle_icon.png")
	assert_gte(level.path_points.size(), 3)
	level.ensure_routes_migrated()
	assert_gte(level.get_all_route_points().size(), 2)
	level.ensure_routes_migrated()
	level.ensure_spawns_migrated()
	assert_gte(level.path_routes.size(), 1)
	assert_gte(level.spawn_points.size(), 1)
	assert_eq(level.spawn_points[0].route_id, level.get_primary_route_id())
	assert_ne(level.gate_position, Vector2.ZERO)


func test_fate_cards_available() -> void:
	var cards := ContentRegistry.get_all_fate_cards()
	assert_gte(cards.size(), 8)


func test_equipment_catalog_integrity() -> void:
	var pieces := ContentRegistry.get_all_equipment_pieces()
	assert_eq(pieces.size(), 28)
	var sets := ContentRegistry.get_all_equipment_sets()
	assert_eq(sets.size(), 7)
	for piece in pieces:
		assert_ne(piece.set_id, "")
		var set_data := ContentRegistry.get_equipment_set(piece.set_id)
		assert_not_null(set_data)
	for level_id in ["level_01", "level_02", "level_03", "level_04", "level_05", "level_06", "level_07"]:
		var boss_pieces := ContentRegistry.get_equipment_for_level(level_id)
		assert_eq(boss_pieces.size(), 2)
