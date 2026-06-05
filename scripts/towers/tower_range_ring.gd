class_name TowerRangeRing
extends Node2D

const FILL_MANAGE := Color(0.35, 0.75, 0.65, 0.12)
const RING_MANAGE := Color(0.45, 0.85, 0.75, 0.55)
const FILL_PREVIEW := Color(0.55, 0.75, 0.95, 0.08)
const RING_PREVIEW := Color(0.65, 0.85, 1.0, 0.4)

var _radius: float = 0.0
var _ring_visible: bool = false
var _preview_mode: bool = false


func show_at(world_pos: Vector2, radius: float, preview: bool = false) -> void:
	if radius <= 0.0:
		hide_ring()
		return
	global_position = world_pos
	_radius = radius
	_preview_mode = preview
	_ring_visible = true
	visible = true
	queue_redraw()


func hide_ring() -> void:
	_radius = 0.0
	_ring_visible = false
	visible = false
	queue_redraw()


func refresh_radius(radius: float) -> void:
	if not _ring_visible:
		return
	if radius <= 0.0:
		hide_ring()
		return
	_radius = radius
	queue_redraw()


func is_showing() -> bool:
	return _ring_visible


func get_radius() -> float:
	return _radius if _ring_visible else 0.0


func _draw() -> void:
	if not _ring_visible or _radius <= 0.0:
		return
	var fill := FILL_PREVIEW if _preview_mode else FILL_MANAGE
	var ring := RING_PREVIEW if _preview_mode else RING_MANAGE
	var width := 1.5 if _preview_mode else 2.0
	draw_circle(Vector2.ZERO, _radius, fill)
	draw_arc(Vector2.ZERO, _radius, 0.0, TAU, 64, ring, width)
