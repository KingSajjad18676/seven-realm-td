class_name HeroController
extends CharacterBody2D

var context: BattleContext = null
var data: HeroData = null
var current_hp: float = 0.0
var _skill_cooldown: float = 0.0
var _attack_cooldown: float = 0.0
var _move_target: Vector2 = Vector2.ZERO
var _has_target: bool = false
var tethered_tower: TowerController = null
var tether_energy: float = 100.0
const TETHER_DRAIN_PER_SEC := 12.0
const TETHER_AS_MULT := 1.25

@onready var _sprite: ColorRect = $Sprite


func initialize(ctx: BattleContext, hero_data: HeroData, start_pos: Vector2) -> void:
	context = ctx
	data = hero_data
	current_hp = hero_data.max_hp
	global_position = start_pos
	_move_target = start_pos
	var sprite_path := hero_data.sprite_path
	if sprite_path == "":
		sprite_path = VisualAssetLoader.khan1_sprite(hero_data.hero_id)
	VisualAssetLoader.apply_sprite(self, sprite_path, hero_data.color, Vector2(28, 28))


func move_to(pos: Vector2) -> void:
	tethered_tower = null
	_move_target = pos
	_has_target = true
	CombatEvents.hero_moved.emit()


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
	if current_hp <= 0.0 and context and context.state_controller:
		context.state_controller.trigger_defeat("hero_fallen")


func _physics_process(delta: float) -> void:
	if context == null or data == null:
		return
	if context.state_controller.current_state != GameEnums.BattleState.WAVE_ACTIVE:
		return
	_skill_cooldown = maxf(0.0, _skill_cooldown - delta)
	_process_tether(delta)
	if _has_target:
		var dir := (_move_target - global_position).normalized()
		var dist := global_position.distance_to(_move_target)
		if dist < 6.0:
			_has_target = false
		else:
			velocity = dir * data.move_speed
			move_and_slide()
	_intercept_leaks()
	_attack_nearby(delta)


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
	for e in context.active_enemies:
		if e is EnemyController and global_position.distance_to(e.global_position) < 55.0:
			e.take_damage(data.attack_damage, false)
			_attack_cooldown = 1.0 / data.attack_rate
			break
