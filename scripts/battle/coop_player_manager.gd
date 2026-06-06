class_name CoopPlayerManager
extends RefCounted

signal sacred_fire_changed(player_index: int, amount: int)
signal materials_changed(player_index: int, materials: Dictionary)
signal focused_slot_changed(player_index: int)

const BROTHERS_HERO_POOL: Array[String] = ["zal", "sohrab"]

var slots: Array[PlayerSlot] = []
var focused_player_index: int = 0


func initialize(hero_ids: Array[String], starting_sacred_fire: int) -> void:
	slots.clear()
	focused_player_index = 0
	for i in hero_ids.size():
		var slot := PlayerSlot.new()
		slot.player_index = i
		slot.hero_id = hero_ids[i]
		slot.sacred_fire = starting_sacred_fire
		slots.append(slot)


func is_active() -> bool:
	return not slots.is_empty()


func get_slot(index: int) -> PlayerSlot:
	if index < 0 or index >= slots.size():
		return null
	return slots[index]


func get_slot_for_hero(hero_id: String) -> PlayerSlot:
	for slot in slots:
		if slot.hero_id == hero_id:
			return slot
	return null


func get_slot_for_hero_controller(hero: HeroController) -> PlayerSlot:
	if hero == null or hero.data == null:
		return null
	return get_slot_for_hero(hero.data.hero_id)


func set_focused_slot(index: int) -> void:
	if index < 0 or index >= slots.size():
		return
	if focused_player_index == index:
		return
	focused_player_index = index
	focused_slot_changed.emit(index)


func get_focused_slot() -> PlayerSlot:
	return get_slot(focused_player_index)


func can_afford_sacred_fire(player_index: int, cost: int) -> bool:
	var slot := get_slot(player_index)
	return slot != null and slot.can_afford_sacred_fire(cost)


func spend_sacred_fire(player_index: int, cost: int) -> bool:
	var slot := get_slot(player_index)
	if slot == null or not slot.spend_sacred_fire(cost):
		return false
	sacred_fire_changed.emit(player_index, slot.sacred_fire)
	return true


func add_sacred_fire(player_index: int, amount: int) -> void:
	var slot := get_slot(player_index)
	if slot == null or amount <= 0:
		return
	slot.add_sacred_fire(amount)
	sacred_fire_changed.emit(player_index, slot.sacred_fire)


func add_material(player_index: int, material_id: String, amount: int) -> void:
	var slot := get_slot(player_index)
	if slot == null:
		return
	slot.collect_material(material_id, amount)
	materials_changed.emit(player_index, slot.get_unbanked_materials())


func get_merged_materials() -> Dictionary:
	var merged: Dictionary = {}
	for slot in slots:
		for mat_id in slot.forge_materials_earned.keys():
			merged[mat_id] = int(merged.get(mat_id, 0)) + int(slot.forge_materials_earned.get(mat_id, 0))
	return merged


func clear_all_unbanked_materials() -> void:
	for slot in slots:
		slot.clear_unbanked_materials()
		materials_changed.emit(slot.player_index, {})
