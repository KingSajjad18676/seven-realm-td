extends GutTest

var _manager: TowerManager
var _ctx: BattleContext


func before_each() -> void:
	_ctx = BattleTestFixtures.context_with_level(self)
	BattleTestFixtures.attach_economy(self, _ctx)
	_manager = TowerManager.new()
	add_child_autofree(_manager)
	var spots: Array[BuildSpot] = []
	var spot := preload("res://scenes/prefabs/build_spot.tscn").instantiate() as BuildSpot
	add_child_autofree(spot)
	spot.global_position = Vector2(200, 300)
	spots.append(spot)
	_manager.initialize(_ctx, spots, Node2D.new(), Node2D.new())


func test_find_spot_at_any_includes_occupied() -> void:
	_manager.build_spots[0].occupied = true
	var found := _manager.find_spot_at_any(Vector2(200, 300))
	assert_eq(found, _manager.build_spots[0])


func test_try_select_spot_at_world_emits_radial_for_empty_pad() -> void:
	var requested := false
	_manager.build_radial_requested.connect(func(_s: BuildSpot) -> void:
		requested = true
	)
	assert_true(_manager.try_select_spot_at_world(Vector2(200, 300)))
	assert_true(requested)
