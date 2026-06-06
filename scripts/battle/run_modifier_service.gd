class_name RunModifierService
extends Node

var context: BattleContext = null
var active_relics: Array[RelicData] = []
var slotted: Dictionary = {}


func initialize(ctx: BattleContext) -> void:
	context = ctx
	active_relics.clear()
	slotted.clear()


func load_slots(slot_map: Dictionary, global_relic_ids: Array[String] = []) -> void:
	slotted.clear()
	for tower_id in slot_map.keys():
		var relic_id := str(slot_map[tower_id])
		var relic := ContentRegistry.get_relic(relic_id) if ContentRegistry else null
		if relic and relic.is_tower_relic():
			slotted[str(tower_id)] = relic
	for relic_id in global_relic_ids:
		var relic := ContentRegistry.get_relic(str(relic_id)) if ContentRegistry else null
		if relic:
			add_relic(relic)


func slot_relic(relic: RelicData, tower_id: String) -> void:
	if relic == null or tower_id == "" or not relic.is_tower_relic():
		return
	slotted[tower_id] = relic
	if context and context.launch_data:
		context.launch_data.tower_relic_slots[tower_id] = relic.relic_id
	if context and context.bridge:
		context.bridge.alert_message.emit("Relic slotted: %s" % relic.title, 50)


func get_relic_for_tower(tower_id: String) -> RelicData:
	return slotted.get(tower_id) as RelicData


func add_relic(relic: RelicData) -> void:
	if relic == null:
		return
	if relic.is_tower_relic():
		slot_relic(relic, relic.slot_tower_id)
		return
	active_relics.append(relic)
	_apply_global_relic(relic)
	if context and context.bridge:
		context.bridge.alert_message.emit("Relic: %s" % relic.title, 50)


func _apply_global_relic(relic: RelicData) -> void:
	if context == null:
		return
	var mods := context.runtime_modifiers
	if relic.attack_mult != 1.0:
		mods["attack_mult"] = float(mods.get("attack_mult", 1.0)) * relic.attack_mult
	if relic.corruption_resist > 0.0:
		mods["corruption_resist"] = float(mods.get("corruption_resist", 0.0)) + relic.corruption_resist
	if relic.sacred_fire_bonus > 0 and context.economy:
		context.economy.add_sacred_fire(relic.sacred_fire_bonus)
	if relic.morale_bonus > 0 and context.morale:
		context.morale.add(relic.morale_bonus)


func on_wave_started() -> void:
	if context == null or context.economy == null:
		return
	for relic in active_relics:
		if relic.gold_bonus_per_wave > 0:
			context.economy.add_gold(relic.gold_bonus_per_wave)
	for tower_id in slotted.keys():
		var relic := slotted[tower_id] as RelicData
		if relic and relic.gold_bonus_per_wave > 0:
			context.economy.add_gold(relic.gold_bonus_per_wave)
	if context.runtime_modifiers.has("wave_gold_penalty"):
		context.economy.add_gold(int(context.runtime_modifiers["wave_gold_penalty"]))
