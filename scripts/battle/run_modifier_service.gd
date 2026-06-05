class_name RunModifierService
extends Node

var context: BattleContext = null
var active_relics: Array[RelicData] = []


func initialize(ctx: BattleContext) -> void:
	context = ctx
	active_relics.clear()


func add_relic(relic: RelicData) -> void:
	if relic == null:
		return
	active_relics.append(relic)
	_apply_relic(relic)
	if context and context.bridge:
		context.bridge.alert_message.emit("Relic: %s" % relic.title, 50)


func _apply_relic(relic: RelicData) -> void:
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
