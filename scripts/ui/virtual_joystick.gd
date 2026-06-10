class_name VirtualJoystick
extends Control

signal direction_changed(direction: Vector2)

const BASE_RADIUS := 56.0
const KNOB_RADIUS := 24.0
const DEADZONE := 0.12

var _active: bool = false
var _touch_index: int = -1
var _base_center: Vector2 = Vector2.ZERO
var _direction: Vector2 = Vector2.ZERO
var _base_color := Color(0.08, 0.1, 0.12, 0.45)
var _knob_color := Color(0.85, 0.75, 0.45, 0.85)


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT)
	offset_left = 12.0
	offset_top = -200.0
	offset_right = 140.0
	offset_bottom = -12.0


func get_direction() -> Vector2:
	return _direction


func is_active() -> bool:
	return _active


func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		_handle_screen_touch(event as InputEventScreenTouch)
	elif event is InputEventScreenDrag:
		_handle_screen_drag(event as InputEventScreenDrag)
	elif event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index != MOUSE_BUTTON_LEFT:
			return
		if mb.pressed:
			_begin_at(mb.position)
		elif _active and _touch_index == -1:
			_end()
	elif event is InputEventMouseMotion and _active and _touch_index == -1:
		_update_knob((event as InputEventMouseMotion).position)


func _handle_screen_touch(event: InputEventScreenTouch) -> void:
	if event.pressed:
		if not _active:
			_begin_at(event.position, event.index)
	elif _active and event.index == _touch_index:
		_end()


func _handle_screen_drag(event: InputEventScreenDrag) -> void:
	if _active and event.index == _touch_index:
		_update_knob(event.position)


func _begin_at(local_pos: Vector2, touch_index: int = -1) -> void:
	_active = true
	_touch_index = touch_index
	_base_center = local_pos
	_update_knob(local_pos)
	accept_event()


func _update_knob(local_pos: Vector2) -> void:
	var offset := local_pos - _base_center
	var max_dist := BASE_RADIUS
	if offset.length() > max_dist:
		offset = offset.normalized() * max_dist
	var raw := offset / max_dist if max_dist > 0.0 else Vector2.ZERO
	if raw.length() < DEADZONE:
		_direction = Vector2.ZERO
	else:
		_direction = raw.normalized() * clampf((raw.length() - DEADZONE) / (1.0 - DEADZONE), 0.0, 1.0)
	direction_changed.emit(_direction)
	queue_redraw()


func _end() -> void:
	_active = false
	_touch_index = -1
	_direction = Vector2.ZERO
	direction_changed.emit(_direction)
	queue_redraw()


func _draw() -> void:
	if not _active:
		draw_circle(size * 0.5, BASE_RADIUS, _base_color)
		draw_circle(size * 0.5, KNOB_RADIUS, _knob_color * Color(1, 1, 1, 0.55))
		return
	var center := _base_center
	var knob := center + _direction.normalized() * BASE_RADIUS * clampf(_direction.length(), 0.0, 1.0) \
		if _direction.length() > 0.01 else center
	draw_circle(center, BASE_RADIUS, _base_color)
	draw_circle(knob, KNOB_RADIUS, _knob_color)
