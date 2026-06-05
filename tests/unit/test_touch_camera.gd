extends GutTest

var _camera: TouchCamera


func before_each() -> void:
	_camera = TouchCamera.new()
	add_child_autofree(_camera)
	await get_tree().process_frame


func test_configure_from_level_uses_fit_center_for_medium_maps() -> void:
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
	var fit := MapCameraUtils.compute_fit_to_view(MapCameraUtils.compute_battle_view_bounds(level))
	assert_eq(_camera.global_position, fit.center)
	assert_true(_camera.is_camera_locked())
	assert_gt(_camera.get_world_bounds().size.x, 0.0)


func test_zoom_clamps_between_min_and_max() -> void:
	var level := _sample_level()
	_camera.configure_from_level(level)
	_camera._apply_zoom_at(Vector2(640, 360), 10.0)
	assert_lte(_camera.zoom.x, _camera.max_zoom)
	_camera._apply_zoom_at(Vector2(640, 360), 0.01)
	assert_gte(_camera.zoom.x, _camera.min_zoom)


func test_should_block_battlefield_tap_when_multi_touch_on_large_map() -> void:
	var level := _sample_level()
	_camera.configure_from_level(level)
	assert_false(_camera.should_block_battlefield_tap())
	_camera._touch_count = 2
	assert_true(_camera.should_block_battlefield_tap())


func test_pan_moved_does_not_block_tap_when_camera_locked() -> void:
	var level := LevelData.new()
	level.path_points = [Vector2(80, 360), Vector2(1180, 360)]
	level.minimap_bounds = MapCameraUtils.compute_world_bounds(level)
	_camera.configure_from_level(level)
	_camera._pan_moved = true
	assert_false(_camera.should_block_battlefield_tap())


func test_should_block_multi_touch_when_camera_locked() -> void:
	var level := LevelData.new()
	level.path_points = [Vector2(80, 360), Vector2(1180, 360)]
	_camera.configure_from_level(level)
	assert_true(_camera.is_camera_locked())
	_camera._touch_count = 2
	assert_true(_camera.should_block_battlefield_tap())


func test_should_block_pinch_when_camera_locked() -> void:
	var level := LevelData.new()
	level.path_points = [Vector2(80, 360), Vector2(1180, 360)]
	_camera.configure_from_level(level)
	_camera._pinch_active = true
	assert_true(_camera.should_block_battlefield_tap())


func test_magnify_gesture_zooms_locked_camera() -> void:
	var level := LevelData.new()
	level.path_points = [Vector2(80, 360), Vector2(1180, 360)]
	_camera.configure_from_level(level)
	assert_true(_camera.is_camera_locked())
	var start_z := _camera.zoom.x
	var ev := InputEventMagnifyGesture.new()
	ev.factor = 1.15
	ev.position = Vector2(640, 360)
	_camera._unhandled_input(ev)
	assert_gt(_camera.zoom.x, start_z)


func test_screen_touch_tracks_count_when_camera_locked() -> void:
	var level := LevelData.new()
	level.path_points = [Vector2(80, 360), Vector2(1180, 360)]
	_camera.configure_from_level(level)
	var press := InputEventScreenTouch.new()
	press.pressed = true
	press.position = Vector2(100, 100)
	_camera._unhandled_input(press)
	assert_eq(_camera.get_touch_count(), 1)
	var second := InputEventScreenTouch.new()
	second.pressed = true
	second.position = Vector2(200, 200)
	second.index = 1
	_camera._unhandled_input(second)
	assert_eq(_camera.get_touch_count(), 2)
	assert_true(_camera.should_block_battlefield_tap())


func test_locked_camera_can_zoom_in_when_apply_zoom() -> void:
	var level := LevelData.new()
	level.path_points = [Vector2(80, 360), Vector2(1180, 360)]
	_camera.configure_from_level(level)
	assert_true(_camera.is_camera_locked())
	var start_z := _camera.zoom.x
	_camera._apply_zoom_at(Vector2(640, 360), 1.1)
	assert_gt(_camera.zoom.x, start_z)
	assert_lte(_camera.zoom.x, _camera.max_zoom)


func test_jump_to_anchor_moves_camera_on_large_map() -> void:
	var level := _sample_level()
	_camera.configure_from_level(level)
	_camera.jump_to_anchor(1, true)
	assert_eq(_camera.global_position, level.camera_anchors[1])


func test_jump_to_anchor_ignored_when_camera_locked() -> void:
	var level := LevelData.new()
	level.path_points = [Vector2(80, 360), Vector2(1180, 360)]
	level.camera_anchors = [Vector2(500, 320), Vector2(900, 360)]
	level.minimap_bounds = MapCameraUtils.compute_world_bounds(level)
	_camera.configure_from_level(level)
	var start := _camera.global_position
	_camera.jump_to_anchor(1, true)
	assert_eq(_camera.global_position, start)


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
