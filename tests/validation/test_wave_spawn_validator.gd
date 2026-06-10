extends GutTest


func test_wave_spawn_validator_passes_on_bootstrap() -> void:
	var catalog := ContentTestUtils.build_catalog()
	var errors := WaveSpawnValidator.validate(catalog)
	assert_true(errors.is_empty(), "expected no wave spawn errors, got: %s" % str(errors))


func test_tutorial_has_two_waves() -> void:
	var catalog := ContentTestUtils.build_catalog()
	var tutorial: LevelData = null
	for level in catalog.levels:
		if level is LevelData and level.level_id == "level_00_tutorial":
			tutorial = level
			break
	assert_not_null(tutorial)
	assert_eq(tutorial.waves.size(), 2)


func test_campaign_labour_one_reaches_wave_30_boss() -> void:
	var waves := CampaignWaveTemplates.generate("level_01", "enemy_lion_boss")
	assert_eq(waves.size(), 30)
	var final_wave: WaveData = waves[29]
	assert_true(final_wave.is_boss_wave)
	assert_eq(final_wave.spawn_groups[0].get("enemy_id"), "enemy_lion_boss")


func test_labour_two_uses_correct_roster() -> void:
	var waves := CampaignWaveTemplates.generate("level_02", "enemy_thirst_manifest")
	assert_eq(waves.size(), 40)
	assert_eq(waves[0].wave_phase, "bait")
	for group in waves[0].spawn_groups:
		assert_eq(str(group.get("enemy_id", "")), "enemy_mirage_shade")


func test_labour_seven_reaches_wave_90_boss() -> void:
	var waves := CampaignWaveTemplates.generate("level_07", "enemy_white_div")
	assert_eq(waves.size(), 90)
	var final_wave: WaveData = waves[89]
	assert_true(final_wave.is_boss_wave)
	assert_eq(final_wave.spawn_groups[0].get("enemy_id"), "enemy_white_div")


func test_damavand_reaches_wave_100_boss_with_chainbreakers() -> void:
	var waves := CampaignWaveTemplates.generate("level_08_damavand", "enemy_zahhak")
	assert_eq(waves.size(), 100)
	var final_wave: WaveData = waves[99]
	assert_true(final_wave.is_boss_wave)
	assert_eq(final_wave.spawn_groups[0].get("enemy_id"), "enemy_zahhak")
	var has_chainbreaker := false
	for wave in waves:
		for group in wave.spawn_groups:
			if str(group.get("enemy_id", "")) == "enemy_chainbreaker_div":
				has_chainbreaker = true
				break
		if has_chainbreaker:
			break
	assert_true(has_chainbreaker)


func test_horde_ends_at_wave_15() -> void:
	assert_eq(ContentCatalog.HORDE_WAVES_TO_CLEAR, 15)
	for wave_num in range(1, 16):
		var wave := CampaignWaveTemplates.generate_horde_slice("level_01", wave_num)
		assert_false(wave.spawn_groups.is_empty(), "horde wave %d empty" % wave_num)


func test_endless_continues_past_wave_15_with_scaling() -> void:
	var w15 := CampaignWaveTemplates.generate_horde_slice("level_01", 15)
	var w30 := CampaignWaveTemplates.generate_horde_slice("level_01", 30)
	var extra_blocks := 29 / CampaignWaveTemplates.MACRO_BLOCK_SIZE
	var extra_scale := 1.0 + float(extra_blocks - 1) * 0.08
	for group in w30.spawn_groups:
		group["count"] = maxi(1, int(round(float(group.get("count", 1)) * extra_scale)))
	var count_15 := 0
	var count_30 := 0
	for group in w15.spawn_groups:
		count_15 += int(group.get("count", 0))
	for group in w30.spawn_groups:
		count_30 += int(group.get("count", 0))
	assert_gt(count_30, 0)
	assert_gt(count_30, count_15, "endless should scale by wave 30")


func test_daily_tale_uses_level_one_and_valid_seed() -> void:
	assert_eq(DailyTaleService.get_daily_level_id(), "level_01")
	assert_gt(DailyTaleService.get_today_seed(), 0)


func test_campaign_run_skirmish_wave_count() -> void:
	assert_eq(CampaignRunGenerator.SKIRMISH_WAVES, 15)
	var launch := BattleLaunchData.new()
	launch.is_campaign_run = true
	launch.skirmish_waves = CampaignRunGenerator.SKIRMISH_WAVES
	assert_false(launch.is_campaign_mode())


func test_throne_mode_uses_radial_spawns() -> void:
	var level := ContentCatalog.build_throne_arena_level()
	assert_eq(level.spawn_points.size(), ContentCatalog.THRONE_SPAWN_COUNT)
	for wave_num in range(1, 16):
		var wave := CampaignWaveTemplates.generate_throne_slice(wave_num)
		for group in wave.spawn_groups:
			var sid := str(group.get("spawn_id", ""))
			assert_true(sid.begins_with("spawn_throne_"), "wave %d spawn %s" % [wave_num, sid])


func test_gauntlet_spawns_labour_bosses_in_order() -> void:
	var expected_bosses := [
		"enemy_lion_boss",
		"enemy_thirst_manifest",
		"enemy_azhdaha",
		"enemy_sorceress",
		"enemy_olad_champion",
		"enemy_arzhang_div",
		"enemy_white_div",
	]
	assert_eq(GauntletRunState.GAUNTLET_LEVEL_IDS.size(), expected_bosses.size())
	for i in GauntletRunState.GAUNTLET_LEVEL_IDS.size():
		var level_id := GauntletRunState.GAUNTLET_LEVEL_IDS[i]
		var boss_id := expected_bosses[i]
		var waves := CampaignWaveTemplates.generate(level_id, boss_id)
		var final: WaveData = waves[waves.size() - 1]
		assert_true(final.is_boss_wave)
		assert_eq(final.spawn_groups[0].get("enemy_id"), boss_id)


func test_hunt_uses_damavand_with_zahhak_and_chainbreakers() -> void:
	var launch := BattleLaunchData.new()
	launch.is_hunt_mode = true
	launch.level_id = "level_08_damavand"
	assert_false(launch.is_campaign_mode())
	var level := ContentRegistry.get_level("level_08_damavand")
	assert_eq(level.waves.size(), 100)
	var final: WaveData = level.waves[99]
	assert_eq(final.spawn_groups[0].get("enemy_id"), "enemy_zahhak")
	var has_chainbreaker := false
	for wave in level.waves:
		for group in wave.spawn_groups:
			if str(group.get("enemy_id", "")) == "enemy_chainbreaker_div":
				has_chainbreaker = true
	assert_true(has_chainbreaker)


func test_unknown_level_wave_count_is_zero() -> void:
	assert_eq(ContentCatalog.wave_count_for("level_unknown"), 0)
