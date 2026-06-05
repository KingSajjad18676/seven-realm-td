extends LabourMode

var _decoys_spawned := false


func initialize(ctx: BattleContext) -> void:
	super.initialize(ctx)
	if context and context.bridge:
		context.bridge.alert_message.emit("Labour of the Temptress — illusions cloud the feast", 70)


func on_wave_started(wave_index: int) -> void:
	if wave_index < 1 or _decoys_spawned or context == null:
		return
	_decoys_spawned = true
	if context.enemy_spawner:
		for i in 6:
			var node := context.enemy_spawner.spawn_enemy_at("enemy_illusion_attendant", context.path_points[0])
			if node:
				node.set_decoy(true)
	_spawn_feast_after_decoys()


func _spawn_feast_after_decoys() -> void:
	if context == null or context.enemy_spawner == null or context.path_points.is_empty():
		return
	await get_tree().create_timer(1.5).timeout
	if context == null or context.enemy_spawner == null:
		return
	var has_decoy := false
	for e in context.active_enemies:
		if e is EnemyController and e.is_decoy():
			has_decoy = true
			break
	if not has_decoy:
		return
	for i in 4:
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
