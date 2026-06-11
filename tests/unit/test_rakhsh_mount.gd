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
