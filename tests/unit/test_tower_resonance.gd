extends GutTest

var _ctx: BattleContext = null
var _manager: TowerManager = null
var _resonance: TowerResonanceController = null
var _root: Node2D = null


func before_each() -> void:
	_ctx = BattleContext.new()
	_level_setup()
	_root = Node2D.new()
	add_child_autofree(_root)
	_manager = TowerManager.new()
	add_child_autofree(_manager)
	_manager.initialize(_ctx, _root, _root, _root)
	_resonance = TowerResonanceController.new()
	add_child_autofree(_resonance)
	_resonance.initialize(_ctx, _root)
	_ctx.tower_resonance = _resonance


func _level_setup() -> void:
	var level := LevelData.new()
	level.region_ids = ["region_north"]
	var route := PathRouteData.new()
	route.points = [Vector2(100, 360), Vector2(1100, 360)]
	level.path_routes.append(route)
	_ctx.level_data = level


func _make_tower(tower_id: String, pos: Vector2) -> TowerController:
	var data := ContentRegistry.get_tower(tower_id)
	var tower := TowerController.new()
	_root.add_child(tower)
	tower.global_position = pos
	tower.initialize(_ctx, data, pos, "region_north", "tower_%s" % tower_id)
	_manager.towers.append(tower)
	return tower


func test_fire_string_links_adjacent_towers() -> void:
	var fire := _make_tower("tower_sacred_fire", Vector2(500, 300))
	var archer := _make_tower("tower_archer", Vector2(540, 300))
	_resonance.scan_all()
	assert_true(fire.has_resonance("fire_string"))
	assert_true(archer.has_resonance("fire_string"))


func test_unlink_after_partner_removed() -> void:
	var fire := _make_tower("tower_sacred_fire", Vector2(500, 300))
	var archer := _make_tower("tower_archer", Vector2(540, 300))
	_resonance.scan_all()
	_manager.towers.erase(archer)
	archer.queue_free()
	_resonance.scan_all()
	assert_false(fire.has_resonance("fire_string"))
