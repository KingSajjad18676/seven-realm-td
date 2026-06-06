class_name MapEditorCanvas
extends Node2D

signal geometry_changed
signal cursor_moved(world_pos: Vector2)
signal routes_changed

enum Tool { ROAD, SPAWN, GATE, SELECT }

const SPAWN_COLOR := Color(0.9, 0.25, 0.2, 0.95)
const GATE_COLOR := Color(0.85, 0.75, 0.35, 0.95)
const PATH_WIDTH := 12.0

var path_routes: Array[Dictionary] = []
var spawn_points: Array[Dictionary] = []
var build_spot_positions: Array[Vector2] = []
var gate_position: Vector2 = Vector2.ZERO
var region_ids: Array[String] = []
var map_sprite_path: String = ""

var active_tool: Tool = Tool.ROAD
var active_route_index: int = 0
var spawn_route_id: String = LevelData.PRIMARY_ROUTE_ID
var snap_enabled: bool = true
var grid_size: int = 10
var input_blocked: bool = false

var _background: Sprite2D = null
var _route_lines: Array[Line2D] = []
var _routes_root: Node2D = null
var _drag_kind: String = ""
var _drag_index: int = -1
var _drag_route_index: int = -1


func _ready() -> void:
	_routes_root = Node2D.new()
	_routes_root.name = "RouteLines"
	add_child(_routes_root)
	set_process_unhandled_input(true)


func load_geometry(state: Dictionary) -> void:
	path_routes.clear()
	for entry in state.get("path_routes", []):
		if entry is Dictionary:
			path_routes.append(entry)
	spawn_points.clear()
	for entry in state.get("spawn_points", []):
		if entry is Dictionary:
			spawn_points.append(entry)
	if path_routes.is_empty() and state.has("path_points"):
		var legacy_points: Array = state.get("path_points", [])
		if not legacy_points.is_empty():
			path_routes.append({
				"route_id": LevelData.PRIMARY_ROUTE_ID,
				"points": legacy_points.duplicate(),
			})
	if spawn_points.is_empty() and state.get("spawn_position", Vector2.ZERO) != Vector2.ZERO:
		spawn_points.append({
			"spawn_id": LevelData.PRIMARY_SPAWN_ID,
			"position": state.get("spawn_position", Vector2.ZERO),
			"route_id": _route_id_at(0),
		})
	build_spot_positions.clear()
	gate_position = state.get("gate_position", Vector2.ZERO)
	region_ids = state.get("region_ids", [])
	map_sprite_path = state.get("map_sprite_path", "")
	active_route_index = clampi(active_route_index, 0, maxi(path_routes.size() - 1, 0))
	if path_routes.is_empty():
		add_route(LevelData.PRIMARY_ROUTE_ID)
	spawn_route_id = _route_id_at(active_route_index)
	_refresh_background()
	_refresh_route_lines()
	queue_redraw()


func get_geometry_state() -> Dictionary:
	return {
		"path_routes": _duplicate_routes(),
		"spawn_points": _duplicate_spawns(),
		"path_points": _active_route_points().duplicate(),
		"build_spot_positions": [],
		"spawn_position": _primary_spawn_position(),
		"gate_position": gate_position,
		"region_ids": region_ids.duplicate(),
		"map_sprite_path": map_sprite_path,
	}


func set_map_sprite_path(sprite_path: String) -> void:
	map_sprite_path = sprite_path
	_refresh_background()


func get_active_route_id() -> String:
	return _route_id_at(active_route_index)


func set_active_route_index(index: int) -> void:
	if path_routes.is_empty():
		return
	active_route_index = clampi(index, 0, path_routes.size() - 1)
	spawn_route_id = _route_id_at(active_route_index)
	queue_redraw()


func add_route(route_id: String = "") -> void:
	var id := route_id if route_id != "" else MapEditorUtils.next_route_id(path_routes)
	path_routes.append({"route_id": id, "points": []})
	active_route_index = path_routes.size() - 1
	spawn_route_id = id
	_refresh_route_lines()
	queue_redraw()
	geometry_changed.emit()
	routes_changed.emit()


func delete_active_route() -> bool:
	if path_routes.size() <= 1:
		return false
	var removed_id := _route_id_at(active_route_index)
	path_routes.remove_at(active_route_index)
	active_route_index = clampi(active_route_index, 0, path_routes.size() - 1)
	spawn_route_id = _route_id_at(active_route_index)
	for spawn in spawn_points:
		if spawn.get("route_id", "") == removed_id:
			spawn["route_id"] = _route_id_at(active_route_index)
	_refresh_route_lines()
	queue_redraw()
	geometry_changed.emit()
	routes_changed.emit()
	return true


func clear_active_tool_data() -> void:
	match active_tool:
		Tool.ROAD:
			if active_route_index >= 0 and active_route_index < path_routes.size():
				path_routes[active_route_index]["points"] = []
		Tool.SPAWN:
			spawn_points.clear()
		Tool.GATE:
			gate_position = Vector2.ZERO
	_refresh_route_lines()
	queue_redraw()
	geometry_changed.emit()


func _refresh_background() -> void:
	if _background:
		_background.queue_free()
		_background = null
	if map_sprite_path == "":
		queue_redraw()
		return
	_background = MapEditorUtils.build_background_sprite(map_sprite_path)
	add_child(_background)
	move_child(_background, 0)
	queue_redraw()


func _refresh_route_lines() -> void:
	for line in _route_lines:
		line.queue_free()
	_route_lines.clear()
	for i in path_routes.size():
		var line := Line2D.new()
		line.name = "RouteLine_%d" % i
		line.width = PATH_WIDTH
		line.default_color = MapEditorUtils.route_color(i)
		line.z_index = -1
		var points: Array = path_routes[i].get("points", [])
		line.points = PackedVector2Array(points)
		_routes_root.add_child(line)
		_route_lines.append(line)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		_handle_mouse_button(event as InputEventMouseButton)
	elif event is InputEventMouseMotion:
		_handle_mouse_motion(event as InputEventMouseMotion)


func _handle_mouse_button(event: InputEventMouseButton) -> void:
	if input_blocked:
		return
	var local := get_local_mouse_position()
	var world := MapEditorUtils.snap_point(local, grid_size, snap_enabled)
	if event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_on_left_press(world)
		else:
			_end_drag()
	elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		_on_right_press(world)


func _handle_mouse_motion(event: InputEventMouseMotion) -> void:
	var local := get_local_mouse_position()
	cursor_moved.emit(local)
	if input_blocked:
		return
	if _drag_kind == "":
		return
	var world := MapEditorUtils.snap_point(local, grid_size, snap_enabled)
	match _drag_kind:
		"path":
			if _drag_route_index >= 0 and _drag_route_index < path_routes.size():
				var points: Array = path_routes[_drag_route_index].get("points", [])
				if _drag_index >= 0 and _drag_index < points.size():
					points[_drag_index] = world
					path_routes[_drag_route_index]["points"] = points
					_refresh_route_lines()
					queue_redraw()
					geometry_changed.emit()
		"spawn":
			if _drag_index >= 0 and _drag_index < spawn_points.size():
				spawn_points[_drag_index]["position"] = world
				queue_redraw()
				geometry_changed.emit()


func _on_left_press(world: Vector2) -> void:
	match active_tool:
		Tool.ROAD:
			var hit := _hit_path_point(world)
			if hit.x >= 0:
				_drag_kind = "path"
				_drag_route_index = hit.x
				_drag_index = hit.y
			else:
				var points: Array = path_routes[active_route_index].get("points", [])
				points.append(world)
				path_routes[active_route_index]["points"] = points
				_refresh_route_lines()
				queue_redraw()
				geometry_changed.emit()
		Tool.SPAWN:
			spawn_points.append({
				"spawn_id": MapEditorUtils.next_spawn_id(spawn_points),
				"position": world,
				"route_id": spawn_route_id,
			})
			queue_redraw()
			geometry_changed.emit()
		Tool.GATE:
			gate_position = world
			queue_redraw()
			geometry_changed.emit()
		Tool.SELECT:
			var path_hit := _hit_path_point(world)
			if path_hit.x >= 0:
				_drag_kind = "path"
				_drag_route_index = path_hit.x
				_drag_index = path_hit.y
				return
			var spawn_hit := _hit_spawn(world)
			if spawn_hit >= 0:
				_drag_kind = "spawn"
				_drag_index = spawn_hit
				return

func _on_right_press(world: Vector2) -> void:
	match active_tool:
		Tool.ROAD:
			_delete_path_point(world, active_route_index)
		Tool.SPAWN:
			_delete_spawn(world)
		Tool.SELECT:
			if not _delete_path_point(world):
				_delete_spawn(world)


func _delete_path_point(world: Vector2, route_index: int = -1) -> bool:
	var hit := _hit_path_point(world, route_index)
	if hit.x < 0:
		return false
	var points: Array = path_routes[hit.x].get("points", [])
	if hit.y >= 0 and hit.y < points.size():
		points.remove_at(hit.y)
		path_routes[hit.x]["points"] = points
		_refresh_route_lines()
		queue_redraw()
		geometry_changed.emit()
		return true
	return false


func _delete_spawn(world: Vector2) -> bool:
	var spawn_hit := _hit_spawn(world)
	if spawn_hit >= 0:
		spawn_points.remove_at(spawn_hit)
		queue_redraw()
		geometry_changed.emit()
		return true
	return false


func _end_drag() -> void:
	_drag_kind = ""
	_drag_index = -1
	_drag_route_index = -1


func _hit_path_point(world: Vector2, route_index: int = -1) -> Vector2i:
	var start := 0
	var end := path_routes.size() - 1
	if route_index >= 0:
		start = route_index
		end = route_index
	for ri in range(start, end + 1):
		var points: Array = path_routes[ri].get("points", [])
		for pi in points.size():
			if world.distance_to(points[pi]) <= MapEditorUtils.HANDLE_RADIUS + 4.0:
				return Vector2i(ri, pi)
	return Vector2i(-1, -1)


func _hit_spawn(world: Vector2) -> int:
	for i in spawn_points.size():
		var pos: Vector2 = spawn_points[i].get("position", Vector2.ZERO)
		if world.distance_to(pos) <= 24.0:
			return i
	return -1


func _draw() -> void:
	if _background == null:
		draw_rect(Rect2(Vector2.ZERO, MapEditorUtils.VIEW_SIZE), Color(0.15, 0.22, 0.14, 1.0))
		draw_rect(Rect2(Vector2.ZERO, MapEditorUtils.VIEW_SIZE), Color(1, 1, 1, 0.08), false, 2.0)

	if snap_enabled and grid_size > 0:
		var grid_color := Color(1, 1, 1, 0.05)
		for x in range(0, int(MapEditorUtils.VIEW_SIZE.x) + 1, grid_size):
			draw_line(Vector2(x, 0), Vector2(x, MapEditorUtils.VIEW_SIZE.y), grid_color)
		for y in range(0, int(MapEditorUtils.VIEW_SIZE.y) + 1, grid_size):
			draw_line(Vector2(0, y), Vector2(MapEditorUtils.VIEW_SIZE.x, y), grid_color)

	for ri in path_routes.size():
		var route_id: String = str(path_routes[ri].get("route_id", ""))
		var points: Array = path_routes[ri].get("points", [])
		var handle_color := MapEditorUtils.route_color(ri).lightened(0.15)
		if ri == active_route_index:
			handle_color = Color(1.0, 1.0, 1.0, 0.95)
		for pi in points.size():
			var p: Vector2 = points[pi]
			draw_circle(p, MapEditorUtils.HANDLE_RADIUS, handle_color)
			draw_string(
				ThemeDB.fallback_font,
				p + Vector2(8, -8),
				"R%d-%d" % [ri + 1, pi + 1],
				HORIZONTAL_ALIGNMENT_LEFT,
				-1,
				14,
				Color.WHITE
			)
		if points.size() >= 2:
			draw_string(
				ThemeDB.fallback_font,
				points[0] + Vector2(-8, -20),
				route_id,
				HORIZONTAL_ALIGNMENT_LEFT,
				-1,
				12,
				handle_color
			)

	for i in spawn_points.size():
		var spawn := spawn_points[i]
		var pos: Vector2 = spawn.get("position", Vector2.ZERO)
		var label := str(spawn.get("spawn_id", "spawn_%d" % (i + 1)))
		_draw_marker(pos, SPAWN_COLOR, label)

	if gate_position != Vector2.ZERO:
		_draw_marker(gate_position, GATE_COLOR, "Gate")


func _draw_marker(center: Vector2, color: Color, label: String) -> void:
	draw_rect(Rect2(center + Vector2(-20, -40), Vector2(40, 80)), color)
	draw_string(ThemeDB.fallback_font, center + Vector2(-24, -48), label, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, color.lightened(0.2))


func _region_color(region_id: String) -> Color:
	match region_id:
		"region_north":
			return Color(0.35, 0.55, 0.9, 0.55)
		"region_south":
			return Color(0.55, 0.35, 0.75, 0.55)
		"region_east":
			return Color(0.35, 0.75, 0.55, 0.55)
		"region_west":
			return Color(0.75, 0.55, 0.35, 0.55)
		_:
			return Color(0.45, 0.45, 0.45, 0.55)


func _route_id_at(index: int) -> String:
	if index < 0 or index >= path_routes.size():
		return LevelData.PRIMARY_ROUTE_ID
	var route_id: String = str(path_routes[index].get("route_id", ""))
	return route_id if route_id != "" else LevelData.PRIMARY_ROUTE_ID


func _active_route_points() -> Array[Vector2]:
	if active_route_index < 0 or active_route_index >= path_routes.size():
		return MapEditorUtils.typed_vector2_array([])
	return MapEditorUtils.typed_vector2_array(path_routes[active_route_index].get("points", []))


func _primary_spawn_position() -> Vector2:
	if spawn_points.is_empty():
		return Vector2.ZERO
	return spawn_points[0].get("position", Vector2.ZERO)


func _duplicate_routes() -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for route in path_routes:
		out.append({
			"route_id": route.get("route_id", ""),
			"points": MapEditorUtils.typed_vector2_array(route.get("points", [])).duplicate(),
		})
	return out


func _duplicate_spawns() -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for spawn in spawn_points:
		out.append({
			"spawn_id": spawn.get("spawn_id", ""),
			"position": spawn.get("position", Vector2.ZERO),
			"route_id": spawn.get("route_id", ""),
		})
	return out
