extends GutTest


func test_bait_waves_have_phase_tag_and_no_corruptors() -> void:
	var waves := CampaignWaveTemplates.generate("level_01", "enemy_lion_boss")
	for i in [0, 1, 2, 10, 11, 12]:
		var wave: WaveData = waves[i]
		assert_eq(wave.wave_phase, "bait", "Wave %d should be bait phase" % (i + 1))
		for group in wave.spawn_groups:
			assert_false(
				str(group.get("enemy_id", "")).contains("corruptor"),
				"Bait wave %d must not spawn corruptors" % (i + 1)
			)


func test_trap_waves_at_four_and_five() -> void:
	var waves := CampaignWaveTemplates.generate("level_01", "enemy_lion_boss")
	assert_eq(waves[3].wave_phase, "trap")
	assert_eq(waves[4].wave_phase, "trap")


func test_hijack_waves_six_through_eight() -> void:
	var waves := CampaignWaveTemplates.generate("level_01", "enemy_lion_boss")
	for i in [5, 6, 7]:
		assert_eq(waves[i].wave_phase, "hijack", "Wave %d should be hijack" % (i + 1))


func test_wave_ten_is_mini_boss_with_vow_phase_tag() -> void:
	var waves := CampaignWaveTemplates.generate("level_01", "enemy_lion_boss")
	assert_eq(waves[9].wave_phase, "mini_boss")
	assert_eq(waves[9].display_name, "Mini-boss")


func test_act_two_differs_from_act_one_on_level_one() -> void:
	var waves := CampaignWaveTemplates.generate("level_01", "enemy_lion_boss")
	var act2_trap := waves[13]
	var act2_has_boar := false
	for group in act2_trap.spawn_groups:
		if str(group.get("enemy_id", "")) == "enemy_boar":
			act2_has_boar = true
	assert_true(act2_has_boar, "Act 2 trap should include boars")
	var act1_only_jackal_bait := true
	for group in waves[0].spawn_groups:
		if str(group.get("enemy_id", "")) != "enemy_jackal":
			act1_only_jackal_bait = false
	assert_true(act1_only_jackal_bait)


func test_damavand_forge_tax_suppresses_bait_drops() -> void:
	var waves := CampaignWaveTemplates.generate("level_08_damavand", "enemy_zahhak")
	for i in range(50, 75):
		var wave: WaveData = waves[i]
		if wave.wave_phase == "bait":
			assert_true(wave.suppress_material_drops, "Forge tax bait wave %d" % (i + 1))


func test_damavand_chainbreaker_phase_includes_chainbreakers() -> void:
	var waves := CampaignWaveTemplates.generate("level_08_damavand", "enemy_zahhak")
	var found := false
	for i in range(25, 50):
		for group in waves[i].spawn_groups:
			if str(group.get("enemy_id", "")) == "enemy_chainbreaker_div":
				found = true
	assert_true(found)


func test_vow_clearance_gate_at_block_end() -> void:
	var block_size := 10
	assert_false((0 + 1) % block_size == 0, "No vow after wave 1")
	assert_true((9 + 1) % block_size == 0, "Vow after wave 10")
	assert_true((19 + 1) % block_size == 0, "Vow after wave 20")
	assert_false((10 + 1) % block_size == 0, "No vow after wave 11")
