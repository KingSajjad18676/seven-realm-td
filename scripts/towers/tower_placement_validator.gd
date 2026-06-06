class_name TowerPlacementValidator
extends RefCounted

const ROAD_HALF_WIDTH := 14.0
const PLACEMENT_BAND_MIN := ROAD_HALF_WIDTH + 8.0
const PLACEMENT_BAND_MAX := 96.0
const TOWER_SEPARATION := 56.0
const TOWER_RADIUS_MARGIN := 22.0


static func is_valid(
	world_pos: Vector2,
	level: LevelData,
	existing_towers: Array,
	ignore_tower: TowerController = null
) -> bool:
	if level == null:
		return false
	if not _inside_bounds(world_pos, level):
		return false
	if not _in_placement_band(world_pos, level):
		return false
	if not _clear_of_towers(world_pos, existing_towers, ignore_tower):
		return false
	return true


static func rejection_reason(
	world_pos: Vector2,
	level: LevelData,
	existing_towers: Array,
	ignore_tower: TowerController = null
) -> String:
	if level == null:
		return "Invalid level"
	if not _inside_bounds(world_pos, level):
		return "Outside build area"
	var dist := _nearest_route_distance(world_pos, level)
	if dist < PLACEMENT_BAND_MIN:
		return "Too close to the road"
	if dist > PLACEMENT_BAND_MAX:
		return "Too far from the road"
	if not _clear_of_towers(world_pos, existing_towers, ignore_tower):
		return "Too close to another tower"
	return ""


static func _inside_bounds(world_pos: Vector2, level: LevelData) -> bool:
	var bounds := level.minimap_bounds
	if bounds.size == Vector2.ZERO:
		return true
	var margin := TOWER_RADIUS_MARGIN
	return (
		world_pos.x >= bounds.position.x + margin
		and world_pos.y >= bounds.position.y + margin
		and world_pos.x <= bounds.position.x + bounds.size.x - margin
		and world_pos.y <= bounds.position.y + bounds.size.y - margin
	)


static func _in_placement_band(world_pos: Vector2, level: LevelData) -> bool:
	var dist := _nearest_route_distance(world_pos, level)
	return dist >= PLACEMENT_BAND_MIN and dist <= PLACEMENT_BAND_MAX


static func _nearest_route_distance(world_pos: Vector2, level: LevelData) -> float:
	level.ensure_routes_migrated()
	var best := INF
	for route in level.path_routes:
		var pts: Array = route.points if route.points else []
		best = minf(best, _nearest_polyline_distance(world_pos, pts))
	if best == INF and not level.path_points.is_empty():
		best = _nearest_polyline_distance(world_pos, level.path_points)
	return best


static func _nearest_polyline_distance(world_pos: Vector2, points: Array) -> float:
	if points.size() < 2:
		if points.size() == 1:
			return world_pos.distance_to(points[0])
		return INF
	var best := INF
	for i in range(points.size() - 1):
		var a: Vector2 = points[i]
		var b: Vector2 = points[i + 1]
		best = minf(best, _point_segment_distance(world_pos, a, b))
	return best


static func _point_segment_distance(point: Vector2, a: Vector2, b: Vector2) -> float:
	var ab := b - a
	var len_sq := ab.length_squared()
	if len_sq <= 0.0001:
		return point.distance_to(a)
	var t := clampf((point - a).dot(ab) / len_sq, 0.0, 1.0)
	return point.distance_to(a + ab * t)


static func _clear_of_towers(
	world_pos: Vector2,
	existing_towers: Array,
	ignore_tower: TowerController
) -> bool:
	for t in existing_towers:
		if t == ignore_tower or not is_instance_valid(t):
			continue
		if world_pos.distance_to(t.global_position) < TOWER_SEPARATION:
			return false
	return true
