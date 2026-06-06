extends GutTest


func test_take_true_damage_ignores_armor() -> void:
	var enemy := EnemyController.new()
	var data := EnemyData.new()
	data.max_hp = 200.0
	data.armor = 40.0
	enemy.data = data
	enemy.current_hp = 200.0
	enemy.take_damage(50.0, false)
	var hp_after_armored := enemy.current_hp
	enemy.current_hp = 200.0
	enemy.take_true_damage(50.0)
	assert_eq(enemy.current_hp, 150.0)
	assert_lt(enemy.current_hp, hp_after_armored)


func test_destroy_tower_without_refund() -> void:
	var ctx := BattleContext.new()
	var economy := BattleEconomy.new()
	ctx.economy = economy
	economy.initialize(ctx)
	var manager := TowerManager.new()
	manager.context = ctx
	var tower_data := TowerData.new()
	tower_data.tower_id = "tower_heavy"
	tower_data.build_cost = 120
	var tower := TowerController.new()
	tower.data = tower_data
	tower.gold_invested = 120
	tower.level = 2
	manager.towers.append(tower)
	var gold_before := economy.gold
	assert_true(manager.destroy_tower(tower, false))
	assert_eq(manager.towers.size(), 0)
	assert_eq(economy.gold, gold_before)


func test_blast_damage_hits_enemy_in_radius() -> void:
	var ctx := BattleContext.new()
	var ctrl := KavusFollyController.new()
	add_child_autofree(ctrl)
	ctrl.context = ctx
	var enemy := EnemyController.new()
	var data := EnemyData.new()
	data.max_hp = 600.0
	enemy.data = data
	enemy.current_hp = 600.0
	enemy.global_position = Vector2(100.0, 100.0)
	ctx.active_enemies = [enemy]
	ctrl._apply_blast_damage(Vector2(100.0, 100.0))
	assert_lte(enemy.current_hp, 100.0)


func test_blast_damage_destroys_tower_in_radius() -> void:
	var ctx := BattleContext.new()
	var manager := TowerManager.new()
	ctx.tower_manager = manager
	manager.context = ctx
	var tower := TowerController.new()
	tower.global_position = Vector2(200.0, 200.0)
	manager.towers.append(tower)
	var ctrl := KavusFollyController.new()
	add_child_autofree(ctrl)
	ctrl.context = ctx
	ctrl._apply_blast_damage(Vector2(200.0, 200.0))
	assert_eq(manager.towers.size(), 0)


func test_strike_timer_only_runs_during_wave_active() -> void:
	var state := BattleStateController.new()
	add_child_autofree(state)
	var ctx := BattleContext.new()
	ctx.state_controller = state
	state.initialize(ctx)
	state.current_state = GameEnums.BattleState.PAUSED
	var ctrl := KavusFollyController.new()
	add_child_autofree(ctrl)
	ctrl.initialize(ctx)
	ctrl._strike_timer = 0.1
	await get_tree().create_timer(0.2).timeout
	assert_almost_eq(ctrl._strike_timer, 0.1, 0.05)
