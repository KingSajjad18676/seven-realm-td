class_name TowerRadialBuildController
extends Control

enum Mode { BUILD, MANAGE }

const OPTION_RADIUS := 72.0
const BUTTON_SIZE := Vector2(72, 52)
const CENTER_LABEL_SIZE := Vector2(80, 40)

var context: BattleContext = null
var camera: Camera2D = null

var _spot: BuildSpot = null
var _mode: Mode = Mode.BUILD
var _option_buttons: Array[Button] = []
var _center_label: Label = null
var _backdrop: ColorRect = null
var _opening_guard: bool = false
var _gold_connected: bool = false
var _range_ring: TowerRangeRing = null
var _selected_tower: TowerController = null
var _option_tower_ids: Array[String] = []
var _light_listener_connected: bool = false


func set_range_ring(ring: TowerRangeRing) -> void:
	_range_ring = ring
	_connect_light_refresh()


func initialize(ctx: BattleContext, cam: Camera2D) -> void:
	context = ctx
	camera = cam
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	z_index = 100
	visible = false
	_backdrop = ColorRect.new()
	_backdrop.name = "Backdrop"
	_backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_backdrop.color = Color(0.02, 0.04, 0.06, 0.35)
	_backdrop.mouse_filter = Control.MOUSE_FILTER_STOP
	_backdrop.visible = false
	_backdrop.gui_input.connect(_on_backdrop_gui_input)
	add_child(_backdrop)
	_connect_gold_refresh()


func _connect_gold_refresh() -> void:
	if _gold_connected or context == null or context.bridge == null:
		return
	context.bridge.gold_changed.connect(_on_gold_changed)
	_gold_connected = true


func _connect_light_refresh() -> void:
	if _light_listener_connected or context == null or context.bridge == null:
		return
	context.bridge.region_light_changed.connect(_on_region_light_changed_for_ring)
	_light_listener_connected = true


func _on_region_light_changed_for_ring(region_id: String, _light: int, _state: GameEnums.RegionLightState) -> void:
	if not visible or _spot == null or _spot.region_id != region_id:
		return
	_refresh_range_ring()


func _on_gold_changed(_amount: int) -> void:
	if visible:
		refresh_affordability()


func refresh_affordability() -> void:
	if not visible:
		return
	if _mode == Mode.BUILD:
		_apply_build_affordability()
		_refresh_range_ring()
	elif _mode == Mode.MANAGE:
		_rebuild_manage_options()
		_position_options()
		_position_center_label()


func _on_backdrop_gui_input(event: InputEvent) -> void:
	if not visible or _opening_guard:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		hide_menu()
	elif event is InputEventScreenTouch and event.pressed:
		hide_menu()


func show_for_spot(spot: BuildSpot) -> void:
	if context == null or spot == null or spot.occupied:
		return
	if context.tutorial_active and not context.tutorial_allows("build_pads"):
		return
	_mode = Mode.BUILD
	_spot = spot
	_rebuild_build_options()
	if _option_buttons.is_empty():
		return
	_open_menu()


func show_for_occupied_spot(spot: BuildSpot) -> void:
	if context == null or spot == null or not spot.occupied or spot.tower == null:
		return
	if context.tutorial_active:
		return
	_mode = Mode.MANAGE
	_spot = spot
	_selected_tower = spot.tower
	_selected_tower.set_selected_visual(true)
	_rebuild_manage_options()
	if _option_buttons.is_empty() and _center_label == null:
		return
	_open_menu()


func _open_menu() -> void:
	_position_options()
	_position_center_label()
	_refresh_range_ring()
	_opening_guard = true
	if _backdrop:
		_backdrop.visible = true
	visible = true
	mouse_filter = Control.MOUSE_FILTER_STOP
	move_to_front()
	call_deferred("_clear_opening_guard")


func hide_menu() -> void:
	if _selected_tower:
		_selected_tower.set_selected_visual(false)
		_selected_tower = null
	if _range_ring:
		_range_ring.hide_ring()
	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_opening_guard = false
	_spot = null
	_mode = Mode.BUILD
	if _backdrop:
		_backdrop.visible = false
	_clear_options()


func _clear_opening_guard() -> void:
	_opening_guard = false


func _clear_options() -> void:
	for btn in _option_buttons:
		btn.queue_free()
	_option_buttons.clear()
	if _center_label:
		_center_label.queue_free()
		_center_label = null


func _rebuild_build_options() -> void:
	_clear_options()
	_option_tower_ids.clear()
	if context == null or context.level_data == null:
		return
	for tid in context.level_data.available_tower_ids:
		if tid in ["tower_zahhak_serpent", "tower_rostam_barracks"] and SaveSystem and not SaveSystem.is_tower_unlocked(tid):
			continue
		var td := ContentRegistry.get_tower(tid)
		if td == null:
			continue
		var btn := _make_option_button("%s\n%dG" % [td.display_name, td.build_cost])
		btn.pressed.connect(_on_build_option_pressed.bind(tid))
		btn.mouse_entered.connect(_on_build_option_hovered.bind(tid))
		btn.focus_entered.connect(_on_build_option_hovered.bind(tid))
		_option_buttons.append(btn)
		_option_tower_ids.append(tid)
	_apply_build_affordability()


func _apply_build_affordability() -> void:
	if context == null or context.level_data == null:
		return
	var idx := 0
	for tid in context.level_data.available_tower_ids:
		if tid in ["tower_zahhak_serpent", "tower_rostam_barracks"] and SaveSystem and not SaveSystem.is_tower_unlocked(tid):
			continue
		var td := ContentRegistry.get_tower(tid)
		if td == null:
			continue
		if idx >= _option_buttons.size():
			break
		var affordable := context.economy != null and context.economy.can_afford_gold(td.build_cost)
		var btn := _option_buttons[idx]
		btn.disabled = not affordable
		btn.modulate = Color(1, 1, 1, 1) if affordable else Color(0.55, 0.55, 0.55, 0.85)
		idx += 1


func _rebuild_manage_options() -> void:
	_clear_options()
	if _spot == null or _spot.tower == null or _spot.tower.data == null:
		return
	var tower := _spot.tower
	var td := tower.data
	var hijacked := tower.hijack_phase != GameEnums.HijackPhase.NONE
	var actions_enabled := _can_act()

	_center_label = Label.new()
	var range_px := int(roundf(tower.get_effective_range()))
	var range_line := " · %dr" % range_px if range_px > 0 else ""
	_center_label.text = "%s\nLv %d/%d%s" % [td.display_name, tower.level, td.max_level, range_line]
	_center_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_center_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_center_label.add_theme_font_size_override("font_size", 10)
	_center_label.custom_minimum_size = CENTER_LABEL_SIZE
	_center_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_center_label.z_index = 101
	add_child(_center_label)

	if hijacked:
		var purify := _make_option_button("Purify")
		purify.disabled = not actions_enabled
		purify.pressed.connect(_on_purify_pressed)
		_option_buttons.append(purify)
		return

	if tower.can_upgrade():
		var cost := tower.get_upgrade_cost()
		var upgrade := _make_option_button(
			"Upgrade\n%dG\nLv%d→%d" % [cost, tower.level, tower.level + 1]
		)
		var can_pay := context.economy != null and context.economy.can_afford_gold(cost)
		upgrade.disabled = not actions_enabled or not can_pay
		upgrade.pressed.connect(_on_upgrade_pressed)
		_option_buttons.append(upgrade)
	else:
		var max_btn := _make_option_button("Max\nLv %d" % tower.level)
		max_btn.disabled = true
		_option_buttons.append(max_btn)

	var sell := _make_option_button("Sell\n+%dG" % tower.get_sell_refund())
	sell.disabled = not actions_enabled
	sell.pressed.connect(_on_sell_pressed)
	_option_buttons.append(sell)


func _make_option_button(text: String) -> Button:
	var btn := Button.new()
	btn.custom_minimum_size = BUTTON_SIZE
	btn.text = text
	btn.add_theme_font_size_override("font_size", 10)
	btn.z_index = 101
	add_child(btn)
	move_child(btn, -1)
	return btn


func _position_options() -> void:
	if _spot == null:
		return
	var vp := get_viewport()
	if vp == null:
		return
	var screen_pos := BattleUiCoords.world_to_screen(vp, _spot.global_position)
	var count := _option_buttons.size()
	if count == 0:
		return
	var start_angle := -PI * 0.5
	var step := TAU / float(count)
	for i in count:
		var angle := start_angle + step * float(i)
		var offset := Vector2(cos(angle), sin(angle)) * OPTION_RADIUS
		var btn := _option_buttons[i]
		btn.position = screen_pos + offset - BUTTON_SIZE * 0.5
		btn.position = _clamp_control_position(btn.position, BUTTON_SIZE)


func _position_center_label() -> void:
	if _center_label == null or _spot == null:
		return
	var vp := get_viewport()
	if vp == null:
		return
	var screen_pos := BattleUiCoords.world_to_screen(vp, _spot.global_position)
	_center_label.position = screen_pos - CENTER_LABEL_SIZE * 0.5
	_center_label.position = _clamp_control_position(_center_label.position, CENTER_LABEL_SIZE)


func _clamp_control_position(pos: Vector2, size: Vector2) -> Vector2:
	var vp := get_viewport_rect().size
	return Vector2(
		clampf(pos.x, 8.0, vp.x - size.x - 8.0),
		clampf(pos.y, 8.0, vp.y - size.y - 8.0)
	)


func _can_act() -> bool:
	if context == null or context.state_controller == null:
		return false
	var state := context.state_controller.current_state
	return state == GameEnums.BattleState.PRE_BATTLE or state == GameEnums.BattleState.WAVE_ACTIVE


func _on_build_option_pressed(tower_id: String) -> void:
	if _spot == null or context == null or context.tower_manager == null:
		hide_menu()
		return
	context.tower_manager.try_build_on_spot(_spot, tower_id)
	hide_menu()


func _on_upgrade_pressed() -> void:
	if _spot == null or _spot.tower == null or context == null or context.tower_manager == null:
		return
	if context.tower_manager.try_upgrade_tower(_spot.tower):
		_rebuild_manage_options()
		_position_options()
		_position_center_label()
		_refresh_range_ring()


func _on_build_option_hovered(tower_id: String) -> void:
	_show_build_preview(tower_id)


func _default_build_preview_tower_id() -> String:
	for tid in _option_tower_ids:
		var td := ContentRegistry.get_tower(tid)
		if td == null:
			continue
		if context.economy != null and context.economy.can_afford_gold(td.build_cost):
			return tid
	if _option_tower_ids.is_empty():
		return ""
	return _option_tower_ids[0]


func _show_build_preview(tower_id: String) -> void:
	if _range_ring == null or _spot == null or context == null:
		return
	var td := ContentRegistry.get_tower(tower_id)
	if td == null:
		return
	var radius := TowerController.compute_preview_range(context, td, _spot.region_id, 1)
	_range_ring.show_at(_spot.global_position, radius, true)


func _refresh_range_ring() -> void:
	if _range_ring == null or _spot == null:
		return
	if _mode == Mode.MANAGE and _spot.tower != null:
		var radius := _spot.tower.get_effective_range()
		_range_ring.show_at(_spot.global_position, radius, false)
	elif _mode == Mode.BUILD:
		var tid := _default_build_preview_tower_id()
		if tid != "":
			_show_build_preview(tid)
		else:
			_range_ring.hide_ring()
	else:
		_range_ring.hide_ring()


func _on_sell_pressed() -> void:
	if _spot == null or _spot.tower == null or context == null or context.tower_manager == null:
		hide_menu()
		return
	if context.tower_manager.try_sell_tower(_spot.tower):
		hide_menu()


func _on_purify_pressed() -> void:
	if _spot == null or _spot.tower == null:
		return
	if _spot.tower.try_recover_hijack():
		_rebuild_manage_options()
		_position_options()
		_position_center_label()


func _gui_input(event: InputEvent) -> void:
	if not visible or _opening_guard:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		hide_menu()
	elif event is InputEventScreenTouch and event.pressed:
		hide_menu()


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("ui_cancel"):
		hide_menu()
		get_viewport().set_input_as_handled()
