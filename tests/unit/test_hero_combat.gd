extends "res://addons/gut/test.gd"

const HeroControllerScript := preload("res://scripts/heroes/hero_controller.gd")
const HeroDataScript := preload("res://scripts/data/hero_data.gd")
const VirtualJoystickScript := preload("res://scripts/ui/virtual_joystick.gd")


func test_hero_dodge_iframes_block_damage() -> void:
	var hero := HeroControllerScript.new()
	add_child_autofree(hero)
	var data := HeroDataScript.new()
	data.max_hp = 100.0
	data.dodge_iframe_sec = 0.5
	data.dodge_cooldown = 1.0
	data.dodge_distance = 80.0
	hero.data = data
	hero.current_hp = 100.0
	hero._iframe_remaining = 0.4
	var hp_before := hero.current_hp
	hero.take_damage(25.0)
	assert_eq(hero.current_hp, hp_before, "i-frames should block damage")


func test_hero_attack_sets_cooldown() -> void:
	var hero := HeroControllerScript.new()
	add_child_autofree(hero)
	var data := HeroDataScript.new()
	data.attack_rate = 1.0
	data.attack_damage = 20.0
	hero.data = data
	hero.context = _make_minimal_context()
	hero.attack()
	assert_gt(hero.get_attack_cooldown_remaining(), 0.0, "attack should trigger cooldown")


func test_joystick_direction_normalized() -> void:
	var stick := VirtualJoystickScript.new()
	add_child_autofree(stick)
	stick._begin_at(Vector2(60, 60), 0)
	stick._update_knob(Vector2(60, 10))
	var dir := stick.get_direction()
	assert_gt(dir.length(), 0.5, "stick up should yield strong direction")


func _make_minimal_context() -> BattleContext:
	var ctx := BattleContext.new()
	ctx.state_controller = BattleStateController.new()
	add_child_autofree(ctx.state_controller)
	ctx.state_controller.initialize(ctx)
	ctx.state_controller.current_state = GameEnums.BattleState.WAVE_ACTIVE
	ctx.active_enemies = []
	ctx.runtime_modifiers = {}
	return ctx
