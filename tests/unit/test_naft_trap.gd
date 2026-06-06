extends GutTest


const TEST_PATH := PackedVector2Array([Vector2(0.0, 0.0), Vector2(400.0, 0.0), Vector2(800.0, 0.0)])


func _make_hero_data() -> HeroData:
	var data := HeroData.new()
	data.hero_id = "rostam"
	data.secondary_skill_id = "rostam_naft"
	data.naft_max_charges = 2
	data.naft_refill_sec = 20.0
	data.naft_max_active = 2
	data.naft_slick_half_length = 70.0
	data.naft_slow_mult = 0.35
	data.naft_oil_duration_sec = 35.0
	data.naft_blaze_duration_sec = 3.5
	data.naft_blaze_burst_damage = 40.0
	data.naft_blaze_dps = 22.0
	return data


func _make_context() -> BattleContext:
	var ctx := BattleContext.new()
	var level := LevelData.new()
	level.path_points = Array(TEST_PATH)
	level.ensure_routes_migrated()
	ctx.level_data = level
	ctx.path_points = level.get_route()
	ctx.state_controller = BattleStateController.new()
	add_child_autofree(ctx.state_controller)
	ctx.state_controller.initialize(ctx)
	ctx.state_controller.current_state = GameEnums.BattleState.WAVE_ACTIVE
	return ctx


func _make_controller(ctx: BattleContext) -> NaftTrapController:
	var root := Node2D.new()
	add_child_autofree(root)
	var ctrl := NaftTrapController.new()
	add_child_autofree(ctrl)
	ctrl.initialize(ctx, root)
	ctrl._hero_data = _make_hero_data()
	ctrl._charges = 2.0
	return ctrl


func _make_enemy(ctx: BattleContext, path_dist: float) -> EnemyController:
	var enemy := EnemyController.new()
	var data := EnemyData.new()
	data.max_hp = 100.0
	data.move_speed = 60.0
	enemy.initialize(ctx, data, TEST_PATH, LevelData.PRIMARY_ROUTE_ID)
	enemy._follower.progress_distance = path_dist
	ctx.active_enemies.append(enemy)
	return enemy


func test_snap_accepts_on_path_tap() -> void:
	var ctx := _make_context()
	var ctrl := _make_controller(ctx)
	var snap := ctrl._snap_on_path(TEST_PATH, Vector2(200.0, 5.0), LevelData.PRIMARY_ROUTE_ID)
	assert_lt(float(snap.get("dist_sq", INF)), NaftTrapController.SNAP_RADIUS * NaftTrapController.SNAP_RADIUS)


func test_snap_rejects_off_path_tap() -> void:
	var ctx := _make_context()
	var ctrl := _make_controller(ctx)
	var snap := ctrl._snap_to_path(Vector2(200.0, 200.0))
	assert_true(snap.is_empty())


func test_placement_consumes_charge_and_disarms() -> void:
	var ctx := _make_context()
	var ctrl := _make_controller(ctx)
	ctrl._armed = true
	assert_true(ctrl.try_place_at(Vector2(200.0, 0.0)))
	assert_eq(ctrl.get_charges(), 1)
	assert_false(ctrl.is_armed())
	assert_eq(ctrl._slicks.size(), 1)


func test_refill_restores_charge_over_time() -> void:
	var ctx := _make_context()
	var ctrl := _make_controller(ctx)
	ctrl._charges = 0.0
	ctrl._refill_bank = 0.0
	ctrl._refill_charges(20.0)
	assert_eq(ctrl.get_charges(), 1)


func test_enemy_in_oil_gets_heavy_slow() -> void:
	var ctx := _make_context()
	var ctrl := _make_controller(ctx)
	var enemy := _make_enemy(ctx, 200.0)
	var slick := NaftSlick.new()
	slick.route_id = LevelData.PRIMARY_ROUTE_ID
	slick.path = TEST_PATH
	slick.center_path_dist = 200.0
	slick.half_length = 70.0
	assert_true(slick.is_enemy_inside(enemy))
	ctrl._apply_oil_slow(slick)
	assert_eq(enemy._slow_mult, 0.35)


func test_enemy_outside_oil_unaffected() -> void:
	var slick := NaftSlick.new()
	slick.route_id = LevelData.PRIMARY_ROUTE_ID
	slick.path = TEST_PATH
	slick.center_path_dist = 200.0
	slick.half_length = 70.0
	var ctx := _make_context()
	var enemy := _make_enemy(ctx, 20.0)
	assert_false(slick.is_enemy_inside(enemy))


func test_sacred_fire_ignites_oiled_segment() -> void:
	var ctx := _make_context()
	var ctrl := _make_controller(ctx)
	var enemy := _make_enemy(ctx, 200.0)
	var slick := NaftSlick.new()
	slick.route_id = LevelData.PRIMARY_ROUTE_ID
	slick.path = TEST_PATH
	slick.center_path_dist = 200.0
	slick.half_length = 70.0
	slick.state = NaftSlick.State.OIL
	slick.remaining_sec = 30.0
	ctrl._slicks.append(slick)
	var hp_before := enemy.current_hp
	var tower_data := TowerData.new()
	tower_data.tower_id = "tower_sacred_fire"
	tower_data.applies_burn = true
	tower_data.family = GameEnums.TowerFamily.SACRED_FIRE
	ctrl.try_ignite_from_fire(enemy, tower_data)
	assert_eq(slick.state, NaftSlick.State.BLAZING)
	assert_lt(enemy.current_hp, hp_before)


func test_blazing_slick_does_not_reignite() -> void:
	var ctx := _make_context()
	var ctrl := _make_controller(ctx)
	var enemy := _make_enemy(ctx, 200.0)
	var slick := NaftSlick.new()
	slick.route_id = LevelData.PRIMARY_ROUTE_ID
	slick.path = TEST_PATH
	slick.center_path_dist = 200.0
	slick.half_length = 70.0
	slick.state = NaftSlick.State.BLAZING
	slick.remaining_sec = 2.0
	ctrl._slicks.append(slick)
	var hp_before := enemy.current_hp
	var tower_data := TowerData.new()
	tower_data.applies_burn = true
	ctrl.try_ignite_from_fire(enemy, tower_data)
	assert_eq(enemy.current_hp, hp_before)


func test_non_burn_tower_does_not_ignite() -> void:
	var ctx := _make_context()
	var ctrl := _make_controller(ctx)
	var enemy := _make_enemy(ctx, 200.0)
	var slick := NaftSlick.new()
	slick.route_id = LevelData.PRIMARY_ROUTE_ID
	slick.path = TEST_PATH
	slick.center_path_dist = 200.0
	slick.half_length = 70.0
	slick.state = NaftSlick.State.OIL
	ctrl._slicks.append(slick)
	var tower_data := TowerData.new()
	tower_data.tower_id = "tower_archer"
	tower_data.applies_burn = false
	ctrl.try_ignite_from_fire(enemy, tower_data)
	assert_eq(slick.state, NaftSlick.State.OIL)
