class_name LootDropManager
extends Node

var context: BattleContext = null
var _drop_scene: PackedScene = preload("res://scenes/prefabs/material_drop.tscn")
var _root: Node2D = null
var _active_drops: Array[MaterialDrop] = []


func initialize(ctx: BattleContext, units_root: Node2D) -> void:
	context = ctx
	_root = units_root


func spawn_guaranteed_drop(world_pos: Vector2, material_id: String, amount: int = 1) -> void:
	if material_id == "" or _root == null or _drop_scene == null:
		return
	var drop: MaterialDrop = _drop_scene.instantiate() as MaterialDrop
	if drop == null:
		return
	_root.add_child(drop)
	drop.global_position = world_pos
	drop.initialize(material_id, amount, self)
	_active_drops.append(drop)


func try_spawn_drop(world_pos: Vector2, enemy_data: EnemyData) -> void:
	if context == null or enemy_data == null:
		return
	var launch = context.launch_data
	if launch == null or not launch.is_scavenge_mode():
		return
	if enemy_data.forge_material_id == "" or enemy_data.forge_material_drop <= 0:
		return
	if randf() > enemy_data.forge_material_drop_chance:
		return
	if _root == null or _drop_scene == null:
		return
	var drop: MaterialDrop = _drop_scene.instantiate() as MaterialDrop
	if drop == null:
		return
	_root.add_child(drop)
	drop.global_position = world_pos
	drop.initialize(enemy_data.forge_material_id, enemy_data.forge_material_drop, self)
	_active_drops.append(drop)


func on_drop_collected(drop: MaterialDrop) -> void:
	_active_drops.erase(drop)
	if context and context.economy:
		context.economy.collect_material(drop.material_id, drop.amount)


func on_drop_despawned(drop: MaterialDrop) -> void:
	_active_drops.erase(drop)


func clear_all_drops() -> void:
	for drop in _active_drops.duplicate():
		if is_instance_valid(drop):
			drop.queue_free()
	_active_drops.clear()
