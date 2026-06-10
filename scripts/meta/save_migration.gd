class_name SaveMigration
extends RefCounted


static func default_accessibility() -> Dictionary:
	return {
		"ui_scale": 1.0,
		"high_contrast": false,
		"reduced_shake": false,
		"reduced_flashes": false,
		"subtitles": true,
		"left_handed": false,
		"vibration": true,
	}


static func migrate(data: Dictionary, target_version: int = 9) -> Dictionary:
	var result := data.duplicate(true)
	var version := int(result.get("save_version", 1))
	if version < 2 and target_version >= 2:
		if not result.has("star_iron"):
			result["star_iron"] = {}
		if not result.has("tower_forge"):
			result["tower_forge"] = {}
		version = 2
	if version < 3 and target_version >= 3:
		if not result.has("replay_stats"):
			result["replay_stats"] = {}
		if not result.has("accessibility"):
			result["accessibility"] = default_accessibility()
		if not result.has("daily_tale"):
			result["daily_tale"] = {}
		if not result.has("endless_best"):
			result["endless_best"] = 0
		result["save_version"] = target_version
		version = target_version
	if version < 4 and target_version >= 4:
		if not result.has("hunt_best_binding"):
			result["hunt_best_binding"] = 0
		if not result.has("damavand_forge_notified"):
			result["damavand_forge_notified"] = false
		if not result.has("roguelite_run"):
			result["roguelite_run"] = {}
		result["save_version"] = 4
		version = 4
	if version < 5 and target_version >= 5:
		if not result.has("forge_tokens"):
			result["forge_tokens"] = 0
		if not result.has("spells_owned"):
			result["spells_owned"] = []
		if not result.has("horde_progress"):
			result["horde_progress"] = {}
		if not result.has("unlocked_towers"):
			result["unlocked_towers"] = []
		if not result.has("paid_entitlements"):
			result["paid_entitlements"] = []
		result["save_version"] = 5
		version = 5
	if version < 6 and target_version >= 6:
		if not result.has("campaign_run"):
			result["campaign_run"] = {}
		var legacy: Variant = result.get("roguelite_run", {})
		if legacy is Dictionary and not legacy.is_empty() and result.get("campaign_run", {}).is_empty():
			result["campaign_run"] = _migrate_legacy_roguelite_run(legacy)
			result["roguelite_run"] = {}
		var unlocked: Variant = result.get("unlocked_towers", [])
		if unlocked is Array:
			for starter_id in SaveSystem.STARTER_TOWER_IDS:
				if starter_id not in unlocked:
					unlocked.append(starter_id)
			result["unlocked_towers"] = unlocked
		result["save_version"] = 6
		version = 6
	if version < 7 and target_version >= 7:
		_migrate_run_relic_slots(result.get("campaign_run", {}))
		_migrate_run_relic_slots(result.get("roguelite_run", {}))
		_migrate_run_companion(result.get("campaign_run", {}))
		result["save_version"] = 7
		version = 7
	if version < 8 and target_version >= 8:
		if not result.has("gauntlet_best"):
			result["gauntlet_best"] = {
				"total_ms": 0,
				"splits_ms": [],
				"trace": [],
			}
		result["save_version"] = 8
		version = 8
	if version < 9 and target_version >= 9:
		if not result.has("equipment_owned"):
			result["equipment_owned"] = []
		if not result.has("equipment_equipped"):
			result["equipment_equipped"] = {
				"weapon": "",
				"armor": "",
				"helm": "",
				"talisman": "",
			}
		if not result.has("daily_missions"):
			result["daily_missions"] = {}
		if not result.has("mission_lifetime"):
			result["mission_lifetime"] = {
				"total_div_kills": 0,
				"total_cleanses": 0,
				"total_forge_tokens_spent": 0,
			}
		if not result.has("royal_bounty_tickets"):
			result["royal_bounty_tickets"] = 0
		result["save_version"] = 9
		version = 9
	return result


static func _migrate_run_companion(run_data: Variant) -> void:
	if not run_data is Dictionary:
		return
	var run: Dictionary = run_data
	if not run.has("active_companion_id"):
		run["active_companion_id"] = ""


static func _migrate_run_relic_slots(run_data: Variant) -> void:
	if not run_data is Dictionary:
		return
	var run: Dictionary = run_data
	if run.has("tower_relic_slots"):
		return
	var saved_relics: Variant = run.get("relic_ids", [])
	if not saved_relics is Array:
		run["tower_relic_slots"] = {}
		run["active_relic_ids"] = []
		run.erase("relic_ids")
		return
	var migrated := RelicSlotHelper.migrate_relic_ids(saved_relics)
	run["tower_relic_slots"] = migrated.get("tower_relic_slots", {}).duplicate()
	run["active_relic_ids"] = migrated.get("active_relic_ids", [])
	run.erase("relic_ids")


static func _migrate_legacy_roguelite_run(legacy: Dictionary) -> Dictionary:
	var nodes: Array = []
	var saved_nodes: Variant = legacy.get("nodes", [])
	if saved_nodes is Array:
		for i in saved_nodes.size():
			var n: Variant = saved_nodes[i]
			if n is Dictionary:
				var node: Dictionary = (n as Dictionary).duplicate(true)
				node["id"] = "legacy_%d" % i
				node["cleared"] = i < int(legacy.get("current_index", 0))
				if not node.has("edges"):
					node["edges"] = []
				nodes.append(node)
	var current_index := int(legacy.get("current_index", 0))
	var current_id := "legacy_%d" % clampi(current_index, 0, maxi(0, nodes.size() - 1))
	return {
		"seed": int(legacy.get("seed", 0)),
		"nodes": nodes,
		"current_node_id": current_id,
		"visited_node_ids": [],
		"run_tower_ids": [],
		"run_tower_upgrades": {},
		"tower_relic_slots": {},
		"active_relic_ids": [],
		"active_companion_id": "",
		"act_index": 0,
	}
