class_name VisualAssetLoader
extends RefCounted

## Loads sprites from art paths when present; falls back to ColorRect tinting.


static func apply_sprite(
	node: Node2D,
	sprite_path: String,
	fallback_color: Color,
	size: Vector2 = Vector2(32, 32),
	entity_key: String = ""
) -> void:
	if entity_key != "" and CosmeticService:
		fallback_color = CosmeticService.get_entity_tint(entity_key, fallback_color)
	if sprite_path != "" and ResourceLoader.exists(sprite_path):
		var tex := load(sprite_path) as Texture2D
		if tex != null:
			_apply_texture_sprite(node, tex, size)
			return
	var generated := _make_circle_texture(fallback_color, int(maxf(size.x, size.y)))
	if generated:
		_apply_texture_sprite(node, generated, size)
		return
	var rect := node.get_node_or_null("Sprite") as ColorRect
	if rect:
		rect.visible = true
		rect.color = fallback_color
		rect.size = size
		rect.position = -size * 0.5


static func _apply_texture_sprite(node: Node2D, tex: Texture2D, size: Vector2) -> void:
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


static func _make_circle_texture(color: Color, diameter: int) -> ImageTexture:
	var d := maxi(diameter, 8)
	var img := Image.create(d, d, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	var r := d * 0.5
	var r2 := r * r
	for y in d:
		for x in d:
			var dx := float(x) - r + 0.5
			var dy := float(y) - r + 0.5
			if dx * dx + dy * dy <= r2:
				img.set_pixel(x, y, color)
	var tex := ImageTexture.create_from_image(img)
	return tex


static func khan1_sprite(entity_id: String) -> String:
	var base := "res://art/_placeholders/khan1/%s.png" % entity_id
	if ResourceLoader.exists(base):
		return base
	return ""


static func make_portrait_texture(
	entity_id: String,
	fallback_color: Color,
	diameter: int = 48,
	portrait_path: String = ""
) -> Texture2D:
	if portrait_path != "" and ResourceLoader.exists(portrait_path):
		var portrait_tex := load(portrait_path) as Texture2D
		if portrait_tex != null:
			return portrait_tex
	var path := khan1_sprite(entity_id)
	if path != "" and ResourceLoader.exists(path):
		var tex := load(path) as Texture2D
		if tex != null:
			return tex
	return _make_circle_texture(fallback_color, diameter)


static func infer_square_strip_frame_count(tex: Texture2D) -> int:
	if tex == null:
		return 1
	var full_size := tex.get_size()
	if full_size.y <= 0.0:
		return 1
	return maxi(1, int(round(full_size.x / full_size.y)))


static func build_sprite_frames_from_strip(strip: HeroAnimStripDef) -> SpriteFrames:
	var sf := SpriteFrames.new()
	if strip == null or strip.strip_path == "":
		return sf
	if not ResourceLoader.exists(strip.strip_path):
		return sf
	var tex := load(strip.strip_path) as Texture2D
	if tex == null:
		return sf
	var frame_count := strip.frame_count
	if frame_count <= 0:
		frame_count = infer_square_strip_frame_count(tex)
	var full_size := tex.get_size()
	var cell_w := full_size.x / float(frame_count)
	var cell_h := full_size.y
	sf.add_animation(strip.anim_name)
	sf.set_animation_loop(strip.anim_name, strip.loop)
	sf.set_animation_speed(strip.anim_name, strip.fps)
	for i in frame_count:
		var atlas := AtlasTexture.new()
		atlas.atlas = tex
		atlas.region = Rect2(i * cell_w, 0.0, cell_w, cell_h)
		sf.add_frame(strip.anim_name, atlas)
	return sf


static func build_hero_sprite_frames(anim_data: HeroAnimData) -> SpriteFrames:
	var merged := SpriteFrames.new()
	if anim_data == null:
		return merged
	for strip in anim_data.strips:
		var partial := build_sprite_frames_from_strip(strip)
		for anim_name in partial.get_animation_names():
			if merged.has_animation(anim_name):
				merged.remove_animation(anim_name)
			merged.add_animation(anim_name)
			merged.set_animation_loop(anim_name, partial.get_animation_loop(anim_name))
			merged.set_animation_speed(anim_name, partial.get_animation_speed(anim_name))
			var frame_count := partial.get_frame_count(anim_name)
			for frame_idx in frame_count:
				merged.add_frame(anim_name, partial.get_frame_texture(anim_name, frame_idx))
	return merged


static func apply_hero_visual(node: Node2D, anim_data: HeroAnimData) -> AnimatedSprite2D:
	var rect := node.get_node_or_null("Sprite") as ColorRect
	if rect:
		rect.visible = false
	var existing_sprite := node.get_node_or_null("ArtSprite") as Sprite2D
	if existing_sprite:
		existing_sprite.queue_free()
	var existing_anim := node.get_node_or_null("HeroAnim") as AnimatedSprite2D
	if existing_anim:
		existing_anim.queue_free()
	var sprite_frames := build_hero_sprite_frames(anim_data)
	if sprite_frames.get_animation_names().is_empty():
		return null
	var anim := AnimatedSprite2D.new()
	anim.name = "HeroAnim"
	anim.sprite_frames = sprite_frames
	anim.animation = "idle"
	anim.play("idle")
	var idle_strip := anim_data.find_strip("idle")
	var cell_h := anim_data.display_size.y
	if idle_strip != null and ResourceLoader.exists(idle_strip.strip_path):
		var tex := load(idle_strip.strip_path) as Texture2D
		if tex != null:
			cell_h = tex.get_size().y
	var scale_factor := anim_data.display_size.y / maxf(cell_h, 1.0)
	anim.scale = Vector2(scale_factor, scale_factor)
	anim.position.y = -anim_data.display_size.y * 0.5
	node.add_child(anim)
	return anim


static func map_sprite(level_id: String) -> String:
	var production := _production_map_sprite(level_id)
	if production != "":
		return production
	var base := "res://art/_placeholders/maps/%s.png" % level_id
	if ResourceLoader.exists(base):
		return base
	return ""


static func _production_map_sprite(level_id: String) -> String:
	match level_id:
		"level_01":
			var p := "res://art/maps/campaign/khan_01_map.png"
			if ResourceLoader.exists(p):
				return p
		"level_00_tutorial":
			var t := "res://art/maps/tutorial/toturial_map.png"
			if ResourceLoader.exists(t):
				return t
	return ""


static func loading_sprite(level_id: String) -> String:
	var placeholder := "res://art/_placeholders/loading/%s.png" % level_id
	if ResourceLoader.exists(placeholder):
		return placeholder
	var production_jpg := "res://art/loading/%s.jpg" % level_id
	if ResourceLoader.exists(production_jpg):
		return production_jpg
	var production_png := "res://art/loading/%s.png" % level_id
	if ResourceLoader.exists(production_png):
		return production_png
	return map_sprite(level_id)


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
