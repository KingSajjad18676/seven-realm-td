extends LabourMode

var _cave_opened := false


func initialize(ctx: BattleContext) -> void:
	super.initialize(ctx)
	if context and context.bridge:
		context.bridge.alert_message.emit("Labour of the Demons — Olad reveals the caves", 70)


func on_wave_completed(wave_index: int) -> void:
	if _cave_opened or wave_index < 2 or context == null:
		return
	_cave_opened = true
	_open_second_cave_front()


func _open_second_cave_front() -> void:
	if context == null or context.enemy_spawner == null:
		return
	var cave_pos := _resolve_cave_spawn_pos()
	for i in 6:
		context.enemy_spawner.spawn_enemy_at("enemy_mountain_raider", cave_pos + Vector2(0, i * 12))
	for i in 3:
		context.enemy_spawner.spawn_enemy_at("enemy_div_infantry", cave_pos + Vector2(40, i * 20))
	if context.bridge:
		context.bridge.alert_message.emit("A second cave front opens — raiders flood the split!", 65)


func _resolve_cave_spawn_pos() -> Vector2:
	if context == null or context.level_data == null:
		return Vector2.ZERO
	for spawn in context.level_data.spawn_points:
		if spawn.spawn_id == "spawn_2" or spawn.route_id == "route_2":
			return spawn.position
	if context.path_points.size() > 2:
		return context.path_points[context.path_points.size() / 2]
	return context.path_points[0] if not context.path_points.is_empty() else Vector2.ZERO
