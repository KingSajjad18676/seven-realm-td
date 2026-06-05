extends GutTest

const BUILD_SPOT_SCENE := preload("res://scenes/prefabs/build_spot.tscn")
const TOWER_SCENE := preload("res://scenes/prefabs/tower.tscn")

var _manager: TowerManager
var _ctx: BattleContext
var _signal_flag: bool = false
var _build_flag: bool = false


func _flag_signal(_spot: BuildSpot = null) -> void:
	_signal_flag = true


func _flag_build(_spot: BuildSpot) -> void:
	_build_flag = true


func before_each() -> void:
	_ctx = BattleTestFixtures.context_with_level(self)
	BattleTestFixtures.attach_economy(self, _ctx)
	var state := BattleStateController.new()
	add_child_autofree(state)
	state.initialize(_ctx)
	_ctx.state_controller = state
	_manager = TowerManager.new()
	add_child_autofree(_manager)
	var spots: Array[BuildSpot] = []
	var spot := BUILD_SPOT_SCENE.instantiate() as BuildSpot
	add_child_autofree(spot)
	spot.global_position = Vector2(200, 300)
	spots.append(spot)
	_manager.initialize(_ctx, spots, Node2D.new(), Node2D.new())
	_ctx.tower_manager = _manager
	await get_tree().process_frame


func test_find_spot_at_any_includes_occupied() -> void:
	_setup_tower_on_spot()
	var found := _manager.find_spot_at_any(Vector2(200, 300))
	assert_eq(found, _manager.build_spots[0])


func test_find_spot_at_any_uses_tower_pick_radius() -> void:
	var spot := _manager.build_spots[0]
	var tower := _setup_tower_on_spot()
	tower.level = 3
	tower._apply_forge_visuals()
	var edge := spot.global_position + Vector2(tower.get_pick_radius() - 2.0, 0.0)
	assert_not_null(_manager.find_spot_at_any(edge))
	var miss := spot.global_position + Vector2(tower.get_pick_radius() + 6.0, 0.0)
	assert_null(_manager.find_spot_at_any(miss))


func test_on_spot_selected_empty_returns_true() -> void:
	var spot := _manager.build_spots[0]
	assert_false(spot.occupied)
	assert_true(_manager._on_spot_selected(spot))


func test_try_select_spot_at_world_emits_radial_for_empty_pad() -> void:
	var spot := _manager.build_spots[0]
	_signal_flag = false
	_manager.build_radial_requested.connect(_flag_signal)
	assert_not_null(_manager.find_spot_at_any(spot.global_position))
	assert_true(_manager.try_select_spot_at_world(spot.global_position))
	assert_true(_signal_flag)


func test_on_spot_selected_occupied_emits_manage() -> void:
	_setup_tower_on_spot()
	_signal_flag = false
	_manager.tower_spot_opened.connect(_flag_signal)
	assert_true(_manager._on_spot_selected(_manager.build_spots[0]))
	assert_true(_signal_flag)


func test_try_select_occupied_spot_emits_manage_signal() -> void:
	var spot := _setup_tower_on_spot()
	_signal_flag = false
	_build_flag = false
	_manager.build_radial_requested.connect(_flag_build)
	_manager.tower_spot_opened.connect(_flag_signal)
	assert_not_null(_manager.find_spot_at_any(spot.global_position))
	assert_true(_manager.try_select_spot_at_world(spot.global_position))
	assert_true(_signal_flag, "Occupied pad should open manage radial")
	assert_false(_build_flag, "Occupied pad must not request build radial")


func test_try_select_occupied_spot_allowed_during_tutorial_with_build_pads() -> void:
	var spot := _setup_tower_on_spot()
	_ctx.tutorial_active = true
	_ctx.set_tutorial_allowed(["build_pads"])
	_signal_flag = false
	_manager.tower_spot_opened.connect(_flag_signal)
	assert_true(_manager.try_select_spot_at_world(spot.global_position))
	assert_true(_signal_flag)


func test_try_select_occupied_spot_blocked_during_tutorial_without_allow() -> void:
	_setup_tower_on_spot()
	_ctx.tutorial_active = true
	_ctx.set_tutorial_allowed([])
	_signal_flag = false
	_manager.tower_spot_opened.connect(_flag_signal)
	assert_false(_manager.try_select_spot_at_world(_manager.build_spots[0].global_position))
	assert_false(_signal_flag)


func test_try_select_occupied_without_tower_returns_false() -> void:
	var spot := _manager.build_spots[0]
	spot.occupied = true
	spot.tower = null
	_signal_flag = false
	_build_flag = false
	_manager.tower_spot_opened.connect(_flag_signal)
	_manager.build_radial_requested.connect(_flag_build)
	assert_false(_manager.try_select_spot_at_world(spot.global_position))
	assert_false(_signal_flag)
	assert_false(_build_flag)


func _setup_tower_on_spot() -> TowerController:
	var td := ContentRegistry.get_tower("tower_archer")
	assert_not_null(td)
	var spot := _manager.build_spots[0]
	var tower := TOWER_SCENE.instantiate() as TowerController
	var towers_root := Node2D.new()
	add_child_autofree(towers_root)
	towers_root.add_child(tower)
	tower.global_position = spot.global_position
	tower.initialize(_ctx, td, spot)
	spot.set_occupied(tower)
	_manager.towers.append(tower)
	assert_true(spot.occupied)
	assert_eq(spot.tower, tower)
	return tower
