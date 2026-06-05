class_name MapEditorUtils
extends RefCounted

const VIEW_SIZE := Vector2(1280.0, 720.0)
const PAD_SIZE := BuildPadVisuals.PAD_DIAMETER
const HANDLE_RADIUS := 10.0
const LEVEL_OVERRIDE_DIR := "res://resources/data/levels/"
const ROUTE_COLORS := [
	Color(0.72, 0.58, 0.38, 0.85),
	Color(0.35, 0.55, 0.95, 0.85),
	Color(0.65, 0.35, 0.85, 0.85),
	Color(0.35, 0.85, 0.55, 0.85),
]


static func snap_point(point: Vector2, grid_size: int, enabled: bool) -> Vector2:
	if not enabled or grid_size <= 0:
		return point
	return Vector2(
		roundf(point.x / float(grid_size)) * float(grid_size),
		roundf(point.y / float(grid_size)) * float(grid_size)
	)


static func route_color(index: int) -> Color:
	if ROUTE_COLORS.is_empty():
		return Color.WHITE
	return ROUTE_COLORS[index % ROUTE_COLORS.size()]


static func pads_along_path(path: Array[Vector2], count: int, offset: Vector2 = Vector2(0, -60)) -> Array[Vector2]:
	var pads: Array[Vector2] = []
	if path.is_empty() or count <= 0:
		return pads
	for i in range(count):
		var t := float(i + 1) / float(count + 1)
		var idx := int(t * float(path.size() - 1))
		idx = clampi(idx, 0, path.size() - 1)
		var side := 1.0 if i % 2 == 0 else -1.0
		pads.append(path[idx] + Vector2(offset.x * side, offset.y))
	return pads


static func override_path(level_id: String) -> String:
	return LEVEL_OVERRIDE_DIR + level_id + ".tres"


static func load_existing_override(level_id: String) -> LevelData:
	var path := override_path(level_id)
	if ResourceLoader.exists(path):
		return load(path) as LevelData
	return null


static func routes_to_state(routes: Array[PathRouteData]) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for route in routes:
		out.append({
			"route_id": route.route_id,
			"points": route.points.duplicate(),
		})
	return out


static func spawns_to_state(spawns: Array[SpawnPointData]) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for spawn in spawns:
		out.append({
			"spawn_id": spawn.spawn_id,
			"position": spawn.position,
			"route_id": spawn.route_id,
		})
	return out


static func state_to_routes(state: Array) -> Array[PathRouteData]:
	var out: Array[PathRouteData] = []
	for entry in state:
		if entry is Dictionary:
			var route := PathRouteData.new()
			route.route_id = str(entry.get("route_id", ""))
			route.points = entry.get("points", [])
			out.append(route)
	return out


static func state_to_spawns(state: Array) -> Array[SpawnPointData]:
	var out: Array[SpawnPointData] = []
	for entry in state:
		if entry is Dictionary:
			var spawn := SpawnPointData.new()
			spawn.spawn_id = str(entry.get("spawn_id", ""))
			spawn.position = entry.get("position", Vector2.ZERO)
			spawn.route_id = str(entry.get("route_id", ""))
			out.append(spawn)
	return out


static func apply_level_to_state(level: LevelData) -> Dictionary:
	level.ensure_routes_migrated()
	level.ensure_spawns_migrated()
	return {
		"path_routes": routes_to_state(level.path_routes),
		"spawn_points": spawns_to_state(level.spawn_points),
		"path_points": level.path_points.duplicate(),
		"build_spot_positions": level.build_spot_positions.duplicate(),
		"spawn_position": level.spawn_position,
		"gate_position": level.gate_position,
		"region_ids": level.region_ids.duplicate(),
		"map_sprite_path": level.map_sprite_path,
		"uses_large_map_camera": level.uses_large_map_camera,
		"camera_anchors": level.camera_anchors.duplicate(),
		"grid_width": level.grid_width,
		"grid_height": level.grid_height,
	}


static func build_background_sprite(map_sprite_path: String) -> Sprite2D:
	var spr := Sprite2D.new()
	spr.name = "MapBackground"
	spr.centered = false
	spr.position = Vector2.ZERO
	spr.z_index = -2
	if map_sprite_path != "" and ResourceLoader.exists(map_sprite_path):
		var tex := load(map_sprite_path) as Texture2D
		if tex:
			spr.texture = tex
			var scale_factor := VIEW_SIZE / tex.get_size()
			spr.scale = Vector2(scale_factor.x, scale_factor.y)
	return spr


static func merge_save_payload(
	level_id: String,
	geometry: Dictionary,
	existing: LevelData = null
) -> LevelData:
	var out := LevelData.new()
	out.level_id = level_id
	if existing:
		out.display_name = existing.display_name
		out.starting_gold = existing.starting_gold
		out.starting_lives = existing.starting_lives
		out.starting_sacred_fire = existing.starting_sacred_fire
		out.hero_id = existing.hero_id
		out.boss_enemy_id = existing.boss_enemy_id
		out.default_objective_id = existing.default_objective_id
		if not existing.waves.is_empty():
			out.waves = existing.waves
	out.map_sprite_path = geometry.get("map_sprite_path", "")
	out.path_routes = state_to_routes(geometry.get("path_routes", []))
	out.spawn_points = state_to_spawns(geometry.get("spawn_points", []))
	out.build_spot_positions = geometry.get("build_spot_positions", [])
	out.gate_position = geometry.get("gate_position", Vector2.ZERO)
	out.region_ids = geometry.get("region_ids", [])
	out.uses_large_map_camera = geometry.get("uses_large_map_camera", false)
	out.camera_anchors = geometry.get("camera_anchors", [])
	out.grid_width = geometry.get("grid_width", 32)
	out.grid_height = geometry.get("grid_height", 18)
	out.sync_legacy_fields()
	return out


static func next_route_id(routes: Array[Dictionary]) -> String:
	var index := routes.size() + 1
	while true:
		var candidate := "route_%d" % index
		var taken := false
		for route in routes:
			if route.get("route_id", "") == candidate:
				taken = true
				break
		if not taken:
			return candidate
		index += 1


static func next_spawn_id(spawns: Array[Dictionary]) -> String:
	var index := spawns.size() + 1
	while true:
		var candidate := "spawn_%d" % index
		var taken := false
		for spawn in spawns:
			if spawn.get("spawn_id", "") == candidate:
				taken = true
				break
		if not taken:
			return candidate
		index += 1
