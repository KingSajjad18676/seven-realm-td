extends GutTest

var _hero: HeroController
var _ctx: BattleContext


func before_each() -> void:
	_ctx = BattleTestFixtures.context_with_level(self)
	var state := BattleStateController.new()
	add_child_autofree(state)
	state.initialize(_ctx)
	_ctx.state_controller = state
	_hero = preload("res://scenes/prefabs/hero.tscn").instantiate() as HeroController
	add_child_autofree(_hero)
	var hero_data := HeroData.new()
	hero_data.max_hp = 100.0
	hero_data.respawn_cooldown = 0.5
	_hero.initialize(_ctx, hero_data, Vector2(100, 100))
	await get_tree().process_frame


func test_hero_respawns_after_cooldown_instead_of_instant_defeat() -> void:
	_hero.take_damage(200.0)
	assert_true(_hero.is_dead())
	assert_false(_hero.visible)
	await get_tree().create_timer(0.6).timeout
	assert_false(_hero.is_dead())
	assert_true(_hero.visible)
	assert_gt(_hero.current_hp, 0.0)
