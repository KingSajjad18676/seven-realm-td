extends GutTest


func test_wave_count_scales_by_khan() -> void:
	assert_eq(ContentCatalog.wave_count_for("level_01"), 30)
	assert_eq(ContentCatalog.wave_count_for("level_02"), 40)
	assert_eq(ContentCatalog.wave_count_for("level_07"), 90)
	assert_eq(ContentCatalog.wave_count_for("level_08_damavand"), 100)


func test_generated_waves_have_mini_boss_every_tenth() -> void:
	var waves := ContentCatalog._generate_campaign_waves("level_01", "enemy_lion_boss")
	assert_eq(waves.size(), 30)
	for i in range(waves.size()):
		var wave_num := i + 1
		var wave: WaveData = waves[i]
		if wave_num == 30:
			assert_true(wave.is_boss_wave, "Final wave should be boss")
			continue
		if wave_num % 10 == 0:
			assert_false(wave.is_boss_wave, "Mini-boss waves are not flagged is_boss_wave")
			var has_mini := false
			for group in wave.spawn_groups:
				if str(group.get("enemy_id", "")) == ContentCatalog.mini_boss_for("level_01"):
					has_mini = true
			assert_true(has_mini, "Wave %d should include mini-boss" % wave_num)


func test_final_wave_uses_campaign_boss() -> void:
	var boss_id := "enemy_zahhak"
	var waves := ContentCatalog._generate_campaign_waves("level_08_damavand", boss_id)
	var final_wave: WaveData = waves[waves.size() - 1]
	assert_true(final_wave.is_boss_wave)
	assert_eq(final_wave.spawn_groups[0].get("enemy_id"), boss_id)
