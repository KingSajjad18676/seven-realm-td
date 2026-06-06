class_name PlayerSlot
extends RefCounted

var player_index: int = 0
var hero_id: String = ""
var sacred_fire: int = 0
var forge_materials_earned: Dictionary = {}


func get_unbanked_materials() -> Dictionary:
	return forge_materials_earned.duplicate()


func collect_material(material_id: String, amount: int) -> void:
	if material_id == "" or amount <= 0:
		return
	forge_materials_earned[material_id] = int(forge_materials_earned.get(material_id, 0)) + amount


func clear_unbanked_materials() -> void:
	forge_materials_earned.clear()


func can_afford_sacred_fire(cost: int) -> bool:
	return sacred_fire >= cost


func spend_sacred_fire(cost: int) -> bool:
	if not can_afford_sacred_fire(cost):
		return false
	sacred_fire -= cost
	return true


func add_sacred_fire(amount: int) -> void:
	sacred_fire += amount
