extends GutTest

const BUILD_SPOT_SCENE := preload("res://scenes/prefabs/build_spot.tscn")
const TOWER_SCENE := preload("res://scenes/prefabs/tower.tscn")

var _radial: TowerRadialBuildController
var _ctx: BattleContext
var _spot: BuildSpot
var _camera: Camera2D
var _layer: CanvasLayer


func before_each() -> void:
	_layer = CanvasLayer.new()
	add_child_autofree(_layer)
	_camera = Camera2D.new()
	_camera.global_position = Vector2(640, 360)
	add_child_autofree(_camera)
	_spot = BUILD_SPOT_SCENE.instantiate() as BuildSpot
	add_child_autofree(_spot)
	_spot.global_position = Vector2(400, 300)
	_ctx = BattleTestFixtures.context_with_level(self, 200, 5)
	var level := ContentRegistry.get_level("level_01")
	assert_not_null(level)
	_ctx.level_data = level
	BattleTestFixtures.attach_economy(self, _ctx)
	_ctx.tower_manager = TowerManager.new()
	add_child_autofree(_ctx.tower_manager)
	var state := BattleStateController.new()
	add_child_autofree(state)
	state.initialize(_ctx)
	_ctx.state_controller = state
	_radial = TowerRadialBuildController.new()
	_layer.add_child(_radial)
	_radial.initialize(_ctx, _camera)
	await get_tree().process_frame


func test_show_for_spot_stays_open_during_opening_guard() -> void:
	_radial.show_for_spot(_spot)
	assert_true(_radial.visible)
	assert_gt(_radial.get_child_count(), 1)
	var click := InputEventMouseButton.new()
	click.button_index = MOUSE_BUTTON_LEFT
	click.pressed = true
	_radial._gui_input(click)
	assert_true(_radial.visible, "Opening guard must block same-frame dismiss")


func test_show_for_spot_dismisses_after_guard_clears() -> void:
	_radial.show_for_spot(_spot)
	await get_tree().process_frame
	var click := InputEventMouseButton.new()
	click.button_index = MOUSE_BUTTON_LEFT
	click.pressed = true
	_radial._gui_input(click)
	assert_false(_radial.visible)


func test_show_for_spot_skips_occupied_pad() -> void:
	_spot.occupied = true
	_radial.show_for_spot(_spot)
	assert_false(_radial.visible)


func test_build_radial_disables_unaffordable_towers() -> void:
	_ctx.economy.gold = 55
	_radial.show_for_spot(_spot)
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
	_setup_tower_on_spot(2)
	_radial.show_for_occupied_spot(_spot)
	assert_true(_radial.visible)
	assert_not_null(_radial._center_label)
	assert_string_contains(_radial._center_label.text, "Lv 2/3")


func test_manage_upgrade_disabled_when_gold_insufficient() -> void:
	_setup_tower_on_spot(1)
	_ctx.economy.gold = 0
	_radial.show_for_occupied_spot(_spot)
	var upgrade_btn: Button = null
	for btn in _radial._option_buttons:
		if btn.text.begins_with("Upgrade"):
			upgrade_btn = btn
	assert_not_null(upgrade_btn)
	assert_true(upgrade_btn.disabled)


func test_manage_sell_closes_menu() -> void:
	_setup_tower_on_spot(1)
	_radial.show_for_occupied_spot(_spot)
	assert_true(_radial.visible)
	for btn in _radial._option_buttons:
		if btn.text.begins_with("Sell"):
			btn.pressed.emit()
			break
	await get_tree().process_frame
	assert_false(_radial.visible)
	assert_false(_spot.occupied)


func _setup_tower_on_spot(level: int) -> TowerController:
	var td := ContentRegistry.get_tower("tower_archer")
	assert_not_null(td)
	var tower := TOWER_SCENE.instantiate() as TowerController
	add_child_autofree(tower)
	tower.initialize(_ctx, td, _spot)
	if level > 1:
		tower.level = level
		tower.gold_invested = td.build_cost + td.upgrade_cost * (level - 1)
	_spot.set_occupied(tower)
	_ctx.tower_manager.towers.append(tower)
	return tower
