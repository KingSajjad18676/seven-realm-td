extends GutTest


func test_mount_and_dismount() -> void:
	var mount := RakhshMountController.new()
	mount.mounted = true
	assert_true(mount.is_mounted())
	assert_eq(mount.get_speed_mult(), 2.2)
	mount.dismount()
	assert_false(mount.is_mounted())
	assert_eq(mount.get_speed_mult(), 1.0)


func test_hero_blocks_tether_while_mounted() -> void:
	var hero := HeroController.new()
	var ctx := BattleContext.new()
	var mount := RakhshMountController.new()
	mount.mounted = true
	ctx.rakhsh_mount = mount
	hero.context = ctx
	hero.data = HeroData.new()
	hero.data.tether_radius = 200.0
	var tower := TowerController.new()
	tower.global_position = Vector2.ZERO
	hero.global_position = Vector2(10, 0)
	hero.tether_to_tower(tower)
	assert_null(hero.tethered_tower)
	assert_false(mount.is_mounted())


func test_mount_requires_proximity() -> void:
	var mount := RakhshMountController.new()
	var hero := HeroController.new()
	var root := Node2D.new()
	add_child_autofree(root)
	root.add_child(hero)
	var ctx := BattleTestFixtures.minimal_context(self)
	var state := BattleStateController.new()
	add_child_autofree(state)
	state.initialize(ctx)
	ctx.state_controller = state
	state.start_battle()
	mount.context = ctx
	mount.hero = hero
	var entity := CompanionEntity.new()
	root.add_child(entity)
	mount._entity = entity
	hero.global_position = Vector2(0, 0)
	entity.global_position = Vector2(200, 0)
	assert_false(mount.is_within_mount_range())
	assert_false(mount.mount())
	entity.global_position = Vector2(20, 0)
	assert_true(mount.is_within_mount_range())
	assert_true(mount.mount())


func test_dismount_leaves_rakhsh_in_place() -> void:
	var mount := RakhshMountController.new()
	var hero := HeroController.new()
	var root := Node2D.new()
	add_child_autofree(root)
	root.add_child(hero)
	var ctx := BattleTestFixtures.minimal_context(self)
	var state := BattleStateController.new()
	add_child_autofree(state)
	state.initialize(ctx)
	ctx.state_controller = state
	state.start_battle()
	mount.context = ctx
	mount.hero = hero
	var entity := CompanionEntity.new()
	root.add_child(entity)
	mount._entity = entity
	hero.global_position = Vector2(100, 80)
	entity.global_position = hero.global_position + Vector2(10, 0)
	mount.mounted = true
	hero.global_position = Vector2(300, 200)
	mount.dismount()
	var parked := entity.global_position
	hero.global_position = Vector2(500, 500)
	await get_tree().process_frame
	assert_false(mount.is_mounted())
	assert_eq(entity.global_position, parked)
