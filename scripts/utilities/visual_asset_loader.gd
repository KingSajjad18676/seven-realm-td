class_name VisualAssetLoader
extends RefCounted

## Loads sprites from art paths when present; falls back to ColorRect tinting.


static func apply_sprite(node: Node2D, sprite_path: String, fallback_color: Color, size: Vector2 = Vector2(32, 32)) -> void:
	if sprite_path != "" and ResourceLoader.exists(sprite_path):
		var tex := load(sprite_path) as Texture2D
		if tex != null:
			var spr := node.get_node_or_null("ArtSprite") as Sprite2D
			if spr == null:
				spr = Sprite2D.new()
				spr.name = "ArtSprite"
				node.add_child(spr)
			spr.texture = tex
			spr.centered = true
			var scale_factor := size / tex.get_size()
			spr.scale = Vector2(scale_factor.x, scale_factor.y)
			var rect := node.get_node_or_null("Sprite") as ColorRect
			if rect:
				rect.visible = false
			return
	var rect := node.get_node_or_null("Sprite") as ColorRect
	if rect:
		rect.visible = true
		rect.color = fallback_color
		rect.size = size
		rect.position = -size * 0.5


static func khan1_sprite(entity_id: String) -> String:
	var base := "res://art/_placeholders/khan1/%s.png" % entity_id
	if ResourceLoader.exists(base):
		return base
	return ""


static func map_sprite(level_id: String) -> String:
	var base := "res://art/_placeholders/maps/%s.png" % level_id
	if ResourceLoader.exists(base):
		return base
	return ""


static func map_terrain_color(level_id: String) -> Color:
	match level_id:
		"level_00_tutorial":
			return Color(0.18, 0.28, 0.2)
		"level_01":
			return Color(0.15, 0.22, 0.14)
		"level_02":
			return Color(0.28, 0.22, 0.14)
		"level_03":
			return Color(0.12, 0.2, 0.18)
		"level_04":
			return Color(0.2, 0.14, 0.22)
		"level_05":
			return Color(0.22, 0.18, 0.12)
		"level_06":
			return Color(0.14, 0.14, 0.2)
		"level_07":
			return Color(0.2, 0.22, 0.26)
		"level_08_damavand":
			return Color(0.1, 0.12, 0.18)
		_:
			return Color(0.15, 0.22, 0.14)
