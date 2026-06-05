class_name SaveMigration
extends RefCounted


static func default_accessibility() -> Dictionary:
	return {
		"ui_scale": 1.0,
		"high_contrast": false,
		"reduced_shake": false,
		"subtitles": true,
	}


static func migrate(data: Dictionary, target_version: int = 5) -> Dictionary:
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
	return result
