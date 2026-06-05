class_name EnemySpawner
extends Node

var context: BattleContext = null
var enemy_scene: PackedScene = preload("res://scenes/prefabs/enemy.tscn")
var units_root: Node2D = null
var _pool: ObjectPool = null


func initialize(ctx: BattleContext, root: Node2D) -> void:
	context = ctx
	units_root = root
	_pool = ObjectPool.new(enemy_scene, root, 8)


func spawn_wave(wave: WaveData) -> void:
	if wave == null or context == null:
		return
	if wave.is_boss_wave and context.level_data:
		var level_id := context.level_data.level_id
		context.runtime_modifiers["campaign_boss_damage_mult"] = (
			ContentCatalog.final_boss_damage_mult(level_id)
		)
	for group in wave.spawn_groups:
		var enemy_id: String = str(group.get("enemy_id", ""))
		var count: int = int(group.get("count", 1))
		var catalog_data := ContentRegistry.get_enemy(enemy_id)
		if catalog_data == null:
			continue
		for i in count:
			var data := catalog_data.duplicate(true) as EnemyData
			if wave.is_boss_wave and data.is_boss:
				data = _scale_final_boss_data(data)
			_spawn_enemy(data, group)
			if wave.spawn_interval > 0.0:
				await get_tree().create_timer(wave.spawn_interval).timeout


func _scale_final_boss_data(data: EnemyData) -> EnemyData:
	if context == null or context.level_data == null:
		return data
	var hp_mult := ContentCatalog.final_boss_hp_mult(context.level_data.level_id)
	data.max_hp *= hp_mult
	data.armor *= 1.0 + (hp_mult - 1.0) * 0.5
	return data


func _spawn_enemy(data: EnemyData, spawn_group: Dictionary = {}) -> void:
	var node := _pool.acquire() as EnemyController
	if node == null:
		return
	var route_info := context.resolve_enemy_route(spawn_group)
	var path: PackedVector2Array = route_info.get("path", context.path_points)
	var spawn_pos: Vector2 = route_info.get("position", Vector2.ZERO)
	node.initialize(context, data, path)
	if data.is_boss:
		node.setup_as_boss()
	if node.get_parent() != units_root:
		if node.get_parent():
			node.get_parent().remove_child(node)
		units_root.add_child(node)
	node.global_position = spawn_pos
	context.active_enemies.append(node)
	if context.state_controller:
		context.state_controller.register_enemy_spawned()


func release_enemy(node: EnemyController) -> void:
	if node == null:
		return
	var idx := context.active_enemies.find(node)
	if idx >= 0:
		context.active_enemies.remove_at(idx)
	if context.state_controller:
		context.state_controller.register_enemy_removed()
	_pool.release(node)


func spawn_enemy_at(enemy_id: String, position: Vector2, spawn_group: Dictionary = {}) -> EnemyController:
	if context == null:
		return null
	var catalog_data := ContentRegistry.get_enemy(enemy_id)
	if catalog_data == null:
		return null
	var data := catalog_data.duplicate(true) as EnemyData
	var group := spawn_group.duplicate()
	if group.is_empty():
		group = {"enemy_id": enemy_id, "count": 1}
	_spawn_enemy(data, group)
	var node := context.active_enemies[context.active_enemies.size() - 1] as EnemyController
	if node:
		node.global_position = position
	return node
