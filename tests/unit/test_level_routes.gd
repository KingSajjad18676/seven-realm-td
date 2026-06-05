extends GutTest


func test_migrates_legacy_path_and_spawn() -> void:
	var level := LevelData.new()
	level.path_points = [Vector2(10, 20), Vector2(100, 200), Vector2(300, 400)]
	level.spawn_position = Vector2(10, 20)
	level.ensure_routes_migrated()
	level.ensure_spawns_migrated()
	assert_eq(level.path_routes.size(), 1)
	assert_eq(level.path_routes[0].route_id, LevelData.PRIMARY_ROUTE_ID)
	assert_eq(level.path_routes[0].points.size(), 3)
	assert_eq(level.spawn_points.size(), 1)
	assert_eq(level.spawn_points[0].spawn_id, LevelData.PRIMARY_SPAWN_ID)
	assert_eq(level.spawn_points[0].route_id, LevelData.PRIMARY_ROUTE_ID)


func test_get_route_by_id() -> void:
	var level := _level_with_two_routes()
	var short_path := level.get_route("route_short")
	assert_eq(short_path.size(), 2)
	assert_eq(short_path[0], Vector2(0, 0))
	assert_eq(short_path[1], Vector2(50, 50))


func test_get_spawn_resolves_linked_route() -> void:
	var level := _level_with_two_routes()
	var alt_spawn := SpawnPointData.new()
	alt_spawn.spawn_id = "spawn_alt"
	alt_spawn.position = Vector2(5, 5)
	alt_spawn.route_id = "route_short"
	level.spawn_points.append(alt_spawn)
	var info := level.get_spawn("spawn_alt")
	assert_eq(info.get("position"), Vector2(5, 5))
	assert_eq(info.get("route_id"), "route_short")
	assert_eq(info.get("path"), PackedVector2Array([Vector2(0, 0), Vector2(50, 50)]))


func test_resolve_enemy_route_overrides_route_id() -> void:
	var level := _level_with_two_routes()
	var info := level.resolve_enemy_route({
		"enemy_id": "enemy_jackal",
		"count": 1,
		"route_id": "route_short",
	})
	assert_eq(info.get("route_id"), "route_short")
	assert_eq(info.get("path"), PackedVector2Array([Vector2(0, 0), Vector2(50, 50)]))


func test_sync_legacy_fields_mirrors_primary() -> void:
	var level := _level_with_two_routes()
	level.sync_legacy_fields()
	assert_eq(level.path_points, level.path_routes[0].points)
	assert_eq(level.spawn_position, level.spawn_points[0].position)


func test_get_all_route_points_unions_routes() -> void:
	var level := _level_with_two_routes()
	var all := level.get_all_route_points()
	assert_eq(all.size(), 4)


func _level_with_two_routes() -> LevelData:
	var level := LevelData.new()
	var main := PathRouteData.new()
	main.route_id = "route_main"
	main.points = [Vector2(0, 100), Vector2(200, 100)]
	var short := PathRouteData.new()
	short.route_id = "route_short"
	short.points = [Vector2(0, 0), Vector2(50, 50)]
	level.path_routes = [main, short]
	var spawn := SpawnPointData.new()
	spawn.spawn_id = "spawn_main"
	spawn.position = Vector2(0, 100)
	spawn.route_id = "route_main"
	level.spawn_points = [spawn]
	return level
