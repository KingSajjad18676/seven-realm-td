extends GutTest


func test_horde_slice_advances_act_index() -> void:
	var wave_early := CampaignWaveTemplates.generate_horde_slice("level_05", 3)
	var wave_late := CampaignWaveTemplates.generate_horde_slice("level_05", 23)
	assert_gt(wave_late.spawn_groups.size(), 0)
	var early_total := 0
	var late_total := 0
	for group in wave_early.spawn_groups:
		early_total += int(group.get("count", 0))
	for group in wave_late.spawn_groups:
		late_total += int(group.get("count", 0))
	assert_gte(late_total, early_total)


func test_horde_slice_tags_secondary_route_on_trap_waves() -> void:
	var wave := CampaignWaveTemplates.generate_horde_slice("level_05", 5)
	var has_route_2 := false
	for group in wave.spawn_groups:
		if str(group.get("route_id", "")) == "route_2":
			has_route_2 = true
			break
	assert_true(has_route_2)


func test_level_05_has_secondary_spawn() -> void:
	var level := ContentRegistry.get_level("level_05")
	assert_not_null(level)
	level.ensure_spawns_migrated()
	var spawn2 := level.get_spawn("spawn_2")
	assert_eq(str(spawn2.get("route_id", "")), "route_2")
	assert_gt(level.get_route("route_2").size(), 1)
