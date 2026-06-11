class_name HeroController
extends CharacterBody2D

const TETHER_DRAIN_PER_SEC := 12.0
const TETHER_AS_MULT := 1.25
const LANE_BLOCK_PATH_RADIUS := 45.0
const LANE_BLOCK_MAX := 3
const LANE_BLOCK_WINDOW_BACK := 32.0
const LANE_BLOCK_WINDOW_AHEAD := 10.0
const HEAVY_WINDUP_SEC := 0.18
const DODGE_DURATION_SEC := 0.22
const MOVE_ACCEL := 900.0
const MOVE_DECEL := 1200.0

var context: BattleContext = null
var data: HeroData = null
var player_index: int = 0
var current_hp: float = 0.0
var tethered_tower: TowerController = null
var tether_energy: float = 100.0

var _skill_cooldown: float = 0.0
var _attack_cooldown: float = 0.0
var _heavy_cooldown: float = 0.0
var _dodge_cooldown: float = 0.0
var _iframe_remaining: float = 0.0
var _dodge_remaining: float = 0.0
var _dodge_dir: Vector2 = Vector2.RIGHT
var _heavy_windup: float = 0.0
var _move_input: Vector2 = Vector2.ZERO
var _facing: Vector2 = Vector2.RIGHT
var _last_real_usec: int = 0
var _spawn_position: Vector2 = Vector2.ZERO
var _dead: bool = false
var _respawn_remaining: float = 0.0
var _was_moving: bool = false
var _anim_sprite: AnimatedSprite2D = null
var _one_shot_anim: bool = false

@onready var _sprite: ColorRect = $Sprite
@onready var _hp_bar: ProgressBar = $HPBar


func initialize(ctx: BattleContext, hero_data: HeroData, start_pos: Vector2) -> void:
	context = ctx
	data = hero_data
	current_hp = get_effective_max_hp()
	global_position = start_pos
	_spawn_position = start_pos
	_dead = false
	_respawn_remaining = 0.0
	z_index = 10
	_last_real_usec = Time.get_ticks_usec()
	if hero_data.anim_data != null and hero_data.anim_data.has_strips():
		_anim_sprite = VisualAssetLoader.apply_hero_visual(self, hero_data.anim_data)
		if _anim_sprite:
			_anim_sprite.animation_finished.connect(_on_hero_anim_finished)
	else:
		var sprite_path := hero_data.sprite_path
		if sprite_path == "":
			sprite_path = VisualAssetLoader.khan1_sprite(hero_data.hero_id)
		VisualAssetLoader.apply_sprite(
			self, sprite_path, hero_data.color, Vector2(28, 28), hero_data.hero_id
		)
	_refresh_hp_bar()


func set_move_input(vec: Vector2) -> void:
	_move_input = vec
	if vec.length_squared() > 0.01:
		_facing = vec.normalized()


func get_facing() -> Vector2:
	return _facing


func cancel_move() -> void:
	_move_input = Vector2.ZERO
	velocity = Vector2.ZERO


func is_dead() -> bool:
	return _dead


func get_respawn_remaining() -> float:
	return _respawn_remaining if _dead else 0.0


func get_skill_cooldown_remaining() -> float:
	return _skill_cooldown


func get_attack_cooldown_remaining() -> float:
	return _attack_cooldown


func get_heavy_cooldown_remaining() -> float:
	return maxf(_heavy_cooldown, _heavy_windup)


func get_dodge_cooldown_remaining() -> float:
	return _dodge_cooldown


func is_invulnerable() -> bool:
	return _iframe_remaining > 0.0 or (
		context != null and context.runtime_modifiers.get("hero_invincible", false)
	)


func get_lane_block_path_distance(path: PackedVector2Array = PackedVector2Array()) -> float:
	var route := path
	if route.size() < 2 and context != null:
		route = context.path_points
	if route.size() < 2:
		return -1.0
	var path_dist := PathFollower.closest_distance_on_path(route, global_position)
	var on_path := PathFollower.position_at_distance(route, path_dist)
	if global_position.distance_to(on_path) > LANE_BLOCK_PATH_RADIUS:
		return -1.0
	return path_dist


func should_block_enemy(enemy: EnemyController) -> bool:
	if enemy == null or context == null:
		return false
	var enemy_path := enemy.get_path_points()
	var block_dist := get_lane_block_path_distance(enemy_path)
	if block_dist < 0.0:
		return false
	var blocked := _pick_lane_blocked_enemies(block_dist, enemy.get_route_id())
	return enemy in blocked


func _pick_lane_blocked_enemies(block_dist: float, route_id: String) -> Array:
	var contenders: Array[EnemyController] = []
	for e in context.active_enemies:
		if e is EnemyController:
			var enemy: EnemyController = e
			if route_id != "" and enemy.get_route_id() != route_id:
				continue
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
	if _is_mounted():
		_dismount_rakhsh("Dismounted for Sacred Tether")
	if global_position.distance_to(tower.global_position) > data.tether_radius:
		if context and context.bridge:
			context.bridge.alert_message.emit("Too far to tether", 35)
		return
	tethered_tower = tower
	cancel_move()
	tower.set_tether_bonus(TETHER_AS_MULT)
	if context and context.equipment_battle:
		context.equipment_battle.on_tether_activated()
	if context and context.bridge:
		context.bridge.alert_message.emit("Sacred Tether active", 40)
	AudioManager.play_sfx("tether")


func get_effective_max_hp() -> float:
	if data == null:
		return 0.0
	var max_hp := data.max_hp
	if context and context.runtime_modifiers.has("hero_max_hp_mult"):
		max_hp *= float(context.runtime_modifiers["hero_max_hp_mult"])
	if context and context.runtime_modifiers.has("hero_level_hp_mult"):
		max_hp *= float(context.runtime_modifiers["hero_level_hp_mult"])
	return max_hp


func apply_level_hp_bonus() -> void:
	current_hp = get_effective_max_hp()
	_refresh_hp_bar()


func attack() -> void:
	if not _can_use_manual_action():
		return
	if _is_mounted():
		return
	if _attack_cooldown > 0.0:
		return
	var rate := data.attack_rate * MoraleController.get_rate_mult(context)
	if context.runtime_modifiers.has("hero_attack_rate_mult"):
		rate *= float(context.runtime_modifiers["hero_attack_rate_mult"])
	_attack_cooldown = 1.0 / maxf(0.1, rate)
	var hits := _deal_arc_damage(
		data.attack_damage * _hero_damage_mult(),
		data.attack_arc_range,
		data.attack_arc_degrees,
		data.attack_max_targets,
		false
	)
	_play_hero_anim("attack")
	if hits > 0:
		AudioManager.play_sfx("hero_attack")
		CombatEvents.hero_melee_used.emit("attack")


func heavy_attack() -> void:
	if not _can_use_manual_action():
		return
	if _is_mounted():
		return
	if _heavy_cooldown > 0.0 or _heavy_windup > 0.0:
		return
	_heavy_windup = HEAVY_WINDUP_SEC
	_heavy_cooldown = data.heavy_cooldown
	if context and context.bridge:
		context.bridge.alert_message.emit("Heavy strike!", 25)


func dodge() -> void:
	if not _can_use_manual_action():
		return
	if _dodge_cooldown > 0.0 or _dodge_remaining > 0.0:
		return
	if _is_mounted():
		_dismount_rakhsh("Dismounted to dodge")
	var dir := _move_input if _move_input.length_squared() > 0.01 else _facing
	if dir.length_squared() < 0.01:
		dir = Vector2.RIGHT
	_dodge_dir = dir.normalized()
	_dodge_remaining = DODGE_DURATION_SEC
	_dodge_cooldown = data.dodge_cooldown
	_iframe_remaining = data.dodge_iframe_sec
	_play_hero_anim("dodge")
	AudioManager.play_sfx("hero_dodge")
	CombatEvents.hero_dodged.emit()


func use_skill() -> void:
	if _dead or _skill_cooldown > 0.0 or context == null or data == null:
		return
	if not _can_act_in_battle():
		return
	if _is_mounted():
		_dismount_rakhsh("Dismounted for skill")
	_skill_cooldown = data.skill_cooldown
	CombatEvents.hero_skill_used.emit(data.skill_id)
	match data.skill_id:
		"zal_foresight":
			_use_zal_foresight()
		"sohrab_rage":
			_use_sohrab_rage()
		"gordafarid_volley":
			_use_gordafarid_volley()
		"esfandiyar_bulwark":
			_use_esfandiyar_bulwark()
		_:
			if context and context.runtime_modifiers.get("equipment_spectral_horse", false):
				EquipmentSetRules.spectral_horse_charge(context.equipment_battle, self)
			else:
				_use_rostam_charge()
	AudioManager.play_sfx("hero_skill")


func _can_use_manual_action() -> bool:
	return not _dead and _can_act_in_battle() and data != null


func _use_rostam_charge() -> void:
	_play_hero_anim("charge")
	var hit_radius := 90.0
	var skill_dmg := data.skill_damage * _hero_damage_mult()
	for e in context.active_enemies:
		if e is EnemyController and global_position.distance_to(e.global_position) <= hit_radius:
			e.take_damage(skill_dmg, false)
			e.apply_slow(0.0, 1.5)
			if e.data:
				CombatEvents.enemy_stunned.emit("hero_skill", e.data.enemy_id)
	if context.bridge:
		context.bridge.alert_message.emit("Rostam charge!", 40)


func _use_zal_foresight() -> void:
	var hit_radius := 140.0
	var marked := 0
	var skill_dmg := data.skill_damage * 0.7 * _hero_damage_mult()
	for e in context.active_enemies:
		if e is EnemyController and global_position.distance_to(e.global_position) <= hit_radius:
			e.take_damage(skill_dmg, false)
			e.apply_slow(0.55, 3.0)
			marked += 1
	if context and context.runtime_modifiers:
		context.runtime_modifiers["attack_mult"] = 1.12
		context.runtime_modifiers["hero_attack_mult"] = 1.12
		get_tree().create_timer(6.0).timeout.connect(func() -> void:
			if context:
				context.runtime_modifiers.erase("attack_mult")
				context.runtime_modifiers.erase("hero_attack_mult")
		, CONNECT_ONE_SHOT)
	if context.bridge:
		context.bridge.alert_message.emit("Zal foresight — %d foes marked!" % marked, 45)


func _use_gordafarid_volley() -> void:
	var hit_radius := 120.0
	var hits := 0
	var skill_dmg := data.skill_damage * _hero_damage_mult()
	for e in context.active_enemies:
		if e is EnemyController and global_position.distance_to(e.global_position) <= hit_radius:
			e.take_damage(skill_dmg, false)
			e.apply_slow(0.5, 2.0)
			hits += 1
	if context.bridge:
		context.bridge.alert_message.emit("Gordafarid volley — %d foes slowed!" % hits, 45)


func _use_esfandiyar_bulwark() -> void:
	context.runtime_modifiers["hero_damage_reduction"] = 0.35
	get_tree().create_timer(5.0).timeout.connect(func() -> void:
		if context:
			context.runtime_modifiers.erase("hero_damage_reduction")
	, CONNECT_ONE_SHOT)
	heavy_attack()
	if context.bridge:
		context.bridge.alert_message.emit("Esfandiyar's bulwark!", 45)


func _use_sohrab_rage() -> void:
	var hit_radius := 110.0
	var hits := 0
	var skill_dmg := data.skill_damage * _hero_damage_mult()
	for e in context.active_enemies:
		if e is EnemyController and global_position.distance_to(e.global_position) <= hit_radius:
			e.take_damage(skill_dmg, false)
			hits += 1
	current_hp = maxf(1.0, current_hp - data.max_hp * 0.12)
	_refresh_hp_bar()
	if context.bridge:
		context.bridge.alert_message.emit("Sohrab's rage — %d foes struck!" % hits, 45)


func take_damage(amount: float) -> void:
	if _dead:
		return
	if is_invulnerable():
		if context and context.bridge:
			context.bridge.alert_message.emit("Dodged!", 20)
		return
	if context and float(context.runtime_modifiers.get("hero_dodge_chance", 0.0)) > randf():
		if context.bridge:
			context.bridge.alert_message.emit("Evaded!", 25)
		return
	if context and context.runtime_modifiers.has("hero_damage_reduction"):
		amount *= 1.0 - float(context.runtime_modifiers["hero_damage_reduction"])
	if context and context.equipment_battle:
		amount = context.equipment_battle.absorb_shield_damage(amount)
		if amount <= 0.0:
			return
	if _is_mounted():
		_dismount_rakhsh("Dismounted — Rostam struck!")
	_play_hero_anim("hit")
	var old_hp := current_hp
	current_hp -= amount
	CombatEvents.hero_damaged.emit(amount)
	if context and context.equipment_battle:
		context.equipment_battle.notify_hero_damaged(amount)
		context.equipment_battle.notify_hero_hp_changed(old_hp, current_hp, data.max_hp if data else 200.0)
	_refresh_hp_bar()
	if current_hp <= 0.0:
		_die()


func heal(amount: float) -> void:
	if _dead or amount <= 0.0:
		return
	current_hp = minf(data.max_hp if data else 200.0, current_hp + amount)
	_refresh_hp_bar()


func _die() -> void:
	_dead = true
	current_hp = 0.0
	cancel_move()
	_clear_tether()
	_respawn_remaining = data.respawn_cooldown if data else 8.0
	visible = false
	if context and context.bridge:
		context.bridge.alert_message.emit(
			"Hero fallen — respawning in %ds" % int(ceilf(_respawn_remaining)), 50
		)


func _respawn() -> void:
	_dead = false
	var max_hp := data.max_hp if data else 200.0
	if context and context.runtime_modifiers.has("hero_max_hp_mult"):
		max_hp *= float(context.runtime_modifiers["hero_max_hp_mult"])
	current_hp = max_hp
	global_position = _spawn_position
	visible = true
	_refresh_hp_bar()
	if context and context.bridge and data:
		context.bridge.alert_message.emit("%s has returned!" % data.display_name, 45)


func _physics_process(delta: float) -> void:
	if _dead:
		_respawn_remaining = maxf(0.0, _respawn_remaining - delta)
		if _respawn_remaining <= 0.0:
			_respawn()
		return
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
	_attack_cooldown = maxf(0.0, _attack_cooldown - step)
	_heavy_cooldown = maxf(0.0, _heavy_cooldown - step)
	_dodge_cooldown = maxf(0.0, _dodge_cooldown - step)
	_iframe_remaining = maxf(0.0, _iframe_remaining - step)
	_process_heavy_windup(step)
	_process_dodge(step)
	_process_tether(step)
	_process_movement(step)
	var visual: CanvasItem = _anim_sprite if _anim_sprite else _sprite
	if _iframe_remaining > 0.0 and visual:
		visual.modulate = Color(0.7, 0.85, 1.0, 0.75)
	elif visual:
		visual.modulate = Color.WHITE
	_update_facing_flip()


func _process_heavy_windup(delta: float) -> void:
	if _heavy_windup <= 0.0:
		return
	_heavy_windup -= delta
	if _heavy_windup > 0.0:
		return
	_play_hero_anim("heavy")
	var dmg := data.heavy_damage * _hero_damage_mult()
	var hits := _deal_arc_damage(dmg, data.heavy_radius, 360.0, 99, true)
	if hits > 0:
		AudioManager.play_sfx("hero_heavy")
	CombatEvents.hero_melee_used.emit("heavy")


func _process_dodge(delta: float) -> void:
	if _dodge_remaining <= 0.0:
		return
	var speed := data.dodge_distance / maxf(0.01, DODGE_DURATION_SEC)
	velocity = _dodge_dir * speed
	move_and_slide()
	_dodge_remaining -= delta
	if _dodge_remaining <= 0.0:
		velocity = Vector2.ZERO


func _process_movement(delta: float) -> void:
	if _dodge_remaining > 0.0:
		return
	if not _can_move_by_tutorial():
		cancel_move()
		return
	var speed := data.move_speed
	if _is_mounted() and context.rakhsh_mount:
		speed *= context.rakhsh_mount.get_speed_mult()
	if context.runtime_modifiers.has("hero_move_speed_mult"):
		speed *= float(context.runtime_modifiers["hero_move_speed_mult"])
	if _move_input.length_squared() < 0.01:
		velocity = velocity.move_toward(Vector2.ZERO, MOVE_DECEL * delta)
	else:
		velocity = velocity.move_toward(_move_input * speed, MOVE_ACCEL * delta)
	move_and_slide()
	var moving := _move_input.length_squared() > 0.01
	if moving and not _was_moving:
		CombatEvents.hero_moved.emit()
	_was_moving = moving


func _hero_damage_mult() -> float:
	var mult := MoraleController.get_damage_mult(context)
	if context.runtime_modifiers.has("hero_melee_damage_mult"):
		mult *= float(context.runtime_modifiers["hero_melee_damage_mult"])
	if context.runtime_modifiers.has("hero_level_damage_mult"):
		mult *= float(context.runtime_modifiers["hero_level_damage_mult"])
	if context.runtime_modifiers.has("hero_attack_mult"):
		mult *= float(context.runtime_modifiers["hero_attack_mult"])
	return mult


func _deal_arc_damage(
	base_dmg: float,
	range_px: float,
	arc_deg: float,
	max_targets: int,
	knockback: bool
) -> int:
	var hits := 0
	var half_arc := deg_to_rad(arc_deg * 0.5)
	var candidates: Array[EnemyController] = []
	for e in context.active_enemies:
		if not e is EnemyController:
			continue
		var enemy: EnemyController = e
		var offset := enemy.global_position - global_position
		if offset.length() > range_px:
			continue
		if arc_deg < 359.0:
			var angle := _facing.angle_to(offset.normalized())
			if absf(angle) > half_arc:
				continue
		candidates.append(enemy)
	candidates.sort_custom(func(a: EnemyController, b: EnemyController) -> bool:
		return global_position.distance_squared_to(a.global_position) \
			< global_position.distance_squared_to(b.global_position)
	)
	for enemy in candidates:
		if hits >= max_targets:
			break
		var hp_before := enemy.current_hp
		enemy.take_damage(base_dmg, false)
		if knockback:
			enemy.apply_path_knockback(28.0)
			enemy.apply_slow(0.2, 0.8)
		if context and context.equipment_battle:
			context.equipment_battle.notify_hero_melee_hit(enemy, base_dmg)
		if hp_before > 0.0 and enemy.current_hp <= 0.0:
			CombatEvents.hero_melee_kill.emit(enemy.data.enemy_id if enemy.data else "")
			if context and context.equipment_battle:
				context.equipment_battle.notify_hero_kill(enemy)
		hits += 1
	return hits


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


func _refresh_hp_bar() -> void:
	if _hp_bar == null or data == null:
		return
	var max_hp := get_effective_max_hp()
	_hp_bar.max_value = max_hp
	_hp_bar.value = minf(current_hp, max_hp)
	_hp_bar.visible = true


func _is_mounted() -> bool:
	return context != null and context.rakhsh_mount != null and context.rakhsh_mount.is_mounted()


func _dismount_rakhsh(reason: String) -> void:
	if context and context.rakhsh_mount:
		context.rakhsh_mount.dismount(reason)


func _play_hero_anim(anim_name: String) -> void:
	if _anim_sprite == null or _anim_sprite.sprite_frames == null:
		return
	if not _anim_sprite.sprite_frames.has_animation(anim_name):
		return
	if anim_name == "idle":
		if _one_shot_anim:
			return
	else:
		_one_shot_anim = true
	_anim_sprite.play(anim_name)


func _on_hero_anim_finished() -> void:
	if _anim_sprite == null:
		return
	if _anim_sprite.animation == "idle":
		_one_shot_anim = false
		return
	_one_shot_anim = false
	if _anim_sprite.sprite_frames.has_animation("idle"):
		_anim_sprite.play("idle")


func _update_facing_flip() -> void:
	if _anim_sprite == null:
		return
	_anim_sprite.flip_h = _facing.x < -0.01
