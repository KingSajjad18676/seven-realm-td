class_name MapEditorCamera
extends Camera2D

signal zoom_changed(zoom_level: float)

const MIN_ZOOM := 0.35
const MAX_ZOOM := 2.5
const ZOOM_STEP := 1.05

var _last_pos: Vector2 = Vector2.ZERO
var _world_bounds: Rect2 = Rect2(Vector2.ZERO, MapEditorUtils.VIEW_SIZE)


func _ready() -> void:
	fit_to_map()
	set_process_unhandled_input(true)


func fit_to_map() -> void:
	zoom = Vector2.ONE
	global_position = MapEditorUtils.VIEW_SIZE * 0.5
	_clamp_position()
	zoom_changed.emit(zoom.x)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		_handle_mouse_button(event as InputEventMouseButton)
	elif event is InputEventMouseMotion:
		_handle_mouse_motion(event as InputEventMouseMotion)


func _is_pan_active() -> bool:
	return Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE) or (
		Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and Input.is_key_pressed(KEY_SPACE)
	)


func _handle_mouse_button(event: InputEventMouseButton) -> void:
	if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
		_apply_zoom_at(event.position, ZOOM_STEP)
	elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
		_apply_zoom_at(event.position, 1.0 / ZOOM_STEP)
	elif event.pressed and (
		event.button_index == MOUSE_BUTTON_MIDDLE
		or (event.button_index == MOUSE_BUTTON_LEFT and Input.is_key_pressed(KEY_SPACE))
	):
		_last_pos = event.position


func _handle_mouse_motion(event: InputEventMouseMotion) -> void:
	if not _is_pan_active():
		return
	var delta: Vector2 = event.position - _last_pos
	global_position -= delta / zoom
	_last_pos = event.position
	_clamp_position()


func _apply_zoom_at(screen_pos: Vector2, factor: float) -> void:
	var old_z := zoom.x
	var new_z := clampf(old_z * factor, MIN_ZOOM, MAX_ZOOM)
	if is_equal_approx(old_z, new_z):
		return
	var viewport_size := _viewport_size()
	var offset := screen_pos - viewport_size * 0.5
	var world_at_cursor := global_position + offset / old_z
	zoom = Vector2(new_z, new_z)
	global_position = world_at_cursor - offset / new_z
	_clamp_position()
	zoom_changed.emit(zoom.x)


func _clamp_position() -> void:
	global_position = MapCameraUtils.clamp_camera_center(
		global_position, _world_bounds, zoom.x, _viewport_size()
	)


func _viewport_size() -> Vector2:
	var vp := get_viewport()
	if vp:
		return vp.get_visible_rect().size
	return MapEditorUtils.VIEW_SIZE
