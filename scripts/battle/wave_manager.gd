class_name WaveManager
extends Node

const INTERMISSION_DURATION := 2.0
const GAUNTLET_INTERMISSION_DURATION := 0.5
const EARLY_CALL_GOLD_PER_SECOND := 5.0
const GAUNTLET_EARLY_CALL_OVERWHELM_PER_SEC := 0.15
const GAUNTLET_EARLY_CALL_OVERWHELM_CAP := 2.0
const GAUNTLET_PRE_BATTLE_RUSH_COUNT_MULT := 1.25
const GAUNTLET_PRE_BATTLE_RUSH_SPEED_MULT := 1.10

var context: BattleContext = null
var current_wave_index: int = -1
var total_waves: int = 0
var is_spawning: bool = false
var _endless_mode: bool = false
var _endless_wave: int = 0
var _horde_mode: bool = false
var _horde_wave: int = 0
var _throne_mode: bool = false
var _throne_wave: int = 0
var _skirmish_max_waves: int = 0
var _early_call_requested: bool = false
var _aborted: bool = false


func _exit_tree() -> void:
	_aborted = true


func _tree_available() -> bool:
	return not _aborted and is_inside_tree()


func _await_process_frame() -> void:
	if not _tree_available():
		return
	await get_tree().process_frame


func initialize(ctx: BattleContext) -> void:
	context = ctx
	if ctx.level_data:
		total_waves = ctx.level_data.waves.size()


func get_endless_wave_count() -> int:
	return _endless_wave


func get_horde_wave_count() -> int:
	return _horde_wave


func get_throne_wave_count() -> int:
	return _throne_wave


func enable_endless_mode() -> void:
	_endless_mode = true
	_endless_wave = 0
	total_waves = 999


func enable_horde_mode() -> void:
	_horde_mode = true
	_horde_wave = 0
	_skirmish_max_waves = 0
	total_waves = ContentCatalog.HORDE_WAVES_TO_CLEAR


func enable_skirmish_mode(wave_count: int) -> void:
	_horde_mode = true
	_horde_wave = 0
	_skirmish_max_waves = maxi(1, wave_count)
	total_waves = _skirmish_max_waves


func enable_throne_defense_mode() -> void:
	_throne_mode = true
	_throne_wave = 0
	_skirmish_max_waves = 0
	total_waves = ContentCatalog.HORDE_WAVES_TO_CLEAR


func start_waves() -> void:
	if is_spawning:
		return
	_spawn_next_wave()


func request_early_call() -> void:
	if context and context.tutorial_hold_waves:
		return
	_early_call_requested = true


func request_pre_battle_rush() -> void:
	if context == null or context.state_controller == null:
		return
	if context.state_controller.current_state != GameEnums.BattleState.PRE_BATTLE:
		return
	if not _is_gauntlet_mode():
		return
	context.runtime_modifiers["gauntlet_pre_battle_rush"] = true
	if context.state_controller:
		context.state_controller.start_battle()


func _spawn_next_wave() -> void:
	if context == null or context.level_data == null:
		return
	if _endless_mode:
		_spawn_endless_wave()
		return
	if _horde_mode:
		_spawn_horde_wave()
		return
	if _throne_mode:
		_spawn_throne_wave()
		return
	current_wave_index += 1
	if current_wave_index >= context.level_data.waves.size():
		if context.state_controller:
			context.state_controller.notify_all_waves_spawned()
		return
	var wave: WaveData = context.level_data.waves[current_wave_index]
	wave = _apply_gauntlet_wave_modifiers(wave)
	if context.bridge:
		context.bridge.wave_changed.emit(current_wave_index + 1, total_waves)
	CombatEvents.wave_started.emit(current_wave_index)
	if wave.wave_phase != "":
		CombatEvents.wave_phase_started.emit(current_wave_index, wave.wave_phase)
	if context and context.run_modifiers:
		context.run_modifiers.on_wave_started()
	is_spawning = true
	if not _tree_available():
		return
	await get_tree().create_timer(wave.pre_wave_delay / _time_scale()).timeout
	if not _tree_available():
		is_spawning = false
		return
	if context.enemy_spawner:
		await context.enemy_spawner.spawn_wave(wave)
	if not _tree_available():
		is_spawning = false
		return
	is_spawning = false
	await _wait_for_wave_clear()
	if not _tree_available():
		return
	CombatEvents.wave_completed.emit(current_wave_index)
	if context:
		if context.morale:
			context.morale.on_wave_cleared()
		if context.objectives:
			context.objectives.on_wave_cleared()
	await _maybe_offer_vow()
	if not _tree_available():
		return
	if _should_offer_pardeh() and context.bridge:
		context.bridge.pardeh_break_requested.emit()
		while (
			_tree_available()
			and context.state_controller
			and context.state_controller.current_state == GameEnums.BattleState.PAUSED
		):
			await _await_process_frame()
	if not _tree_available():
		return
	await _wait_intermission(_build_wave_preview_text(current_wave_index + 1))
	if not _tree_available():
		return
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
	var wave := _build_endless_wave_data(_endless_wave)
	if context and context.run_modifiers:
		context.run_modifiers.on_wave_started()
	is_spawning = true
	if not _tree_available():
		return
	await get_tree().create_timer(wave.pre_wave_delay / _time_scale()).timeout
	if not _tree_available():
		is_spawning = false
		return
	if context.enemy_spawner:
		await context.enemy_spawner.spawn_wave(wave)
	if not _tree_available():
		is_spawning = false
		return
	is_spawning = false
	await _wait_for_wave_clear()
	if not _tree_available():
		return
	if context and context.morale:
		context.morale.on_wave_cleared()
	await _maybe_offer_vow()
	if not _tree_available():
		return
	var next_preview := _format_wave_preview(_build_endless_wave_data(_endless_wave + 1), _endless_wave + 1)
	await _wait_intermission(next_preview)
	if not _tree_available():
		return
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
	if not _tree_available():
		return
	await get_tree().create_timer(wave.pre_wave_delay / _time_scale()).timeout
	if not _tree_available():
		is_spawning = false
		return
	if context.enemy_spawner:
		await context.enemy_spawner.spawn_wave(wave)
	if not _tree_available():
		is_spawning = false
		return
	is_spawning = false
	await _wait_for_wave_clear()
	if not _tree_available():
		return
	if context and context.morale:
		context.morale.on_wave_cleared()
	var horde_target := _skirmish_max_waves if _skirmish_max_waves > 0 else ContentCatalog.HORDE_WAVES_TO_CLEAR
	if _horde_wave >= horde_target:
		if context.state_controller:
			context.state_controller.notify_all_waves_spawned()
		return
	var next_preview := _format_wave_preview(
		_build_horde_wave_data(_horde_wave + 1, level_id),
		_horde_wave + 1
	)
	await _wait_intermission(next_preview)
	if not _tree_available():
		return
	if context.state_controller and context.state_controller.current_state == GameEnums.BattleState.WAVE_ACTIVE:
		_spawn_horde_wave()


func _spawn_throne_wave() -> void:
	_throne_wave += 1
	current_wave_index = _throne_wave - 1
	if context.bridge:
		context.bridge.wave_changed.emit(_throne_wave, total_waves)
	var wave := _build_throne_wave_data(_throne_wave)
	if context and context.run_modifiers:
		context.run_modifiers.on_wave_started()
	is_spawning = true
	if not _tree_available():
		return
	await get_tree().create_timer(wave.pre_wave_delay / _time_scale()).timeout
	if not _tree_available():
		is_spawning = false
		return
	if context.enemy_spawner:
		await context.enemy_spawner.spawn_wave(wave)
	if not _tree_available():
		is_spawning = false
		return
	is_spawning = false
	await _wait_for_wave_clear()
	if not _tree_available():
		return
	if context and context.morale:
		context.morale.on_wave_cleared()
	if _throne_wave >= ContentCatalog.HORDE_WAVES_TO_CLEAR:
		if context.state_controller:
			context.state_controller.notify_all_waves_spawned()
		return
	var next_preview := _format_wave_preview(
		_build_throne_wave_data(_throne_wave + 1),
		_throne_wave + 1
	)
	await _wait_intermission(next_preview)
	if not _tree_available():
		return
	if context.state_controller and context.state_controller.current_state == GameEnums.BattleState.WAVE_ACTIVE:
		_spawn_throne_wave()


func _should_offer_pardeh() -> bool:
	if _is_gauntlet_mode():
		return false
	if _endless_mode:
		return false
	var cleared := current_wave_index + 1
	if cleared % 5 != 0:
		return false
	return current_wave_index < total_waves - 1


func _build_horde_wave_data(wave_num: int, level_id: String) -> WaveData:
	return CampaignWaveTemplates.generate_horde_slice(level_id, wave_num)


func _build_throne_wave_data(wave_num: int) -> WaveData:
	return CampaignWaveTemplates.generate_throne_slice(wave_num)


func _build_endless_wave_data(wave_num: int) -> WaveData:
	var level_id := context.level_data.level_id if context and context.level_data else "level_01"
	var wave := CampaignWaveTemplates.generate_horde_slice(level_id, wave_num)
	wave.wave_id = "endless_%d" % wave_num
	if wave_num > ContentCatalog.HORDE_WAVES_TO_CLEAR:
		var extra_blocks := (wave_num - 1) / CampaignWaveTemplates.MACRO_BLOCK_SIZE
		var extra_scale := 1.0 + float(extra_blocks - 1) * 0.08
		if extra_scale > 1.0:
			for group in wave.spawn_groups:
				group["count"] = maxi(1, int(round(float(group.get("count", 1)) * extra_scale)))
	return wave


func _wait_for_wave_clear() -> void:
	if context == null or context.state_controller == null:
		return
	while context.state_controller.get_active_enemy_count() > 0:
		if not _tree_available():
			return
		if context.state_controller.current_state in [
			GameEnums.BattleState.DEFEAT,
			GameEnums.BattleState.VICTORY,
		]:
			return
		await _await_process_frame()


func _wait_intermission(preview_text: String) -> void:
	if context == null or not _tree_available():
		return
	if context.tutorial_hold_waves:
		return
	if preview_text.is_empty():
		return
	_early_call_requested = false
	var intermission := _intermission_duration()
	var max_bonus := int(round(intermission * EARLY_CALL_GOLD_PER_SECOND))
	if _is_gauntlet_mode():
		max_bonus = 0
	if context.bridge:
		var preview := preview_text
		if _is_gauntlet_mode():
			preview += "\nStart Now — next wave swells!"
		context.bridge.intermission_started.emit(preview, max_bonus)
	var timer := get_tree().create_timer(intermission / _time_scale())
	while timer.time_left > 0.0:
		if not _tree_available():
			return
		if _early_call_requested:
			if _is_gauntlet_mode():
				var seconds_skipped := timer.time_left
				var mult := 1.0 + minf(
					seconds_skipped * GAUNTLET_EARLY_CALL_OVERWHELM_PER_SEC,
					GAUNTLET_EARLY_CALL_OVERWHELM_CAP - 1.0
				)
				context.runtime_modifiers["gauntlet_next_wave_overwhelm"] = mult
				if context.bridge:
					context.bridge.alert_message.emit("Early call! Next wave swells!", 60)
			else:
				var bonus := int(round(timer.time_left * EARLY_CALL_GOLD_PER_SECOND))
				bonus = maxi(0, bonus)
				if bonus > 0 and context.economy:
					context.economy.add_gold(bonus)
				if context.bridge:
					context.bridge.alert_message.emit("Early call! +%d gold" % bonus, 60)
			break
		await _await_process_frame()
	if _tree_available() and context.bridge:
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


func get_battle_time_scale() -> float:
	return _time_scale()


func debug_force_wave_advance() -> void:
	if context == null:
		return
	for enemy in context.active_enemies.duplicate():
		if enemy is EnemyController and is_instance_valid(enemy):
			(enemy as EnemyController).take_damage(999999.0, true)


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
	if _is_gauntlet_mode():
		return
	if context == null or context.level_data == null:
		return
	if context.level_data.is_tutorial:
		return
	if context.objectives == null or context.bridge == null:
		return
	var block_size := _block_size()
	var cleared := current_wave_index + 1
	if cleared % block_size != 0:
		return
	if cleared >= total_waves:
		return
	var block_index := (cleared / block_size) - 1
	var block_start := block_index * block_size + 1
	var block_end := block_index * block_size + block_size
	if not _endless_mode and not _horde_mode and not _throne_mode:
		block_end = mini(block_end, total_waves)
	var vow := context.objectives.pick_next_vow(block_index)
	if vow == null:
		return
	context.bridge.vow_offer_requested.emit(vow, block_start, block_end)
	while (
		_tree_available()
		and context.state_controller
		and context.state_controller.current_state == GameEnums.BattleState.PAUSED
	):
		await _await_process_frame()


func _is_gauntlet_mode() -> bool:
	return context != null and context.launch_data != null and context.launch_data.is_gauntlet_mode


func _intermission_duration() -> float:
	if _is_gauntlet_mode():
		return GAUNTLET_INTERMISSION_DURATION
	return INTERMISSION_DURATION


func _apply_gauntlet_wave_modifiers(wave: WaveData) -> WaveData:
	if wave == null or context == null or not _is_gauntlet_mode():
		return wave
	var count_mult := 1.0
	var speed_mult := 1.0
	if bool(context.runtime_modifiers.get("gauntlet_pre_battle_rush", false)) and current_wave_index == 0:
		count_mult *= GAUNTLET_PRE_BATTLE_RUSH_COUNT_MULT
		speed_mult *= GAUNTLET_PRE_BATTLE_RUSH_SPEED_MULT
		context.runtime_modifiers.erase("gauntlet_pre_battle_rush")
	var overwhelm: Variant = context.runtime_modifiers.get("gauntlet_next_wave_overwhelm", null)
	if overwhelm != null:
		count_mult *= float(overwhelm)
		context.runtime_modifiers.erase("gauntlet_next_wave_overwhelm")
	if is_equal_approx(count_mult, 1.0) and is_equal_approx(speed_mult, 1.0):
		return wave
	var copy := wave.duplicate(true) as WaveData
	var scaled_groups: Array[Dictionary] = []
	for group in copy.spawn_groups:
		var g: Dictionary = group.duplicate()
		g["count"] = maxi(1, int(round(int(g.get("count", 1)) * count_mult)))
		scaled_groups.append(g)
	copy.spawn_groups = scaled_groups
	if not is_equal_approx(speed_mult, 1.0):
		var existing := float(context.runtime_modifiers.get("enemy_speed_mult", 1.0))
		context.runtime_modifiers["enemy_speed_mult"] = existing * speed_mult
	return copy
