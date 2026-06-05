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


func on_gate_leak() -> void:
	add(-8)


func on_wave_cleared() -> void:
	add(5)


func on_boss_defeated() -> void:
	add(15)


func _emit() -> void:
	if context and context.bridge:
		context.bridge.morale_changed.emit(current, MAX_MORALE)
