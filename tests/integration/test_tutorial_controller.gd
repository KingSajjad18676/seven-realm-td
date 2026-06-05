extends GutTest

const TUTORIAL_SCENE := preload("res://scenes/ui/tutorial_overlay.tscn")

var _tutorial: TutorialController = null
var _ctx: BattleContext = null


func before_each() -> void:
	_ctx = BattleTestFixtures.context_with_level(self)
	var state := BattleStateController.new()
	add_child(state)
	state.initialize(_ctx)
	_ctx.state_controller = state
	_tutorial = TUTORIAL_SCENE.instantiate() as TutorialController
	add_child(_tutorial)


func after_each() -> void:
	if _tutorial:
		_tutorial.queue_free()
		_tutorial = null


func test_got_it_button_advances_welcome_step() -> void:
	_tutorial.initialize(_ctx, null, null, null)
	await get_tree().process_frame
	assert_eq(_tutorial._step_index, 0, "Should start on welcome step")
	var btn := _tutorial.get_node("%GotItButton") as Button
	assert_not_null(btn)
	btn.pressed.emit()
	assert_eq(_tutorial._step_index, 1, "Got it should advance to step 2")


func test_coach_panel_tap_advances_got_it_step() -> void:
	_tutorial.initialize(_ctx, null, null, null)
	await get_tree().process_frame
	var panel := _tutorial.get_node("%CoachPanel") as Panel
	assert_not_null(panel)
	var tap := InputEventMouseButton.new()
	tap.button_index = MOUSE_BUTTON_LEFT
	tap.pressed = true
	tap.position = panel.get_global_rect().get_center()
	panel.gui_input.emit(tap)
	assert_eq(_tutorial._step_index, 1, "Tapping coach text should advance GOT_IT step")


func test_dim_blocks_input_on_coach_steps() -> void:
	_tutorial.initialize(_ctx, null, null, null)
	await get_tree().process_frame
	var root := _tutorial.get_node("%Root") as Control
	assert_not_null(root)
	assert_eq(root.mouse_filter, Control.MOUSE_FILTER_STOP, "Welcome step root should block HUD clicks")
	var dim := _tutorial.get_node("%Dim") as ColorRect
	assert_not_null(dim)
	assert_eq(dim.mouse_filter, Control.MOUSE_FILTER_IGNORE, "Dim should be visual-only")


func test_coach_panel_passes_input_on_place_tower_step() -> void:
	_tutorial.initialize(_ctx, null, null, null)
	await get_tree().process_frame
	_tutorial._show_step(_step_index_for("place_tower"))
	await get_tree().process_frame
	var panel := _tutorial.get_node("%CoachPanel") as Panel
	assert_not_null(panel)
	assert_eq(
		panel.mouse_filter,
		Control.MOUSE_FILTER_IGNORE,
		"Place tower step should not block build pad taps"
	)


func test_coach_panel_passes_input_on_move_hero_step() -> void:
	_tutorial.initialize(_ctx, null, null, null)
	await get_tree().process_frame
	_tutorial._show_step(_step_index_for("move_hero"))
	await get_tree().process_frame
	var panel := _tutorial.get_node("%CoachPanel") as Panel
	assert_not_null(panel)
	assert_eq(
		panel.mouse_filter,
		Control.MOUSE_FILTER_IGNORE,
		"Move hero step should not block battlefield taps"
	)
	var blocker := _tutorial.get_node("%MapInputBlocker") as ColorRect
	assert_not_null(blocker)
	assert_eq(
		blocker.mouse_filter,
		Control.MOUSE_FILTER_IGNORE,
		"Move hero step should leave playfield tappable"
	)


func test_map_blocker_stops_input_on_hero_skill_step() -> void:
	_tutorial.initialize(_ctx, null, null, null)
	await get_tree().process_frame
	_tutorial._show_step(_step_index_for("hero_skill"))
	await get_tree().process_frame
	var root := _tutorial.get_node("%Root") as Control
	var panel := _tutorial.get_node("%CoachPanel") as Panel
	var blocker := _tutorial.get_node("%MapInputBlocker") as ColorRect
	assert_not_null(root)
	assert_not_null(panel)
	assert_not_null(blocker)
	assert_eq(root.mouse_filter, Control.MOUSE_FILTER_IGNORE, "Root should pass HUD clicks through")
	assert_eq(panel.mouse_filter, Control.MOUSE_FILTER_STOP, "Coach panel should block center taps")
	assert_eq(blocker.mouse_filter, Control.MOUSE_FILTER_STOP, "Playfield should block stray map taps")


func test_hero_skill_step_swallows_playfield_press() -> void:
	_tutorial.initialize(_ctx, null, null, null)
	await get_tree().process_frame
	_tutorial._show_step(_step_index_for("hero_skill"))
	var step: Dictionary = _tutorial._steps[_step_index_for("hero_skill")]
	assert_true(
		_tutorial.should_swallow_playfield_press(step, Vector2(640, 360)),
		"Hero skill step should swallow stray playfield taps"
	)


func test_move_hero_step_does_not_swallow_playfield_press() -> void:
	_tutorial.initialize(_ctx, null, null, null)
	await get_tree().process_frame
	_tutorial._show_step(_step_index_for("move_hero"))
	var step: Dictionary = _tutorial._steps[_step_index_for("move_hero")]
	assert_false(
		_tutorial.should_swallow_playfield_press(step, Vector2(640, 360)),
		"Move hero step should allow battlefield taps"
	)


func test_fate_cards_step_passes_input_to_pardeh() -> void:
	_tutorial.initialize(_ctx, null, null, null)
	await get_tree().process_frame
	_tutorial._show_step(_step_index_for("fate_cards"))
	await get_tree().process_frame
	var root := _tutorial.get_node("%Root") as Control
	var panel := _tutorial.get_node("%CoachPanel") as Panel
	var dim := _tutorial.get_node("%Dim") as ColorRect
	var blocker := _tutorial.get_node("%MapInputBlocker") as ColorRect
	assert_not_null(root)
	assert_not_null(panel)
	assert_not_null(dim)
	assert_not_null(blocker)
	assert_eq(root.mouse_filter, Control.MOUSE_FILTER_IGNORE, "Fate cards step should pass clicks to Pardeh")
	assert_false(panel.visible, "Coach should hide during Pardeh Break")
	assert_false(dim.visible, "Dim should hide during Pardeh Break")
	assert_eq(blocker.mouse_filter, Control.MOUSE_FILTER_IGNORE, "Map blocker should not intercept Pardeh taps")


func test_scavenge_step_allows_battlefield_and_spawns_drop() -> void:
	_tutorial.initialize(_ctx, null, null, null)
	await get_tree().process_frame
	var idx := _step_index_for("scavenge_star_iron")
	assert_gte(idx, 0, "Tutorial should include scavenge_star_iron step")
	_tutorial._show_step(idx)
	await get_tree().process_frame
	var step: Dictionary = _tutorial._steps[idx]
	assert_false(
		_tutorial.should_swallow_playfield_press(step, Vector2(640, 360)),
		"Scavenge step should allow battlefield taps"
	)
	assert_true(step.get("allowed", []).has("battlefield"))


func test_survive_step_does_not_swallow_playfield_press() -> void:
	_tutorial.initialize(_ctx, null, null, null)
	await get_tree().process_frame
	_tutorial._show_step(_step_index_for("survive"))
	var step: Dictionary = _tutorial._steps[_step_index_for("survive")]
	assert_false(
		_tutorial.should_swallow_playfield_press(step, Vector2(640, 360)),
		"Survive step should allow battlefield taps for Rostam"
	)
	assert_true(step.get("allowed", []).has("battlefield"), "Survive step should allow battlefield gating")


func test_cancel_move_clears_locomotion_target() -> void:
	const HERO_SCENE := preload("res://scenes/prefabs/hero.tscn")
	var hero := HERO_SCENE.instantiate() as HeroController
	add_child(hero)
	var hero_data := ContentRegistry.get_hero("rostam")
	assert_not_null(hero_data)
	hero.initialize(_ctx, hero_data.duplicate(true) as HeroData, Vector2.ZERO)
	hero.move_to(Vector2(400, 300))
	hero.cancel_move()
	assert_false(hero._has_target, "cancel_move should clear locomotion target")
	assert_eq(hero.velocity, Vector2.ZERO)


func _step_index_for(step_id: String) -> int:
	for i in _tutorial._steps.size():
		if _tutorial._steps[i].get("id", "") == step_id:
			return i
	return -1
