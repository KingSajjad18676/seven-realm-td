extends LabourMode

const AMBUSH_ENEMY := "enemy_jackal"
const AMBUSH_COUNT := 4


func initialize(ctx: BattleContext) -> void:
	super.initialize(ctx)
	if context and context.bridge:
		context.bridge.alert_message.emit("Labour of the Lion — Rakhsh keeps watch", 70)


func on_wave_started(wave_index: int) -> void:
	if context == null:
		return
	if wave_index == 0:
		_schedule_ambush(AMBUSH_COUNT, 2.5)
	elif act_index_for(wave_index) >= 2 and is_trap_phase(wave_index):
		_schedule_ambush(6, 1.5)


func _schedule_ambush(count: int, delay: float) -> void:
	await get_tree().create_timer(delay).timeout
	if context == null or context.enemy_spawner == null:
		return
	var hero := context.hero_manager.hero if context.hero_manager else null
	var spawn_pos := hero.global_position + Vector2(-80, 0) if hero else context.path_points[0]
	for i in count:
		context.enemy_spawner.spawn_enemy_at(AMBUSH_ENEMY, spawn_pos + Vector2(i * 18, 0))
	if context.bridge:
		context.bridge.alert_message.emit("Ambush! Rakhsh engages the lion pack!", 55)


func spawn_roar_ambush_at(pos: Vector2, count: int = 8) -> void:
	if context == null or context.enemy_spawner == null:
		return
	for i in count:
		context.enemy_spawner.spawn_enemy_at(
			AMBUSH_ENEMY, pos + Vector2(-40 + i * 12, randf_range(-20, 20))
		)
	if context.bridge:
		context.bridge.alert_message.emit("The Lion's roar summons jackals on Rostam!", 60)
