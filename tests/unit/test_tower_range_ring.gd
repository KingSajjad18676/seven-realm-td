extends GutTest

const BUILD_SPOT_SCENE := preload("res://scenes/prefabs/build_spot.tscn")
const TOWER_SCENE := preload("res://scenes/prefabs/tower.tscn")


func before_each() -> void:
	SaveSystem.test_reset_to_defaults()


func test_compute_preview_range_archer_levels() -> void:
	var ctx := BattleTestFixtures.minimal_context(self)
	var td := ContentRegistry.get_tower("tower_archer")
	assert_not_null(td)
	var r1 := TowerController.compute_preview_range(ctx, td, "region_north", 1)
	var r2 := TowerController.compute_preview_range(ctx, td, "region_north", 2)
	assert_almost_eq(r1, 150.0, 0.01)
	assert_almost_eq(r2, 165.0, 0.01)


func test_compute_preview_range_barracks_is_zero() -> void:
	var ctx := BattleTestFixtures.minimal_context(self)
	var td := ContentRegistry.get_tower("tower_rostam_barracks")
	assert_not_null(td)
	assert_eq(TowerController.compute_preview_range(ctx, td, "region_north", 1), 0.0)


func test_get_effective_range_increases_on_upgrade() -> void:
	var ctx := BattleTestFixtures.minimal_context(self)
	var spot := BUILD_SPOT_SCENE.instantiate() as BuildSpot
	add_child_autofree(spot)
	spot.region_id = "region_north"
	var tower := TOWER_SCENE.instantiate() as TowerController
	add_child_autofree(tower)
	var td := ContentRegistry.get_tower("tower_archer")
	tower.initialize(ctx, td, spot)
	tower._efficiency = 1.0
	tower._forge_range_mult = 1.0
	var before := tower.get_effective_range()
	tower.level = 2
	var after := tower.get_effective_range()
	assert_almost_eq(before, 150.0, 0.01)
	assert_almost_eq(after, 165.0, 0.01)


func test_range_ring_hides_when_radius_zero() -> void:
	var ring := TowerRangeRing.new()
	add_child_autofree(ring)
	ring.show_at(Vector2(100, 100), 120.0)
	assert_true(ring.is_showing())
	ring.show_at(Vector2(100, 100), 0.0)
	assert_false(ring.is_showing())


func test_radial_shows_manage_range_ring() -> void:
	var layer := CanvasLayer.new()
	add_child_autofree(layer)
	var camera := Camera2D.new()
	camera.global_position = Vector2(640, 360)
	add_child_autofree(camera)
	var spot := BUILD_SPOT_SCENE.instantiate() as BuildSpot
	add_child_autofree(spot)
	spot.global_position = Vector2(400, 300)
	var ctx := BattleTestFixtures.context_with_level(self, 200, 5)
	var level := ContentRegistry.get_level("level_01")
	ctx.level_data = level
	BattleTestFixtures.attach_economy(self, ctx)
	var ring := TowerRangeRing.new()
	add_child_autofree(ring)
	var radial := TowerRadialBuildController.new()
	layer.add_child(radial)
	radial.initialize(ctx, camera)
	radial.set_range_ring(ring)
	var tower := TOWER_SCENE.instantiate() as TowerController
	add_child_autofree(tower)
	var td := ContentRegistry.get_tower("tower_archer")
	tower.initialize(ctx, td, spot)
	tower._efficiency = 1.0
	tower._forge_range_mult = 1.0
	spot.set_occupied(tower)
	radial.show_for_occupied_spot(spot)
	await get_tree().process_frame
	assert_true(ring.is_showing())
	assert_almost_eq(ring.get_radius(), 150.0, 0.01)
	radial.hide_menu()
	assert_false(ring.is_showing())
