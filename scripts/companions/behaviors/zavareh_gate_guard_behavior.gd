class_name ZavarehGateGuardBehavior
extends RefCounted

const ENGAGE_GATE_THRESHOLD := 0.55
const ENGAGE_RADIUS := 120.0

var entity: CompanionEntity = null
var context: BattleContext = null
var data: CompanionData = null
var anchor_position: Vector2 = Vector2.ZERO
var current_hp: float = 0.0
var _attack_cooldown: float = 0.0
var _dead: bool = false


func bind(companion_entity: CompanionEntity, ctx: BattleContext, companion_data: CompanionData) -> void:
	entity = companion_entity
	context = ctx
	data = companion_data
	current_hp = companion_data.max_hp
	if ctx.level_data:
		anchor_position = ctx.level_data.gate_position + companion_data.gate_offset
		entity.global_position = anchor_position
	_refresh_hp()


func tick(delta: float) -> void:
	if entity == null or context == null or data == null or _dead:
		return
	if context.state_controller.current_state != GameEnums.BattleState.WAVE_ACTIVE:
		return
	_attack_cooldown = maxf(0.0, _attack_cooldown - delta)
	var target := _pick_target()
	if target == null:
		_move_toward(anchor_position, data.move_speed * 0.85, delta)
	else:
		_move_toward(target.global_position, data.move_speed, delta)
		_try_attack(target)


func take_damage(amount: float) -> void:
	if _dead:
		return
	current_hp -= amount
	_refresh_hp()
	if current_hp <= 0.0:
		_die()


func is_alive() -> bool:
	return not _dead


func _die() -> void:
	_dead = true
	entity.visible = false
	if context and context.bridge:
		context.bridge.alert_message.emit("Zavareh has fallen!", 50)


func _pick_target() -> EnemyController:
	var best: EnemyController = null
	var best_progress := -1.0
	for e in context.active_enemies:
		if not e is EnemyController:
			continue
		var enemy: EnemyController = e
		if not enemy.is_near_gate(ENGAGE_GATE_THRESHOLD):
			if anchor_position.distance_to(enemy.global_position) > ENGAGE_RADIUS:
				continue
		var progress := enemy.get_path_progress()
		if progress > best_progress:
			best_progress = progress
			best = enemy
	return best


func _try_attack(enemy: EnemyController) -> void:
	if _attack_cooldown > 0.0:
		return
	if entity.global_position.distance_to(enemy.global_position) > 55.0:
		return
	enemy.take_damage(data.attack_damage, false)
	_attack_cooldown = 1.0 / maxf(0.1, data.attack_rate)


func _move_toward(target: Vector2, speed: float, delta: float) -> void:
	var dir := target - entity.global_position
	if dir.length() <= 6.0:
		entity.velocity = Vector2.ZERO
		return
	entity.velocity = dir.normalized() * speed
	entity.move_and_slide()


func _refresh_hp() -> void:
	if entity == null or entity.get_node_or_null("HPBar") == null or data == null:
		return
	var bar: ProgressBar = entity.get_node("HPBar")
	bar.visible = true
	bar.max_value = data.max_hp
	bar.value = current_hp
