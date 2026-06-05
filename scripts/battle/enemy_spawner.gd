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
	for group in wave.spawn_groups:
		var enemy_id: String = str(group.get("enemy_id", ""))
		var count: int = int(group.get("count", 1))
		var catalog_data := ContentRegistry.get_enemy(enemy_id)
		if catalog_data == null:
			continue
		for i in count:
			var data := catalog_data.duplicate(true) as EnemyData
			_spawn_enemy(data)
			if wave.spawn_interval > 0.0:
				await get_tree().create_timer(wave.spawn_interval).timeout


func _spawn_enemy(data: EnemyData) -> void:
	var node := _pool.acquire() as EnemyController
	if node == null:
		return
	node.initialize(context, data, context.path_points)
	if data.is_boss:
		node.setup_as_boss()
	if node.get_parent() != units_root:
		if node.get_parent():
			node.get_parent().remove_child(node)
		units_root.add_child(node)
	node.global_position = context.level_data.spawn_position if context.level_data else Vector2.ZERO
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
