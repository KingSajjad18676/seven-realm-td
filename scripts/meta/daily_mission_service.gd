extends Node

## Daily mission rotation — 3 missions per 24h, Royal Bounty bonus slots.


func _ready() -> void:
	refresh_if_needed()


func get_today_day() -> int:
	var dt := Time.get_datetime_dict_from_system()
	return dt.year * 10000 + dt.month * 100 + dt.day


func refresh_if_needed() -> void:
	if not SaveSystem:
		return
	var state := SaveSystem.get_daily_missions_state()
	var today := get_today_day()
	if int(state.get("last_refresh_day", -1)) == today:
		return
	_roll_new_day(today)


func _roll_new_day(today: int) -> void:
	var defs: Array[DailyMissionDefinition] = []
	if ContentRegistry:
		defs = ContentRegistry.get_all_daily_mission_defs()
	var pool: Array[DailyMissionDefinition] = defs.duplicate()
	pool.shuffle()
	var active: Array = []
	var count := mini(3, pool.size())
	for i in count:
		var def := pool[i] as DailyMissionDefinition
		active.append({
			"mission_id": def.mission_id,
			"progress": 0,
			"claimed": false,
		})
	SaveSystem.set_daily_missions_state({
		"last_refresh_day": today,
		"active": active,
		"bonus_slots": [],
		"royal_bounty_used_today": false,
	})


func get_active_missions() -> Array[Dictionary]:
	refresh_if_needed()
	var state := SaveSystem.get_daily_missions_state() if SaveSystem else {}
	var active: Variant = state.get("active", [])
	var bonus: Variant = state.get("bonus_slots", [])
	var out: Array[Dictionary] = []
	if active is Array:
		for entry in active:
			if entry is Dictionary:
				out.append(_enrich_mission(entry))
	if bonus is Array:
		for entry in bonus:
			if entry is Dictionary:
				out.append(_enrich_mission(entry))
	return out


func _enrich_mission(entry: Dictionary) -> Dictionary:
	var copy := entry.duplicate()
	var def := ContentRegistry.get_daily_mission_def(str(entry.get("mission_id", ""))) if ContentRegistry else null
	if def:
		copy["description"] = def.description
		copy["goal_target"] = def.goal_target
		copy["tracking_key"] = def.tracking_key
	return copy


func update_mission_progress(mission_id: String, progress: int) -> void:
	if not SaveSystem or mission_id == "":
		return
	var state := SaveSystem.get_daily_missions_state()
	var changed := false
	for key in ["active", "bonus_slots"]:
		var list: Variant = state.get(key, [])
		if not list is Array:
			continue
		for i in list.size():
			var entry: Variant = list[i]
			if not entry is Dictionary:
				continue
			if str(entry.get("mission_id", "")) != mission_id:
				continue
			var e: Dictionary = entry
			if bool(e.get("claimed", false)):
				continue
			e["progress"] = progress
			list[i] = e
			changed = true
	if changed:
		state["active"] = state.get("active", [])
		SaveSystem.set_daily_missions_state(state)


func is_mission_complete(entry: Dictionary) -> bool:
	var target := int(entry.get("goal_target", 0))
	var progress := int(entry.get("progress", 0))
	return target > 0 and progress >= target


func claim_mission(mission_id: String) -> Dictionary:
	if not SaveSystem or mission_id == "":
		return {}
	var state := SaveSystem.get_daily_missions_state()
	for key in ["active", "bonus_slots"]:
		var list: Variant = state.get(key, [])
		if not list is Array:
			continue
		for i in list.size():
			var entry: Variant = list[i]
			if not entry is Dictionary:
				continue
			var e: Dictionary = entry
			if str(e.get("mission_id", "")) != mission_id:
				continue
			if bool(e.get("claimed", false)):
				return {}
			var enriched := _enrich_mission(e)
			if not is_mission_complete(enriched):
				return {}
			e["claimed"] = true
			list[i] = e
			state[key] = list
			SaveSystem.set_daily_missions_state(state)
			if EquipmentService:
				return EquipmentService.open_daily_loot_chest()
			return {}
	return {}


func add_bonus_missions(count: int) -> bool:
	if not SaveSystem or count <= 0:
		return false
	refresh_if_needed()
	var state := SaveSystem.get_daily_missions_state()
	if bool(state.get("royal_bounty_used_today", false)):
		return false
	var defs: Array[DailyMissionDefinition] = ContentRegistry.get_all_daily_mission_defs() if ContentRegistry else []
	var active_ids: Dictionary = {}
	for entry in get_active_missions():
		active_ids[str(entry.get("mission_id", ""))] = true
	var pool: Array[DailyMissionDefinition] = []
	for def in defs:
		if not active_ids.has(def.mission_id):
			pool.append(def)
	pool.shuffle()
	var bonus: Array = state.get("bonus_slots", [])
	for i in mini(count, pool.size()):
		bonus.append({
			"mission_id": pool[i].mission_id,
			"progress": 0,
			"claimed": false,
		})
	state["bonus_slots"] = bonus
	state["royal_bounty_used_today"] = true
	SaveSystem.set_daily_missions_state(state)
	return true


func sync_lifetime_mission(mission_id: String, lifetime_value: int) -> void:
	var def := ContentRegistry.get_daily_mission_def(mission_id) if ContentRegistry else null
	if def == null:
		return
	update_mission_progress(mission_id, lifetime_value)
