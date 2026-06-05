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
	if context.enemy_spawner and context.path_points.size() > 2:
		var cave_pos := context.path_points[context.path_points.size() / 2]
		for i in 5:
			context.enemy_spawner.spawn_enemy_at("enemy_div_infantry", cave_pos + Vector2(0, i * 12))
		for i in 2:
			context.enemy_spawner.spawn_enemy_at("enemy_div_brute", cave_pos + Vector2(40, i * 20))
	if context.bridge:
		context.bridge.alert_message.emit("A second cave front opens — split your defense!", 65)
