class_name ObjectiveController
extends Node

var context: BattleContext = null
var active_objective: ObjectiveData = null
var progress: int = 0
var completed: bool = false
var failed: bool = false
var _total_leaks: int = 0
var _hijack_count: int = 0


func initialize(ctx: BattleContext) -> void:
	context = ctx
	_reset()


func assign_objective(obj: ObjectiveData) -> void:
	active_objective = obj
	_reset()
	if context and context.bridge and obj:
		context.bridge.alert_message.emit("Objective: %s" % obj.title, 60)


func _reset() -> void:
	progress = 0
	completed = false
	failed = false
	_total_leaks = 0
	_hijack_count = 0


func on_cleanse() -> void:
	if active_objective == null or completed:
		return
	if active_objective.goal_type == "cleanse_twice":
		progress += 1
		if progress >= active_objective.goal_count:
			_complete()


func on_gate_leak() -> void:
	_total_leaks += 1
	if active_objective and active_objective.goal_type == "no_leaks":
		failed = true


func on_hijack() -> void:
	_hijack_count += 1
	if active_objective and active_objective.goal_type == "no_hijack":
		failed = true


func on_wave_cleared() -> void:
	pass


func evaluate_at_victory() -> void:
	if active_objective == null or completed or failed:
		return
	match active_objective.goal_type:
		"no_leaks":
			if _total_leaks == 0:
				_complete()
		"no_hijack":
			if _hijack_count == 0:
				_complete()
		"cleanse_twice":
			if progress >= active_objective.goal_count:
				_complete()


func _complete() -> void:
	completed = true
	if context == null:
		return
	if context.economy and active_objective:
		context.economy.add_gold(active_objective.gold_reward)
		if active_objective.sacred_fire_reward > 0:
			context.economy.add_sacred_fire(active_objective.sacred_fire_reward)
	if context.morale and active_objective.morale_reward > 0:
		context.morale.add(active_objective.morale_reward)
	AnalyticsService.objective_completed(active_objective.objective_id, true)
	if context.bridge:
		context.bridge.alert_message.emit("Objective complete!", 70)
