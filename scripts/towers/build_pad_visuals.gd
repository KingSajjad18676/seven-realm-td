class_name BuildPadVisuals
extends RefCounted

const PAD_RADIUS := 26.0
const PAD_DIAMETER := PAD_RADIUS * 2.0

static func draw_empty_pad(canvas: CanvasItem, highlighted: bool = false) -> void:
	var fill := Color(0.62, 0.48, 0.32, 0.82) if not highlighted else Color(0.78, 0.62, 0.38, 0.92)
	var ring := Color(0.28, 0.18, 0.1, 0.95) if not highlighted else Color(0.95, 0.82, 0.35, 1.0)
	canvas.draw_circle(Vector2.ZERO, PAD_RADIUS, fill)
	canvas.draw_arc(Vector2.ZERO, PAD_RADIUS, 0.0, TAU, 32, ring, 2.5)
	_draw_hammer_glyph(canvas)


static func _draw_hammer_glyph(canvas: CanvasItem) -> void:
	var head := Color(0.22, 0.14, 0.08, 0.95)
	canvas.draw_rect(Rect2(-7, -11, 14, 8), head)
	canvas.draw_rect(Rect2(-2, -3, 4, 14), head)
