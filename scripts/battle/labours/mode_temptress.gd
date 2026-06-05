extends LabourMode

var _decoys_spawned_this_wave := false


func initialize(ctx: BattleContext) -> void:
	super.initialize(ctx)
	if context and context.bridge:
		context.bridge.alert_message.emit("Labour of the Temptress — illusions cloud the feast", 70)


func on_wave_started(wave_index: int) -> void:
	if wave_index < 1 or context == null:
		return
	_decoys_spawned_this_wave = false
	var decoy_count := 6 if act_index_for(wave_index) >= 1 else 4
	_spawn_decoys(decoy_count)
	if act_index_for(wave_index) >= 1:
		_spawn_feast_after_decoys()


func _spawn_decoys(count: int) -> void:
	if context == null or context.enemy_spawner == null or context.path_points.is_empty():
		return
	_decoys_spawned_this_wave = true
	for i in count:
		var node: EnemyController = context.enemy_spawner.spawn_enemy_at(
			"enemy_illusion_attendant", context.path_points[0]
		)
		if node:
			node.set_decoy(true)


func _spawn_feast_after_decoys() -> void:
	if context == null or context.enemy_spawner == null or context.path_points.is_empty():
		return
	await get_tree().create_timer(1.5).timeout
	if context == null or context.enemy_spawner == null:
		return
	var feast_count := 4 if act_index_for(context.wave_manager.current_wave_index if context.wave_manager else 0) < 2 else 6
	for i in feast_count:
		context.enemy_spawner.spawn_enemy_at(
			"enemy_feast_shade",
			context.path_points[0] + Vector2(40 + i * 22, 0)
		)
	if context.bridge:
		context.bridge.alert_message.emit("Feast shades join the illusions!", 45)


func on_cleanse(_region_id: String) -> void:
	if context == null:
		return
	var dispelled := 0
	for e in context.active_enemies:
		if e is EnemyController and e.is_decoy():
			e.take_damage(9999.0, false)
			dispelled += 1
	if dispelled > 0 and context.bridge:
		context.bridge.alert_message.emit("Illusions dispelled in the name of God!", 50)
	if act_index_for(context.wave_manager.current_wave_index if context.wave_manager else 0) >= 3:
		_apply_corruptor_pressure()


func _apply_corruptor_pressure() -> void:
	if context == null or context.map_light == null or context.tower_manager == null:
		return
	for tower in context.tower_manager.towers:
		if tower == null or tower.build_spot == null:
			continue
		context.map_light.apply_corruption_pressure(tower.build_spot.region_id, 18.0)
