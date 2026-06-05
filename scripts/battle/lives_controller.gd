class_name LivesController
extends Node

var context: BattleContext = null
var current_lives: int = 0
var max_lives: int = 0


func initialize(ctx: BattleContext) -> void:
	context = ctx
	if ctx.level_data:
		max_lives = ctx.level_data.starting_lives
		current_lives = max_lives
	_emit()


func lose_life(amount: int = 1) -> void:
	current_lives = maxi(0, current_lives - amount)
	if context:
		if context.objectives:
			context.objectives.on_gate_leak()
		if context.morale:
			context.morale.on_gate_leak()
	_emit()
	if context and context.bridge:
		context.bridge.alert_message.emit("Gate breached! -%d life" % amount, 100)
	if current_lives <= 0 and context.state_controller:
		context.state_controller.trigger_defeat("lives_depleted")


func _emit() -> void:
	if context and context.bridge:
		context.bridge.lives_changed.emit(current_lives, max_lives)
