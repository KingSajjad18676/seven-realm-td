class_name BattleStateController
extends Node

var context: BattleContext = null
var current_state: GameEnums.BattleState = GameEnums.BattleState.PRE_BATTLE
var speed_multiplier: float = 1.0
var _active_enemies: int = 0
var all_waves_spawned: bool = false


func initialize(ctx: BattleContext) -> void:
	context = ctx
	_set_state(GameEnums.BattleState.PRE_BATTLE)


func start_battle() -> void:
	if current_state != GameEnums.BattleState.PRE_BATTLE:
		return
	_set_state(GameEnums.BattleState.WAVE_ACTIVE)
	if context.wave_manager:
		context.wave_manager.start_waves()
	CombatEvents.battle_started.emit(context.level_data.level_id if context.level_data else "")
	AnalyticsService.battle_started(context.level_data.level_id if context.level_data else "")


func pause_battle() -> void:
	if current_state == GameEnums.BattleState.WAVE_ACTIVE:
		_set_state(GameEnums.BattleState.PAUSED)


func resume_battle() -> void:
	if current_state == GameEnums.BattleState.PAUSED:
		_set_state(GameEnums.BattleState.WAVE_ACTIVE)


func set_speed_multiplier(mult: float) -> void:
	speed_multiplier = clampf(mult, 1.0, 2.0)
	Engine.time_scale = speed_multiplier if current_state == GameEnums.BattleState.WAVE_ACTIVE else Engine.time_scale


func register_enemy_spawned() -> void:
	_active_enemies += 1


func register_enemy_removed() -> void:
	_active_enemies = maxi(0, _active_enemies - 1)
	_check_victory()


func notify_all_waves_spawned() -> void:
	all_waves_spawned = true
	_check_victory()


func trigger_victory(reason: String = "waves_cleared") -> void:
	if current_state == GameEnums.BattleState.VICTORY:
		return
	_set_state(GameEnums.BattleState.VICTORY)
	Engine.time_scale = 0.0
	if context.bridge:
		context.bridge.results_requested.emit(true, reason)
	var level_id := context.level_data.level_id if context.level_data else ""
	CombatEvents.battle_completed.emit(true, level_id)
	AnalyticsService.battle_completed(true, level_id)
	var launch := context.launch_data if context else null
	if SaveSystem and context.level_data and launch and launch.is_campaign_mode():
		var lid := context.level_data.level_id
		SaveSystem.mark_level_cleared(lid)
	if launch and launch.is_endless_mode and context and context.wave_manager and SaveSystem:
		SaveSystem.set_endless_best(context.wave_manager.get_endless_wave_count())
	if launch and launch.is_hunt_mode and SaveSystem and context and context.hunt:
		SaveSystem.record_hunt_binding(context.hunt.binding_shards)
	if launch and launch.is_daily_tale and DailyTaleService:
		DailyTaleService.mark_daily_completed()
	if SaveSystem and context.economy and launch and (
		launch.is_campaign_mode() or launch.is_hunt_mode or launch.is_daily_tale
	):
		SaveSystem.commit_battle_materials(context.economy.forge_materials_earned)
	_emit_run_summary(true, reason)


func trigger_defeat(reason: String = "gate_breached") -> void:
	if current_state == GameEnums.BattleState.DEFEAT:
		return
	_set_state(GameEnums.BattleState.DEFEAT)
	Engine.time_scale = 0.0
	if context.bridge:
		context.bridge.results_requested.emit(false, reason)
	var level_id := context.level_data.level_id if context.level_data else ""
	CombatEvents.battle_completed.emit(false, level_id)
	AnalyticsService.battle_completed(false, level_id)
	_emit_run_summary(false, reason)


func _check_victory() -> void:
	if current_state != GameEnums.BattleState.WAVE_ACTIVE:
		return
	if context and context.runtime_modifiers.get("tutorial_block_victory", false):
		return
	if all_waves_spawned and _active_enemies <= 0:
		trigger_victory()


func _emit_run_summary(victory: bool, reason: String) -> void:
	if context == null or context.bridge == null:
		return
	var summary := {
		"victory": victory,
		"reason": reason,
		"fate_card": context.selected_fate_card.card_id if context.selected_fate_card else "",
		"morale": context.morale.current if context.morale else 0,
		"objective_done": context.objectives.completed if context.objectives else false,
		"objective_failed": context.objectives.failed if context.objectives else false,
	}
	context.run_summary = summary
	context.bridge.run_summary_ready.emit(summary)


func _set_state(state: GameEnums.BattleState) -> void:
	current_state = state
	match state:
		GameEnums.BattleState.PRE_BATTLE, GameEnums.BattleState.WAVE_ACTIVE:
			Engine.time_scale = speed_multiplier
		GameEnums.BattleState.PAUSED, GameEnums.BattleState.VICTORY, GameEnums.BattleState.DEFEAT:
			Engine.time_scale = 0.0
	if context and context.bridge:
		context.bridge.battle_state_changed.emit(state)
