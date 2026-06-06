class_name SimurghOrbiterBehavior
extends RefCounted

var entity: CompanionEntity = null
var context: BattleContext = null
var data: CompanionData = null
var _orbit_angle: float = 0.0
var _pulse_timer: float = 0.0


func bind(companion_entity: CompanionEntity, ctx: BattleContext, companion_data: CompanionData) -> void:
	entity = companion_entity
	context = ctx
	data = companion_data
	_pulse_timer = companion_data.pulse_interval_sec if companion_data else 15.0


func tick(delta: float) -> void:
	if entity == null or context == null or data == null:
		return
	if context.state_controller.current_state != GameEnums.BattleState.WAVE_ACTIVE:
		return
	var hero := _hero()
	if hero == null:
		return
	_orbit_angle += data.orbit_speed * delta
	var offset := Vector2(cos(_orbit_angle), sin(_orbit_angle)) * data.orbit_radius
	entity.global_position = hero.global_position + offset
	_pulse_timer -= delta
	if _pulse_timer <= 0.0:
		_pulse_timer = data.pulse_interval_sec
		_pulse_light()


func _hero() -> HeroController:
	if context.hero_manager:
		return context.hero_manager.hero
	return null


func _pulse_light() -> void:
	if context.map_light == null:
		return
	var hero := _hero()
	if hero == null:
		return
	var region_id := context.map_light.get_region_for_position(hero.global_position)
	if region_id == "":
		region_id = context.map_light.get_best_cleanse_target()
	if region_id == "":
		return
	context.map_light.repair_region_light(region_id, data.pulse_light_amount)
	if context.bridge:
		context.bridge.alert_message.emit("Simurgh light burst!", 30)
	if entity and entity.get_node_or_null("Sprite") is ColorRect:
		var spr: ColorRect = entity.get_node("Sprite")
		spr.scale = Vector2(1.35, 1.35)
		entity.get_tree().create_timer(0.25).timeout.connect(func() -> void:
			if is_instance_valid(spr):
				spr.scale = Vector2.ONE
		, CONNECT_ONE_SHOT)
