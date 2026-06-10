extends Node

const SAVE_PATH := "user://shahnamehtd_save.json"
const SAVE_VERSION := 9

const STARTER_TOWER_IDS: Array[String] = [
	"tower_archer",
	"tower_sacred_fire",
	"tower_heavy",
	"tower_control",
]

var _data: Dictionary = {}


func _ready() -> void:
	load_save()


func load_save() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		_data = _default_data()
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		_data = _default_data()
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	if parsed is Dictionary:
		_data = parsed
		_migrate_save()
	else:
		_data = _default_data()


func _migrate_save() -> void:
	var version_before := int(_data.get("save_version", 1))
	_data = SaveMigration.migrate(_data, SAVE_VERSION)
	ensure_starter_towers_in_pool()
	if int(_data.get("save_version", 1)) != version_before:
		save_game()


func test_replace_data(data: Dictionary) -> void:
	_data = data.duplicate(true)


func test_reset_to_defaults() -> void:
	test_replace_data(_default_data())


func save_game() -> void:
	_data["save_version"] = SAVE_VERSION
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_warning("SaveSystem: could not write save.")
		return
	file.store_string(JSON.stringify(_data, "\t"))
	file.close()


func _default_data() -> Dictionary:
	var data := {
		"save_version": SAVE_VERSION,
		"tutorial_completed": false,
		"unlocked_levels": ["level_00_tutorial"],
		"campaign_progress": {},
		"settings": {
			"music_volume": 0.8,
			"sfx_volume": 0.8,
			"reduced_particles": false,
		},
		"analytics_consent": false,
		"khan_seals": 0,
		"star_iron": {},
		"tower_forge": {},
		"replay_stats": {},
		"accessibility": _default_accessibility(),
		"daily_tale": {},
		"endless_best": 0,
		"hunt_best_binding": 0,
		"damavand_forge_notified": false,
		"roguelite_run": {},
		"campaign_run": {},
		"relics_owned": [],
		"cosmetic_entitlements": [],
		"paid_entitlements": [],
		"seen_hints": {},
		"forge_tokens": 0,
		"spells_owned": [],
		"horde_progress": {},
		"unlocked_towers": STARTER_TOWER_IDS.duplicate(),
		"gauntlet_best": _default_gauntlet_best(),
		"equipment_owned": [],
		"equipment_equipped": {
			"weapon": "",
			"armor": "",
			"helm": "",
			"talisman": "",
		},
		"hero_skill_selected": "rostam_charge",
		"daily_missions": {},
		"mission_lifetime": {
			"total_div_kills": 0,
			"total_cleanses": 0,
			"total_forge_tokens_spent": 0,
		},
		"royal_bounty_tickets": 0,
	}
	return data


func _default_gauntlet_best() -> Dictionary:
	return {
		"total_ms": 0,
		"splits_ms": [],
		"trace": [],
	}


func _default_accessibility() -> Dictionary:
	return SaveMigration.default_accessibility()


func record_replay(level_id: String) -> void:
	var stats: Dictionary = _data.get("replay_stats", {})
	var entry: Dictionary = stats.get(level_id, {"count": 0, "last_time": 0})
	entry["count"] = int(entry.get("count", 0)) + 1
	entry["last_time"] = Time.get_unix_time_from_system()
	stats[level_id] = entry
	_data["replay_stats"] = stats
	save_game()


func get_replay_count(level_id: String) -> int:
	var stats: Dictionary = _data.get("replay_stats", {})
	var entry: Variant = stats.get(level_id, null)
	if entry is Dictionary:
		return int(entry.get("count", 0))
	return 0


func get_accessibility(key: String, default_value: Variant = null) -> Variant:
	var acc: Dictionary = _data.get("accessibility", {})
	return acc.get(key, default_value)


func set_accessibility(key: String, value: Variant) -> void:
	var acc: Dictionary = _data.get("accessibility", {})
	acc[key] = value
	_data["accessibility"] = acc
	save_game()


func add_khan_seal() -> void:
	var seals := int(_data.get("khan_seals", 0))
	_data["khan_seals"] = mini(seals + 1, 7)
	save_game()


func get_khan_seals() -> int:
	return int(_data.get("khan_seals", 0))


func has_all_khan_seals() -> bool:
	return get_khan_seals() >= 7


func get_roguelite_run() -> Dictionary:
	var state: Variant = _data.get("roguelite_run", {})
	return state if state is Dictionary else {}


func set_roguelite_run(run_data: Dictionary) -> void:
	_data["roguelite_run"] = run_data.duplicate(true)
	save_game()


func clear_roguelite_run() -> void:
	_data["roguelite_run"] = {}
	save_game()


func get_campaign_run() -> Dictionary:
	var state: Variant = _data.get("campaign_run", {})
	return state if state is Dictionary else {}


func set_campaign_run(run_data: Dictionary) -> void:
	_data["campaign_run"] = run_data.duplicate(true)
	save_game()


func clear_campaign_run() -> void:
	_data["campaign_run"] = {}
	save_game()


func get_unlocked_tower_pool() -> Array[String]:
	var raw: Variant = _data.get("unlocked_towers", [])
	var ids: Array[String] = []
	if raw is Array:
		for entry in raw:
			if entry is String:
				ids.append(entry)
	if ids.is_empty():
		return STARTER_TOWER_IDS.duplicate()
	return ids


func is_tower_in_pool(tower_id: String) -> bool:
	return tower_id in get_unlocked_tower_pool()


func unlock_tower_to_pool(tower_id: String) -> void:
	unlock_tower(tower_id)


func ensure_starter_towers_in_pool() -> void:
	for tid in STARTER_TOWER_IDS:
		if not is_tower_in_pool(tid):
			unlock_tower(tid)


func get_daily_tale_state() -> Dictionary:
	var state: Variant = _data.get("daily_tale", {})
	return state if state is Dictionary else {}


func set_daily_tale_state(state: Dictionary) -> void:
	_data["daily_tale"] = state
	save_game()


func get_cosmetic_entitlements() -> Array[String]:
	var raw: Variant = _data.get("cosmetic_entitlements", [])
	var ids: Array[String] = []
	if raw is Array:
		for entry in raw:
			if entry is String:
				ids.append(entry)
	return ids


func set_cosmetic_entitlements(ids: Array[String]) -> void:
	_data["cosmetic_entitlements"] = ids.duplicate()
	save_game()


func get_paid_entitlements() -> Array[String]:
	var raw: Variant = _data.get("paid_entitlements", [])
	var ids: Array[String] = []
	if raw is Array:
		for entry in raw:
			if entry is String:
				ids.append(entry)
	return ids


func set_paid_entitlements(ids: Array[String]) -> void:
	_data["paid_entitlements"] = ids.duplicate()
	save_game()


func get_forge_tokens() -> int:
	return int(_data.get("forge_tokens", 0))


func add_forge_tokens(amount: int) -> void:
	if amount <= 0:
		return
	_data["forge_tokens"] = get_forge_tokens() + amount
	save_game()


func spend_forge_tokens(amount: int) -> bool:
	if amount <= 0:
		return false
	if get_forge_tokens() < amount:
		return false
	_data["forge_tokens"] = get_forge_tokens() - amount
	if MissionProgressTracker:
		MissionProgressTracker.record_forge_tokens_spent(amount)
	save_game()
	return true


func get_spells_owned() -> Array[String]:
	var raw: Variant = _data.get("spells_owned", [])
	var ids: Array[String] = []
	if raw is Array:
		for entry in raw:
			if entry is String:
				ids.append(entry)
	return ids


func owns_spell(spell_id: String) -> bool:
	return spell_id in get_spells_owned()


func add_spell(spell_id: String) -> void:
	if spell_id == "" or owns_spell(spell_id):
		return
	var owned := get_spells_owned()
	owned.append(spell_id)
	_data["spells_owned"] = owned
	save_game()


func is_tower_unlocked(tower_id: String) -> bool:
	var raw: Variant = _data.get("unlocked_towers", [])
	if raw is Array:
		return tower_id in raw
	return false


func unlock_tower(tower_id: String) -> void:
	if tower_id == "" or is_tower_unlocked(tower_id):
		return
	var unlocked: Array = _data.get("unlocked_towers", [])
	unlocked.append(tower_id)
	_data["unlocked_towers"] = unlocked
	save_game()


func get_horde_progress(level_id: String) -> Dictionary:
	var progress: Dictionary = _data.get("horde_progress", {})
	var entry: Variant = progress.get(level_id, null)
	return entry if entry is Dictionary else {"cleared": false, "best_wave": 0}


func is_horde_cleared(level_id: String) -> bool:
	return bool(get_horde_progress(level_id).get("cleared", false))


func record_horde_victory(level_id: String, waves_cleared: int) -> void:
	var progress: Dictionary = _data.get("horde_progress", {})
	var entry: Dictionary = get_horde_progress(level_id)
	entry["cleared"] = true
	entry["best_wave"] = maxi(int(entry.get("best_wave", 0)), waves_cleared)
	progress[level_id] = entry
	_data["horde_progress"] = progress
	if has_all_khan_horde_clears() and not is_tower_unlocked("tower_zahhak_serpent"):
		unlock_tower("tower_zahhak_serpent")
	save_game()


func has_all_khan_horde_clears() -> bool:
	for level_id in ContentCatalog.KHAN_HORDE_LEVELS:
		if not is_horde_cleared(level_id):
			return false
	return true


func get_horde_clears_count() -> int:
	var count := 0
	for level_id in ContentCatalog.KHAN_HORDE_LEVELS:
		if is_horde_cleared(level_id):
			count += 1
	return count


func get_endless_best() -> int:
	return int(_data.get("endless_best", 0))


func set_endless_best(wave: int) -> void:
	if wave > get_endless_best():
		_data["endless_best"] = wave
		save_game()


func get_gauntlet_best() -> Dictionary:
	var best: Variant = _data.get("gauntlet_best", {})
	if best is Dictionary:
		return best.duplicate(true)
	return _default_gauntlet_best()


func try_set_gauntlet_best(run: GauntletRunState) -> bool:
	if run == null:
		return false
	var elapsed := run.get_elapsed_ms()
	var current := get_gauntlet_best()
	var prev_ms := int(current.get("total_ms", 0))
	if prev_ms > 0 and elapsed >= prev_ms:
		return false
	_data["gauntlet_best"] = {
		"total_ms": elapsed,
		"splits_ms": run.splits_ms.duplicate(),
		"trace": run.trace.duplicate(true),
	}
	save_game()
	return true


func get_hunt_best_binding() -> int:
	return int(_data.get("hunt_best_binding", 0))


func record_hunt_binding(shards: int) -> void:
	if shards > get_hunt_best_binding():
		_data["hunt_best_binding"] = shards
		save_game()


func is_damavand_forge_notified() -> bool:
	return bool(_data.get("damavand_forge_notified", false))


func set_damavand_forge_notified() -> void:
	_data["damavand_forge_notified"] = true
	save_game()


func unlock_levels_after_clear(level_id: String) -> void:
	match level_id:
		"level_01":
			unlock_level("level_02")
		"level_02":
			unlock_level("level_03")
		"level_03":
			unlock_level("level_04")
		"level_04":
			unlock_level("level_05")
		"level_05":
			unlock_level("level_06")
		"level_06":
			unlock_level("level_07")
		"level_07":
			unlock_level("level_08_damavand")
		_:
			pass


func get_material(material_id: String) -> int:
	var bank: Dictionary = _data.get("star_iron", {})
	return int(bank.get(material_id, 0))


func add_material(material_id: String, amount: int) -> void:
	if material_id == "" or amount <= 0:
		return
	var bank: Dictionary = _data.get("star_iron", {})
	bank[material_id] = int(bank.get(material_id, 0)) + amount
	_data["star_iron"] = bank
	save_game()


func spend_material(material_id: String, amount: int) -> bool:
	if material_id == "" or amount <= 0:
		return false
	var bank: Dictionary = _data.get("star_iron", {})
	var current := int(bank.get(material_id, 0))
	if current < amount:
		return false
	bank[material_id] = current - amount
	_data["star_iron"] = bank
	save_game()
	return true


func get_tower_forge(tower_id: String) -> Dictionary:
	var forge: Dictionary = _data.get("tower_forge", {})
	var state: Variant = forge.get(tower_id, null)
	if state is Dictionary:
		return state.duplicate()
	return {"level": 1, "elite_level": 0}


func set_tower_forge(tower_id: String, state: Dictionary) -> void:
	var forge: Dictionary = _data.get("tower_forge", {})
	forge[tower_id] = state
	_data["tower_forge"] = forge
	save_game()


func commit_battle_materials(earned: Dictionary) -> void:
	if earned.is_empty():
		return
	var bank: Dictionary = _data.get("star_iron", {})
	for mat_id in earned.keys():
		var amt := int(earned[mat_id])
		if amt <= 0:
			continue
		bank[mat_id] = int(bank.get(mat_id, 0)) + amt
	_data["star_iron"] = bank
	save_game()


func is_level_unlocked(level_id: String) -> bool:
	var unlocked: Array = _data.get("unlocked_levels", [])
	return level_id in unlocked


func is_level_cleared(level_id: String) -> bool:
	var progress: Dictionary = _data.get("campaign_progress", {})
	var entry: Variant = progress.get(level_id, null)
	if entry is Dictionary:
		return bool(entry.get("cleared", false))
	return false


func has_level_seal(level_id: String) -> bool:
	var progress: Dictionary = _data.get("campaign_progress", {})
	var entry: Variant = progress.get(level_id, null)
	if entry is Dictionary:
		return bool(entry.get("seal_awarded", false))
	return false


func unlock_level(level_id: String) -> void:
	var unlocked: Array = _data.get("unlocked_levels", [])
	if level_id not in unlocked:
		unlocked.append(level_id)
		_data["unlocked_levels"] = unlocked
		save_game()


func is_tutorial_completed() -> bool:
	return bool(_data.get("tutorial_completed", false))


func mark_tutorial_completed() -> void:
	_data["tutorial_completed"] = true
	unlock_level("level_01")
	save_game()


func has_seen_hint(hint_id: String) -> bool:
	if hint_id == "":
		return false
	var hints: Dictionary = _data.get("seen_hints", {})
	return bool(hints.get(hint_id, false))


func mark_hint_seen(hint_id: String) -> void:
	if hint_id == "":
		return
	var hints: Dictionary = _data.get("seen_hints", {})
	hints[hint_id] = true
	_data["seen_hints"] = hints
	save_game()


func mark_level_cleared(level_id: String) -> void:
	var progress: Dictionary = _data.get("campaign_progress", {})
	var entry: Dictionary = progress.get(level_id, {})
	var first_clear := not bool(entry.get("cleared", false))
	entry["cleared"] = true
	entry["best_waves"] = maxi(int(entry.get("best_waves", 0)), 5)
	progress[level_id] = entry
	_data["campaign_progress"] = progress
	if level_id == "level_00_tutorial":
		mark_tutorial_completed()
	if first_clear:
		unlock_levels_after_clear(level_id)
		if level_id in ["level_01", "level_02", "level_03", "level_04", "level_05", "level_06", "level_07"]:
			entry["seal_awarded"] = true
			progress[level_id] = entry
			_data["campaign_progress"] = progress
			add_khan_seal()
			if get_khan_seals() >= 7 and not is_tower_unlocked("tower_rostam_barracks"):
				unlock_tower("tower_rostam_barracks")
				if SceneFlowController:
					SceneFlowController.pending_alert = "Rostam's Barracks unlocked!"
	save_game()


func get_setting(key: String, default_value: Variant = null) -> Variant:
	var settings: Dictionary = _data.get("settings", {})
	return settings.get(key, default_value)


func set_setting(key: String, value: Variant) -> void:
	var settings: Dictionary = _data.get("settings", {})
	settings[key] = value
	_data["settings"] = settings
	save_game()


func get_save_data() -> Dictionary:
	return _data


func get_equipment_owned() -> Array[String]:
	var raw: Variant = _data.get("equipment_owned", [])
	var ids: Array[String] = []
	if raw is Array:
		for entry in raw:
			if entry is String:
				ids.append(entry)
	return ids


func set_equipment_owned(ids: Array[String]) -> void:
	_data["equipment_owned"] = ids.duplicate()
	save_game()


func get_equipment_equipped() -> Dictionary:
	var raw: Variant = _data.get("equipment_equipped", {})
	if raw is Dictionary:
		return raw.duplicate()
	return {"weapon": "", "armor": "", "helm": "", "talisman": ""}


func set_equipment_equipped(slots: Dictionary) -> void:
	_data["equipment_equipped"] = slots.duplicate()
	save_game()


func get_hero_skill_selected() -> String:
	var skill := str(_data.get("hero_skill_selected", "rostam_charge"))
	if not ContentCatalog.is_valid_hero_skill_id(skill):
		return "rostam_charge"
	return skill


func set_hero_skill_selected(skill_id: String) -> void:
	if not ContentCatalog.is_valid_hero_skill_id(skill_id):
		return
	if not is_hero_skill_unlocked(skill_id):
		return
	_data["hero_skill_selected"] = skill_id
	save_game()


func is_hero_skill_unlocked(skill_id: String) -> bool:
	for entry in ContentCatalog.get_hero_skill_catalog():
		if str(entry.get("skill_id", "")) != skill_id:
			continue
		var unlock_level := str(entry.get("unlock_level_id", ""))
		if unlock_level == "":
			return true
		return is_level_cleared(unlock_level)
	return false


func get_unlocked_hero_skill_ids() -> Array[String]:
	var ids: Array[String] = []
	for entry in ContentCatalog.get_hero_skill_catalog():
		var skill_id := str(entry.get("skill_id", ""))
		if is_hero_skill_unlocked(skill_id):
			ids.append(skill_id)
	return ids


func get_daily_missions_state() -> Dictionary:
	var state: Variant = _data.get("daily_missions", {})
	return state if state is Dictionary else {}


func set_daily_missions_state(state: Dictionary) -> void:
	_data["daily_missions"] = state.duplicate(true)
	save_game()


func get_mission_lifetime(key: String) -> int:
	var stats: Dictionary = _data.get("mission_lifetime", {})
	return int(stats.get(key, 0))


func add_mission_lifetime(key: String, delta: int) -> void:
	if key == "" or delta == 0:
		return
	var stats: Dictionary = _data.get("mission_lifetime", {})
	stats[key] = get_mission_lifetime(key) + delta
	_data["mission_lifetime"] = stats
	save_game()


func get_royal_bounty_tickets() -> int:
	return int(_data.get("royal_bounty_tickets", 0))


func add_royal_bounty_tickets(amount: int) -> void:
	if amount <= 0:
		return
	_data["royal_bounty_tickets"] = get_royal_bounty_tickets() + amount
	save_game()


func consume_royal_bounty_ticket() -> bool:
	if get_royal_bounty_tickets() <= 0:
		return false
	_data["royal_bounty_tickets"] = get_royal_bounty_tickets() - 1
	save_game()
	return true
