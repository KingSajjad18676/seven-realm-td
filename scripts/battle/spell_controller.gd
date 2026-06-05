class_name SpellController
extends Node

var context: BattleContext = null
var _cooldowns: Dictionary = {}


func initialize(ctx: BattleContext) -> void:
	context = ctx


func get_owned_spells() -> Array[SpellData]:
	var owned: Array[SpellData] = []
	if SaveSystem == null or ContentRegistry == null:
		return owned
	for spell_id in SaveSystem.get_spells_owned():
		var spell := ContentRegistry.get_spell(spell_id)
		if spell:
			owned.append(spell)
	return owned


func is_on_cooldown(spell_id: String) -> bool:
	return float(_cooldowns.get(spell_id, 0.0)) > 0.0


func cooldown_remaining(spell_id: String) -> float:
	return maxf(0.0, float(_cooldowns.get(spell_id, 0.0)))


func tick(delta: float) -> void:
	for spell_id in _cooldowns.keys():
		_cooldowns[spell_id] = maxf(0.0, float(_cooldowns[spell_id]) - delta)


func cast_spell(spell_id: String) -> bool:
	if context == null or SaveSystem == null or ContentRegistry == null:
		return false
	if not SaveSystem.owns_spell(spell_id):
		return false
	if is_on_cooldown(spell_id):
		return false
	var spell := ContentRegistry.get_spell(spell_id)
	if spell == null:
		return false
	if not _apply_effect(spell):
		return false
	_cooldowns[spell_id] = spell.cooldown_seconds
	if context.bridge:
		context.bridge.alert_message.emit("Cast: %s" % spell.display_name, 55)
	return true


func _apply_effect(spell: SpellData) -> bool:
	match spell.effect_type:
		"gold_bonus":
			if context.economy:
				context.economy.add_gold(int(spell.effect_value))
			return true
		"morale_bonus":
			if context.morale:
				context.morale.add(int(spell.effect_value))
			return true
		"cleanse_all":
			return _cleanse_all_regions()
		"damage_all":
			return _damage_all_enemies(spell.effect_value)
		"tower_buff":
			context.runtime_modifiers["tower_damage_mult"] = float(
				context.runtime_modifiers.get("tower_damage_mult", 1.0)
			) * spell.effect_value
			_schedule_tower_buff_reset(spell.effect_value, 12.0)
			return true
		"boss_burst":
			return _damage_bosses_and_brutes(spell.effect_value)
		_:
			return false


func _cleanse_all_regions() -> bool:
	if context == null or context.map_light == null:
		return false
	var cleansed := false
	for region_id in context.level_data.region_ids if context.level_data else []:
		if context.map_light.get_light(region_id) < MapLightManager.LIGHT_MAX:
			context.map_light.repair_region_light(region_id, MapLightManager.LIGHT_MAX)
			if context.objectives:
				context.objectives.on_cleanse()
			cleansed = true
	return cleansed


func _damage_all_enemies(amount: float) -> bool:
	if context == null:
		return false
	for node in context.active_enemies:
		if is_instance_valid(node) and node.has_method("take_damage"):
			node.call("take_damage", amount, false)
	return true


func _damage_bosses_and_brutes(amount: float) -> bool:
	if context == null:
		return false
	var hit := false
	for node in context.active_enemies:
		if not is_instance_valid(node) or not node.has_method("take_damage"):
			continue
		var data = node.get("data")
		if data == null:
			continue
		if data.is_boss or "brute" in data.tags:
			node.call("take_damage", amount, false)
			hit = true
	return hit


func _schedule_tower_buff_reset(mult: float, duration: float) -> void:
	var tree := get_tree()
	if tree == null:
		return
	await tree.create_timer(duration).timeout
	if context:
		var current := float(context.runtime_modifiers.get("tower_damage_mult", 1.0))
		context.runtime_modifiers["tower_damage_mult"] = current / mult
