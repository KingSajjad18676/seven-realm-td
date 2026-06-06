extends GutTest

var _level: LevelData = null


func before_each() -> void:
	_level = LevelData.new()
	_level.minimap_bounds = Rect2(0, 0, 1280, 720)
	_level.region_ids = ["region_north"]
	var route := PathRouteData.new()
	route.route_id = "route_main"
	route.points = [Vector2(100, 360), Vector2(600, 360), Vector2(1100, 360)]
	_level.path_routes.append(route)


func test_rejects_position_on_road() -> void:
	var pos := Vector2(600, 360)
	assert_false(TowerPlacementValidator.is_valid(pos, _level, []))


func test_accepts_position_beside_road() -> void:
	var pos := Vector2(600, 300)
	assert_true(TowerPlacementValidator.is_valid(pos, _level, []))


func test_rejects_too_far_from_road() -> void:
	var pos := Vector2(600, 200)
	assert_false(TowerPlacementValidator.is_valid(pos, _level, []))


func test_rejects_overlapping_towers() -> void:
	var pos_a := Vector2(400, 300)
	var pos_b := Vector2(420, 300)
	var tower := TowerController.new()
	tower.global_position = pos_a
	assert_false(TowerPlacementValidator.is_valid(pos_b, _level, [tower]))
