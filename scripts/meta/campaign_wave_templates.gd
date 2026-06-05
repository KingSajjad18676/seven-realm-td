class_name CampaignWaveTemplates
extends RefCounted

const BLOCK_SIZE := 5
const BLOCK_SCALE_STEP := 0.22

enum WaveRole { INTRO_A, INTRO_B, ESCALATION_A, ESCALATION_B, CLIMAX }


static func generate(level_id: String, boss_id: String) -> Array[WaveData]:
	var wave_count := ContentCatalog.wave_count_for(level_id)
	var block_count := wave_count / BLOCK_SIZE
	var diff := ContentCatalog.khan_difficulty(level_id)
	var count_mult := float(diff.count_mult)
	var mini_boss := ContentCatalog.mini_boss_for(level_id)
	var roster := ContentCatalog.get_horde_roster(level_id)
	var roles := _role_templates(level_id)
	var hijack_tax := _is_hijack_tax_map(level_id)
	var waves: Array[WaveData] = []
	for block in block_count:
		for slot in BLOCK_SIZE:
			var global_wave := block * BLOCK_SIZE + slot + 1
			var wave_id := "%s_wave_%d" % [level_id, global_wave]
			if global_wave == wave_count:
				var boss_wave := _make_wave(
					wave_id, [{"enemy_id": boss_id, "count": 1}], 2.5, true
				)
				boss_wave.display_name = "Final Boss"
				waves.append(boss_wave)
				continue
			var scale := count_mult * (1.0 + float(block) * BLOCK_SCALE_STEP)
			if block % 3 == 2 and hijack_tax:
				scale *= 1.12
			var delay := _delay_for(global_wave)
			if global_wave % 10 == 0:
				var escort_count := maxi(2, int((3 + global_wave / 10) * scale))
				var groups: Array = [
					{"enemy_id": mini_boss, "count": 1},
					{"enemy_id": roster[0], "count": escort_count},
				]
				if roster.size() > 2:
					groups.append({
						"enemy_id": roster[2],
						"count": maxi(1, int(float(escort_count) * 0.5)),
					})
				var mini := _make_wave(wave_id, groups, delay, false)
				mini.display_name = "Mini-boss"
				waves.append(mini)
				continue
			var role: WaveRole = slot as WaveRole
			var template: Dictionary = roles[role]
			var scaled_groups := _scale_groups(template.get("groups", []), scale)
			var interval := float(template.get("interval", 0.0))
			if level_id in ["level_02", "level_04", "level_07"] and role == WaveRole.CLIMAX:
				interval = maxf(interval, 0.1)
			var pre_delay := float(template.get("delay", delay))
			if level_id == "level_07" and role == WaveRole.CLIMAX:
				pre_delay = maxf(pre_delay, 2.8)
			waves.append(_make_wave(wave_id, scaled_groups, pre_delay, false, interval))
	return waves


static func generate_horde_slice(level_id: String, wave_num: int) -> WaveData:
	var block := (wave_num - 1) / BLOCK_SIZE
	var slot := (wave_num - 1) % BLOCK_SIZE
	var diff := ContentCatalog.khan_difficulty(level_id)
	var scale := float(diff.count_mult) * (1.0 + float(block) * BLOCK_SCALE_STEP)
	var roles := _role_templates(level_id)
	var role: WaveRole = slot as WaveRole
	var template: Dictionary = roles[role]
	var wave := WaveData.new()
	wave.wave_id = "horde_%s_%d" % [level_id, wave_num]
	wave.pre_wave_delay = float(template.get("delay", 1.8))
	wave.spawn_interval = float(template.get("interval", 0.0))
	wave.spawn_groups = _scale_groups(template.get("groups", []), scale)
	return wave


static func _role_templates(level_id: String) -> Array:
	match level_id:
		"level_01":
			return _level_01_roles()
		"level_02":
			return _level_02_roles()
		"level_03":
			return _level_03_roles()
		"level_04":
			return _level_04_roles()
		"level_05":
			return _level_05_roles()
		"level_06":
			return _level_06_roles()
		"level_07":
			return _level_07_roles()
		"level_08_damavand":
			return _damavand_roles()
		_:
			return _level_01_roles()


static func _level_01_roles() -> Array:
	return [
		{
			"groups": [
				{"enemy_id": "enemy_boar", "count": 4},
				{"enemy_id": "enemy_jackal", "count": 6},
			],
			"delay": 2.5,
		},
		{
			"groups": [
				{"enemy_id": "enemy_jackal", "count": 12},
				{"enemy_id": "enemy_boar", "count": 2},
			],
			"delay": 2.0,
		},
		{
			"groups": [
				{"enemy_id": "enemy_jackal", "count": 10},
				{"enemy_id": "enemy_corruptor", "count": 2},
			],
			"delay": 2.0,
		},
		{
			"groups": [
				{"enemy_id": "enemy_boar", "count": 3},
				{"enemy_id": "enemy_corruptor", "count": 3},
			],
			"delay": 2.0,
		},
		{
			"groups": [
				{"enemy_id": "enemy_boar", "count": 4},
				{"enemy_id": "enemy_jackal", "count": 8},
				{"enemy_id": "enemy_corruptor", "count": 3},
			],
			"delay": 2.0,
		},
	]


static func _level_02_roles() -> Array:
	return [
		{
			"groups": [{"enemy_id": "enemy_mirage_shade", "count": 14}],
			"delay": 2.5,
			"interval": 0.18,
		},
		{
			"groups": [
				{"enemy_id": "enemy_mirage_shade", "count": 10},
				{"enemy_id": "enemy_salt_crust_brute", "count": 3},
			],
			"delay": 2.0,
		},
		{
			"groups": [
				{"enemy_id": "enemy_corruptor", "count": 3},
				{"enemy_id": "enemy_mirage_shade", "count": 12},
			],
			"delay": 2.0,
		},
		{
			"groups": [
				{"enemy_id": "enemy_salt_crust_brute", "count": 4},
				{"enemy_id": "enemy_corruptor", "count": 4},
			],
			"delay": 2.0,
		},
		{
			"groups": [
				{"enemy_id": "enemy_mirage_shade", "count": 14},
				{"enemy_id": "enemy_corruptor", "count": 4},
				{"enemy_id": "enemy_salt_crust_brute", "count": 3},
			],
			"delay": 2.0,
			"interval": 0.12,
		},
	]


static func _level_03_roles() -> Array:
	return [
		{
			"groups": [
				{"enemy_id": "enemy_canyon_serpent", "count": 6},
				{"enemy_id": "enemy_scorched_hound", "count": 6},
			],
			"delay": 2.5,
		},
		{
			"groups": [{"enemy_id": "enemy_scorched_hound", "count": 12}],
			"delay": 2.0,
			"interval": 0.15,
		},
		{
			"groups": [
				{"enemy_id": "enemy_scorched_hound", "count": 10},
				{"enemy_id": "enemy_corruptor", "count": 3},
			],
			"delay": 2.0,
			"interval": 0.12,
		},
		{
			"groups": [
				{"enemy_id": "enemy_canyon_serpent", "count": 6},
				{"enemy_id": "enemy_scorched_hound", "count": 8},
				{"enemy_id": "enemy_corruptor", "count": 2},
			],
			"delay": 2.0,
		},
		{
			"groups": [
				{"enemy_id": "enemy_canyon_serpent", "count": 8},
				{"enemy_id": "enemy_scorched_hound", "count": 10},
				{"enemy_id": "enemy_corruptor", "count": 3},
			],
			"delay": 2.0,
		},
	]


static func _level_04_roles() -> Array:
	return [
		{
			"groups": [{"enemy_id": "enemy_illusion_attendant", "count": 16}],
			"delay": 2.5,
			"interval": 0.12,
		},
		{
			"groups": [
				{"enemy_id": "enemy_illusion_attendant", "count": 10},
				{"enemy_id": "enemy_feast_shade", "count": 4},
			],
			"delay": 2.0,
		},
		{
			"groups": [
				{"enemy_id": "enemy_feast_shade", "count": 5},
				{"enemy_id": "enemy_corruptor", "count": 3},
			],
			"delay": 2.0,
		},
		{
			"groups": [
				{"enemy_id": "enemy_illusion_attendant", "count": 14},
				{"enemy_id": "enemy_corruptor", "count": 4},
			],
			"delay": 2.0,
		},
		{
			"groups": [
				{"enemy_id": "enemy_illusion_attendant", "count": 12},
				{"enemy_id": "enemy_feast_shade", "count": 5},
				{"enemy_id": "enemy_corruptor", "count": 4},
			],
			"delay": 2.0,
			"interval": 0.1,
		},
	]


static func _level_05_roles() -> Array:
	return [
		{
			"groups": [
				{"enemy_id": "enemy_mountain_raider", "count": 14},
				{"enemy_id": "enemy_mountain_archer", "count": 6},
			],
			"delay": 2.5,
			"interval": 0.14,
		},
		{
			"groups": [
				{"enemy_id": "enemy_mountain_raider", "count": 12},
				{"enemy_id": "enemy_mountain_archer", "count": 8},
			],
			"delay": 2.0,
		},
		{
			"groups": [{"enemy_id": "enemy_mountain_raider", "count": 18}],
			"delay": 2.0,
			"interval": 0.1,
		},
		{
			"groups": [
				{"enemy_id": "enemy_mountain_raider", "count": 12},
				{"enemy_id": "enemy_corruptor", "count": 4},
			],
			"delay": 2.0,
		},
		{
			"groups": [
				{"enemy_id": "enemy_boar", "count": 6},
				{"enemy_id": "enemy_mountain_raider", "count": 10},
				{"enemy_id": "enemy_corruptor", "count": 3},
			],
			"delay": 2.0,
		},
	]


static func _level_06_roles() -> Array:
	return [
		{
			"groups": [
				{"enemy_id": "enemy_div_infantry", "count": 12},
				{"enemy_id": "enemy_div_corruptor", "count": 2},
			],
			"delay": 2.5,
		},
		{
			"groups": [{"enemy_id": "enemy_div_infantry", "count": 14}],
			"delay": 2.0,
		},
		{
			"groups": [
				{"enemy_id": "enemy_div_corruptor", "count": 6},
				{"enemy_id": "enemy_div_infantry", "count": 10},
			],
			"delay": 2.0,
		},
		{
			"groups": [
				{"enemy_id": "enemy_div_brute", "count": 3},
				{"enemy_id": "enemy_div_corruptor", "count": 5},
				{"enemy_id": "enemy_div_infantry", "count": 12},
			],
			"delay": 2.0,
		},
		{
			"groups": [
				{"enemy_id": "enemy_div_brute", "count": 4},
				{"enemy_id": "enemy_div_corruptor", "count": 4},
				{"enemy_id": "enemy_div_infantry", "count": 14},
			],
			"delay": 2.0,
		},
	]


static func _level_07_roles() -> Array:
	return [
		{
			"groups": [{"enemy_id": "enemy_white_div_thrall", "count": 18}],
			"delay": 2.5,
			"interval": 0.08,
		},
		{
			"groups": [
				{"enemy_id": "enemy_cavern_boulder_brute", "count": 3},
				{"enemy_id": "enemy_white_div_thrall", "count": 12},
			],
			"delay": 2.0,
		},
		{
			"groups": [
				{"enemy_id": "enemy_white_div_thrall", "count": 14},
				{"enemy_id": "enemy_div_corruptor", "count": 4},
			],
			"delay": 2.0,
		},
		{
			"groups": [
				{"enemy_id": "enemy_cavern_boulder_brute", "count": 4},
				{"enemy_id": "enemy_div_corruptor", "count": 5},
			],
			"delay": 2.0,
		},
		{
			"groups": [
				{"enemy_id": "enemy_cavern_boulder_brute", "count": 5},
				{"enemy_id": "enemy_div_corruptor", "count": 4},
				{"enemy_id": "enemy_white_div_thrall", "count": 10},
			],
			"delay": 2.8,
		},
	]


static func _damavand_roles() -> Array:
	return [
		{
			"groups": [
				{"enemy_id": "enemy_zahhak_serpent_guard", "count": 6},
				{"enemy_id": "enemy_corruptor", "count": 3},
			],
			"delay": 2.5,
		},
		{
			"groups": [
				{"enemy_id": "enemy_zahhak_serpent_guard", "count": 8},
				{"enemy_id": "enemy_div_infantry", "count": 10},
			],
			"delay": 2.0,
		},
		{
			"groups": [{"enemy_id": "enemy_zahhak_serpent_guard", "count": 10}],
			"delay": 2.0,
			"interval": 0.2,
		},
		{
			"groups": [
				{"enemy_id": "enemy_chainbreaker_div", "count": 3},
				{"enemy_id": "enemy_div_brute", "count": 3},
				{"enemy_id": "enemy_corruptor", "count": 3},
			],
			"delay": 2.0,
		},
		{
			"groups": [
				{"enemy_id": "enemy_zahhak_serpent_guard", "count": 8},
				{"enemy_id": "enemy_chainbreaker_div", "count": 2},
				{"enemy_id": "enemy_div_brute", "count": 3},
			],
			"delay": 2.0,
		},
	]


static func _is_hijack_tax_map(level_id: String) -> bool:
	return level_id in ["level_04", "level_07"]


static func _delay_for(global_wave: int) -> float:
	if global_wave % 10 == 0:
		return 2.0
	if global_wave > 20:
		return 1.2
	return 1.5


static func _scale_groups(groups: Array, scale: float) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for entry in groups:
		var g: Dictionary = (entry as Dictionary).duplicate()
		var base_count := int(g.get("count", 1))
		g["count"] = maxi(1, int(round(float(base_count) * scale)))
		out.append(g)
	return out


static func _make_wave(
	wave_id: String,
	groups: Array,
	delay: float,
	boss: bool,
	interval: float = 0.0
) -> WaveData:
	var w := WaveData.new()
	w.wave_id = wave_id
	w.pre_wave_delay = delay
	w.spawn_groups = _scale_groups(groups, 1.0)
	w.is_boss_wave = boss
	w.spawn_interval = interval
	return w
