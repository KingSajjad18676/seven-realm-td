extends GutTest


func test_throne_launch_flags() -> void:
	var launch := BattleLaunchData.new()
	launch.is_throne_defense_mode = true
	assert_false(launch.is_campaign_mode())
	assert_true(launch.is_scavenge_mode())


func test_throne_arena_level_radial_routes() -> void:
	var level := ContentCatalog.build_throne_arena_level()
	assert_eq(level.level_id, ContentCatalog.THRONE_ARENA_LEVEL_ID)
	assert_eq(level.spawn_points.size(), ContentCatalog.THRONE_SPAWN_COUNT)
	assert_eq(level.path_routes.size(), ContentCatalog.THRONE_SPAWN_COUNT)
	for route in level.path_routes:
		assert_eq(route.points.size(), 2)
		assert_almost_eq(route.points[1].x, level.gate_position.x, 0.1)
		assert_almost_eq(route.points[1].y, level.gate_position.y, 0.1)


func test_throne_wave_uses_multiple_spawns() -> void:
	var wave := CampaignWaveTemplates.generate_throne_slice(5)
	var spawn_ids: Dictionary = {}
	for group in wave.spawn_groups:
		var sid := str(group.get("spawn_id", ""))
		if sid != "":
			spawn_ids[sid] = true
	assert_true(spawn_ids.size() >= 2)


func test_throne_final_wave_spawns_all_sides() -> void:
	var wave := CampaignWaveTemplates.generate_throne_slice(13)
	assert_true(wave.spawn_groups.size() >= ContentCatalog.THRONE_SPAWN_COUNT)
