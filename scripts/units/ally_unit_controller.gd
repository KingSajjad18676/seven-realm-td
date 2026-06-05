class_name AllyUnitController
extends CharacterBody2D

var context: BattleContext = null
var data: AllyUnitData = null
var owner_tower: TowerController = null
var current_hp: float = 0.0
var rally_position: Vector2 = Vector2.ZERO
var _attack_cooldown: float = 0.0
var _dead: bool = false

@onready var _sprite: ColorRect = $Sprite
@onready var _hp_bar: ProgressBar = $HPBar


func _ready() -> void:
	if get_node_or_null("Sprite") == null:
		var spr := ColorRect.new()
		spr.name = "Sprite"
		spr.offset_left = -14.0
		spr.offset_top = -14.0
		spr.offset_right = 14.0
		spr.offset_bottom = 14.0
		add_child(spr)
		_sprite = spr
	if get_node_or_null("HPBar") == null:
		var bar := ProgressBar.new()
		bar.name = "HPBar"
		bar.offset_left = -18.0
		bar.offset_top = -28.0
		bar.offset_right = 18.0
		bar.offset_bottom = -20.0
		bar.show_percentage = false
		add_child(bar)
		_hp_bar = bar


func initialize(ctx: BattleContext, unit_data: AllyUnitData, start_pos: Vector2, tower: TowerController) -> void:
	context = ctx
	data = unit_data
	owner_tower = tower
	current_hp = unit_data.max_hp
	global_position = start_pos
	rally_position = start_pos
	_dead = false
	z_index = 8
	VisualAssetLoader.apply_sprite(self, unit_data.sprite_path, unit_data.color, Vector2(28, 28))
	_refresh_hp()


func take_damage(amount: float, is_fire: bool = false) -> void:
	if _dead:
		return
	var dmg := amount
	if is_fire and data:
		dmg *= 1.0 - data.magic_fire_resist
	current_hp -= dmg
	_refresh_hp()
	if current_hp <= 0.0:
		_die()


func _die() -> void:
	_dead = true
	visible = false
	if context and owner_tower:
		owner_tower.notify_ally_died(self)


func is_alive() -> bool:
	return not _dead


func _physics_process(delta: float) -> void:
	if _dead or context == null or data == null:
		return
	if context.state_controller.current_state != GameEnums.BattleState.WAVE_ACTIVE:
		return
	var dir := (rally_position - global_position)
	if dir.length() > 8.0:
		velocity = dir.normalized() * data.move_speed
		move_and_slide()
	else:
		velocity = Vector2.ZERO
	_attack_nearby(delta)


func _attack_nearby(delta: float) -> void:
	_attack_cooldown -= delta
	if _attack_cooldown > 0.0:
		return
	var hit_any := false
	for e in context.active_enemies:
		if not e is EnemyController:
			continue
		var enemy: EnemyController = e
		if global_position.distance_to(enemy.global_position) > 55.0:
			continue
		if data.cleave_radius > 0.0:
			for other in context.active_enemies:
				if other is EnemyController and global_position.distance_to(other.global_position) <= data.cleave_radius:
					_hit_enemy(other as EnemyController)
		else:
			_hit_enemy(enemy)
		hit_any = true
		break
	if hit_any:
		_attack_cooldown = 1.0 / maxf(0.1, data.attack_rate)


func _hit_enemy(enemy: EnemyController) -> void:
	enemy.take_damage(data.damage, false)
	if data.armor_shatter > 0.0:
		enemy.add_armor_delta(-data.armor_shatter)
	if data.stun_seconds > 0.0:
		enemy.apply_slow(0.05, data.stun_seconds)


func _refresh_hp() -> void:
	if _hp_bar and data:
		_hp_bar.max_value = data.max_hp
		_hp_bar.value = current_hp
