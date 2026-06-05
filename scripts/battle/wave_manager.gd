class_name WaveManager
extends Node

var context: BattleContext = null
var current_wave_index: int = -1
var total_waves: int = 0
var is_spawning: bool = false
var _endless_mode: bool = false
var _endless_wave: int = 0


func initialize(ctx: BattleContext) -> void:
	context = ctx
	if ctx.level_data:
		total_waves = ctx.level_data.waves.size()


func get_endless_wave_count() -> int:
	return _endless_wave


func enable_endless_mode() -> void:
	_endless_mode = true
	_endless_wave = 0
	total_waves = 999


func start_waves() -> void:
	if is_spawning:
		return
	_spawn_next_wave()


func _spawn_next_wave() -> void:
	if context == null or context.level_data == null:
		return
	if _endless_mode:
		_spawn_endless_wave()
		return
	current_wave_index += 1
	if current_wave_index >= context.level_data.waves.size():
		if context.state_controller:
			context.state_controller.notify_all_waves_spawned()
		return
	var wave: WaveData = context.level_data.waves[current_wave_index]
	if context.bridge:
		context.bridge.wave_changed.emit(current_wave_index + 1, total_waves)
	CombatEvents.wave_started.emit(current_wave_index)
	if context and context.run_modifiers:
		context.run_modifiers.on_wave_started()
	is_spawning = true
	await get_tree().create_timer(wave.pre_wave_delay / _time_scale()).timeout
	if context.enemy_spawner:
		await context.enemy_spawner.spawn_wave(wave)
	is_spawning = false
	await _wait_for_wave_clear()
	CombatEvents.wave_completed.emit(current_wave_index)
	if context:
		if context.morale:
			context.morale.on_wave_cleared()
		if context.objectives:
			context.objectives.on_wave_cleared()
	if current_wave_index == 3 and context.bridge:
		context.bridge.pardeh_break_requested.emit()
		while context.state_controller and context.state_controller.current_state == GameEnums.BattleState.PAUSED:
			await get_tree().process_frame
	await get_tree().create_timer(2.0 / _time_scale()).timeout
	if context.tutorial_hold_waves:
		return
	if context.state_controller and context.state_controller.current_state == GameEnums.BattleState.WAVE_ACTIVE:
		if current_wave_index < context.level_data.waves.size() - 1:
			_spawn_next_wave()
		else:
			context.state_controller.notify_all_waves_spawned()


func continue_after_tutorial_hold() -> void:
	if context == null or context.level_data == null:
		return
	if current_wave_index >= context.level_data.waves.size() - 1:
		if context.state_controller:
			context.state_controller.notify_all_waves_spawned()
			context.state_controller._check_victory()
		return
	_spawn_next_wave()


func _spawn_endless_wave() -> void:
	_endless_wave += 1
	current_wave_index = _endless_wave - 1
	if context.bridge:
		context.bridge.wave_changed.emit(_endless_wave, 999)
	var wave := WaveData.new()
	wave.wave_id = "endless_%d" % _endless_wave
	wave.pre_wave_delay = 2.0
	var count := int(6 + _endless_wave * 1.5)
	var groups: Array[Dictionary] = []
	groups.append({"enemy_id": "enemy_jackal", "count": count})
	if _endless_wave % 3 == 0:
		groups.append({"enemy_id": "enemy_boar", "count": int(1 + _endless_wave / 3)})
	if _endless_wave % 5 == 0:
		groups.append({"enemy_id": "enemy_corruptor", "count": 2})
	wave.spawn_groups = groups
	if context and context.run_modifiers:
		context.run_modifiers.on_wave_started()
	is_spawning = true
	await get_tree().create_timer(wave.pre_wave_delay / _time_scale()).timeout
	if context.enemy_spawner:
		await context.enemy_spawner.spawn_wave(wave)
	is_spawning = false
	await _wait_for_wave_clear()
	if context and context.morale:
		context.morale.on_wave_cleared()
	await get_tree().create_timer(2.0 / _time_scale()).timeout
	if context.state_controller and context.state_controller.current_state == GameEnums.BattleState.WAVE_ACTIVE:
		_spawn_endless_wave()


func _wait_for_wave_clear() -> void:
	if context == null or context.state_controller == null:
		return
	while context.state_controller.get_active_enemy_count() > 0:
		if context.state_controller.current_state in [
			GameEnums.BattleState.DEFEAT,
			GameEnums.BattleState.VICTORY,
		]:
			return
		await get_tree().process_frame


func _time_scale() -> float:
	if context and context.state_controller:
		return maxf(context.state_controller.speed_multiplier, 0.01)
	return 1.0
