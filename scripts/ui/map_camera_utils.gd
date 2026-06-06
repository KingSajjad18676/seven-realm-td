class_name MapCameraUtils
extends RefCounted

const VIEWPORT_SIZE := Vector2(1280.0, 720.0)
const BASE_GRID := Vector2(32.0, 18.0)


static func compute_world_bounds(level: LevelData) -> Rect2:
	if level == null:
		return Rect2(Vector2.ZERO, VIEWPORT_SIZE)
	level.ensure_routes_migrated()
	level.ensure_spawns_migrated()
	var points: Array[Vector2] = []
	points.append_array(level.get_all_route_points())
	for spawn in level.spawn_points:
		points.append(spawn.position)
	if level.spawn_position != Vector2.ZERO and level.spawn_points.is_empty():
		points.append(level.spawn_position)
	if level.gate_position != Vector2.ZERO:
		points.append(level.gate_position)
	for anchor in level.camera_anchors:
		points.append(anchor)
	if points.is_empty():
		return Rect2(Vector2.ZERO, VIEWPORT_SIZE)
	var min_p := Vector2(INF, INF)
	var max_p := Vector2(-INF, -INF)
	for p in points:
		min_p.x = minf(min_p.x, p.x)
		min_p.y = minf(min_p.y, p.y)
		max_p.x = maxf(max_p.x, p.x)
		max_p.y = maxf(max_p.y, p.y)
	var padding := 120.0 if level.uses_large_map_camera else 80.0
	if level.uses_large_map_camera:
		var tile_size := VIEWPORT_SIZE / BASE_GRID
		var grid_extent := Vector2(level.grid_width, level.grid_height) * tile_size
		max_p.x = maxf(max_p.x, grid_extent.x)
		max_p.y = maxf(max_p.y, grid_extent.y)
	var size := max_p - min_p + Vector2(padding * 2.0, padding * 2.0)
	size.x = maxf(size.x, VIEWPORT_SIZE.x)
	size.y = maxf(size.y, VIEWPORT_SIZE.y)
	return Rect2(min_p - Vector2(padding, padding), size)


static func camera_center_limits(world_bounds: Rect2, zoom: float, viewport: Vector2 = VIEWPORT_SIZE) -> Dictionary:
	var half := viewport / (2.0 * zoom)
	var min_center := world_bounds.position + half
	var max_center := world_bounds.end - half
	if min_center.x > max_center.x:
		var mid_x := world_bounds.position.x + world_bounds.size.x * 0.5
		min_center.x = mid_x
		max_center.x = mid_x
	if min_center.y > max_center.y:
		var mid_y := world_bounds.position.y + world_bounds.size.y * 0.5
		min_center.y = mid_y
		max_center.y = mid_y
	return {"min": min_center, "max": max_center}


static func clamp_camera_center(center: Vector2, world_bounds: Rect2, zoom: float, viewport: Vector2 = VIEWPORT_SIZE) -> Vector2:
	var limits := camera_center_limits(world_bounds, zoom, viewport)
	return Vector2(
		clampf(center.x, limits.min.x, limits.max.x),
		clampf(center.y, limits.min.y, limits.max.y)
	)


static func compute_battle_view_bounds(level: LevelData) -> Rect2:
	if level == null:
		return Rect2(Vector2.ZERO, VIEWPORT_SIZE)
	if not level.uses_large_map_camera:
		return Rect2(Vector2.ZERO, VIEWPORT_SIZE)
	return compute_world_bounds(level)


static func compute_fit_to_view(world_bounds: Rect2, viewport: Vector2 = VIEWPORT_SIZE) -> Dictionary:
	if world_bounds.size.x <= 0.0 or world_bounds.size.y <= 0.0:
		return {"center": viewport * 0.5, "zoom": 1.0}
	var fit_zoom := minf(viewport.x / world_bounds.size.x, viewport.y / world_bounds.size.y)
	return {"center": world_bounds.get_center(), "zoom": fit_zoom}
