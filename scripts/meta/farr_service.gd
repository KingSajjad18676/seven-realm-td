extends Node

signal farr_changed(balance: int, lifetime: int)

const FIRST_CLEAR_REWARD := 25
const VICTORY_REWARD := 5
const DAILY_MISSION_REWARD := 10


func get_balance() -> int:
	return SaveSystem.get_farr_balance() if SaveSystem else 0


func get_lifetime() -> int:
	return SaveSystem.get_farr_lifetime() if SaveSystem else 0


func earn(amount: int, source: String) -> void:
	if amount <= 0 or SaveSystem == null:
		return
	SaveSystem.add_farr(amount)
	AnalyticsService.farr_earned(amount, source)
	farr_changed.emit(get_balance(), get_lifetime())


func spend(amount: int) -> bool:
	if amount <= 0 or SaveSystem == null:
		return false
	if get_balance() < amount:
		return false
	SaveSystem.spend_farr(amount)
	farr_changed.emit(get_balance(), get_lifetime())
	return true


func on_first_labour_clear(level_id: String) -> void:
	if level_id in ["level_01", "level_02", "level_03", "level_04", "level_05", "level_06", "level_07"]:
		earn(FIRST_CLEAR_REWARD, "first_clear_%s" % level_id)


func on_campaign_victory(level_id: String) -> void:
	earn(VICTORY_REWARD, "victory_%s" % level_id)


func on_daily_mission_claimed() -> void:
	earn(DAILY_MISSION_REWARD, "daily_mission")
