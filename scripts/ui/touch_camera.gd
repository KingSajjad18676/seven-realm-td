class_name TouchCamera
extends Camera2D

@export var pan_speed: float = 1.0
@export var min_zoom: float = 0.65
@export var max_zoom: float = 1.2

var _dragging: bool = false
var _last_pos: Vector2 = Vector2.ZERO
var _large_map: bool = false
var _anchors: Array[Vector2] = []
var _bounds_min := Vector2(500.0, 320.0)
var _bounds_max := Vector2(900.0, 400.0)


func configure_large_map(anchors: Array[Vector2], gate_pos: Vector2) -> void:
	_large_map = true
	_anchors = anchors
	if anchors.size() > 0:
		_bounds_min = Vector2(200.0, 150.0)
		_bounds_max = Vector2(1300.0, 500.0)
		global_position = anchors[0]
	else:
		global_position = gate_pos * 0.5


func jump_to_anchor(index: int) -> void:
	if not _large_map or index < 0 or index >= _anchors.size():
		return
	global_position = _anchors[index]


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			_dragging = true
			_last_pos = event.position
		else:
			_dragging = false
	elif event is InputEventScreenDrag and _dragging:
		var delta := (event.position - _last_pos) * pan_speed / zoom
		global_position -= delta / zoom
		_last_pos = event.position
		_clamp_position()
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			zoom = (zoom * 1.05).clamp(Vector2(min_zoom, min_zoom), Vector2(max_zoom, max_zoom))
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			zoom = (zoom / 1.05).clamp(Vector2(min_zoom, min_zoom), Vector2(max_zoom, max_zoom))
	elif event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if not _dragging:
			_dragging = true
			_last_pos = event.position
		var delta := (event.position - _last_pos) * pan_speed / zoom
		global_position -= delta / zoom
		_last_pos = event.position
		_clamp_position()


func _clamp_position() -> void:
	global_position.x = clampf(global_position.x, _bounds_min.x, _bounds_max.x)
	global_position.y = clampf(global_position.y, _bounds_min.y, _bounds_max.y)
