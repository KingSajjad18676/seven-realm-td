class_name MinimapController
extends Panel

const PANEL_SIZE := Vector2(168.0, 94.0)

var context: BattleContext = null
var camera: TouchCamera = null

var _world_bounds: Rect2 = Rect2()
var _route_paths: Array[PackedVector2Array] = []
var _anchors: Array[Vector2] = []


func initialize(ctx: BattleContext, cam: TouchCamera) -> void:
	context = ctx
	camera = cam
	_route_paths.clear()
	if ctx and ctx.level_data:
		var level := ctx.level_data
		level.ensure_routes_migrated()
		level.ensure_spawns_migrated()
		_world_bounds = level.minimap_bounds
		if _world_bounds.size.length_squared() <= 0.0:
			_world_bounds = MapCameraUtils.compute_world_bounds(level)
		if not level.path_routes.is_empty():
			for route in level.path_routes:
				_route_paths.append(PackedVector2Array(route.points))
		else:
			_route_paths.append(PackedVector2Array(level.path_points))
		_anchors = level.camera_anchors.duplicate()
	elif cam:
		_world_bounds = cam.get_world_bounds()
		_anchors = cam.get_anchors()
	mouse_filter = Control.MOUSE_FILTER_STOP
	gui_input.connect(_on_gui_input)
	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.08, 0.1, 0.12, 0.88))
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.45, 0.55, 0.5, 0.6), false, 2.0)
	for i in _route_paths.size():
		var route_points := _route_paths[i]
		if route_points.size() < 2:
			continue
		var mini_path: PackedVector2Array = PackedVector2Array()
		for p in route_points:
			mini_path.append(_world_to_minimap(p))
		draw_polyline(mini_path, MapEditorUtils.route_color(i), 2.0, true)
	if context and context.level_data:
		var level := context.level_data
		level.ensure_spawns_migrated()
		if not level.spawn_points.is_empty():
			for spawn in level.spawn_points:
				var spawn_pos := _world_to_minimap(spawn.position)
				draw_circle(spawn_pos, 4.0, Color(0.9, 0.25, 0.2, 0.95))
		elif level.spawn_position != Vector2.ZERO:
			var spawn := _world_to_minimap(level.spawn_position)
			draw_circle(spawn, 4.0, Color(0.9, 0.25, 0.2, 0.95))
		var gate := _world_to_minimap(level.gate_position)
		draw_circle(gate, 4.0, Color(0.85, 0.75, 0.35, 0.95))
	for i in _anchors.size():
		var anchor_pos := _world_to_minimap(_anchors[i])
		draw_circle(anchor_pos, 5.0, Color(0.35, 0.7, 0.95, 0.95))
		draw_arc(anchor_pos, 5.0, 0.0, TAU, 12, Color(0.9, 0.95, 1.0, 0.8), 1.5)
	if camera:
		var cam_rect := _world_rect_to_minimap(camera.get_visible_world_rect())
		draw_rect(cam_rect, Color(1.0, 1.0, 1.0, 0.25), false, 1.5)


func _process(_delta: float) -> void:
	if camera:
		queue_redraw()


func _on_gui_input(event: InputEvent) -> void:
	if camera == null:
		return
	var local_pos := Vector2.ZERO
	var pressed := false
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		local_pos = event.position
		pressed = true
	elif event is InputEventScreenTouch and event.pressed:
		local_pos = event.position
		pressed = true
	if not pressed:
		return
	var world := _minimap_to_world(local_pos)
	var anchor_idx := _nearest_anchor_index(world)
	if anchor_idx >= 0:
		camera.jump_to_anchor(anchor_idx)
	else:
		camera.focus_on(world)
	get_viewport().set_input_as_handled()


func _world_to_minimap(world_pos: Vector2) -> Vector2:
	if _world_bounds.size.x <= 0.0 or _world_bounds.size.y <= 0.0:
		return Vector2.ZERO
	var rel := (world_pos - _world_bounds.position) / _world_bounds.size
	return rel * size


func _minimap_to_world(local_pos: Vector2) -> Vector2:
	if size.x <= 0.0 or size.y <= 0.0:
		return _world_bounds.get_center()
	var rel := local_pos / size
	return _world_bounds.position + rel * _world_bounds.size


func _world_rect_to_minimap(world_rect: Rect2) -> Rect2:
	var top_left := _world_to_minimap(world_rect.position)
	var bottom_right := _world_to_minimap(world_rect.end)
	return Rect2(top_left, bottom_right - top_left)


func _nearest_anchor_index(world_pos: Vector2) -> int:
	if _anchors.is_empty() or _world_bounds.size.length_squared() <= 0.0:
		return -1
	var best_idx := -1
	var best_dist := _world_bounds.size.length() * 0.12
	for i in _anchors.size():
		var dist := world_pos.distance_to(_anchors[i])
		if dist <= best_dist:
			best_dist = dist
			best_idx = i
	return best_idx
