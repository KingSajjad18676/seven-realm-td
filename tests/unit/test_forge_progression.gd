extends GutTest


func before_each() -> void:
	SaveSystem.test_reset_to_defaults()


func _set_all_starter_forge(level: int) -> void:
	for tid in ForgeService.get_all_forgeable_tower_ids():
		SaveSystem.set_tower_forge(tid, {"level": level, "elite_level": 0})


func test_expected_forge_curve_monotonic() -> void:
	var levels := [
		"level_01",
		"level_02",
		"level_03",
		"level_04",
		"level_05",
		"level_06",
		"level_07",
		"level_08_damavand",
	]
	var prev := 0
	for level_id in levels:
		var expected := ForgeService.expected_forge_level_for(level_id)
		assert_gte(expected, prev, "Expected forge should not decrease for %s" % level_id)
		prev = expected
	assert_eq(ForgeService.expected_forge_level_for("level_03"), 8)
	assert_eq(ForgeService.expected_forge_level_for("level_08_damavand"), 30)


func test_l1_l2_difficulty_unchanged_from_old_formula() -> void:
	var l1 := ContentCatalog.khan_difficulty("level_01")
	assert_almost_eq(float(l1.hp_mult), 1.0, 0.001)
	assert_almost_eq(float(l1.count_mult), 1.0, 0.001)
	var l2 := ContentCatalog.khan_difficulty("level_02")
	assert_almost_eq(float(l2.hp_mult), 1.12, 0.001)
	assert_almost_eq(float(l2.count_mult), 1.15, 0.001)


func test_l3_plus_scales_with_expected_forge() -> void:
	var l2 := ContentCatalog.khan_difficulty("level_02")
	var l3 := ContentCatalog.khan_difficulty("level_03")
	assert_gt(float(l3.hp_mult), float(l2.hp_mult))
	var forge_dmg := ForgeService.expected_damage_mult_for_level("level_03")
	assert_almost_eq(float(l3.hp_mult), 1.24 * forge_dmg, 0.01)


func test_unforged_wall_invariant_l3() -> void:
	_set_all_starter_forge(1)
	var l3 := ContentCatalog.khan_difficulty("level_03")
	var unforged_dps := 1.0
	var forged_dps := ForgeService.get_damage_mult("tower_archer")
	_set_all_starter_forge(ForgeService.expected_forge_level_for("level_03"))
	var expected_dps := ForgeService.get_damage_mult("tower_archer")
	var hp := float(l3.hp_mult)
	assert_lt(unforged_dps / hp, forged_dps / hp * 0.85, "Unforged should face a harder wall than expected-forge player")
	assert_true(ForgeService.is_under_forge_recommendation("level_03"))


func test_at_expected_forge_not_under_recommendation() -> void:
	_set_all_starter_forge(ForgeService.expected_forge_level_for("level_05"))
	assert_false(ForgeService.is_under_forge_recommendation("level_05"))


func test_forge_gate_skips_l1_l2() -> void:
	assert_false(ForgeService.forge_gate_applies_to_level("level_01"))
	assert_false(ForgeService.forge_gate_applies_to_level("level_02"))
	assert_true(ForgeService.forge_gate_applies_to_level("level_03"))


func test_defeat_guidance_when_under_forged() -> void:
	_set_all_starter_forge(1)
	var ctx := BattleContext.new()
	ctx.level_data = LevelData.new()
	ctx.level_data.level_id = "level_03"
	var text := BattleResultsFormatter.format_forge_defeat_guidance(ctx, false)
	assert_true(text.contains("Kaveh's Forge"))
	assert_true(text.contains("Star Iron"))


func test_defeat_guidance_hidden_on_victory_or_l1() -> void:
	_set_all_starter_forge(1)
	var ctx := BattleContext.new()
	ctx.level_data = LevelData.new()
	ctx.level_data.level_id = "level_01"
	assert_eq(BattleResultsFormatter.format_forge_defeat_guidance(ctx, false), "")
	ctx.level_data.level_id = "level_03"
	assert_eq(BattleResultsFormatter.format_forge_defeat_guidance(ctx, true), "")
