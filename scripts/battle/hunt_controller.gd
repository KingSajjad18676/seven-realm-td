class_name HuntController
extends Node

const SHARDS_TO_BIND := 3

var context: BattleContext = null
var binding_shards: int = 0
var milestones_reached: int = 0


func initialize(ctx: BattleContext) -> void:
	context = ctx
	binding_shards = 0
	milestones_reached = 0
	if ctx.bridge:
		ctx.bridge.alert_message.emit("Hunt: slay corruptors to gather binding shards", 75)


func on_enemy_slain(data: EnemyData) -> void:
	if context == null or data == null:
		return
	var gained := 0
	if data.tags.has("corruptor"):
		gained = 1
	elif data.is_boss:
		gained = 2
	elif randf() < 0.15:
		gained = 1
	if gained <= 0:
		return
	binding_shards = mini(binding_shards + gained, SHARDS_TO_BIND)
	_check_milestones()


func _check_milestones() -> void:
	if context == null:
		return
	var milestone := binding_shards
	if milestone > milestones_reached:
		milestones_reached = milestone
		context.runtime_modifiers["hunt_binding_bonus"] = float(milestones_reached) * 0.35
		if context.bridge:
			context.bridge.alert_message.emit(
				"Binding shard %d/%d — Zahhak weakens!" % [milestones_reached, SHARDS_TO_BIND],
				80
			)
	if milestones_reached >= SHARDS_TO_BIND and context.bridge:
		context.bridge.alert_message.emit("Binding complete — strike Zahhak down!", 90)
