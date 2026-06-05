extends GutTest

var _camera: TouchCamera


func before_each() -> void:
	_camera = TouchCamera.new()
	add_child_autofree(_camera)
	await get_tree().process_frame


func test_configure_from_level_sets_bounds_and_anchor() -> void:
	var level := LevelData.new()
	level.grid_width = 32
	level.grid_height = 18
	level.path_points = [Vector2(80, 360), Vector2(1180, 360)]
	level.build_spot_positions = [Vector2(400, 300)]
	level.spawn_position = Vector2(80, 360)
	level.gate_position = Vector2(1180, 360)
	level.camera_anchors = [Vector2(500, 320), Vector2(900, 360)]
	level.minimap_bounds = MapCameraUtils.compute_world_bounds(level)
	_camera.configure_from_level(level)
	assert_eq(_camera.global_position, Vector2(500, 320))
	assert_gt(_camera.get_world_bounds().size.x, 0.0)


func test_zoom_clamps_between_min_and_max() -> void:
	var level := _sample_level()
	_camera.configure_from_level(level)
	_camera._apply_zoom_at(Vector2(640, 360), 10.0)
	assert_lte(_camera.zoom.x, _camera.max_zoom)
	_camera._apply_zoom_at(Vector2(640, 360), 0.01)
	assert_gte(_camera.zoom.x, _camera.min_zoom)


func test_should_block_battlefield_tap_when_multi_touch() -> void:
	assert_false(_camera.should_block_battlefield_tap())
	_camera._touch_count = 2
	assert_true(_camera.should_block_battlefield_tap())


func test_should_block_battlefield_tap_after_pan() -> void:
	_camera._pan_moved = true
	assert_true(_camera.should_block_battlefield_tap())


func test_jump_to_anchor_moves_camera() -> void:
	var level := _sample_level()
	_camera.configure_from_level(level)
	_camera.jump_to_anchor(1, true)
	assert_eq(_camera.global_position, level.camera_anchors[1])


func test_is_world_visible_for_center_position() -> void:
	var level := _sample_level()
	_camera.configure_from_level(level)
	assert_true(_camera.is_world_visible(_camera.global_position))
	assert_false(_camera.is_world_visible(Vector2(-500, -500)))


func _sample_level() -> LevelData:
	var level := LevelData.new()
	level.grid_width = 40
	level.grid_height = 22
	level.uses_large_map_camera = true
	level.path_points = [Vector2(80, 200), Vector2(1200, 360)]
	level.build_spot_positions = [Vector2(500, 300)]
	level.spawn_position = Vector2(80, 200)
	level.gate_position = Vector2(1200, 360)
	level.camera_anchors = [Vector2(640, 360), Vector2(900, 400)]
	level.minimap_bounds = MapCameraUtils.compute_world_bounds(level)
	return level
