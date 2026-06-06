extends GutTest

const TOWER_SCENE := preload("res://scenes/prefabs/tower.tscn")

var _radial: TowerRadialBuildController
var _ctx: BattleContext
var _build_pos: Vector2 = Vector2(400, 300)
var _camera: Camera2D
var _layer: CanvasLayer


func before_each() -> void:
	_layer = CanvasLayer.new()
	add_child_autofree(_layer)
	_camera = Camera2D.new()
	_camera.global_position = Vector2(640, 360)
	add_child_autofree(_camera)
	_ctx = BattleTestFixtures.context_with_level(self, 200, 5)
	var level := ContentRegistry.get_level("level_01")
	assert_not_null(level)
	_ctx.level_data = level
	BattleTestFixtures.attach_economy(self, _ctx)
	_ctx.tower_manager = TowerManager.new()
	add_child_autofree(_ctx.tower_manager)
	var towers_root := Node2D.new()
	add_child_autofree(towers_root)
	_ctx.tower_manager.initialize(_ctx, towers_root, towers_root, towers_root)
	var state := BattleStateController.new()
	add_child_autofree(state)
	state.initialize(_ctx)
	_ctx.state_controller = state
	_radial = TowerRadialBuildController.new()
	_layer.add_child(_radial)
	_radial.initialize(_ctx, _camera)
	await get_tree().process_frame


func test_show_for_position_stays_open_during_opening_guard() -> void:
	_radial.show_for_position(_build_pos, "region_north")
	assert_true(_radial.visible)
	assert_gt(_radial.get_child_count(), 1)
	var click := InputEventMouseButton.new()
	click.button_index = MOUSE_BUTTON_LEFT
	click.pressed = true
	_radial._gui_input(click)
	assert_true(_radial.visible, "Opening guard must block same-frame dismiss")


func test_show_for_position_dismisses_after_guard_clears() -> void:
	_radial.show_for_position(_build_pos, "region_north")
	await get_tree().process_frame
	var click := InputEventMouseButton.new()
	click.button_index = MOUSE_BUTTON_LEFT
	click.pressed = true
	_radial._gui_input(click)
	assert_false(_radial.visible)


func test_show_for_tower_allowed_during_tutorial_with_build_pads() -> void:
	var tower := _setup_tower(1)
	_ctx.tutorial_active = true
	_ctx.set_tutorial_allowed(["build_pads"])
	_radial.show_for_tower(tower)
	assert_true(_radial.visible)


func test_build_radial_disables_unaffordable_towers() -> void:
	_ctx.economy.gold = 55
	_radial.show_for_position(_build_pos, "region_north")
	assert_true(_radial.visible)
	var archer_btn: Button = null
	var heavy_btn: Button = null
	for btn in _radial._option_buttons:
		if "Archer" in btn.text:
			archer_btn = btn
		if "Heavy" in btn.text:
			heavy_btn = btn
	assert_not_null(archer_btn, "Archer tower option expected")
	assert_not_null(heavy_btn, "Heavy tower option expected")
	assert_false(archer_btn.disabled, "50G archer should be affordable at 55G")
	assert_true(heavy_btn.disabled, "80G heavy should be unaffordable at 55G")


func test_manage_radial_shows_tower_level() -> void:
	var tower := _setup_tower(2)
	_radial.show_for_tower(tower)
	assert_true(_radial.visible)
	assert_not_null(_radial._center_label)
	assert_string_contains(_radial._center_label.text, "Lv 2/3")


func test_manage_upgrade_disabled_when_gold_insufficient() -> void:
	var tower := _setup_tower(1)
	_ctx.economy.gold = 0
	_radial.show_for_tower(tower)
	var upgrade_btn: Button = null
	for btn in _radial._option_buttons:
		if btn.text.begins_with("Upgrade"):
			upgrade_btn = btn
	assert_not_null(upgrade_btn)
	assert_true(upgrade_btn.disabled)


func test_manage_sell_closes_menu() -> void:
	var tower := _setup_tower(1)
	_radial.show_for_tower(tower)
	assert_true(_radial.visible)
	for btn in _radial._option_buttons:
		if btn.text.begins_with("Sell"):
			btn.pressed.emit()
			break
	await get_tree().process_frame
	assert_false(_radial.visible)
	assert_eq(_ctx.tower_manager.towers.size(), 0)


func _setup_tower(level: int) -> TowerController:
	var td := ContentRegistry.get_tower("tower_archer")
	assert_not_null(td)
	var tower := TOWER_SCENE.instantiate() as TowerController
	_ctx.tower_manager.towers_root.add_child(tower)
	tower.global_position = _build_pos
	tower.initialize(_ctx, td, _build_pos, "region_north", "tower_test")
	if level > 1:
		tower.level = level
		tower.gold_invested = td.build_cost + td.upgrade_cost * (level - 1)
	_ctx.tower_manager.towers.append(tower)
	return tower
