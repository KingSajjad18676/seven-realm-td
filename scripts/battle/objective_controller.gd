class_name ObjectiveController
extends Node

const VOW_STATE_PENDING := 0
const VOW_STATE_ACTIVE := 1
const VOW_STATE_HONORED := 2
const VOW_STATE_BROKEN := 3
const VOW_STATE_DECLINED := 4

var context: BattleContext = null
var active_objective: ObjectiveData = null
var progress: int = 0
var completed: bool = false
var failed: bool = false
var _total_leaks: int = 0
var _hijack_count: int = 0
var _current_wave: int = 0
var _vow_block_index: int = 0
var _active_vow: Dictionary = {}
var vows_honored: int = 0
var vows_offered: int = 0


func initialize(ctx: BattleContext) -> void:
	context = ctx
	_reset()
	_connect_combat_events()


func _connect_combat_events() -> void:
	if not CombatEvents.wave_started.is_connected(_on_wave_started):
		CombatEvents.wave_started.connect(_on_wave_started)
	if not CombatEvents.hero_moved.is_connected(_on_hero_moved):
		CombatEvents.hero_moved.connect(_on_hero_moved)
	if not CombatEvents.tower_built.is_connected(_on_tower_built):
		CombatEvents.tower_built.connect(_on_tower_built)
	if not CombatEvents.tower_upgraded.is_connected(_on_tower_upgraded):
		CombatEvents.tower_upgraded.connect(_on_tower_upgraded)
	if not CombatEvents.tower_sold.is_connected(_on_tower_sold):
		CombatEvents.tower_sold.connect(_on_tower_sold)
	if not CombatEvents.hero_skill_used.is_connected(_on_hero_skill_used):
		CombatEvents.hero_skill_used.connect(_on_hero_skill_used)
	if not CombatEvents.cleanse_used.is_connected(_on_cleanse_event):
		CombatEvents.cleanse_used.connect(_on_cleanse_event)


func assign_objective(obj: ObjectiveData) -> void:
	active_objective = obj
	_reset_legacy()
	if context and context.bridge and obj:
		context.bridge.alert_message.emit("Objective: %s" % obj.title, 60)


func pick_next_vow(block_index: int) -> ObjectiveData:
	var vows := ContentRegistry.get_all_vows()
	if vows.is_empty():
		return null
	var idx := block_index % vows.size()
	var vow := vows[idx]
	if vow == null:
		return null
	var scaled := vow.duplicate(true) as ObjectiveData
	var bonus := block_index / 3
	scaled.sacred_fire_reward = vow.sacred_fire_reward + bonus
	scaled.morale_reward = vow.morale_reward + bonus * 2
	return scaled


func activate_vow(vow_data: ObjectiveData, start_wave: int, end_wave: int) -> void:
	if vow_data == null:
		return
	_active_vow = {
		"data": vow_data,
		"start_wave": start_wave,
		"end_wave": end_wave,
		"state": VOW_STATE_ACTIVE,
	}
	vows_offered += 1
	_emit_vow_status()
	if context and context.bridge:
		context.bridge.alert_message.emit(
			"Vow sworn: %s (waves %d-%d)" % [vow_data.title, start_wave, end_wave],
			65
		)


func decline_vow() -> void:
	if _active_vow.is_empty():
		return
	_active_vow["state"] = VOW_STATE_DECLINED
	_active_vow.clear()
	_emit_vow_status()


func get_active_vow_data() -> ObjectiveData:
	if _active_vow.is_empty():
		return null
	return _active_vow.get("data") as ObjectiveData


func is_vow_active() -> bool:
	return not _active_vow.is_empty() and int(_active_vow.get("state", VOW_STATE_PENDING)) == VOW_STATE_ACTIVE


func _reset() -> void:
	_reset_legacy()
	_current_wave = 0
	_vow_block_index = 0
	_active_vow.clear()
	vows_honored = 0
	vows_offered = 0


func _reset_legacy() -> void:
	progress = 0
	completed = false
	failed = false
	_total_leaks = 0
	_hijack_count = 0


func _on_wave_started(wave_index: int) -> void:
	_current_wave = wave_index + 1
	if is_vow_active():
		_emit_vow_status()


func _on_hero_moved() -> void:
	_break_vow_if("vow_no_hero_move")


func _on_tower_built(_tower_id: String) -> void:
	_break_vow_if("vow_no_build")


func _on_tower_upgraded(_tower_id: String, _new_level: int) -> void:
	_break_vow_if("vow_no_upgrade")


func _on_tower_sold(_tower_id: String, _refund: int) -> void:
	_break_vow_if("vow_no_sell")


func _on_hero_skill_used(_skill_id: String) -> void:
	_break_vow_if("vow_no_hero_skill")


func _on_cleanse_event(_region_id: String) -> void:
	on_cleanse()


func on_cleanse() -> void:
	if active_objective and not completed and active_objective.goal_type == "cleanse_twice":
		progress += 1
		if progress >= active_objective.goal_count:
			_complete_legacy()
	_break_vow_if("vow_no_cleanse")


func on_gate_leak() -> void:
	_total_leaks += 1
	if active_objective and active_objective.goal_type == "no_leaks":
		failed = true
	_break_vow_if("vow_no_leak_window")


func on_hijack() -> void:
	_hijack_count += 1
	if active_objective and active_objective.goal_type == "no_hijack":
		failed = true
	_break_vow_if("vow_no_hijack_window")


func on_wave_cleared() -> void:
	if _active_vow.is_empty():
		return
	var state := int(_active_vow.get("state", VOW_STATE_PENDING))
	if state != VOW_STATE_ACTIVE:
		return
	var end_wave := int(_active_vow.get("end_wave", 0))
	if _current_wave < end_wave:
		return
	_honor_vow()


func evaluate_at_victory() -> void:
	if active_objective == null or completed or failed:
		return
	match active_objective.goal_type:
		"no_leaks":
			if _total_leaks == 0:
				_complete_legacy()
		"no_hijack":
			if _hijack_count == 0:
				_complete_legacy()
		"cleanse_twice":
			if progress >= active_objective.goal_count:
				_complete_legacy()


func _break_vow_if(goal_type: String) -> void:
	if not is_vow_active():
		return
	var data := get_active_vow_data()
	if data == null or data.goal_type != goal_type:
		return
	_active_vow["state"] = VOW_STATE_BROKEN
	if context and context.morale and data.penalty_morale > 0:
		context.morale.add(-data.penalty_morale)
	if context and context.bridge:
		context.bridge.alert_message.emit("Vow broken — morale falters", 70)
	_emit_vow_status(VOW_STATE_BROKEN)


func _honor_vow() -> void:
	if _active_vow.is_empty():
		return
	var data := get_active_vow_data()
	if data == null:
		return
	_active_vow["state"] = VOW_STATE_HONORED
	vows_honored += 1
	if context and context.economy:
		if data.sacred_fire_reward > 0:
			context.economy.add_sacred_fire(data.sacred_fire_reward)
		if data.gold_reward > 0:
			context.economy.add_gold(data.gold_reward)
	if context and context.morale and data.morale_reward > 0:
		context.morale.add(data.morale_reward)
	AnalyticsService.objective_completed(data.objective_id, true)
	if context and context.bridge:
		context.bridge.alert_message.emit("Vow honored!", 75)
	_emit_vow_status(VOW_STATE_HONORED)
	_active_vow.clear()


func _complete_legacy() -> void:
	completed = true
	if context == null or active_objective == null:
		return
	if context.economy:
		context.economy.add_gold(active_objective.gold_reward)
		if active_objective.sacred_fire_reward > 0:
			context.economy.add_sacred_fire(active_objective.sacred_fire_reward)
	if context.morale and active_objective.morale_reward > 0:
		context.morale.add(active_objective.morale_reward)
	AnalyticsService.objective_completed(active_objective.objective_id, true)
	if context.bridge:
		context.bridge.alert_message.emit("Objective complete!", 70)


func _emit_vow_status(state: int = VOW_STATE_ACTIVE) -> void:
	if context == null or context.bridge == null:
		return
	var data := get_active_vow_data()
	if data == null:
		context.bridge.vow_status.emit("", state)
		return
	var end_wave := int(_active_vow.get("end_wave", _current_wave))
	var remaining := maxi(0, end_wave - _current_wave)
	var text := "%s (%d waves left)" % [data.title, remaining]
	context.bridge.vow_status.emit(text, state)
