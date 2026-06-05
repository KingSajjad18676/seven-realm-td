extends LabourMode

const AMBUSH_ENEMY := "enemy_jackal"
const AMBUSH_COUNT := 4


func initialize(ctx: BattleContext) -> void:
	super.initialize(ctx)
	if context and context.bridge:
		context.bridge.alert_message.emit("Labour of the Lion — Rakhsh keeps watch", 70)


func on_wave_started(wave_index: int) -> void:
	if wave_index != 0 or context == null:
		return
	await get_tree().create_timer(2.5).timeout
	if context == null or context.enemy_spawner == null:
		return
	var hero := context.hero_manager.hero if context.hero_manager else null
	var spawn_pos := hero.global_position + Vector2(-80, 0) if hero else context.path_points[0]
	for i in AMBUSH_COUNT:
		context.enemy_spawner.spawn_enemy_at(AMBUSH_ENEMY, spawn_pos + Vector2(i * 18, 0))
	if context.bridge:
		context.bridge.alert_message.emit("Ambush! Rakhsh engages the lion pack!", 55)
