class_name WaveManager
extends Node

const INTERMISSION_DURATION := 2.0
const EARLY_CALL_GOLD_PER_SECOND := 5.0

var context: BattleContext = null
var current_wave_index: int = -1
var total_waves: int = 0
var is_spawning: bool = false
var _endless_mode: bool = false
var _endless_wave: int = 0
var _horde_mode: bool = false
var _horde_wave: int = 0
var _early_call_requested: bool = false


func initialize(ctx: BattleContext) -> void:
	context = ctx
	if ctx.level_data:
		total_waves = ctx.level_data.waves.size()


func get_endless_wave_count() -> int:
	return _endless_wave


func get_horde_wave_count() -> int:
	return _horde_wave


func enable_endless_mode() -> void:
	_endless_mode = true
	_endless_wave = 0
	total_waves = 999


func enable_horde_mode() -> void:
	_horde_mode = true
	_horde_wave = 0
	total_waves = ContentCatalog.HORDE_WAVES_TO_CLEAR


func start_waves() -> void:
	if is_spawning:
		return
	_spawn_next_wave()


func request_early_call() -> void:
	if context and context.tutorial_hold_waves:
		return
	_early_call_requested = true


func _spawn_next_wave() -> void:
	if context == null or context.level_data == null:
		return
	if _endless_mode:
		_spawn_endless_wave()
		return
	if _horde_mode:
		_spawn_horde_wave()
		return
	current_wave_index += 1
	if current_wave_index >= context.level_data.waves.size():
		if context.state_controller:
			context.state_controller.notify_all_waves_spawned()
		return
	await _maybe_offer_vow()
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
	await _wait_intermission(_build_wave_preview_text(current_wave_index + 1))
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
	await _maybe_offer_vow()
	if context.bridge:
		context.bridge.wave_changed.emit(_endless_wave, 999)
	var wave := _build_endless_wave_data(_endless_wave)
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
	var next_preview := _format_wave_preview(_build_endless_wave_data(_endless_wave + 1), _endless_wave + 1)
	await _wait_intermission(next_preview)
	if context.state_controller and context.state_controller.current_state == GameEnums.BattleState.WAVE_ACTIVE:
		_spawn_endless_wave()


func _spawn_horde_wave() -> void:
	_horde_wave += 1
	current_wave_index = _horde_wave - 1
	if context.bridge:
		context.bridge.wave_changed.emit(_horde_wave, total_waves)
	var level_id := context.level_data.level_id if context.level_data else "level_01"
	var wave := _build_horde_wave_data(_horde_wave, level_id)
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
	if _horde_wave >= ContentCatalog.HORDE_WAVES_TO_CLEAR:
		if context.state_controller:
			context.state_controller.notify_all_waves_spawned()
		return
	var next_preview := _format_wave_preview(
		_build_horde_wave_data(_horde_wave + 1, level_id),
		_horde_wave + 1
	)
	await _wait_intermission(next_preview)
	if context.state_controller and context.state_controller.current_state == GameEnums.BattleState.WAVE_ACTIVE:
		_spawn_horde_wave()


func _build_horde_wave_data(wave_num: int, level_id: String) -> WaveData:
	var wave := WaveData.new()
	wave.wave_id = "horde_%s_%d" % [level_id, wave_num]
	wave.pre_wave_delay = 1.8
	var diff := ContentCatalog.khan_difficulty(level_id)
	var roster := ContentCatalog.get_horde_roster(level_id)
	var count := int((8 + wave_num * 2) * float(diff.count_mult))
	var groups: Array[Dictionary] = []
	groups.append({"enemy_id": roster[0], "count": count})
	if wave_num % 2 == 0 and roster.size() > 1:
		groups.append({"enemy_id": roster[1], "count": int(1 + wave_num / 2)})
	if wave_num % 3 == 0 and roster.size() > 2:
		groups.append({"enemy_id": roster[2], "count": int(1 + wave_num / 4)})
	if wave_num % 5 == 0 and context and context.level_data:
		var boss_id := context.level_data.boss_enemy_id
		if boss_id != "":
			wave.is_boss_wave = true
			groups.append({"enemy_id": boss_id, "count": 1})
	wave.spawn_groups = groups
	wave.spawn_interval = maxf(0.05, 0.25 - float(ContentCatalog.khan_index(level_id)) * 0.02)
	return wave


func _build_endless_wave_data(wave_num: int) -> WaveData:
	var wave := WaveData.new()
	wave.wave_id = "endless_%d" % wave_num
	wave.pre_wave_delay = 2.0
	var count := int(6 + wave_num * 1.5)
	var groups: Array[Dictionary] = []
	groups.append({"enemy_id": "enemy_jackal", "count": count})
	if wave_num % 3 == 0:
		groups.append({"enemy_id": "enemy_boar", "count": int(1 + wave_num / 3)})
	if wave_num % 5 == 0:
		groups.append({"enemy_id": "enemy_corruptor", "count": 2})
	wave.spawn_groups = groups
	return wave


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


func _wait_intermission(preview_text: String) -> void:
	if context == null:
		return
	if context.tutorial_hold_waves:
		return
	if preview_text.is_empty():
		return
	_early_call_requested = false
	var max_bonus := int(round(INTERMISSION_DURATION * EARLY_CALL_GOLD_PER_SECOND))
	if context.bridge:
		context.bridge.intermission_started.emit(preview_text, max_bonus)
	var timer := get_tree().create_timer(INTERMISSION_DURATION / _time_scale())
	while timer.time_left > 0.0:
		if _early_call_requested:
			var bonus := int(round(timer.time_left * EARLY_CALL_GOLD_PER_SECOND))
			bonus = maxi(0, bonus)
			if bonus > 0 and context.economy:
				context.economy.add_gold(bonus)
			if context.bridge:
				context.bridge.alert_message.emit("Early call! +%d gold" % bonus, 60)
			break
		await get_tree().process_frame
	if context.bridge:
		context.bridge.intermission_ended.emit()


func _build_wave_preview_text(next_wave_index: int) -> String:
	if context == null or context.level_data == null:
		return ""
	if next_wave_index < 0 or next_wave_index >= context.level_data.waves.size():
		return ""
	var wave: WaveData = context.level_data.waves[next_wave_index]
	return _format_wave_preview(wave, next_wave_index + 1)


func _format_wave_preview(wave: WaveData, wave_number: int) -> String:
	if wave == null:
		return ""
	var parts: PackedStringArray = PackedStringArray()
	for group in wave.spawn_groups:
		var enemy_id := str(group.get("enemy_id", ""))
		var count := int(group.get("count", 1))
		var catalog := ContentRegistry.get_enemy(enemy_id)
		var display := catalog.display_name if catalog else enemy_id
		parts.append("%dx %s" % [count, display])
	var enemy_line := ", ".join(parts)
	if wave.display_name != "":
		return "Wave %d — %s: %s" % [wave_number, wave.display_name, enemy_line]
	return "Next: %s" % enemy_line


func _time_scale() -> float:
	if context and context.state_controller:
		return maxf(context.state_controller.speed_multiplier, 0.01)
	return 1.0


func _block_size() -> int:
	if context == null or context.level_data == null:
		return 10
	var size := context.level_data.block_size
	return size if size > 0 else 10


func _maybe_offer_vow() -> void:
	if context == null or context.level_data == null:
		return
	if context.level_data.is_tutorial:
		return
	if context.objectives == null or context.bridge == null:
		return
	var block_size := _block_size()
	if current_wave_index % block_size != 0:
		return
	var block_index := current_wave_index / block_size
	var block_start := block_index * block_size + 1
	var block_end := block_index * block_size + block_size
	if not _endless_mode and not _horde_mode:
		block_end = mini(block_end, total_waves)
	var vow := context.objectives.pick_next_vow(block_index)
	if vow == null:
		return
	context.bridge.vow_offer_requested.emit(vow, block_start, block_end)
	while context.state_controller and context.state_controller.current_state == GameEnums.BattleState.PAUSED:
		await get_tree().process_frame
