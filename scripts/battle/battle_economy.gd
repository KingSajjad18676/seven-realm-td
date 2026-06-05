class_name BattleEconomy
extends Node

var context: BattleContext = null
var gold: int = 0
var sacred_fire: int = 0
var forge_materials_earned: Dictionary = {}


func get_unbanked_materials() -> Dictionary:
	return forge_materials_earned.duplicate()


func collect_material(material_id: String, amount: int) -> void:
	if material_id == "" or amount <= 0:
		return
	forge_materials_earned[material_id] = int(forge_materials_earned.get(material_id, 0)) + amount
	_emit_materials()


func clear_unbanked_materials() -> void:
	forge_materials_earned.clear()
	_emit_materials()


func initialize(ctx: BattleContext) -> void:
	context = ctx
	if ctx.level_data:
		gold = ctx.level_data.starting_gold
		sacred_fire = ctx.level_data.starting_sacred_fire
	_emit()


func can_afford_gold(cost: int) -> bool:
	return gold >= cost


func spend_gold(cost: int) -> bool:
	if not can_afford_gold(cost):
		return false
	gold -= cost
	_emit()
	return true


func add_gold(amount: int) -> void:
	gold += amount
	_emit()


func can_afford_sacred_fire(cost: int) -> bool:
	return sacred_fire >= cost


func spend_sacred_fire(cost: int) -> bool:
	if not can_afford_sacred_fire(cost):
		return false
	sacred_fire -= cost
	_emit()
	CombatEvents.cleanse_used.emit("")
	return true


func add_sacred_fire(amount: int) -> void:
	sacred_fire += amount
	_emit()


func apply_kill_rewards(enemy_data: EnemyData) -> void:
	if enemy_data == null:
		return
	add_gold(enemy_data.gold_reward)
	if enemy_data.sacred_fire_reward > 0:
		add_sacred_fire(enemy_data.sacred_fire_reward)
	CombatEvents.enemy_killed.emit(
		enemy_data.enemy_id,
		enemy_data.gold_reward,
		enemy_data.sacred_fire_reward
	)


func _emit() -> void:
	if context and context.bridge:
		context.bridge.gold_changed.emit(gold)
		context.bridge.sacred_fire_changed.emit(sacred_fire)


func _emit_materials() -> void:
	if context and context.bridge:
		context.bridge.materials_changed.emit(get_unbanked_materials())
