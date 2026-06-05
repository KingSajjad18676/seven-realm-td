extends GutTest


func test_compute_world_bounds_from_path_and_pads() -> void:
	var level := LevelData.new()
	level.grid_width = 32
	level.grid_height = 18
	level.path_points = [
		Vector2(80, 360), Vector2(640, 260), Vector2(1180, 360),
	]
	level.build_spot_positions = [Vector2(320, 300), Vector2(700, 300)]
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
	level.build_spot_positions = [Vector2(500, 300)]
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
