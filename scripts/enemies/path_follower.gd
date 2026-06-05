class_name PathFollower
extends RefCounted

var path_points: PackedVector2Array = PackedVector2Array()
var progress_distance: float = 0.0
var total_length: float = 0.0
var _segment_lengths: Array[float] = []


func setup(points: PackedVector2Array) -> void:
	path_points = points
	progress_distance = 0.0
	_segment_lengths.clear()
	total_length = 0.0
	if points.size() < 2:
		return
	for i in range(points.size() - 1):
		var seg_len := points[i].distance_to(points[i + 1])
		_segment_lengths.append(seg_len)
		total_length += seg_len


func advance(distance: float) -> Vector2:
	if path_points.is_empty():
		return Vector2.ZERO
	progress_distance += distance
	if progress_distance >= total_length:
		progress_distance = total_length
		return path_points[path_points.size() - 1]
	var traveled := 0.0
	for i in _segment_lengths.size():
		var seg := _segment_lengths[i]
		if traveled + seg >= progress_distance:
			var t := (progress_distance - traveled) / seg if seg > 0.0 else 0.0
			return path_points[i].lerp(path_points[i + 1], t)
		traveled += seg
	return path_points[path_points.size() - 1]


func is_at_end() -> bool:
	return total_length > 0.0 and progress_distance >= total_length - 1.0


func get_progress_distance() -> float:
	return progress_distance


static func closest_distance_on_path(points: PackedVector2Array, world_pos: Vector2) -> float:
	if points.size() < 2:
		return 0.0
	var best_dist_sq := INF
	var best_path_dist := 0.0
	var traveled := 0.0
	for i in range(points.size() - 1):
		var a: Vector2 = points[i]
		var b: Vector2 = points[i + 1]
		var seg_len := a.distance_to(b)
		var closest := Geometry2D.get_closest_point_to_segment(world_pos, a, b)
		var d_sq := world_pos.distance_squared_to(closest)
		if d_sq < best_dist_sq:
			best_dist_sq = d_sq
			var seg_t := a.distance_to(closest) / seg_len if seg_len > 0.0 else 0.0
			best_path_dist = traveled + seg_t * seg_len
		traveled += seg_len
	return best_path_dist


static func position_at_distance(points: PackedVector2Array, dist: float) -> Vector2:
	var follower := PathFollower.new()
	follower.setup(points)
	follower.progress_distance = clampf(dist, 0.0, follower.total_length)
	return follower.advance(0.0)
