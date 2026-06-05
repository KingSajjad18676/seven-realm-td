extends GutTest

const MAP_IDS := [
	"level_01",
	"level_02",
	"level_03",
	"level_04",
	"level_05",
	"level_06",
	"level_07",
	"level_08_damavand",
]


func test_each_map_generates_expected_wave_count() -> void:
	for level_id in MAP_IDS:
		var waves := CampaignWaveTemplates.generate(level_id, _boss_for(level_id))
		assert_eq(
			waves.size(),
			ContentCatalog.wave_count_for(level_id),
			"Wave count mismatch for %s" % level_id
		)


func test_hijack_maps_include_corruptors_in_templates() -> void:
	for level_id in ["level_04", "level_07"]:
		var boss := "enemy_sorceress" if level_id == "level_04" else "enemy_white_div"
		var waves := CampaignWaveTemplates.generate(level_id, boss)
		var found_corruptor := false
		for wave in waves:
			for group in wave.spawn_groups:
				var enemy_id := str(group.get("enemy_id", ""))
				if enemy_id.contains("corruptor"):
					found_corruptor = true
		assert_true(found_corruptor, "%s should include corruptor pressure" % level_id)


func test_block_two_scales_above_block_one() -> void:
	var waves := CampaignWaveTemplates.generate("level_01", "enemy_lion_boss")
	var wave1_count := _total_enemies(waves[0])
	var wave6_count := _total_enemies(waves[5])
	assert_gt(wave6_count, wave1_count, "Block 2 wave 1 should scale above block 1 wave 1")


func test_level_one_wave_one_favors_boars() -> void:
	var waves := CampaignWaveTemplates.generate("level_01", "enemy_lion_boss")
	var wave1: WaveData = waves[0]
	var boar_count := 0
	var jackal_count := 0
	for group in wave1.spawn_groups:
		match str(group.get("enemy_id", "")):
			"enemy_boar":
				boar_count = int(group.get("count", 0))
			"enemy_jackal":
				jackal_count = int(group.get("count", 0))
	assert_gt(boar_count, 0, "Wave 1 should include armored boars")
	assert_gte(boar_count, jackal_count / 2, "Boars should be a meaningful intro threat")


func test_horde_slice_matches_campaign_roles() -> void:
	var campaign := CampaignWaveTemplates.generate("level_03", "enemy_azhdaha")
	var horde := CampaignWaveTemplates.generate_horde_slice("level_03", 1)
	assert_eq(
		horde.spawn_groups.size(),
		campaign[0].spawn_groups.size(),
		"Horde wave 1 should mirror campaign block role"
	)


func _total_enemies(wave: WaveData) -> int:
	var total := 0
	for group in wave.spawn_groups:
		total += int(group.get("count", 0))
	return total


func _boss_for(level_id: String) -> String:
	match level_id:
		"level_01":
			return "enemy_lion_boss"
		"level_02":
			return "enemy_thirst_manifest"
		"level_03":
			return "enemy_azhdaha"
		"level_04":
			return "enemy_sorceress"
		"level_05":
			return "enemy_olad_champion"
		"level_06":
			return "enemy_arzhang_div"
		"level_07":
			return "enemy_white_div"
		"level_08_damavand":
			return "enemy_zahhak"
		_:
			return "enemy_lion_boss"
