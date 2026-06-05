class_name TouchCamera
extends Camera2D

const DRAG_THRESHOLD := 12.0
const PINCH_COOLDOWN := 0.15

@export var pan_speed: float = 1.0
@export var min_zoom: float = 0.65
@export var max_zoom: float = 1.2

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


func configure_from_level(level: LevelData) -> void:
	_anchors = level.camera_anchors.duplicate()
	if level.minimap_bounds.size.length_squared() > 0.0:
		_world_bounds = level.minimap_bounds
	else:
		_world_bounds = MapCameraUtils.compute_world_bounds(level)
	if _anchors.size() > 0:
		global_position = _anchors[0]
	elif level.gate_position != Vector2.ZERO:
		global_position = level.gate_position * 0.5
	else:
		global_position = _world_bounds.get_center()
	zoom = Vector2.ONE
	_clamp_position()


func get_world_bounds() -> Rect2:
	return _world_bounds


func get_anchors() -> Array[Vector2]:
	return _anchors


func jump_to_anchor(index: int, instant: bool = false) -> void:
	if index < 0 or index >= _anchors.size():
		return
	focus_on(_anchors[index], not instant)


func focus_on(world_pos: Vector2, tween: bool = true) -> void:
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
	return _touch_count >= 2 or _pinch_active or _pan_moved


func get_touch_count() -> int:
	return _touch_count


func _process(delta: float) -> void:
	if _pinch_cooldown > 0.0:
		_pinch_cooldown = maxf(0.0, _pinch_cooldown - delta)
		if _pinch_cooldown <= 0.0:
			_pinch_active = false


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			_touch_count += 1
			if _touch_count == 1:
				_dragging = true
				_last_pos = event.position
				_pan_start_pos = event.position
				_pan_moved = false
			else:
				_dragging = false
		else:
			_touch_count = maxi(0, _touch_count - 1)
			if _touch_count == 0:
				_dragging = false
	elif event is InputEventScreenDrag and _dragging and _touch_count == 1 and not _pinch_active:
		if event.position.distance_to(_pan_start_pos) >= DRAG_THRESHOLD:
			_pan_moved = true
		var delta: Vector2 = (event.position - _last_pos) * pan_speed
		global_position -= delta / zoom
		_last_pos = event.position
		_clamp_position()
	elif event is InputEventMagnifyGesture:
		_pinch_active = true
		_pinch_cooldown = PINCH_COOLDOWN
		_dragging = false
		_apply_zoom_at(event.position, event.factor)
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			_apply_zoom_at(event.position, 1.05)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			_apply_zoom_at(event.position, 1.0 / 1.05)
		elif event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				_dragging = true
				_last_pos = event.position
				_pan_start_pos = event.position
				_pan_moved = false
			else:
				_dragging = false
	elif event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and _dragging:
		if event.position.distance_to(_pan_start_pos) >= DRAG_THRESHOLD:
			_pan_moved = true
		var delta: Vector2 = (event.position - _last_pos) * pan_speed
		global_position -= delta / zoom
		_last_pos = event.position
		_clamp_position()


func _apply_zoom_at(screen_pos: Vector2, factor: float) -> void:
	var old_z := zoom.x
	var new_z := clampf(old_z * factor, min_zoom, max_zoom)
	if is_equal_approx(old_z, new_z):
		return
	var viewport_size := _viewport_size()
	var offset := screen_pos - viewport_size * 0.5
	var world_at_cursor := global_position + offset / old_z
	zoom = Vector2(new_z, new_z)
	global_position = world_at_cursor - offset / new_z
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
