extends GutTest


func test_drag_threshold_distinguishes_tap_from_drag() -> void:
	var start := Vector2(100, 100)
	var tap_end := Vector2(105, 108)
	var drag_end := Vector2(130, 100)
	assert_lt(tap_end.distance_to(start), TouchCamera.DRAG_THRESHOLD)
	assert_gte(drag_end.distance_to(start), TouchCamera.DRAG_THRESHOLD)


func test_should_block_pan_gesture_on_large_map() -> void:
	var camera := TouchCamera.new()
	add_child_autofree(camera)
	await get_tree().process_frame
	var level := LevelData.new()
	level.uses_large_map_camera = true
	level.path_points = [Vector2(80, 200), Vector2(1200, 360)]
	level.build_spot_positions = [Vector2(500, 300)]
	level.minimap_bounds = MapCameraUtils.compute_world_bounds(level)
	camera.configure_from_level(level)
	camera._pan_moved = true
	assert_true(camera.should_block_battlefield_tap())
