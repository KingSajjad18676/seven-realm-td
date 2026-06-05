class_name BuildSpot
extends Area2D

signal spot_selected(spot: BuildSpot)

@export var spot_id: String = ""
@export var region_id: String = "region_north"

var occupied: bool = false
var tower: TowerController = null

@onready var _pad: ColorRect = $Pad
@onready var _label: Label = $Label


func _ready() -> void:
	input_pickable = true
	if _pad:
		_pad.color = Color(0.25, 0.55, 0.45, 0.35)
		_pad.size = Vector2(48, 48)
		_pad.position = Vector2(-24, -24)
	if _label:
		_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_label.position = Vector2(-30, -40)
		_label.add_theme_font_size_override("font_size", 10)


func _input_event(
	_viewport: Node,
	event: InputEvent,
	_shape_idx: int
) -> void:
	var pressed := false
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		pressed = true
	elif event is InputEventScreenTouch and event.pressed:
		pressed = true
	if pressed:
		get_viewport().set_input_as_handled()
		spot_selected.emit(self)


func set_occupied(t: TowerController) -> void:
	occupied = t != null
	tower = t
	if _pad:
		_pad.color = Color(0.4, 0.35, 0.2, 0.5) if occupied else Color(0.25, 0.55, 0.45, 0.35)
