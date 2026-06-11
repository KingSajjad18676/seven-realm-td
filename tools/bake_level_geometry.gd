extends SceneTree

## Run: godot --headless --path . --script res://tools/bake_level_geometry.gd
## Bakes procedural catalog paths into resources/data/levels/level_02..level_08_damavand.tres

const LEVEL_IDS: Array[String] = [
	"level_02", "level_03", "level_04", "level_05",
	"level_06", "level_07", "level_08_damavand",
]
const VIEW_SIZE := Vector2(1280.0, 720.0)
const MARGIN := 48.0
const FORK_FROM_LEVEL := 3


func _init() -> void:
	var catalog_levels := ContentCatalog.build_levels()
	for catalog_level in catalog_levels:
		if catalog_level.level_id not in LEVEL_IDS:
			continue
		var baked := _bake_level(catalog_level)
		var out_path := MapEditorUtils.override_path(catalog_level.level_id)
		var err := ResourceSaver.save(baked, out_path)
		if err != OK:
			push_error("bake_level_geometry: failed %s err=%s" % [out_path, err])
		else:
			print("Baked ", out_path)
	quit()


func _bake_level(source: LevelData) -> LevelData:
	var existing := MapEditorUtils.load_existing_override(source.level_id)
	var scaled := _scale_path(source.path_points)
	var level := LevelData.new()
	level.level_id = source.level_id
	level.display_name = source.display_name if existing == null or existing.display_name == "" else existing.display_name
	level.starting_gold = source.starting_gold
	level.starting_sacred_fire = source.starting_sacred_fire
	if existing:
		if existing.starting_gold > 0:
			level.starting_gold = existing.starting_gold
		if existing.starting_sacred_fire > 0:
			level.starting_sacred_fire = existing.starting_sacred_fire
		if existing.default_objective_id != "":
			level.default_objective_id = existing.default_objective_id
	level.region_ids = source.region_ids.duplicate()
	level.map_sprite_path = VisualAssetLoader.map_sprite(source.level_id)
	level.uses_large_map_camera = source.uses_large_map_camera
	level.camera_anchors = source.camera_anchors.duplicate()
	level.grid_width = source.grid_width
	level.grid_height = source.grid_height

	var main_route := PathRouteData.new()
	main_route.route_id = "route_main"
	main_route.points = scaled
	level.path_routes.append(main_route)

	var khan_idx := ContentCatalog.khan_index(source.level_id)
	if khan_idx >= FORK_FROM_LEVEL:
		var fork := PathRouteData.new()
		fork.route_id = "route_2"
		var lateral := 70.0 if khan_idx < 5 else 90.0
		for pt in scaled:
			fork.points.append(pt + Vector2(lateral * 0.35, lateral))
		level.path_routes.append(fork)

	level.ensure_spawns_migrated()
	level.spawn_points.clear()
	var spawn_main := SpawnPointData.new()
	spawn_main.spawn_id = "spawn_main"
	spawn_main.position = scaled[0] + Vector2(-20, 0)
	spawn_main.route_id = "route_main"
	level.spawn_points.append(spawn_main)
	if level.path_routes.size() > 1:
		var spawn_fork := SpawnPointData.new()
		spawn_fork.spawn_id = "spawn_2"
		spawn_fork.position = level.path_routes[1].points[0] + Vector2(-20, 0)
		spawn_fork.route_id = "route_2"
		level.spawn_points.append(spawn_fork)

	level.gate_position = scaled[scaled.size() - 1] + Vector2(20, -10)
	var pad_count := 6 if khan_idx <= 4 else 8
	level.build_spot_positions = MapEditorUtils.pads_along_path(scaled, pad_count)
	level.sync_legacy_fields()
	level.minimap_bounds = MapCameraUtils.compute_world_bounds(level)
	return level


func _scale_path(points: Array[Vector2]) -> Array[Vector2]:
	if points.is_empty():
		return points
	var min_v := points[0]
	var max_v := points[0]
	for pt in points:
		min_v = min_v.min(pt)
		max_v = max_v.max(pt)
	var src_size := max_v - min_v
	var dst_size := VIEW_SIZE - Vector2(MARGIN * 2.0, MARGIN * 2.0)
	var scale_factor := minf(
		dst_size.x / maxf(src_size.x, 1.0),
		dst_size.y / maxf(src_size.y, 1.0)
	)
	var scaled: Array[Vector2] = []
	for pt in points:
		var norm := (pt - min_v) * scale_factor
		scaled.append(Vector2(MARGIN, MARGIN) + norm)
	return scaled
