class_name LabourMode
extends Node

var context: BattleContext = null
var mode_id: String = ""


func initialize(ctx: BattleContext) -> void:
	context = ctx


func on_wave_started(_wave_index: int) -> void:
	pass


func on_wave_completed(_wave_index: int) -> void:
	pass


func on_enemy_died(_enemy_id: String, _enemy: EnemyController = null) -> void:
	pass


func on_boss_defeated() -> void:
	pass


func on_cleanse(_region_id: String) -> void:
	pass
