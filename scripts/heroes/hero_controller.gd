class_name HeroController
extends CharacterBody2D

const TETHER_DRAIN_PER_SEC := 12.0
const TETHER_AS_MULT := 1.25
const LANE_BLOCK_PATH_RADIUS := 45.0
const LANE_BLOCK_MAX := 3
const LANE_BLOCK_WINDOW_BACK := 32.0
const LANE_BLOCK_WINDOW_AHEAD := 10.0

var context: BattleContext = null
var data: HeroData = null
var current_hp: float = 0.0
var _skill_cooldown: float = 0.0
var _attack_cooldown: float = 0.0
var _move_target: Vector2 = Vector2.ZERO
var _has_target: bool = false
var tethered_tower: TowerController = null
var tether_energy: float = 100.0
var _last_real_usec: int = 0

@onready var _sprite: ColorRect = $Sprite
@onready var _hp_bar: ProgressBar = $HPBar


func initialize(ctx: BattleContext, hero_data: HeroData, start_pos: Vector2) -> void:
	context = ctx
	data = hero_data
	current_hp = hero_data.max_hp
	global_position = start_pos
	_move_target = start_pos
	z_index = 10
	_last_real_usec = Time.get_ticks_usec()
	var sprite_path := hero_data.sprite_path
	if sprite_path == "":
		sprite_path = VisualAssetLoader.khan1_sprite(hero_data.hero_id)
	VisualAssetLoader.apply_sprite(self, sprite_path, hero_data.color, Vector2(28, 28))
	_refresh_hp_bar()


func move_to(pos: Vector2) -> void:
	tethered_tower = null
	_move_target = pos
	_has_target = true
	CombatEvents.hero_moved.emit()


func cancel_move() -> void:
	_has_target = false
	velocity = Vector2.ZERO


func get_lane_block_path_distance() -> float:
	if context == null or context.path_points.size() < 2:
		return -1.0
	var path_dist := PathFollower.closest_distance_on_path(context.path_points, global_position)
	var on_path := PathFollower.position_at_distance(context.path_points, path_dist)
	if global_position.distance_to(on_path) > LANE_BLOCK_PATH_RADIUS:
		return -1.0
	return path_dist


func should_block_enemy(enemy: EnemyController) -> bool:
	if enemy == null or context == null:
		return false
	var block_dist := get_lane_block_path_distance()
	if block_dist < 0.0:
		return false
	var blocked := _pick_lane_blocked_enemies(block_dist)
	return enemy in blocked


func _pick_lane_blocked_enemies(block_dist: float) -> Array:
	var contenders: Array[EnemyController] = []
	for e in context.active_enemies:
		if e is EnemyController:
			var enemy: EnemyController = e
			var ed := enemy.get_path_progress()
			if ed > block_dist + LANE_BLOCK_WINDOW_AHEAD:
				continue
			if ed < block_dist - LANE_BLOCK_WINDOW_BACK:
				continue
			if enemy.global_position.distance_to(global_position) > 72.0:
				continue
			contenders.append(enemy)
	contenders.sort_custom(func(a: EnemyController, b: EnemyController) -> bool:
		return a.get_path_progress() > b.get_path_progress()
	)
	if contenders.size() <= LANE_BLOCK_MAX:
		return contenders
	return contenders.slice(0, LANE_BLOCK_MAX)


func tether_to_tower(tower: TowerController) -> void:
	if tower == null or data == null:
		return
	if global_position.distance_to(tower.global_position) > data.tether_radius:
		if context and context.bridge:
			context.bridge.alert_message.emit("Too far to tether", 35)
		return
	tethered_tower = tower
	_has_target = false
	tower.set_tether_bonus(TETHER_AS_MULT)
	if context and context.bridge:
		context.bridge.alert_message.emit("Sacred Tether active", 40)


func use_skill() -> void:
	if _skill_cooldown > 0.0 or context == null or data == null:
		return
	_skill_cooldown = data.skill_cooldown
	CombatEvents.hero_skill_used.emit(data.skill_id)
	match data.skill_id:
		"zal_foresight":
			_use_zal_foresight()
		_:
			_use_rostam_charge()


func _use_rostam_charge() -> void:
	var hit_radius := 90.0
	for e in context.active_enemies:
		if e is EnemyController and global_position.distance_to(e.global_position) <= hit_radius:
			e.take_damage(data.skill_damage, false)
	if context.bridge:
		context.bridge.alert_message.emit("Rostam charge!", 40)


func _use_zal_foresight() -> void:
	var hit_radius := 140.0
	var marked := 0
	for e in context.active_enemies:
		if e is EnemyController and global_position.distance_to(e.global_position) <= hit_radius:
			e.take_damage(data.skill_damage * 0.7, false)
			e.apply_slow(0.55, 3.0)
			marked += 1
	if context and context.runtime_modifiers:
		context.runtime_modifiers["attack_mult"] = 1.12
		get_tree().create_timer(6.0).timeout.connect(func() -> void:
			if context:
				context.runtime_modifiers.erase("attack_mult")
		, CONNECT_ONE_SHOT)
	if context.bridge:
		context.bridge.alert_message.emit("Zal foresight — %d foes marked!" % marked, 45)


func take_damage(amount: float) -> void:
	current_hp -= amount
	_refresh_hp_bar()
	if current_hp <= 0.0 and context and context.state_controller:
		context.state_controller.trigger_defeat("hero_fallen")


func _physics_process(delta: float) -> void:
	if context == null or data == null:
		return
	if not _can_act_in_battle():
		return
	var step := delta
	if step <= 0.0 and _needs_unscaled_step():
		step = _real_delta()
	if step <= 0.0:
		return
	_skill_cooldown = maxf(0.0, _skill_cooldown - step)
	_process_tether(step)
	if _has_target and _can_move_by_tutorial():
		var dir := (_move_target - global_position).normalized()
		var dist := global_position.distance_to(_move_target)
		if dist < 6.0:
			_has_target = false
		else:
			var speed := data.move_speed
			if context.runtime_modifiers.has("hero_move_speed_mult"):
				speed *= float(context.runtime_modifiers["hero_move_speed_mult"])
			velocity = dir * speed
			move_and_slide()
	elif _has_target and not _can_move_by_tutorial():
		cancel_move()
	_intercept_leaks()
	_attack_nearby(step)


func _can_act_in_battle() -> bool:
	if context.state_controller.current_state == GameEnums.BattleState.WAVE_ACTIVE:
		return true
	if context.tutorial_active and context.tutorial_allows("battlefield"):
		return true
	return false


func _can_move_by_tutorial() -> bool:
	if context == null or not context.tutorial_active:
		return true
	return context.tutorial_allows("battlefield")


func _needs_unscaled_step() -> bool:
	return context.tutorial_active and context.tutorial_allows("battlefield")


func _real_delta() -> float:
	var now := Time.get_ticks_usec()
	var dt := (now - _last_real_usec) / 1_000_000.0
	_last_real_usec = now
	return dt


func _intercept_leaks() -> void:
	if context == null:
		return
	for e in context.active_enemies:
		if e is EnemyController and e.is_near_gate(0.75):
			if global_position.distance_to(e.global_position) < 50.0:
				e.take_damage(data.attack_damage, false)


func _process_tether(delta: float) -> void:
	if tethered_tower == null:
		return
	if not is_instance_valid(tethered_tower):
		_clear_tether()
		return
	if global_position.distance_to(tethered_tower.global_position) > data.tether_radius * 1.2:
		_clear_tether()
		return
	tether_energy -= TETHER_DRAIN_PER_SEC * delta
	if tether_energy <= 0.0:
		_clear_tether()


func _clear_tether() -> void:
	if tethered_tower and is_instance_valid(tethered_tower):
		tethered_tower.set_tether_bonus(1.0)
	tethered_tower = null
	tether_energy = 100.0


func _attack_nearby(delta: float) -> void:
	_attack_cooldown -= delta
	if _attack_cooldown > 0.0:
		return
	var dmg := data.attack_damage * MoraleController.get_damage_mult(context)
	for e in context.active_enemies:
		if e is EnemyController and global_position.distance_to(e.global_position) < 55.0:
			e.take_damage(dmg, false)
			var rate := data.attack_rate * MoraleController.get_rate_mult(context)
			_attack_cooldown = 1.0 / maxf(0.1, rate)
			break


func _refresh_hp_bar() -> void:
	if _hp_bar == null or data == null:
		return
	_hp_bar.max_value = data.max_hp
	_hp_bar.value = current_hp
	_hp_bar.visible = true
