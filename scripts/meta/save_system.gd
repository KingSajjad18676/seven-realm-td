extends Node

const SAVE_PATH := "user://shahnamehtd_save.json"
const SAVE_VERSION := 4

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
	return {
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
		"relics_owned": [],
		"cosmetic_entitlements": [],
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


func get_endless_best() -> int:
	return int(_data.get("endless_best", 0))


func set_endless_best(wave: int) -> void:
	if wave > get_endless_best():
		_data["endless_best"] = wave
		save_game()


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
	save_game()


func get_setting(key: String, default_value: Variant = null) -> Variant:
	var settings: Dictionary = _data.get("settings", {})
	return settings.get(key, default_value)


func set_setting(key: String, value: Variant) -> void:
	var settings: Dictionary = _data.get("settings", {})
	settings[key] = value
	_data["settings"] = settings
	save_game()
