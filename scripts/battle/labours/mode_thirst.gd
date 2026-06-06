extends LabourMode

const HERO_DRAIN := 2.5
const LIGHT_DRAIN := 3.0
const FOUNTAIN_INTERVAL := 18.0

var _fountain_timer := 0.0
var _fountain_pos := Vector2.ZERO
var _drought_active := false


func initialize(ctx: BattleContext) -> void:
	super.initialize(ctx)
	if context and context.level_data:
		var pts := context.level_data.get_all_route_points()
		if not pts.is_empty():
			_fountain_pos = pts[pts.size() / 2]
	if context and context.bridge:
		context.bridge.alert_message.emit("Labour of Thirst — the desert saps strength", 70)


func _process(delta: float) -> void:
	if context == null or context.state_controller == null:
		return
	if context.state_controller.current_state != GameEnums.BattleState.WAVE_ACTIVE:
		return
	_drain_strength(delta)
	if _drought_active:
		return
	_fountain_timer += delta
	if _fountain_timer >= FOUNTAIN_INTERVAL:
		_fountain_timer = 0.0
		_pulse_fountain()


func _drain_strength(delta: float) -> void:
	if context.hero_manager and context.hero_manager.hero:
		var hero := context.hero_manager.hero
		if not hero.is_dead():
			hero.take_damage(HERO_DRAIN * delta)
	if context.map_light and context.level_data:
		for region_id in context.level_data.region_ids:
			context.map_light.apply_corruption_pressure(region_id, LIGHT_DRAIN * delta)


func _pulse_fountain() -> void:
	if context == null:
		return
	if context.economy:
		context.economy.add_sacred_fire(1)
	if context.map_light and context.level_data:
		for region_id in context.level_data.region_ids:
			context.map_light.repair_region_light(region_id, 15)
	if context.hero_manager and context.hero_manager.hero:
		var hero := context.hero_manager.hero
		if not hero.is_dead() and hero.global_position.distance_to(_fountain_pos) < 120.0:
			hero.current_hp = minf(hero.current_hp + 40.0, hero.data.max_hp if hero.data else 220.0)
			if context.bridge:
				context.bridge.alert_message.emit("Oasis found — strength restored!", 45)
	if act_index_for(context.wave_manager.current_wave_index if context.wave_manager else 0) >= 1:
		_spawn_mirage_at_fountain()


func _spawn_mirage_at_fountain() -> void:
	if context == null or context.enemy_spawner == null:
		return
	var count := 5
	for i in count:
		context.enemy_spawner.spawn_enemy_at(
			"enemy_mirage_shade",
			_fountain_pos + Vector2(-60 + i * 24, 20)
		)
	if context.bridge:
		context.bridge.alert_message.emit("Mirages rise from the heat — defend the oasis!", 50)


func on_cleanse(_region_id: String) -> void:
	if context and context.hero_manager and context.hero_manager.hero:
		var hero := context.hero_manager.hero
		if not hero.is_dead():
			hero.current_hp = minf(hero.current_hp + 15.0, hero.data.max_hp if hero.data else 220.0)


func set_drought(active: bool) -> void:
	_drought_active = active
	if active and context and context.bridge:
		context.bridge.alert_message.emit("The oasis dries up — Sacred Fire must sustain you!", 65)
