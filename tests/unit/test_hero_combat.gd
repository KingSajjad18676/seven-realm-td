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


func test_joystick_partial_deflection_is_slower_than_full() -> void:
	var stick := VirtualJoystickScript.new()
	add_child_autofree(stick)
	stick._begin_at(Vector2(60, 60), 0)
	stick._update_knob(Vector2(60, 40))
	var partial := stick.get_direction().length()
	stick._update_knob(Vector2(60, 4))
	var full := stick.get_direction().length()
	assert_gt(partial, 0.0, "partial stick should produce movement")
	assert_lt(partial, full, "partial stick should be slower than full deflection")


func test_hero_movement_honors_analog_input() -> void:
	var hero := HeroControllerScript.new()
	add_child_autofree(hero)
	var data := HeroDataScript.new()
	data.move_speed = 100.0
	hero.data = data
	hero.context = _make_minimal_context()
	hero.set_move_input(Vector2.UP * 0.4)
	for _i in 50:
		hero._process_movement(0.1)
	var partial_speed := hero.velocity.length()
	assert_gt(partial_speed, 30.0, "partial input should move hero")
	assert_lt(partial_speed, 80.0, "partial input should stay below max speed")
	hero.set_move_input(Vector2.UP)
	for _i in 50:
		hero._process_movement(0.1)
	assert_gt(hero.velocity.length(), partial_speed, "full stick should exceed partial speed")
	assert_almost_eq(hero.velocity.length(), 100.0, 1.0, "full stick should reach max speed")


func _make_minimal_context() -> BattleContext:
	var ctx := BattleContext.new()
	ctx.state_controller = BattleStateController.new()
	add_child_autofree(ctx.state_controller)
	ctx.state_controller.initialize(ctx)
	ctx.state_controller.current_state = GameEnums.BattleState.WAVE_ACTIVE
	ctx.active_enemies = []
	ctx.runtime_modifiers = {}
	return ctx
