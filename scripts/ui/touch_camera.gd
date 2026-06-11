class_name TouchCamera
extends Camera2D

const DRAG_THRESHOLD := 12.0
const PINCH_COOLDOWN := 0.15

@export var pan_speed: float = 1.0
@export var min_zoom: float = 0.65
@export var max_zoom: float = 1.2
@export var locked_zoom_out_factor: float = 1.0
@export var locked_zoom_in_factor: float = 1.2

var _dragging: bool = false
var _last_pos: Vector2 = Vector2.ZERO
var _pan_start_pos: Vector2 = Vector2.ZERO
var _pan_moved: bool = false
var _touch_count: int = 0
var _pinch_active: bool = false
var _pinch_cooldown: float = 0.0
var _anchors: Array[Vector2] = []
var _world_bounds: Rect2 = Rect2(Vector2.ZERO, MapCameraUtils.VIEWPORT_SIZE)
var _focus_tween: Tween = null
var _camera_locked: bool = false
var _fit_zoom: float = 1.0
var _shake_strength: float = 0.0
var _shake_decay: float = 10.0
var _level: LevelData = null


func configure_from_level(level: LevelData) -> void:
	_level = level
	_anchors = level.camera_anchors.duplicate()
	if level.minimap_bounds.size.length_squared() > 0.0 and level.uses_large_map_camera:
		_world_bounds = level.minimap_bounds
	else:
		_world_bounds = MapCameraUtils.compute_battle_view_bounds(level)
	_camera_locked = not level.uses_large_map_camera
	_apply_fit_zoom(true)


func get_fit_zoom() -> float:
	return _fit_zoom


func is_camera_locked() -> bool:
	return _camera_locked


func get_world_bounds() -> Rect2:
	return _world_bounds


func get_anchors() -> Array[Vector2]:
	return _anchors


func jump_to_anchor(index: int, instant: bool = false) -> void:
	if _camera_locked:
		return
	if index < 0 or index >= _anchors.size():
		return
	focus_on(_anchors[index], not instant)


func focus_on(world_pos: Vector2, tween: bool = true) -> void:
	if _camera_locked:
		return
	var target := MapCameraUtils.clamp_camera_center(
		world_pos, _world_bounds, zoom.x, _viewport_size()
	)
	if not tween:
		global_position = target
		return
	if _focus_tween and _focus_tween.is_valid():
		_focus_tween.kill()
	_focus_tween = create_tween()
	_focus_tween.tween_property(self, "global_position", target, 0.35)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


func is_world_visible(world_pos: Vector2, margin: float = 24.0) -> bool:
	return get_visible_world_rect().grow(margin).has_point(world_pos)


func get_visible_world_rect() -> Rect2:
	var half := _viewport_size() / (2.0 * zoom.x)
	return Rect2(global_position - half, half * 2.0)


func should_block_battlefield_tap() -> bool:
	if _touch_count >= 2 or _pinch_active:
		return true
	if _camera_locked:
		return false
	return _pan_moved


func get_touch_count() -> int:
	return _touch_count


func request_shake(strength: float = 6.0) -> void:
	strength *= AccessibilityHelper.shake_strength_multiplier()
	if strength <= 0.01:
		return
	_shake_strength = maxf(_shake_strength, strength)


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_SIZE_CHANGED and _level != null:
		_apply_fit_zoom(false)


func _process(delta: float) -> void:
	if _pinch_cooldown > 0.0:
		_pinch_cooldown = maxf(0.0, _pinch_cooldown - delta)
		if _pinch_cooldown <= 0.0:
			_pinch_active = false
	if _shake_strength > 0.05:
		offset = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * _shake_strength
		_shake_strength = move_toward(_shake_strength, 0.0, _shake_decay * delta)
	else:
		offset = Vector2.ZERO
		_shake_strength = 0.0


func _unhandled_input(event: InputEvent) -> void:
	if _handle_desktop_zoom(event):
		return
	if event is InputEventScreenTouch:
		_handle_screen_touch(event as InputEventScreenTouch)
	elif event is InputEventMagnifyGesture:
		var magnify := event as InputEventMagnifyGesture
		if _camera_locked and magnify.factor < 1.0:
			return
		_pinch_active = true
		_pinch_cooldown = PINCH_COOLDOWN
		_dragging = false
		_apply_zoom_at(magnify.position, magnify.factor)
	elif not _camera_locked:
		if event is InputEventScreenDrag:
			_handle_screen_drag(event as InputEventScreenDrag)
		elif event is InputEventMouseButton:
			_handle_mouse_button(event as InputEventMouseButton)
		elif event is InputEventMouseMotion:
			_handle_mouse_motion(event as InputEventMouseMotion)


func _handle_screen_touch(event: InputEventScreenTouch) -> void:
	if event.pressed:
		_touch_count += 1
		if _touch_count == 1:
			_dragging = not _camera_locked
			_last_pos = event.position
			_pan_start_pos = event.position
			_pan_moved = false
		else:
			_dragging = false
	else:
		_touch_count = maxi(0, _touch_count - 1)
		if _touch_count == 0:
			_dragging = false


func _handle_screen_drag(event: InputEventScreenDrag) -> void:
	if not _dragging or _touch_count != 1 or _pinch_active:
		return
	if event.position.distance_to(_pan_start_pos) >= DRAG_THRESHOLD:
		_pan_moved = true
	var delta: Vector2 = (event.position - _last_pos) * pan_speed
	global_position -= delta / zoom
	_last_pos = event.position
	_clamp_position()


func _handle_mouse_button(event: InputEventMouseButton) -> void:
	if event.button_index != MOUSE_BUTTON_LEFT:
		return
	if event.pressed:
		_dragging = true
		_last_pos = event.position
		_pan_start_pos = event.position
		_pan_moved = false
	else:
		_dragging = false


func _handle_mouse_motion(event: InputEventMouseMotion) -> void:
	if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) or not _dragging:
		return
	if event.position.distance_to(_pan_start_pos) >= DRAG_THRESHOLD:
		_pan_moved = true
	var delta: Vector2 = (event.position - _last_pos) * pan_speed
	global_position -= delta / zoom
	_last_pos = event.position
	_clamp_position()


func _handle_desktop_zoom(event: InputEvent) -> bool:
	if not event is InputEventMouseButton or not event.pressed:
		return false
	var factor := 0.0
	if event.button_index == MOUSE_BUTTON_WHEEL_UP:
		factor = 1.05
	elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
		factor = 1.0 / 1.05
	else:
		return false
	if _camera_locked and factor < 1.0:
		return false
	_apply_zoom_at(event.position, factor)
	get_viewport().set_input_as_handled()
	return true


func _apply_zoom_at(screen_pos: Vector2, factor: float) -> void:
	var old_z := zoom.x
	var new_z := clampf(old_z * factor, min_zoom, max_zoom)
	if is_equal_approx(old_z, new_z):
		return
	var viewport_size := _viewport_size()
	var pan_offset := screen_pos - viewport_size * 0.5
	var world_at_cursor := global_position + pan_offset / old_z
	zoom = Vector2(new_z, new_z)
	global_position = world_at_cursor - pan_offset / new_z
	if zoom.x < min_zoom:
		zoom = Vector2(min_zoom, min_zoom)
	_clamp_position()


func _apply_fit_zoom(initial: bool) -> void:
	var fit_mode := MapCameraUtils.FitMode.COVER if _camera_locked else MapCameraUtils.FitMode.CONTAIN
	var fit := MapCameraUtils.compute_fit_to_view(_world_bounds, _viewport_size(), fit_mode)
	_fit_zoom = fit.zoom
	if _camera_locked:
		min_zoom = _fit_zoom
		max_zoom = _fit_zoom * locked_zoom_in_factor
	else:
		min_zoom = _fit_zoom
		max_zoom = maxf(_fit_zoom, max_zoom)
	if initial:
		global_position = fit.center
		zoom = Vector2(_fit_zoom, _fit_zoom)
	else:
		var new_z := clampf(zoom.x, min_zoom, max_zoom)
		zoom = Vector2(new_z, new_z)
		if _camera_locked:
			global_position = fit.center
	_clamp_position()


func _clamp_position() -> void:
	global_position = MapCameraUtils.clamp_camera_center(
		global_position, _world_bounds, zoom.x, _viewport_size()
	)


func _viewport_size() -> Vector2:
	var vp := get_viewport()
	if vp:
		return vp.get_visible_rect().size
	return MapCameraUtils.VIEWPORT_SIZE
