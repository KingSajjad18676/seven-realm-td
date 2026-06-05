class_name BattleLaunchData
extends RefCounted

var level_id: String = "level_01"
var auto_start: bool = false
var is_endless_mode: bool = false
var is_hunt_mode: bool = false
var is_roguelite_run: bool = false
var is_daily_tale: bool = false
var is_horde_mode: bool = false
var is_campaign_run: bool = false
var campaign_node_id: String = ""
var run_tower_ids: Array[String] = []
var run_tower_upgrades: Dictionary = {}
var skirmish_waves: int = 0
var active_relic_ids: Array[String] = []
var roguelite_node_index: int = 0


func duplicate_launch() -> BattleLaunchData:
	var copy := BattleLaunchData.new()
	copy.level_id = level_id
	copy.auto_start = auto_start
	copy.is_endless_mode = is_endless_mode
	copy.is_hunt_mode = is_hunt_mode
	copy.is_roguelite_run = is_roguelite_run
	copy.is_daily_tale = is_daily_tale
	copy.is_horde_mode = is_horde_mode
	copy.is_campaign_run = is_campaign_run
	copy.campaign_node_id = campaign_node_id
	copy.run_tower_ids = run_tower_ids.duplicate()
	copy.run_tower_upgrades = run_tower_upgrades.duplicate()
	copy.skirmish_waves = skirmish_waves
	copy.active_relic_ids = active_relic_ids.duplicate()
	copy.roguelite_node_index = roguelite_node_index
	return copy


func is_campaign_mode() -> bool:
	return (
		not is_endless_mode
		and not is_hunt_mode
		and not is_roguelite_run
		and not is_campaign_run
		and not is_daily_tale
		and not is_horde_mode
	)


func is_scavenge_mode() -> bool:
	return is_campaign_run or is_campaign_mode() or is_horde_mode or is_hunt_mode or is_daily_tale
