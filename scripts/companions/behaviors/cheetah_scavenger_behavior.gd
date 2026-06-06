class_name CheetahScavengerBehavior
extends RefCounted

enum State { IDLE, SEEK_DROP, RETURN }

var entity: CompanionEntity = null
var context: BattleContext = null
var data: CompanionData = null
var _state: State = State.IDLE
var _cargo: Dictionary = {}
var _target_drop: MaterialDrop = null


func bind(companion_entity: CompanionEntity, ctx: BattleContext, companion_data: CompanionData) -> void:
	entity = companion_entity
	context = ctx
	data = companion_data


func tick(delta: float) -> void:
	if entity == null or context == null or data == null:
		return
	if not _can_act():
		return
	var hero := _hero()
	if hero == null:
		return
	match _state:
		State.RETURN:
			_move_toward(hero.global_position, data.move_speed, delta)
			if entity.global_position.distance_to(hero.global_position) <= data.bank_radius:
				_bank_cargo()
				_state = State.IDLE
		State.SEEK_DROP:
			if _target_drop == null or not is_instance_valid(_target_drop):
				_target_drop = null
				_state = State.IDLE
			else:
				_move_toward(_target_drop.global_position, data.move_speed, delta)
				if entity.global_position.distance_to(_target_drop.global_position) <= 20.0:
					_try_collect_drop(_target_drop)
		State.IDLE:
			if not _cargo.is_empty():
				_state = State.RETURN
				return
			_target_drop = _find_nearest_drop()
			if _target_drop != null:
				_state = State.SEEK_DROP
			else:
				_move_toward(hero.global_position + Vector2(36, -12), data.move_speed * 0.6, delta)


func _can_act() -> bool:
	if context.launch_data and not context.launch_data.is_scavenge_mode():
		return false
	if context.state_controller.current_state != GameEnums.BattleState.WAVE_ACTIVE:
		return false
	return true


func _hero() -> HeroController:
	if context.hero_manager:
		return context.hero_manager.hero
	return null


func _find_nearest_drop() -> MaterialDrop:
	if context.loot_drops == null:
		return null
	var hero := _hero()
	if hero == null:
		return null
	var best: MaterialDrop = null
	var best_dist := INF
	for drop in context.loot_drops.get_active_drops():
		if drop == null or not is_instance_valid(drop):
			continue
		var d := hero.global_position.distance_to(drop.global_position)
		if d < best_dist:
			best_dist = d
			best = drop
	return best


func _try_collect_drop(drop: MaterialDrop) -> void:
	if drop == null or not drop.can_collect(entity):
		return
	var payload := drop.collect_to_cargo(entity)
	if payload.is_empty():
		return
	for mat_id in payload.keys():
		_cargo[mat_id] = int(_cargo.get(mat_id, 0)) + int(payload[mat_id])
	_target_drop = null
	_state = State.RETURN


func _bank_cargo() -> void:
	if context.economy == null or _cargo.is_empty():
		return
	for mat_id in _cargo.keys():
		context.economy.collect_material(str(mat_id), int(_cargo[mat_id]))
	_cargo.clear()
	if context.bridge:
		context.bridge.alert_message.emit("Royal Cheetah banked loot", 25)


func _move_toward(target: Vector2, speed: float, delta: float) -> void:
	var dir := target - entity.global_position
	if dir.length() <= 4.0:
		entity.velocity = Vector2.ZERO
		return
	entity.velocity = dir.normalized() * speed
	entity.move_and_slide()
