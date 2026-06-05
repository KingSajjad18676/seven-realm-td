class_name TowerBuildDragController
extends Control

const DRAG_THRESHOLD := 12.0

var context: BattleContext = null
var _ghost: Control = null
var _ghost_label: Label = null
var _armed: bool = false
var _dragging: bool = false
var _armed_tower_id: String = ""
var _start_pos: Vector2 = Vector2.ZERO
var _highlighted_spot: BuildSpot = null


func initialize(ctx: BattleContext) -> void:
	context = ctx
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)


func register_tower_button(btn: Button, tower_id: String) -> void:
	btn.gui_input.connect(_on_button_gui_input.bind(btn, tower_id))


func _on_button_gui_input(event: InputEvent, _btn: Button, tower_id: String) -> void:
	if not _allows_tower_input():
		if _is_press(event):
			get_viewport().set_input_as_handled()
		return
	if _is_press(event):
		_armed = true
		_dragging = false
		_armed_tower_id = tower_id
		_start_pos = _event_pos(event)
	elif _is_release(event) and _armed and not _dragging:
		_armed = false
		_armed_tower_id = ""


func _input(event: InputEvent) -> void:
	if not _armed and not _dragging:
		return
	if event is InputEventScreenDrag or (
		event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	):
		var pos := _event_pos(event)
		if _armed and not _dragging and pos.distance_to(_start_pos) >= DRAG_THRESHOLD:
			_begin_drag()
		if _dragging:
			_update_ghost(pos)
			_update_pad_highlight(pos)
			get_viewport().set_input_as_handled()
	elif _is_release(event):
		if _dragging:
			_finish_drag(_event_pos(event))
			get_viewport().set_input_as_handled()
		_reset_drag_state()


func _allows_tower_input() -> bool:
	if context == null:
		return true
	if context.tutorial_active and not context.tutorial_allows("tower_buttons"):
		return false
	return true


func _begin_drag() -> void:
	_dragging = true
	if context and context.tower_manager:
		context.tower_manager.selected_tower_id = _armed_tower_id
	var td := ContentRegistry.get_tower(_armed_tower_id)
	_ghost = Control.new()
	_ghost.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ghost.custom_minimum_size = Vector2(72, 72)
	_ghost.size = Vector2(72, 72)
	var bg := ColorRect.new()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.color = td.color if td else Color(0.4, 0.7, 0.6, 0.85)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ghost.add_child(bg)
	_ghost_label = Label.new()
	_ghost_label.text = td.display_name if td else "Tower"
	_ghost_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_ghost_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_ghost_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_ghost_label.add_theme_font_size_override("font_size", 10)
	_ghost_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ghost.add_child(_ghost_label)
	add_child(_ghost)
	_update_ghost(_start_pos)


func _update_ghost(screen_pos: Vector2) -> void:
	if _ghost:
		_ghost.global_position = screen_pos - _ghost.size * 0.5


func _update_pad_highlight(screen_pos: Vector2) -> void:
	if context == null or context.tower_manager == null:
		return
	var world := _screen_to_world(screen_pos)
	var spot := context.tower_manager.find_spot_at(world)
	if spot == _highlighted_spot:
		return
	if _highlighted_spot:
		_highlighted_spot.set_drag_highlight(false)
	_highlighted_spot = spot
	if _highlighted_spot:
		_highlighted_spot.set_drag_highlight(true)


func _finish_drag(screen_pos: Vector2) -> void:
	if context == null or context.tower_manager == null:
		return
	var world := _screen_to_world(screen_pos)
	var spot := context.tower_manager.find_spot_at(world)
	if spot:
		context.tower_manager.try_build_on_spot(spot, _armed_tower_id)
	_clear_ghost()


func _clear_ghost() -> void:
	if _highlighted_spot:
		_highlighted_spot.set_drag_highlight(false)
		_highlighted_spot = null
	if _ghost:
		_ghost.queue_free()
		_ghost = null
		_ghost_label = null


func _reset_drag_state() -> void:
	_clear_ghost()
	_armed = false
	_dragging = false
	_armed_tower_id = ""


func _screen_to_world(screen_pos: Vector2) -> Vector2:
	var canvas := get_viewport().get_canvas_transform()
	return canvas.affine_inverse() * screen_pos


func _is_press(event: InputEvent) -> bool:
	if event is InputEventScreenTouch:
		return event.pressed
	if event is InputEventMouseButton:
		return event.pressed and event.button_index == MOUSE_BUTTON_LEFT
	return false


func _is_release(event: InputEvent) -> bool:
	if event is InputEventScreenTouch:
		return not event.pressed
	if event is InputEventMouseButton:
		return not event.pressed and event.button_index == MOUSE_BUTTON_LEFT
	return false


func _event_pos(event: InputEvent) -> Vector2:
	if event is InputEventScreenTouch or event is InputEventScreenDrag:
		return event.position
	if event is InputEventMouseButton or event is InputEventMouseMotion:
		return event.position
	return Vector2.ZERO
