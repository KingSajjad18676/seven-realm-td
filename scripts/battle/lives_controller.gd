class_name LivesController
extends Node

var context: BattleContext = null
var current_lives: int = 0
var max_lives: int = 0
var _life_heal_accum: float = 0.0


func initialize(ctx: BattleContext) -> void:
	context = ctx
	if ctx.level_data:
		max_lives = ctx.level_data.starting_lives
		current_lives = max_lives
	_emit()


func lose_life(amount: int = 1) -> void:
	if context and context.runtime_modifiers.has("gate_leak_reduction"):
		amount = maxi(1, amount - int(context.runtime_modifiers["gate_leak_reduction"]))
	current_lives = maxi(0, current_lives - amount)
	if context:
		if context.objectives:
			context.objectives.on_gate_leak()
		if context.morale:
			context.morale.on_gate_leak()
	_emit()
	if context and context.bridge:
		var breach_msg := "Throne breached! -%d life" % amount
		if context.launch_data == null or not context.launch_data.is_throne_defense_mode:
			breach_msg = "Gate breached! -%d life" % amount
		context.bridge.alert_message.emit(breach_msg, 100)
	if current_lives <= 0:
		if context and context.equipment_battle and context.equipment_battle.try_gate_rebuild():
			return
		if context and context.simorgh_continue and context.simorgh_continue.try_offer_continue():
			return
		if context and context.state_controller:
			var reason := "throne_breached" if (
				context.launch_data and context.launch_data.is_throne_defense_mode
			) else "lives_depleted"
			context.state_controller.trigger_defeat(reason)


func heal_life(amount: int = 1) -> void:
	current_lives = mini(max_lives, current_lives + amount)
	_emit()


func restore_fraction(amount: float) -> void:
	if amount <= 0.0:
		return
	_life_heal_accum += amount
	while _life_heal_accum >= 1.0 and current_lives < max_lives:
		_life_heal_accum -= 1.0
		current_lives += 1
	_emit()


func _emit() -> void:
	if context and context.bridge:
		context.bridge.lives_changed.emit(current_lives, max_lives)
