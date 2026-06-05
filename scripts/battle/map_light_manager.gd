class_name MapLightManager
extends Node

const CLEANSE_COST := 2
const LIGHT_MAX := 100
const PRESSURED_THRESHOLD := 70
const CRITICAL_THRESHOLD := 40
const COLLAPSED_THRESHOLD := 0

var context: BattleContext = null
var selected_region_id: String = ""
var region_light: Dictionary = {}
var region_state: Dictionary = {}
var region_decay_rate: Dictionary = {}
var _hijack_timers: Dictionary = {}


func initialize(ctx: BattleContext) -> void:
	context = ctx
	region_light.clear()
	region_state.clear()
	region_decay_rate.clear()
	_hijack_timers.clear()
	if ctx.level_data:
		for region_id in ctx.level_data.region_ids:
			region_light[region_id] = LIGHT_MAX
			region_state[region_id] = GameEnums.RegionLightState.STABLE
			region_decay_rate[region_id] = 0.0
			_emit_region(region_id)


func get_region_for_position(pos: Vector2) -> String:
	if context == null or context.level_data == null:
		return ""
	context.level_data.ensure_routes_migrated()
	return MapRegionUtils.region_for_position(
		pos,
		context.level_data.get_all_route_points(),
		context.level_data.region_ids
	)


func get_light(region_id: String) -> int:
	return int(region_light.get(region_id, LIGHT_MAX))


func get_state(region_id: String) -> GameEnums.RegionLightState:
	return int(region_state.get(region_id, GameEnums.RegionLightState.STABLE))


func apply_corruption_pressure(region_id: String, amount: float) -> void:
	if region_id == "" or not region_light.has(region_id):
		return
	var curse_rate: float = float(context.runtime_modifiers.get("corruption_rate_bonus", 0.0))
	var resist: float = float(context.runtime_modifiers.get("corruption_resist", 0.0))
	var light: int = get_light(region_id)
	var effective := amount * (1.0 + curse_rate) * (1.0 - resist)
	light = clampi(light - int(round(effective)), 0, LIGHT_MAX)
	region_light[region_id] = light
	_update_state(region_id)
	_emit_region(region_id)


func tick_decay(delta: float) -> void:
	for region_id in region_light.keys():
		var rate: float = float(region_decay_rate.get(region_id, 0.0))
		if rate <= 0.0:
			continue
		var light: int = get_light(region_id)
		light = clampi(light - int(rate * delta), 0, LIGHT_MAX)
		region_light[region_id] = light
		_update_state(region_id)
		_emit_region(region_id)


func try_cleanse_region(region_id: String) -> bool:
	if context == null or context.economy == null:
		return false
	if not context.economy.spend_sacred_fire(CLEANSE_COST):
		if context.bridge:
			context.bridge.alert_message.emit("Need %d Sacred Fire to cleanse" % CLEANSE_COST, 50)
		return false
	region_light[region_id] = LIGHT_MAX
	region_decay_rate[region_id] = 0.0
	_update_state(region_id)
	_emit_region(region_id)
	CombatEvents.cleanse_used.emit(region_id)
	AnalyticsService.cleanse_used(region_id)
	if context and context.objectives:
		context.objectives.on_cleanse()
	if context.bridge:
		context.bridge.alert_message.emit("Region cleansed!", 30)
	return true


func try_cleanse_at_position(pos: Vector2) -> bool:
	return try_cleanse_region(get_region_for_position(pos))


func repair_region_light(region_id: String, amount: int) -> void:
	if region_id == "" or not region_light.has(region_id):
		return
	region_light[region_id] = mini(get_light(region_id) + amount, LIGHT_MAX)
	_update_state(region_id)
	_emit_region(region_id)


func select_region(region_id: String) -> void:
	if region_id == "" or not region_light.has(region_id):
		return
	selected_region_id = region_id
	if context and context.bridge:
		context.bridge.region_selected.emit(region_id, get_light(region_id))


func get_best_cleanse_target() -> String:
	var best_id := ""
	var best_light := LIGHT_MAX + 1
	for region_id in region_light.keys():
		var light := get_light(region_id)
		var state := get_state(region_id)
		if state == GameEnums.RegionLightState.CRITICAL or state == GameEnums.RegionLightState.PRESSURED:
			if light < best_light:
				best_light = light
				best_id = region_id
	if best_id != "":
		return best_id
	best_light = LIGHT_MAX + 1
	for region_id in region_light.keys():
		var light := get_light(region_id)
		if light < best_light:
			best_light = light
			best_id = region_id
	return best_id


func try_cleanse_selected() -> bool:
	var target := selected_region_id if selected_region_id != "" else get_best_cleanse_target()
	if target == "":
		return false
	return try_cleanse_region(target)


func register_hijack_warning(spot_id: String) -> void:
	_hijack_timers[spot_id] = 4.0
	if context and context.bridge:
		context.bridge.tower_hijack_warning.emit(spot_id)
		context.bridge.alert_message.emit("Tower hijack warning!", 90)
	AudioManager.play_warning()


func is_region_collapsed(region_id: String) -> bool:
	return get_state(region_id) == GameEnums.RegionLightState.COLLAPSED


func _update_state(region_id: String) -> void:
	var light := get_light(region_id)
	var state: GameEnums.RegionLightState
	if light <= COLLAPSED_THRESHOLD:
		state = GameEnums.RegionLightState.COLLAPSED
	elif light <= CRITICAL_THRESHOLD:
		state = GameEnums.RegionLightState.CRITICAL
	elif light <= PRESSURED_THRESHOLD:
		state = GameEnums.RegionLightState.PRESSURED
	else:
		state = GameEnums.RegionLightState.STABLE
	var prev: int = int(region_state.get(region_id, GameEnums.RegionLightState.STABLE))
	region_state[region_id] = state
	if state == GameEnums.RegionLightState.CRITICAL:
		region_decay_rate[region_id] = 4.0
	elif state == GameEnums.RegionLightState.STABLE:
		region_decay_rate[region_id] = 0.0
	if prev != state:
		CombatEvents.region_state_changed.emit(region_id, state)
		AnalyticsService.region_state_changed(region_id, state)
		if state == GameEnums.RegionLightState.CRITICAL and context and context.bridge:
			context.bridge.alert_message.emit("Region critical — cleanse soon!", 80)
			AudioManager.play_warning()


func _emit_region(region_id: String) -> void:
	if context and context.bridge:
		context.bridge.region_light_changed.emit(
			region_id,
			get_light(region_id),
			get_state(region_id)
		)


func process_hijack_timers(delta: float) -> void:
	var done: Array[String] = []
	for spot_id in _hijack_timers.keys():
		_hijack_timers[spot_id] = float(_hijack_timers[spot_id]) - delta
		if _hijack_timers[spot_id] <= 0.0:
			done.append(spot_id)
	for spot_id in done:
		_hijack_timers.erase(spot_id)
		_force_hijack_at_spot(spot_id)


func _force_hijack_at_spot(spot_id: String) -> void:
	if context == null or context.tower_manager == null:
		return
	for spot in context.tower_manager.build_spots:
		if spot.spot_id == spot_id and spot.tower:
			if spot.tower.hijack_phase == GameEnums.HijackPhase.WARNING:
				spot.tower.force_enter_hijacked()
			return
