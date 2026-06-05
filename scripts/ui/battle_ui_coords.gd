class_name BattleUiCoords
extends RefCounted


static func world_to_screen(viewport: Viewport, world_pos: Vector2) -> Vector2:
	if viewport == null:
		return world_pos
	return viewport.get_canvas_transform() * world_pos
