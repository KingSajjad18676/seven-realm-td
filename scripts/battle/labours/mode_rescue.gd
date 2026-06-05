extends LabourMode

var _captive_pos := Vector2.ZERO
var _rescued := false


func initialize(ctx: BattleContext) -> void:
	super.initialize(ctx)
	if context and context.level_data:
		_captive_pos = context.level_data.gate_position + Vector2(-180, 0)
	if context and context.bridge:
		context.bridge.alert_message.emit("Labour of Rescue — free blind King Kay Kavus", 70)


func _process(_delta: float) -> void:
	if _rescued or context == null:
		return
	var hero := context.hero_manager.hero if context.hero_manager else null
	if hero and not hero.is_dead() and hero.global_position.distance_to(_captive_pos) < 90.0:
		_rescued = true
		if context.morale:
			context.morale.add(20)
		if context.economy:
			context.economy.add_sacred_fire(2)
		if context.bridge:
			context.bridge.alert_message.emit("Kay Kavus rescued — morale surges!", 60)


func on_wave_started(wave_index: int) -> void:
	if context == null or context.map_light == null:
		return
	if wave_index == 2 or (wave_index > 2 and wave_index % 10 == 2):
		for region_id in context.level_data.region_ids:
			context.map_light.apply_corruption_pressure(region_id, 25.0)
		if context.bridge:
			context.bridge.alert_message.emit("Sudden corruption spike — cleanse or lose towers!", 55)
