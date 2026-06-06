class_name CampaignWaveTemplates
extends RefCounted

const MACRO_BLOCK_SIZE := 10
const BLOCK_SCALE_STEP := 0.22
const BAIT_SCALE := 0.7
const TRAP_SCALE := 1.3
const HIJACK_CORRUPTOR_TAX := 1.12

enum MacroRole {
	BAIT_A,
	BAIT_B,
	BAIT_C,
	TRAP_A,
	TRAP_B,
	HIJACK_A,
	HIJACK_B,
	HIJACK_C,
	PUSH,
	MINI_BOSS,
}


static func generate(level_id: String, boss_id: String) -> Array[WaveData]:
	var wave_count := ContentCatalog.wave_count_for(level_id)
	var diff := ContentCatalog.khan_difficulty(level_id)
	var count_mult := float(diff.count_mult)
	var mini_boss := ContentCatalog.mini_boss_for(level_id)
	var roster := ContentCatalog.get_horde_roster(level_id)
	var hijack_tax := _is_hijack_tax_map(level_id)
	var waves: Array[WaveData] = []
	for global_wave in wave_count:
		var wave_num := global_wave + 1
		var wave_id := "%s_wave_%d" % [level_id, wave_num]
		if wave_num == wave_count:
			var boss_wave := _make_wave(
				wave_id, [{"enemy_id": boss_id, "count": 1}], 2.5, true, 0.0, "boss", 1.0, false
			)
			boss_wave.display_name = "Final Boss"
			waves.append(boss_wave)
			continue
		var act_index := global_wave / MACRO_BLOCK_SIZE
		var block_index := act_index
		var scale := count_mult * (1.0 + float(block_index) * BLOCK_SCALE_STEP)
		if block_index % 3 == 2 and hijack_tax:
			scale *= HIJACK_CORRUPTOR_TAX
		var delay := _delay_for(wave_num)
		if wave_num % 10 == 0:
			var escort_count := maxi(2, int((3 + wave_num / 10) * scale))
			var groups: Array = [
				{"enemy_id": mini_boss, "count": 1},
				{"enemy_id": roster[0], "count": escort_count},
			]
			if roster.size() > 2:
				groups.append({
					"enemy_id": roster[2],
					"count": maxi(1, int(float(escort_count) * 0.5)),
				})
			var mini := _make_wave(wave_id, groups, delay, false, 0.0, "mini_boss", 1.0, false)
			mini.display_name = "Mini-boss"
			waves.append(mini)
			continue
		var slot := global_wave % MACRO_BLOCK_SIZE
		var role: MacroRole = slot as MacroRole
		var template := _macro_role_template(level_id, act_index, role, scale, hijack_tax, wave_num)
		var scaled_groups := _scale_groups(template.get("groups", []), float(template.get("scale_mult", 1.0)))
		scaled_groups = _apply_route_tags(level_id, role, scaled_groups)
		var interval := float(template.get("interval", 0.0))
		var pre_delay := float(template.get("delay", delay))
		var phase := str(template.get("phase", _phase_for_role(role)))
		var mat_mult := float(template.get("material_drop_mult", 1.0))
		var suppress_drops := bool(template.get("suppress_material_drops", false))
		if level_id in ["level_02", "level_04", "level_07"] and role in [MacroRole.TRAP_B, MacroRole.PUSH]:
			interval = maxf(interval, 0.1)
		if level_id == "level_07" and role == MacroRole.PUSH:
			pre_delay = maxf(pre_delay, 2.8)
		waves.append(_make_wave(
			wave_id, scaled_groups, pre_delay, false, interval, phase, mat_mult, suppress_drops
		))
	return waves


static func generate_horde_slice(level_id: String, wave_num: int) -> WaveData:
	var act_index := 0
	var slot := (wave_num - 1) % MACRO_BLOCK_SIZE
	var block_index := (wave_num - 1) / MACRO_BLOCK_SIZE
	var diff := ContentCatalog.khan_difficulty(level_id)
	var scale := float(diff.count_mult) * (1.0 + float(block_index) * BLOCK_SCALE_STEP)
	var hijack_tax := _is_hijack_tax_map(level_id)
	var role: MacroRole = slot as MacroRole
	if wave_num % 10 == 0:
		role = MacroRole.MINI_BOSS
	var template: Dictionary
	if role == MacroRole.MINI_BOSS:
		var mini_boss := ContentCatalog.mini_boss_for(level_id)
		var roster := ContentCatalog.get_horde_roster(level_id)
		var escort_count := maxi(2, int(3 * scale))
		template = {
			"groups": [
				{"enemy_id": mini_boss, "count": 1},
				{"enemy_id": roster[0], "count": escort_count},
			],
			"delay": 2.0,
			"phase": "mini_boss",
		}
	else:
		template = _macro_role_template(level_id, act_index, role, scale, hijack_tax, wave_num)
	var wave := WaveData.new()
	wave.wave_id = "horde_%s_%d" % [level_id, wave_num]
	wave.pre_wave_delay = float(template.get("delay", 1.8))
	wave.spawn_interval = float(template.get("interval", 0.0))
	wave.spawn_groups = _scale_groups(template.get("groups", []), float(template.get("scale_mult", 1.0)))
	wave.wave_phase = str(template.get("phase", _phase_for_role(role)))
	wave.material_drop_mult = float(template.get("material_drop_mult", 1.0))
	wave.suppress_material_drops = bool(template.get("suppress_material_drops", false))
	return wave


static func generate_throne_slice(wave_num: int) -> WaveData:
	var spawn_count := ContentCatalog.THRONE_SPAWN_COUNT
	var wave := WaveData.new()
	wave.wave_id = "throne_%d" % wave_num
	wave.pre_wave_delay = 1.6 if wave_num <= 3 else 1.4
	wave.spawn_interval = 0.35 if wave_num >= 8 else 0.5
	var scale := 1.0 + float(wave_num - 1) * 0.12
	var groups: Array[Dictionary] = []
	if wave_num % 10 == 0:
		wave.wave_phase = "mini_boss"
		groups.append({
			"enemy_id": "enemy_lion_boss",
			"count": 1,
			"spawn_id": "spawn_throne_0",
		})
		var escort := maxi(2, int(3 * scale))
		groups.append({
			"enemy_id": "enemy_div_brute",
			"count": escort,
			"spawn_id": "spawn_throne_4",
		})
	elif wave_num >= 13:
		var per_spawn := maxi(1, int(2 * scale))
		for i in spawn_count:
			groups.append({
				"enemy_id": _throne_enemy_for_wave(wave_num, i),
				"count": per_spawn,
				"spawn_id": "spawn_throne_%d" % i,
			})
	else:
		var active_spawns := mini(3 + wave_num / 3, spawn_count)
		var start_spawn := (wave_num - 1) % spawn_count
		for j in active_spawns:
			var spawn_idx := (start_spawn + j) % spawn_count
			groups.append({
				"enemy_id": _throne_enemy_for_wave(wave_num, spawn_idx),
				"count": maxi(1, int((2 + wave_num / 2) * scale / float(active_spawns))),
				"spawn_id": "spawn_throne_%d" % spawn_idx,
			})
		if wave_num % 5 == 0:
			groups.append({
				"enemy_id": "enemy_corruptor",
				"count": 2,
				"spawn_id": "spawn_throne_%d" % ((start_spawn + 2) % spawn_count),
			})
	wave.spawn_groups = groups
	return wave


static func _throne_enemy_for_wave(wave_num: int, spawn_idx: int) -> String:
	if wave_num <= 4:
		return "enemy_jackal"
	if wave_num <= 8:
		return "enemy_boar" if spawn_idx % 2 == 0 else "enemy_jackal"
	if wave_num <= 12:
		return "enemy_div_brute" if spawn_idx % 3 == 0 else "enemy_boar"
	return "enemy_div_brute" if spawn_idx % 2 == 0 else "enemy_corruptor"


static func macro_role_for_wave_index(wave_index: int) -> int:
	return wave_index % MACRO_BLOCK_SIZE


static func act_index_for_wave_index(wave_index: int) -> int:
	return wave_index / MACRO_BLOCK_SIZE


static func phase_for_role(role: MacroRole) -> String:
	return _phase_for_role(role)


static func _phase_for_role(role: MacroRole) -> String:
	match role:
		MacroRole.BAIT_A, MacroRole.BAIT_B, MacroRole.BAIT_C:
			return "bait"
		MacroRole.TRAP_A, MacroRole.TRAP_B:
			return "trap"
		MacroRole.HIJACK_A, MacroRole.HIJACK_B, MacroRole.HIJACK_C:
			return "hijack"
		MacroRole.PUSH:
			return "push"
		MacroRole.MINI_BOSS:
			return "mini_boss"
	return ""


static func _map_roster(level_id: String) -> Dictionary:
	match level_id:
		"level_01":
			return {
				"bait": "enemy_jackal", "swarm": "enemy_jackal",
				"brute": "enemy_boar", "corruptor": "enemy_corruptor",
			}
		"level_02":
			return {
				"bait": "enemy_mirage_shade", "swarm": "enemy_mirage_shade",
				"brute": "enemy_salt_crust_brute", "corruptor": "enemy_corruptor",
			}
		"level_03":
			return {
				"bait": "enemy_canyon_serpent", "swarm": "enemy_scorched_hound",
				"brute": "enemy_canyon_serpent", "corruptor": "enemy_corruptor",
			}
		"level_04":
			return {
				"bait": "enemy_illusion_attendant", "swarm": "enemy_illusion_attendant",
				"brute": "enemy_feast_shade", "corruptor": "enemy_corruptor",
			}
		"level_05":
			return {
				"bait": "enemy_mountain_raider", "swarm": "enemy_mountain_raider",
				"brute": "enemy_boar", "corruptor": "enemy_corruptor",
				"alt": "enemy_mountain_archer",
			}
		"level_06":
			return {
				"bait": "enemy_div_infantry", "swarm": "enemy_div_infantry",
				"brute": "enemy_div_brute", "corruptor": "enemy_div_corruptor",
			}
		"level_07":
			return {
				"bait": "enemy_white_div_thrall", "swarm": "enemy_white_div_thrall",
				"brute": "enemy_cavern_boulder_brute", "corruptor": "enemy_div_corruptor",
			}
		"level_08_damavand":
			return {
				"bait": "enemy_zahhak_serpent_guard", "swarm": "enemy_zahhak_serpent_guard",
				"brute": "enemy_div_brute", "corruptor": "enemy_corruptor",
				"chainbreaker": "enemy_chainbreaker_div",
			}
		_:
			return {
				"bait": "enemy_jackal", "swarm": "enemy_jackal",
				"brute": "enemy_boar", "corruptor": "enemy_corruptor",
			}


static func _macro_role_template(
	level_id: String,
	act_index: int,
	role: MacroRole,
	base_scale: float,
	hijack_tax: bool,
	global_wave: int
) -> Dictionary:
	if level_id == "level_08_damavand":
		return _damavand_template(act_index, role, base_scale, global_wave)
	var roster := _map_roster(level_id)
	var units := _act_units(level_id, act_index, roster)
	var scale_mult := base_scale
	var interval := 0.0
	var delay := _delay_for(global_wave)
	var material_drop_mult := 1.0
	var suppress_material_drops := false
	match role:
		MacroRole.BAIT_A:
			scale_mult *= BAIT_SCALE
			material_drop_mult = 1.5
			return {
				"groups": [{"enemy_id": units.bait, "count": 6}],
				"delay": 2.5, "interval": interval, "phase": "bait",
				"scale_mult": scale_mult, "material_drop_mult": material_drop_mult,
				"suppress_material_drops": suppress_material_drops,
			}
		MacroRole.BAIT_B:
			scale_mult *= BAIT_SCALE
			material_drop_mult = 1.5
			return {
				"groups": [{"enemy_id": units.bait, "count": 8}],
				"delay": 2.2, "interval": interval, "phase": "bait",
				"scale_mult": scale_mult, "material_drop_mult": material_drop_mult,
				"suppress_material_drops": suppress_material_drops,
			}
		MacroRole.BAIT_C:
			scale_mult *= BAIT_SCALE
			material_drop_mult = 1.5
			var bait_groups: Array = [{"enemy_id": units.bait, "count": 10}]
			if units.get("bait_extra", "") != "":
				bait_groups.append({"enemy_id": units.bait_extra, "count": 3})
			return {
				"groups": bait_groups,
				"delay": 2.0, "interval": interval, "phase": "bait",
				"scale_mult": scale_mult, "material_drop_mult": material_drop_mult,
				"suppress_material_drops": suppress_material_drops,
			}
		MacroRole.TRAP_A:
			scale_mult *= TRAP_SCALE
			return {
				"groups": [
					{"enemy_id": units.swarm, "count": 10},
					{"enemy_id": units.brute, "count": 3},
				],
				"delay": delay, "interval": units.get("trap_interval", 0.0), "phase": "trap",
				"scale_mult": scale_mult, "material_drop_mult": 1.0,
				"suppress_material_drops": suppress_material_drops,
			}
		MacroRole.TRAP_B:
			scale_mult *= TRAP_SCALE * 1.1
			var trap_groups: Array = [
				{"enemy_id": units.brute, "count": 4},
				{"enemy_id": units.swarm, "count": 8},
			]
			if units.get("alt", "") != "":
				trap_groups.append({"enemy_id": units.alt, "count": 4})
			return {
				"groups": trap_groups,
				"delay": maxf(1.0, delay - 0.3), "interval": units.get("trap_interval", 0.12),
				"phase": "trap", "scale_mult": scale_mult, "material_drop_mult": 1.0,
				"suppress_material_drops": suppress_material_drops,
			}
		MacroRole.HIJACK_A:
			scale_mult *= 1.0
			if hijack_tax:
				scale_mult *= HIJACK_CORRUPTOR_TAX
			return {
				"groups": [
					{"enemy_id": units.corruptor, "count": 4},
					{"enemy_id": units.swarm, "count": 8},
				],
				"delay": delay, "interval": 0.0, "phase": "hijack",
				"scale_mult": scale_mult, "material_drop_mult": 1.0,
				"suppress_material_drops": suppress_material_drops,
			}
		MacroRole.HIJACK_B:
			scale_mult *= 1.05
			if hijack_tax:
				scale_mult *= HIJACK_CORRUPTOR_TAX
			return {
				"groups": [
					{"enemy_id": units.corruptor, "count": 5},
					{"enemy_id": units.swarm, "count": 6},
					{"enemy_id": units.brute, "count": 2},
				],
				"delay": delay, "interval": 0.0, "phase": "hijack",
				"scale_mult": scale_mult, "material_drop_mult": 1.0,
				"suppress_material_drops": suppress_material_drops,
			}
		MacroRole.HIJACK_C:
			scale_mult *= 1.1
			if hijack_tax:
				scale_mult *= HIJACK_CORRUPTOR_TAX
			return {
				"groups": [
					{"enemy_id": units.corruptor, "count": 6},
					{"enemy_id": units.brute, "count": 3},
					{"enemy_id": units.swarm, "count": 8},
				],
				"delay": delay, "interval": units.get("hijack_interval", 0.1),
				"phase": "hijack", "scale_mult": scale_mult, "material_drop_mult": 1.0,
				"suppress_material_drops": suppress_material_drops,
			}
		MacroRole.PUSH:
			return {
				"groups": [
					{"enemy_id": units.brute, "count": 4},
					{"enemy_id": units.swarm, "count": 10},
				],
				"delay": delay, "interval": units.get("push_interval", 0.0), "phase": "push",
				"scale_mult": scale_mult, "material_drop_mult": 1.0,
				"suppress_material_drops": suppress_material_drops,
			}
	return {"groups": [], "delay": delay, "phase": "bait", "scale_mult": scale_mult}


static func _act_units(level_id: String, act_index: int, roster: Dictionary) -> Dictionary:
	var units := roster.duplicate()
	units["trap_interval"] = 0.0
	units["hijack_interval"] = 0.0
	units["push_interval"] = 0.0
	units["bait_extra"] = ""
	match level_id:
		"level_01":
			if act_index == 0:
				units["brute"] = units.bait
			elif act_index == 1:
				pass
			else:
				units["hijack_interval"] = 0.12
		"level_02":
			if act_index == 0:
				units["trap_interval"] = 0.18
			elif act_index == 1:
				units["trap_interval"] = 0.15
				units["push_interval"] = 0.12
			elif act_index == 2:
				units["bait"] = units.brute
				units["bait_extra"] = units.swarm
			else:
				units["trap_interval"] = 0.12
		"level_03":
			if act_index == 0:
				units["swarm"] = units.bait
			elif act_index == 1:
				units["trap_interval"] = 0.15
				units["push_interval"] = 0.12
			elif act_index >= 3:
				units["hijack_interval"] = 0.1
		"level_04":
			if act_index >= 1:
				units["bait_extra"] = units.brute
			if act_index >= 2:
				units["hijack_interval"] = 0.1
			if act_index >= 3:
				units["trap_interval"] = 0.1
		"level_05":
			if act_index == 0:
				units["brute"] = units.bait
			elif act_index >= 1:
				units["alt"] = roster.get("alt", "")
				units["trap_interval"] = 0.14
			if act_index >= 2:
				units["push_interval"] = 0.1
		"level_06":
			if act_index >= 3:
				units["hijack_interval"] = 0.08
		"level_07":
			if act_index >= 3:
				units["brute"] = roster.brute
			if act_index >= 6:
				units["hijack_interval"] = 0.08
				units["push_interval"] = 0.08
	return units


static func _damavand_template(
	act_index: int,
	role: MacroRole,
	base_scale: float,
	global_wave: int
) -> Dictionary:
	var delay := _delay_for(global_wave)
	var scale_mult := base_scale
	var suppress_material_drops := false
	var material_drop_mult := 1.0
	if act_index >= 5 and act_index <= 7:
		scale_mult *= 0.65
		if role in [MacroRole.BAIT_A, MacroRole.BAIT_B, MacroRole.BAIT_C]:
			suppress_material_drops = true
			material_drop_mult = 0.0
	if act_index <= 2:
		return _damavand_gauntlet_template(role, scale_mult, delay, material_drop_mult, suppress_material_drops)
	if act_index <= 4:
		return _damavand_chainbreaker_template(role, scale_mult, delay, material_drop_mult, suppress_material_drops)
	if act_index <= 7:
		return _damavand_forge_tax_template(role, scale_mult, delay, material_drop_mult, suppress_material_drops)
	return _damavand_guard_template(role, scale_mult, delay, material_drop_mult, suppress_material_drops)


static func _damavand_gauntlet_template(
	role: MacroRole, scale_mult: float, delay: float,
	mat_mult: float, suppress: bool
) -> Dictionary:
	match role:
		MacroRole.BAIT_A, MacroRole.BAIT_B, MacroRole.BAIT_C:
			var bait_id := "enemy_white_div_thrall" if role == MacroRole.BAIT_C else "enemy_jackal"
			var count := 6 + int(role)
			return {
				"groups": [{"enemy_id": bait_id, "count": count}],
				"delay": 2.5, "phase": "bait", "scale_mult": scale_mult * BAIT_SCALE,
				"material_drop_mult": 1.5, "suppress_material_drops": suppress,
			}
		MacroRole.TRAP_A, MacroRole.TRAP_B:
			return {
				"groups": [
					{"enemy_id": "enemy_illusion_attendant", "count": 8},
					{"enemy_id": "enemy_scorched_hound", "count": 6},
				],
				"delay": delay, "interval": 0.12, "phase": "trap", "scale_mult": scale_mult * TRAP_SCALE,
				"material_drop_mult": mat_mult, "suppress_material_drops": suppress,
			}
		MacroRole.HIJACK_A, MacroRole.HIJACK_B, MacroRole.HIJACK_C:
			return {
				"groups": [
					{"enemy_id": "enemy_canyon_serpent", "count": 4 + int(role) - 4},
					{"enemy_id": "enemy_corruptor", "count": 3},
				],
				"delay": delay, "phase": "hijack", "scale_mult": scale_mult,
				"material_drop_mult": mat_mult, "suppress_material_drops": suppress,
			}
		MacroRole.PUSH:
			return {
				"groups": [
					{"enemy_id": "enemy_mirage_shade", "count": 10},
					{"enemy_id": "enemy_boar", "count": 3},
				],
				"delay": delay, "phase": "push", "scale_mult": scale_mult,
				"material_drop_mult": mat_mult, "suppress_material_drops": suppress,
			}
	return {"groups": [], "delay": delay, "phase": "bait", "scale_mult": scale_mult}


static func _damavand_chainbreaker_template(
	role: MacroRole, scale_mult: float, delay: float,
	mat_mult: float, suppress: bool
) -> Dictionary:
	match role:
		MacroRole.BAIT_A, MacroRole.BAIT_B, MacroRole.BAIT_C:
			return {
				"groups": [{"enemy_id": "enemy_zahhak_serpent_guard", "count": 5 + int(role)}],
				"delay": 2.2, "phase": "bait", "scale_mult": scale_mult * BAIT_SCALE,
				"material_drop_mult": mat_mult, "suppress_material_drops": suppress,
			}
		MacroRole.TRAP_A, MacroRole.TRAP_B, MacroRole.HIJACK_A, MacroRole.HIJACK_B, MacroRole.HIJACK_C:
			return {
				"groups": [
					{"enemy_id": "enemy_chainbreaker_div", "count": 2 + int(role) - 3},
					{"enemy_id": "enemy_div_brute", "count": 3},
					{"enemy_id": "enemy_corruptor", "count": 3},
				],
				"delay": delay, "phase": "hijack" if role >= MacroRole.HIJACK_A else "trap",
				"scale_mult": scale_mult * TRAP_SCALE, "material_drop_mult": mat_mult,
				"suppress_material_drops": suppress,
			}
		MacroRole.PUSH:
			return {
				"groups": [
					{"enemy_id": "enemy_chainbreaker_div", "count": 2},
					{"enemy_id": "enemy_zahhak_serpent_guard", "count": 8},
				],
				"delay": delay, "phase": "push", "scale_mult": scale_mult,
				"material_drop_mult": mat_mult, "suppress_material_drops": suppress,
			}
	return {"groups": [], "delay": delay, "phase": "bait", "scale_mult": scale_mult}


static func _damavand_forge_tax_template(
	role: MacroRole, scale_mult: float, delay: float,
	mat_mult: float, suppress: bool
) -> Dictionary:
	var bait := role in [MacroRole.BAIT_A, MacroRole.BAIT_B, MacroRole.BAIT_C]
	var no_drops := suppress or bait
	match role:
		MacroRole.BAIT_A, MacroRole.BAIT_B, MacroRole.BAIT_C:
			return {
				"groups": [{"enemy_id": "enemy_div_infantry", "count": 4 + int(role)}],
				"delay": 2.2, "phase": "bait", "scale_mult": scale_mult * BAIT_SCALE,
				"material_drop_mult": 0.0, "suppress_material_drops": true,
			}
		MacroRole.TRAP_A, MacroRole.TRAP_B:
			return {
				"groups": [
					{"enemy_id": "enemy_zahhak_serpent_guard", "count": 6},
					{"enemy_id": "enemy_div_brute", "count": 2},
				],
				"delay": delay, "phase": "trap", "scale_mult": scale_mult,
				"material_drop_mult": mat_mult, "suppress_material_drops": no_drops,
			}
		MacroRole.HIJACK_A, MacroRole.HIJACK_B, MacroRole.HIJACK_C:
			return {
				"groups": [
					{"enemy_id": "enemy_div_corruptor", "count": 3},
					{"enemy_id": "enemy_div_infantry", "count": 6},
				],
				"delay": delay, "phase": "hijack", "scale_mult": scale_mult,
				"material_drop_mult": mat_mult, "suppress_material_drops": no_drops,
			}
		MacroRole.PUSH:
			return {
				"groups": [
					{"enemy_id": "enemy_div_brute", "count": 3},
					{"enemy_id": "enemy_div_infantry", "count": 8},
				],
				"delay": delay, "phase": "push", "scale_mult": scale_mult,
				"material_drop_mult": mat_mult, "suppress_material_drops": no_drops,
			}
	return {"groups": [], "delay": delay, "phase": "bait", "scale_mult": scale_mult}


static func _damavand_guard_template(
	role: MacroRole, scale_mult: float, delay: float,
	mat_mult: float, suppress: bool
) -> Dictionary:
	match role:
		MacroRole.BAIT_A, MacroRole.BAIT_B, MacroRole.BAIT_C:
			return {
				"groups": [{"enemy_id": "enemy_zahhak_serpent_guard", "count": 8 + int(role)}],
				"delay": 2.0, "phase": "bait", "scale_mult": scale_mult * BAIT_SCALE,
				"material_drop_mult": mat_mult, "suppress_material_drops": suppress,
			}
		MacroRole.TRAP_A, MacroRole.TRAP_B, MacroRole.PUSH:
			return {
				"groups": [
					{"enemy_id": "enemy_zahhak_serpent_guard", "count": 10},
					{"enemy_id": "enemy_div_brute", "count": 4},
				],
				"delay": delay, "interval": 0.15, "phase": "trap" if role != MacroRole.PUSH else "push",
				"scale_mult": scale_mult * TRAP_SCALE, "material_drop_mult": mat_mult,
				"suppress_material_drops": suppress,
			}
		MacroRole.HIJACK_A, MacroRole.HIJACK_B, MacroRole.HIJACK_C:
			return {
				"groups": [
					{"enemy_id": "enemy_div_corruptor", "count": 5},
					{"enemy_id": "enemy_zahhak_serpent_guard", "count": 8},
					{"enemy_id": "enemy_div_brute", "count": 3},
				],
				"delay": delay, "interval": 0.1, "phase": "hijack", "scale_mult": scale_mult * 1.15,
				"material_drop_mult": mat_mult, "suppress_material_drops": suppress,
			}
	return {"groups": [], "delay": delay, "phase": "bait", "scale_mult": scale_mult}


static func _apply_route_tags(level_id: String, role: MacroRole, groups: Array[Dictionary]) -> Array[Dictionary]:
	if level_id not in ["level_05", "level_06", "level_07", "level_08_damavand"]:
		return groups
	if role not in [MacroRole.TRAP_B, MacroRole.PUSH]:
		return groups
	var out: Array[Dictionary] = []
	for entry in groups:
		var g: Dictionary = entry.duplicate()
		if role == MacroRole.TRAP_B:
			g["route_id"] = "route_2"
			g["spawn_id"] = "spawn_2"
		elif role == MacroRole.PUSH and int(g.get("count", 0)) >= 4:
			g["route_id"] = "route_2"
		out.append(g)
	return out


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
	interval: float = 0.0,
	phase: String = "",
	material_drop_mult: float = 1.0,
	suppress_material_drops: bool = false
) -> WaveData:
	var w := WaveData.new()
	w.wave_id = wave_id
	w.pre_wave_delay = delay
	w.spawn_groups = _scale_groups(groups, 1.0)
	w.is_boss_wave = boss
	w.spawn_interval = interval
	w.wave_phase = phase
	w.material_drop_mult = material_drop_mult
	w.suppress_material_drops = suppress_material_drops
	return w
