extends GutTest

var _ctx: BattleContext = null
var _manager: TowerManager = null
var _economy: BattleEconomy = null
var _root: Node2D = null
var _opened: bool = false
var _build_requested: bool = false


func before_each() -> void:
	_ctx = BattleContext.new()
	_level_setup()
	_root = Node2D.new()
	add_child_autofree(_root)
	_economy = BattleEconomy.new()
	add_child_autofree(_economy)
	_economy.initialize(_ctx)
	_ctx.economy = _economy
	_manager = TowerManager.new()
	add_child_autofree(_manager)
	_manager.initialize(_ctx, _root, _root, _root)
	_manager.tower_opened.connect(func(_t: TowerController) -> void: _opened = true)
	_manager.build_radial_requested.connect(func(_p: Vector2, _r: String) -> void: _build_requested = true)
	_opened = false
	_build_requested = false


func _level_setup() -> void:
	var level := LevelData.new()
	level.minimap_bounds = Rect2(0, 0, 1280, 720)
	level.region_ids = ["region_north"]
	level.available_tower_ids = ["tower_archer"]
	var route := PathRouteData.new()
	route.points = [Vector2(100, 360), Vector2(1100, 360)]
	level.path_routes.append(route)
	_ctx.level_data = level


func test_find_tower_at_empty_returns_null() -> void:
	assert_null(_manager.find_tower_at(Vector2(500, 300)))


func test_valid_build_position_beside_road() -> void:
	assert_true(_manager.is_valid_build_position(Vector2(500, 300)))


func test_try_build_at_spends_gold_and_places_tower() -> void:
	var pos := Vector2(500, 300)
	assert_true(_manager.try_build_at(pos, "tower_archer"))
	assert_eq(_manager.towers.size(), 1)
	assert_eq(_manager.towers[0].global_position, pos)


func test_try_select_at_tower_opens_manage() -> void:
	_manager.try_build_at(Vector2(500, 300), "tower_archer")
	_opened = false
	assert_true(_manager.try_select_at_world(Vector2(500, 300)))
	assert_true(_opened)


func test_try_select_at_valid_empty_requests_build_radial() -> void:
	assert_true(_manager.try_select_at_world(Vector2(700, 300)))
	assert_true(_build_requested)


func test_tutorial_blocks_build() -> void:
	_ctx.tutorial_active = true
	_ctx.set_tutorial_allowed([])
	assert_false(_manager.try_build_at(Vector2(500, 300), "tower_archer"))
