extends Node

## Seeded daily challenge — fair modifiers, no FOMO grind.


func get_today_seed() -> int:
	var dt := Time.get_datetime_dict_from_system()
	return dt.year * 10000 + dt.month * 100 + dt.day


func get_daily_level_id() -> String:
	return "level_01"


func is_daily_completed() -> bool:
	if not SaveSystem:
		return false
	var state: Dictionary = SaveSystem.get_daily_tale_state()
	var seed := get_today_seed()
	return int(state.get("last_seed", -1)) == seed and bool(state.get("completed", false))


func mark_daily_completed() -> void:
	if not SaveSystem:
		return
	SaveSystem.set_daily_tale_state({
		"last_seed": get_today_seed(),
		"completed": true,
	})


func launch_daily_battle() -> void:
	var launch := BattleLaunchData.new()
	launch.level_id = get_daily_level_id()
	launch.is_daily_tale = true
	launch.auto_start = false
	SceneFlowController.go_to_battle(launch)
