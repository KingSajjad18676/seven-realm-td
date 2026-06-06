extends GutTest


func test_picks_highest_progress_near_gate() -> void:
	var ctx := BattleContext.new()
	var level := LevelData.new()
	level.gate_position = Vector2(200, 200)
	ctx.level_data = level
	var behavior := ZavarehGateGuardBehavior.new()
	var entity := CompanionEntity.new()
	var data := CompanionData.new()
	data.gate_offset = Vector2(-55, 0)
	behavior.bind(entity, ctx, data)
	var slow := _make_enemy(ctx, 300.0)
	var fast := _make_enemy(ctx, 350.0)
	ctx.active_enemies = [slow, fast]
	var picked := behavior._pick_target()
	assert_eq(picked, fast)


func _make_enemy(ctx: BattleContext, progress: float) -> EnemyController:
	var enemy := EnemyController.new()
	enemy.context = ctx
	enemy.data = EnemyData.new()
	var path := PackedVector2Array([Vector2(0, 0), Vector2(400, 0)])
	enemy.initialize(ctx, enemy.data, path)
	enemy._follower.progress_distance = progress
	return enemy
