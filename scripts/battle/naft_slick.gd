class_name NaftSlick
extends RefCounted

enum State { OIL, BLAZING }

var route_id: String = ""
var path: PackedVector2Array = PackedVector2Array()
var center_path_dist: float = 0.0
var half_length: float = 70.0
var state: State = State.OIL
var remaining_sec: float = 35.0
var visual: Node2D = null


func is_enemy_inside(enemy: EnemyController) -> bool:
	if enemy == null:
		return false
	var same_route := route_id != "" and enemy.get_route_id() != "" and enemy.get_route_id() == route_id
	var same_path := enemy.get_path_points() == path
	if not same_route and not same_path:
		return false
	var prog := enemy.get_path_progress()
	return prog >= center_path_dist - half_length and prog <= center_path_dist + half_length


static func build_segment_points(
		path_points: PackedVector2Array,
		center_dist: float,
		segment_half_length: float,
		step: float = 8.0
) -> PackedVector2Array:
	var follower := PathFollower.new()
	follower.setup(path_points)
	if follower.total_length <= 0.0:
		return PackedVector2Array()
	var start_dist := maxf(0.0, center_dist - segment_half_length)
	var end_dist := minf(follower.total_length, center_dist + segment_half_length)
	var out := PackedVector2Array()
	var d := start_dist
	while d <= end_dist:
		follower.progress_distance = d
		out.append(follower.advance(0.0))
		d += step
	return out
