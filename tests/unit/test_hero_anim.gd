extends GutTest

const HERO_SCENE := preload("res://scenes/prefabs/hero.tscn")


func test_rostam_anim_includes_walk_and_dying() -> void:
	var anim := ContentCatalog.build_rostam_anim()
	var names: PackedStringArray = PackedStringArray()
	for strip in anim.strips:
		names.append(strip.anim_name)
	assert_true(names.has("walk"))
	assert_true(names.has("dying"))


func test_play_hero_anim_restarts_attack_from_frame_zero() -> void:
	if not ResourceLoader.exists("res://art/heroes/rostam/rostam_idle.png"):
		pass_test("rostam art not imported in CI")
		return
	var hero := HERO_SCENE.instantiate() as HeroController
	add_child_autofree(hero)
	hero.set_physics_process(false)
	var ctx := BattleTestFixtures.minimal_context(self)
	hero.initialize(ctx, ContentRegistry.get_hero("rostam"), Vector2.ZERO)
	await get_tree().process_frame
	var anim_sprite := hero.get_node_or_null("HeroAnim") as AnimatedSprite2D
	assert_not_null(anim_sprite)
	hero._play_hero_anim("attack")
	await get_tree().process_frame
	hero._play_hero_anim("attack")
	assert_eq(anim_sprite.frame, 0, "Repeated attack should restart from frame 0")
	assert_eq(anim_sprite.animation, "attack")


func test_infer_square_strip_frame_count() -> void:
	if not ResourceLoader.exists("res://art/heroes/rostam/rostam_walk.png"):
		pass_test("rostam walk art not imported in CI")
		return
	var tex := load("res://art/heroes/rostam/rostam_walk.png") as Texture2D
	var count := VisualAssetLoader.infer_square_strip_frame_count(tex)
	assert_gt(count, 1, "Walk strip should infer multiple square frames")
