class_name WaveSpawnValidator
extends RefCounted

## Validates wave spawn data across all maps and game modes.
## Run headless via smoke_test or in-editor from the debug menu (F3).


static func validate(catalog: BootstrapContent = null) -> Array[String]:
	var errors: Array[String] = []
	if catalog == null:
		catalog = ContentCatalog.build_bootstrap()
	if catalog == null:
		errors.append("catalog is null")
		return errors

	var enemy_ids := _collect_enemy_ids(catalog)
	for level in catalog.levels:
		if not (level is LevelData):
			continue
		errors.append_array(_validate_level_routes(level))
		errors.append_array(_validate_authored_waves(level, enemy_ids))
		errors.append_array(_validate_campaign_invariants(level, enemy_ids))

	errors.append_array(_validate_horde_slices(enemy_ids))
	errors.append_array(_validate_throne_slices(enemy_ids))
	errors.append_array(_validate_endless_slices(enemy_ids))
	errors.append_array(_validate_gauntlet_bosses(enemy_ids))
	errors.append_array(_validate_tutorial(catalog))
	errors.append_array(_validate_mode_wave_sources(catalog))
	return errors


static func validate_and_report(catalog: BootstrapContent = null) -> bool:
	var errors := validate(catalog)
	if errors.is_empty():
		print("WaveSpawnValidator: PASS")
		return true
	for err in errors:
		push_error("WaveSpawnValidator: %s" % err)
	print("WaveSpawnValidator: FAIL (%d errors)" % errors.size())
	return false


static func _collect_enemy_ids(catalog: BootstrapContent) -> Dictionary:
	var ids := {}
	for e in catalog.enemies:
		if e is EnemyData:
			ids[e.enemy_id] = true
	return ids


static func _validate_level_routes(level: LevelData) -> Array[String]:
	var errors: Array[String] = []
	level.ensure_routes_migrated()
	level.ensure_spawns_migrated()
	if level.path_routes.is_empty() and level.path_points.is_empty():
		errors.append("level %s has no routes" % level.level_id)
	if level.spawn_points.is_empty() and level.spawn_position == Vector2.ZERO:
		if level.level_id != ContentCatalog.THRONE_ARENA_LEVEL_ID:
			errors.append("level %s has no spawn points" % level.level_id)

	var route_ids := {}
	for route in level.path_routes:
		if route.route_id == "":
			errors.append("level %s has route with empty route_id" % level.level_id)
		elif route.points.is_empty():
			errors.append("level %s route %s has no points" % [level.level_id, route.route_id])
		else:
			route_ids[route.route_id] = true

	var spawn_ids := {}
	for spawn in level.spawn_points:
		if spawn.spawn_id == "":
			errors.append("level %s has spawn with empty spawn_id" % level.level_id)
		else:
			spawn_ids[spawn.spawn_id] = true
		var rid := spawn.route_id
		if rid != "" and not route_ids.has(rid) and level.path_routes.size() > 0:
			errors.append("level %s spawn %s references missing route %s" % [
				level.level_id, spawn.spawn_id, rid
			])

	if level.level_id == ContentCatalog.THRONE_ARENA_LEVEL_ID:
		if level.path_routes.size() < ContentCatalog.THRONE_SPAWN_COUNT:
			errors.append("throne arena needs %d radial routes, has %d" % [
				ContentCatalog.THRONE_SPAWN_COUNT, level.path_routes.size()
			])
		if level.spawn_points.size() < ContentCatalog.THRONE_SPAWN_COUNT:
			errors.append("throne arena needs %d radial spawns, has %d" % [
				ContentCatalog.THRONE_SPAWN_COUNT, level.spawn_points.size()
			])
		for i in ContentCatalog.THRONE_SPAWN_COUNT:
			var expected_route := "route_throne_%d" % i
			var expected_spawn := "spawn_throne_%d" % i
			if not route_ids.has(expected_route):
				errors.append("throne arena missing %s" % expected_route)
			if not spawn_ids.has(expected_spawn):
				errors.append("throne arena missing %s" % expected_spawn)

	for wave in level.waves:
		for group in wave.spawn_groups:
			var sid := str(group.get("spawn_id", ""))
			var rid := str(group.get("route_id", ""))
			if sid != "" and not spawn_ids.has(sid) and level.spawn_points.size() > 0:
				# Fallback spawn resolution is allowed; only error if route_id also missing.
				if rid != "" and not route_ids.has(rid):
					errors.append("level %s wave %s spawn %s route %s not on map" % [
						level.level_id, wave.wave_id, sid, rid
					])
			elif rid != "" and not route_ids.has(rid):
				errors.append("level %s wave %s references missing route %s" % [
					level.level_id, wave.wave_id, rid
				])
	return errors


static func _validate_authored_waves(level: LevelData, enemy_ids: Dictionary) -> Array[String]:
	var errors: Array[String] = []
	for wave in level.waves:
		if wave.spawn_groups.is_empty():
			errors.append("level %s wave %s has no spawn groups" % [level.level_id, wave.wave_id])
		for group in wave.spawn_groups:
			var eid := str(group.get("enemy_id", ""))
			if eid == "":
				errors.append("level %s wave %s has empty enemy_id" % [level.level_id, wave.wave_id])
			elif not enemy_ids.has(eid):
				errors.append("level %s wave %s unknown enemy %s" % [level.level_id, wave.wave_id, eid])
			if int(group.get("count", 0)) < 1:
				errors.append("level %s wave %s group count < 1 for %s" % [
					level.level_id, wave.wave_id, eid
				])
	return errors


static func _validate_campaign_invariants(level: LevelData, enemy_ids: Dictionary) -> Array[String]:
	var errors: Array[String] = []
	if level.is_tutorial or level.level_id == ContentCatalog.THRONE_ARENA_LEVEL_ID:
		return errors
	if level.waves.is_empty():
		return errors

	var expected := ContentCatalog.wave_count_for(level.level_id)
	if expected <= 0:
		return errors
	if level.waves.size() != expected:
		errors.append("campaign %s expected %d waves, has %d" % [
			level.level_id, expected, level.waves.size()
		])

	var boss_id := level.boss_enemy_id
	if boss_id == "":
		errors.append("campaign %s missing boss_enemy_id" % level.level_id)
	elif not enemy_ids.has(boss_id):
		errors.append("campaign %s boss %s not in catalog" % [level.level_id, boss_id])

	var mini_boss := ContentCatalog.mini_boss_for(level.level_id)
	if not enemy_ids.has(mini_boss):
		errors.append("campaign %s mini_boss %s not in catalog" % [level.level_id, mini_boss])

	for i in range(level.waves.size()):
		var wave_num := i + 1
		var wave: WaveData = level.waves[i]
		if wave_num == expected:
			if not wave.is_boss_wave:
				errors.append("%s final wave %d should be boss wave" % [level.level_id, wave_num])
			elif wave.spawn_groups.is_empty():
				errors.append("%s final wave has no spawn groups" % level.level_id)
			elif str(wave.spawn_groups[0].get("enemy_id", "")) != boss_id:
				errors.append("%s final wave boss should be %s" % [level.level_id, boss_id])
		elif wave_num % 10 == 0:
			var has_mini := false
			for group in wave.spawn_groups:
				if str(group.get("enemy_id", "")) == mini_boss:
					has_mini = true
					break
			if not has_mini:
				errors.append("%s wave %d should include mini-boss %s" % [
					level.level_id, wave_num, mini_boss
				])
	return errors


static func _validate_horde_slices(enemy_ids: Dictionary) -> Array[String]:
	var errors: Array[String] = []
	for level_id in ContentCatalog.KHAN_HORDE_LEVELS:
		for wave_num in range(1, ContentCatalog.HORDE_WAVES_TO_CLEAR + 1):
			var wave := CampaignWaveTemplates.generate_horde_slice(level_id, wave_num)
			errors.append_array(_validate_procedural_wave(
				wave, enemy_ids, "horde %s wave %d" % [level_id, wave_num]
			))
	return errors


static func _validate_throne_slices(enemy_ids: Dictionary) -> Array[String]:
	var errors: Array[String] = []
	var throne_level := ContentCatalog.build_throne_arena_level()
	for wave_num in range(1, ContentCatalog.HORDE_WAVES_TO_CLEAR + 1):
		var wave := CampaignWaveTemplates.generate_throne_slice(wave_num)
		errors.append_array(_validate_procedural_wave(
			wave, enemy_ids, "throne wave %d" % wave_num
		))
		for group in wave.spawn_groups:
			var sid := str(group.get("spawn_id", ""))
			if sid == "":
				errors.append("throne wave %d group missing spawn_id" % wave_num)
				continue
			if not sid.begins_with("spawn_throne_"):
				errors.append("throne wave %d uses non-radial spawn %s" % [wave_num, sid])
				continue
			var idx_str := sid.replace("spawn_throne_", "")
			if not idx_str.is_valid_int():
				errors.append("throne wave %d invalid spawn_id %s" % [wave_num, sid])
				continue
			var idx := int(idx_str)
			if idx < 0 or idx >= ContentCatalog.THRONE_SPAWN_COUNT:
				errors.append("throne wave %d spawn index out of range: %s" % [wave_num, sid])
			var resolved := throne_level.resolve_enemy_route(group)
			if (resolved.get("path", PackedVector2Array()) as PackedVector2Array).size() < 2:
				errors.append("throne wave %d spawn %s resolves to invalid path" % [wave_num, sid])
	return errors


static func _validate_endless_slices(enemy_ids: Dictionary) -> Array[String]:
	var errors: Array[String] = []
	var level_id := "level_01"
	for wave_num in [16, 30, 50, 100]:
		var wave := _build_endless_wave_data(level_id, wave_num)
		errors.append_array(_validate_procedural_wave(
			wave, enemy_ids, "endless wave %d" % wave_num
		))
	var w15 := CampaignWaveTemplates.generate_horde_slice(level_id, 15)
	var w30 := _build_endless_wave_data(level_id, 30)
	if _total_enemy_count(w30) <= _total_enemy_count(w15):
		errors.append(
			"endless wave 30 should scale above wave 15 (got %d vs %d)" % [
				_total_enemy_count(w30), _total_enemy_count(w15)
			]
		)
	return errors


static func _build_endless_wave_data(level_id: String, wave_num: int) -> WaveData:
	var wave := CampaignWaveTemplates.generate_horde_slice(level_id, wave_num)
	wave.wave_id = "endless_%d" % wave_num
	if wave_num > ContentCatalog.HORDE_WAVES_TO_CLEAR:
		var extra_blocks := (wave_num - 1) / CampaignWaveTemplates.MACRO_BLOCK_SIZE
		var extra_scale := 1.0 + float(extra_blocks - 1) * 0.08
		if extra_scale > 1.0:
			for group in wave.spawn_groups:
				group["count"] = maxi(1, int(round(float(group.get("count", 1)) * extra_scale)))
	return wave


static func _validate_gauntlet_bosses(enemy_ids: Dictionary) -> Array[String]:
	var errors: Array[String] = []
	var expected_bosses := {
		"level_01": "enemy_lion_boss",
		"level_02": "enemy_thirst_manifest",
		"level_03": "enemy_azhdaha",
		"level_04": "enemy_sorceress",
		"level_05": "enemy_olad_champion",
		"level_06": "enemy_arzhang_div",
		"level_07": "enemy_white_div",
	}
	for i in GauntletRunState.GAUNTLET_LEVEL_IDS.size():
		var level_id := GauntletRunState.GAUNTLET_LEVEL_IDS[i]
		var boss_id := expected_bosses.get(level_id, "")
		if boss_id == "":
			errors.append("gauntlet missing boss mapping for %s" % level_id)
			continue
		if not enemy_ids.has(boss_id):
			errors.append("gauntlet boss %s not in catalog" % boss_id)
		if BossControllerFactory.create(boss_id) == null:
			errors.append("gauntlet boss %s has no controller" % boss_id)
		var waves := CampaignWaveTemplates.generate(level_id, boss_id)
		var final: WaveData = waves[waves.size() - 1]
		if not final.is_boss_wave:
			errors.append("gauntlet %s final wave not flagged boss" % level_id)
		elif str(final.spawn_groups[0].get("enemy_id", "")) != boss_id:
			errors.append("gauntlet %s final boss mismatch" % level_id)
	return errors


static func _validate_tutorial(catalog: BootstrapContent) -> Array[String]:
	var errors: Array[String] = []
	var tutorial := _find_level(catalog.levels, "level_00_tutorial")
	if tutorial == null:
		errors.append("missing tutorial level")
		return errors
	if tutorial.waves.size() != 2:
		errors.append("tutorial must have exactly 2 waves, has %d" % tutorial.waves.size())
	for wave in tutorial.waves:
		if wave.spawn_groups.is_empty():
			errors.append("tutorial wave %s empty" % wave.wave_id)
	return errors


static func _validate_mode_wave_sources(catalog: BootstrapContent) -> Array[String]:
	var errors: Array[String] = []
	var throne := _find_level(catalog.levels, ContentCatalog.THRONE_ARENA_LEVEL_ID)
	if throne and not throne.waves.is_empty():
		errors.append("throne arena should use procedural waves (authored waves must be empty)")

	for level_id in ["level_01", "level_02", "level_08_damavand"]:
		var level := _find_level(catalog.levels, level_id)
		if level and level.waves.is_empty():
			errors.append("campaign level %s has no authored waves" % level_id)

	# Mode launch sanity — each mode flag resolves to a wave path without crashing.
	var launch_checks: Array[Dictionary] = [
		{"label": "campaign", "launch": _make_launch({})},
		{"label": "horde", "launch": _make_launch({"is_horde_mode": true})},
		{"label": "endless", "launch": _make_launch({"is_endless_mode": true})},
		{"label": "daily", "launch": _make_launch({"is_daily_tale": true})},
		{"label": "brothers", "launch": _make_launch({"is_brothers_mode": true})},
		{"label": "throne", "launch": _make_launch({
			"is_throne_defense_mode": true, "level_id": ContentCatalog.THRONE_ARENA_LEVEL_ID
		})},
		{"label": "gauntlet", "launch": _make_launch({"is_gauntlet_mode": true})},
		{"label": "hunt", "launch": _make_launch({
			"is_hunt_mode": true, "level_id": "level_08_damavand"
		})},
		{"label": "campaign_run_skirmish", "launch": _make_launch({
			"is_campaign_run": true, "skirmish_waves": CampaignRunGenerator.SKIRMISH_WAVES
		})},
	]
	for check in launch_checks:
		var launch: BattleLaunchData = check["launch"]
		var label: String = str(check["label"])
		if label == "campaign":
			if not launch.is_campaign_mode():
				errors.append("campaign launch should report is_campaign_mode")
		elif launch.is_campaign_mode():
			errors.append("%s launch incorrectly reports campaign mode" % label)
	return errors


static func _validate_procedural_wave(
	wave: WaveData, enemy_ids: Dictionary, label: String
) -> Array[String]:
	var errors: Array[String] = []
	if wave == null:
		errors.append("%s: wave is null" % label)
		return errors
	if wave.spawn_groups.is_empty():
		errors.append("%s: no spawn groups" % label)
	for group in wave.spawn_groups:
		var eid := str(group.get("enemy_id", ""))
		if not enemy_ids.has(eid):
			errors.append("%s: unknown enemy %s" % [label, eid])
	return errors


static func _total_enemy_count(wave: WaveData) -> int:
	var total := 0
	for group in wave.spawn_groups:
		total += int(group.get("count", 0))
	return total


static func _find_level(levels: Array, level_id: String) -> LevelData:
	for l in levels:
		if l is LevelData and l.level_id == level_id:
			return l
	return null


static func _make_launch(flags: Dictionary) -> BattleLaunchData:
	var launch := BattleLaunchData.new()
	for key in flags.keys():
		launch.set(key, flags[key])
	return launch
