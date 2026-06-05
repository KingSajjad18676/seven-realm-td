class_name LevelData
extends Resource

const PRIMARY_ROUTE_ID := "route_main"
const PRIMARY_SPAWN_ID := "spawn_main"

@export var level_id: String = ""
@export var display_name: String = ""
@export var grid_width: int = 32
@export var grid_height: int = 18
@export var starting_gold: int = 120
@export var starting_lives: int = 20
@export var starting_sacred_fire: int = 3
@export var waves: Array[WaveData] = []
@export var available_tower_ids: Array[String] = []
@export var hero_id: String = "rostam"
@export var build_spot_positions: Array[Vector2] = []
@export var path_routes: Array[PathRouteData] = []
@export var spawn_points: Array[SpawnPointData] = []
@export var path_points: Array[Vector2] = []
@export var gate_position: Vector2 = Vector2.ZERO
@export var spawn_position: Vector2 = Vector2.ZERO
@export var region_ids: Array[String] = []
@export var is_tutorial: bool = false
@export var map_sprite_path: String = ""
@export var camera_anchors: Array[Vector2] = []
@export var uses_large_map_camera: bool = false
@export var minimap_bounds: Rect2 = Rect2(0, 0, 1280, 720)
@export var boss_enemy_id: String = ""
@export var default_objective_id: String = ""
@export var block_size: int = 10


func ensure_routes_migrated() -> void:
	if not path_routes.is_empty():
		return
	if path_points.is_empty():
		return
	var route := PathRouteData.new()
	route.route_id = PRIMARY_ROUTE_ID
	route.points = path_points.duplicate()
	path_routes.append(route)


func ensure_spawns_migrated() -> void:
	ensure_routes_migrated()
	if not spawn_points.is_empty():
		return
	if spawn_position == Vector2.ZERO:
		return
	var spawn := SpawnPointData.new()
	spawn.spawn_id = PRIMARY_SPAWN_ID
	spawn.position = spawn_position
	spawn.route_id = get_primary_route_id()
	spawn_points.append(spawn)


func get_primary_route_id() -> String:
	ensure_routes_migrated()
	if path_routes.is_empty():
		return PRIMARY_ROUTE_ID
	return path_routes[0].route_id if path_routes[0].route_id != "" else PRIMARY_ROUTE_ID


func get_primary_spawn_id() -> String:
	ensure_spawns_migrated()
	if spawn_points.is_empty():
		return PRIMARY_SPAWN_ID
	return spawn_points[0].spawn_id if spawn_points[0].spawn_id != "" else PRIMARY_SPAWN_ID


func get_route(route_id: String = "") -> PackedVector2Array:
	ensure_routes_migrated()
	var resolved_id := route_id if route_id != "" else get_primary_route_id()
	for route in path_routes:
		if route.route_id == resolved_id:
			return PackedVector2Array(route.points)
	if not path_routes.is_empty():
		return PackedVector2Array(path_routes[0].points)
	return PackedVector2Array(path_points)


func get_spawn(spawn_id: String = "") -> Dictionary:
	ensure_spawns_migrated()
	var resolved_id := spawn_id if spawn_id != "" else get_primary_spawn_id()
	for spawn in spawn_points:
		if spawn.spawn_id == resolved_id:
			var route_id := spawn.route_id if spawn.route_id != "" else get_primary_route_id()
			return {
				"spawn_id": spawn.spawn_id,
				"position": spawn.position,
				"route_id": route_id,
				"path": get_route(route_id),
			}
	if not spawn_points.is_empty():
		var fallback := spawn_points[0]
		var route_id := fallback.route_id if fallback.route_id != "" else get_primary_route_id()
		return {
			"spawn_id": fallback.spawn_id,
			"position": fallback.position,
			"route_id": route_id,
			"path": get_route(route_id),
		}
	return {
		"spawn_id": PRIMARY_SPAWN_ID,
		"position": spawn_position,
		"route_id": get_primary_route_id(),
		"path": get_route(),
	}


func get_all_route_points() -> Array[Vector2]:
	ensure_routes_migrated()
	var points: Array[Vector2] = []
	for route in path_routes:
		points.append_array(route.points)
	if points.is_empty():
		points.append_array(path_points)
	return points


func sync_legacy_fields() -> void:
	ensure_routes_migrated()
	ensure_spawns_migrated()
	if not path_routes.is_empty():
		path_points = path_routes[0].points.duplicate()
	if not spawn_points.is_empty():
		spawn_position = spawn_points[0].position


func resolve_enemy_route(spawn_group: Dictionary) -> Dictionary:
	var route_id := str(spawn_group.get("route_id", ""))
	var spawn_id := str(spawn_group.get("spawn_id", ""))
	var spawn_info := get_spawn(spawn_id)
	if route_id != "":
		spawn_info["route_id"] = route_id
		spawn_info["path"] = get_route(route_id)
	return spawn_info
