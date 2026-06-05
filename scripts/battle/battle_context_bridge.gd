class_name BattleContextBridge
extends Node

signal gold_changed(amount: int)
signal sacred_fire_changed(amount: int)
signal lives_changed(current: int, max_lives: int)
signal wave_changed(current: int, total: int)
signal battle_state_changed(state: GameEnums.BattleState)
signal alert_message(message: String, priority: int)
signal region_light_changed(region_id: String, light: int, state: GameEnums.RegionLightState)
signal region_selected(region_id: String, light: int)
signal tower_hijack_warning(spot_id: String)
signal pardeh_break_requested
signal results_requested(victory: bool, reason: String)
signal morale_changed(current: int, max_morale: int)
signal run_summary_ready(summary: Dictionary)
signal enemy_died(enemy_id: String)
signal intermission_started(preview_text: String, max_bonus_gold: int)
signal intermission_ended
signal vow_offer_requested(vow_data: ObjectiveData, block_start: int, block_end: int)
signal vow_status(text: String, state: int)

var context: BattleContext = null
