class_name MoraleController
extends Node

const MAX_MORALE := 100

var context: BattleContext = null
var current: int = 50


func initialize(ctx: BattleContext) -> void:
	context = ctx
	current = 50
	_emit()


func add(amount: int) -> void:
	current = clampi(current + amount, 0, MAX_MORALE)
	_emit()
	if context:
		context.runtime_modifiers["morale_mult"] = 1.0 + float(current) * 0.002
		if current < 25:
			context.runtime_modifiers["morale_rate_penalty"] = 0.85
		else:
			context.runtime_modifiers.erase("morale_rate_penalty")


static func get_damage_mult(ctx: BattleContext) -> float:
	if ctx == null:
		return 1.0
	return float(ctx.runtime_modifiers.get("morale_mult", 1.0))


static func get_rate_mult(ctx: BattleContext) -> float:
	var mult := get_damage_mult(ctx)
	if ctx and ctx.runtime_modifiers.has("morale_rate_penalty"):
		mult *= float(ctx.runtime_modifiers["morale_rate_penalty"])
	return mult


func on_gate_leak() -> void:
	add(-8)


func on_wave_cleared() -> void:
	add(5)


func on_boss_defeated() -> void:
	add(15)


func _emit() -> void:
	if context and context.bridge:
		context.bridge.morale_changed.emit(current, MAX_MORALE)
