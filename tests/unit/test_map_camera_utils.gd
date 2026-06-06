extends GutTest


func test_compute_world_bounds_from_path_and_pads() -> void:
	var level := LevelData.new()
	level.grid_width = 32
	level.grid_height = 18
	level.path_points = [
		Vector2(80, 360), Vector2(640, 260), Vector2(1180, 360),
	]
	level.spawn_position = Vector2(80, 360)
	level.gate_position = Vector2(1180, 360)
	var bounds := MapCameraUtils.compute_world_bounds(level)
	assert_true(bounds.size.x >= MapCameraUtils.VIEWPORT_SIZE.x)
	assert_true(bounds.has_point(Vector2(640, 300)))
	assert_true(bounds.has_point(Vector2(80, 360)))


func test_large_map_expands_bounds_with_grid() -> void:
	var level := LevelData.new()
	level.grid_width = 48
	level.grid_height = 27
	level.uses_large_map_camera = true
	level.path_points = [Vector2(80, 200), Vector2(1200, 360)]
	level.spawn_position = Vector2(80, 200)
	level.gate_position = Vector2(1200, 360)
	level.camera_anchors = [Vector2(640, 360), Vector2(900, 400)]
	var bounds := MapCameraUtils.compute_world_bounds(level)
	assert_gt(bounds.size.x, MapCameraUtils.VIEWPORT_SIZE.x)


func test_clamp_camera_center_stays_inside_world() -> void:
	var world := Rect2(0, 0, 1600, 900)
	var zoom := 1.0
	var clamped := MapCameraUtils.clamp_camera_center(Vector2(2000, 2000), world, zoom)
	var limits := MapCameraUtils.camera_center_limits(world, zoom)
	assert_lte(clamped.x, limits.max.x)
	assert_lte(clamped.y, limits.max.y)


func test_high_zoom_tightens_center_limits() -> void:
	var world := Rect2(0, 0, 1280, 720)
	var loose := MapCameraUtils.camera_center_limits(world, 0.65)
	var tight := MapCameraUtils.camera_center_limits(world, 1.2)
	assert_gt(loose.max.x - loose.min.x, tight.max.x - tight.min.x)


func test_compute_battle_view_bounds_uses_full_canvas_for_medium_maps() -> void:
	var level := LevelData.new()
	level.path_points = [Vector2(80, 360), Vector2(1180, 360)]
	var bounds := MapCameraUtils.compute_battle_view_bounds(level)
	assert_eq(bounds, Rect2(Vector2.ZERO, MapCameraUtils.VIEWPORT_SIZE))


func test_compute_world_bounds_includes_all_routes_and_spawns() -> void:
	var level := LevelData.new()
	var main := PathRouteData.new()
	main.route_id = "route_main"
	main.points = [Vector2(80, 360), Vector2(640, 260)]
	var short := PathRouteData.new()
	short.route_id = "route_short"
	short.points = [Vector2(80, 360), Vector2(200, 500)]
	level.path_routes = [main, short]
	var spawn := SpawnPointData.new()
	spawn.spawn_id = "spawn_main"
	spawn.position = Vector2(80, 360)
	spawn.route_id = "route_main"
	var alt := SpawnPointData.new()
	alt.spawn_id = "spawn_alt"
	alt.position = Vector2(20, 700)
	alt.route_id = "route_short"
	level.spawn_points = [spawn, alt]
	level.gate_position = Vector2(1180, 360)
	var bounds := MapCameraUtils.compute_world_bounds(level)
	assert_true(bounds.has_point(Vector2(200, 500)))
	assert_true(bounds.has_point(Vector2(20, 700)))


func test_compute_fit_to_view_fills_viewport_for_khan1_bounds() -> void:
	var bounds := Rect2(0, 0, 1280, 720)
	var fit := MapCameraUtils.compute_fit_to_view(bounds)
	assert_eq(fit.center, Vector2(640, 360))
	assert_almost_eq(fit.zoom, 1.0, 0.001)


func test_compute_fit_to_view_scales_up_for_smaller_bounds() -> void:
	var bounds := Rect2(0, 0, 640, 360)
	var fit := MapCameraUtils.compute_fit_to_view(bounds)
	assert_almost_eq(fit.zoom, 2.0, 0.001)
