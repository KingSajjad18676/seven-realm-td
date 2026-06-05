class_name BuildSpot
extends Area2D

signal spot_selected(spot: BuildSpot)

@export var spot_id: String = ""
@export var region_id: String = "region_north"

var occupied: bool = false
var tower: TowerController = null
var battle_context: BattleContext = null

var _highlighted: bool = false

@onready var _collision_shape: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	input_pickable = true
	refresh_pick_collision()
	queue_redraw()


func get_pick_radius() -> float:
	if occupied and tower != null:
		return tower.get_pick_radius()
	return BuildPadVisuals.PAD_RADIUS + 8.0


func refresh_pick_collision() -> void:
	if _collision_shape == null:
		_collision_shape = get_node_or_null("CollisionShape2D") as CollisionShape2D
	if _collision_shape == null or not _collision_shape.shape is CircleShape2D:
		return
	(_collision_shape.shape as CircleShape2D).radius = get_pick_radius()


func _draw() -> void:
	if occupied:
		return
	BuildPadVisuals.draw_empty_pad(self, _highlighted)


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
		if battle_context and battle_context.tutorial_active and not battle_context.tutorial_allows("build_pads"):
			return
		get_viewport().set_input_as_handled()
		spot_selected.emit(self)


func set_drag_highlight(active: bool) -> void:
	if _highlighted == active:
		return
	_highlighted = active
	queue_redraw()


func set_occupied(t: TowerController) -> void:
	occupied = t != null
	tower = t
	refresh_pick_collision()
	if t != null:
		t.refresh_pick_area()
	queue_redraw()
