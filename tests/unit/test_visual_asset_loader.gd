extends GutTest


func test_map_sprite_resolves_production_khan_01() -> void:
	var path := VisualAssetLoader.map_sprite("level_01")
	if ResourceLoader.exists("res://art/maps/campaign/khan_01_map.png"):
		assert_eq(path, "res://art/maps/campaign/khan_01_map.png")
	else:
		pass_test("production map art not imported in CI")


func test_map_sprite_resolves_production_tutorial() -> void:
	var path := VisualAssetLoader.map_sprite("level_00_tutorial")
	if ResourceLoader.exists("res://art/maps/tutorial/toturial_map.png"):
		assert_eq(path, "res://art/maps/tutorial/toturial_map.png")
	else:
		pass_test("production tutorial map art not imported in CI")


func test_build_sprite_frames_from_rostam_idle_strip() -> void:
	var strip := HeroAnimStripDef.new()
	strip.anim_name = "idle"
	strip.strip_path = "res://art/heroes/rostam/rostam_idle.png"
	strip.frame_count = 3
	strip.fps = 6.0
	strip.loop = true
	if not ResourceLoader.exists(strip.strip_path):
		pass_test("rostam_idle.png not imported in CI")
		return
	var sf := VisualAssetLoader.build_sprite_frames_from_strip(strip)
	assert_true(sf.has_animation("idle"))
	assert_eq(sf.get_frame_count("idle"), 3)
	var frame_tex := sf.get_frame_texture("idle", 0) as AtlasTexture
	assert_not_null(frame_tex)
	assert_almost_eq(frame_tex.region.size.x, 724.0, 1.0)
	assert_almost_eq(frame_tex.region.size.y, 724.0, 1.0)


func test_build_rostam_hero_sprite_frames() -> void:
	var anim := ContentCatalog.build_rostam_anim()
	var sf := VisualAssetLoader.build_hero_sprite_frames(anim)
	if not ResourceLoader.exists("res://art/heroes/rostam/rostam_idle.png"):
		pass_test("rostam art not imported in CI")
		return
	assert_true(sf.has_animation("idle"))
	assert_true(sf.has_animation("attack"))
	assert_eq(sf.get_frame_count("attack"), 8)
	if ResourceLoader.exists("res://art/heroes/rostam/rostam_walk.png"):
		assert_true(sf.has_animation("walk"))
		assert_gt(sf.get_frame_count("walk"), 0)


func test_apply_hero_visual_creates_animated_sprite() -> void:
	if not ResourceLoader.exists("res://art/heroes/rostam/rostam_idle.png"):
		pass_test("rostam art not imported in CI")
		return
	var node := Node2D.new()
	add_child_autofree(node)
	var rect := ColorRect.new()
	rect.name = "Sprite"
	node.add_child(rect)
	var anim := ContentCatalog.build_rostam_anim()
	var spr := VisualAssetLoader.apply_hero_visual(node, anim)
	assert_not_null(spr)
	assert_true(node.get_node_or_null("HeroAnim") is AnimatedSprite2D)
