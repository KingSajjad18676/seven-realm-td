class_name EnemyController
extends Area2D

signal died(enemy: EnemyController)
signal reached_gate(enemy: EnemyController)

var context: BattleContext = null
var data: EnemyData = null
var current_hp: float = 0.0
var _follower: PathFollower = PathFollower.new()
var _burn_timer: float = 0.0
var _slow_mult: float = 1.0
var _slow_timer: float = 0.0
var _is_boss: bool = false
var _boss_controller: RefCounted = null
var _armor_delta: float = 0.0
var _move_speed_bonus: float = 0.0
var _max_hp_override: float = -1.0
var _revealed_form: bool = false

@onready var _sprite: ColorRect = $Sprite
@onready var _hp_bar: ProgressBar = $HPBar


func initialize(ctx: BattleContext, enemy_data: EnemyData, path: PackedVector2Array) -> void:
	context = ctx
	data = enemy_data
	_boss_controller = null
	_armor_delta = 0.0
	_move_speed_bonus = 0.0
	_max_hp_override = -1.0
	_revealed_form = false
	current_hp = _effective_max_hp()
	_follower.setup(path)
	_burn_timer = 0.0
	_slow_mult = 1.0
	_slow_timer = 0.0
	_is_boss = enemy_data.is_boss
	var sprite_path := enemy_data.sprite_path
	if sprite_path == "":
		sprite_path = VisualAssetLoader.khan1_sprite(enemy_data.enemy_id)
	VisualAssetLoader.apply_sprite(self, sprite_path, enemy_data.color, Vector2(24, 24) * enemy_data.scale)
	if _hp_bar:
		_hp_bar.max_value = current_hp
		_hp_bar.value = current_hp
		_hp_bar.visible = true
	monitoring = true
	monitorable = true


func setup_as_boss() -> void:
	_is_boss = true
	if data:
		_boss_controller = BossControllerFactory.create(data.enemy_id)
		if _boss_controller and _boss_controller.has_method("attach"):
			_boss_controller.attach(self)


func _process(delta: float) -> void:
	if context == null or data == null:
		return
	if context.state_controller.current_state != GameEnums.BattleState.WAVE_ACTIVE:
		return
	var hero := context.hero_manager.hero if context.hero_manager else null
	if hero and hero.should_block_enemy(self):
		if _is_boss and _boss_controller and _boss_controller.has_method("tick"):
			_boss_controller.tick(delta)
		_apply_corruption_trail()
		return
	var speed := (data.move_speed + _move_speed_bonus) * _slow_mult
	if context and context.runtime_modifiers.has("enemy_speed_mult"):
		speed *= float(context.runtime_modifiers["enemy_speed_mult"])
	if _is_boss and _boss_controller and _boss_controller.has_method("get_speed_mult"):
		speed *= _boss_controller.get_speed_mult()
	global_position = _follower.advance(speed * delta)
	if data.tags.has("regen") and current_hp < _effective_max_hp():
		current_hp = minf(current_hp + 3.0 * delta, _effective_max_hp())
	if _burn_timer > 0.0:
		_burn_timer -= delta
		take_damage(4.0 * delta, false)
	if _slow_timer > 0.0:
		_slow_timer -= delta
		if _slow_timer <= 0.0:
			_slow_mult = 1.0
	if _follower.is_at_end():
		_on_reached_gate()
		return
	if _is_boss and _boss_controller and _boss_controller.has_method("tick"):
		_boss_controller.tick(delta)
	_apply_corruption_trail()


func take_damage(amount: float, from_tower: bool = true) -> void:
	var dmg := maxf(1.0, amount - _effective_armor() * 0.5)
	if _is_boss and from_tower and _boss_controller and _boss_controller.has_method("blocks_tower_damage") and _boss_controller.blocks_tower_damage():
		dmg *= 0.5
	current_hp -= dmg
	if _hp_bar:
		_hp_bar.value = current_hp
	if current_hp <= 0.0:
		_die()


func apply_burn(duration: float = 2.0) -> void:
	_burn_timer = maxf(_burn_timer, duration)


func apply_slow(mult: float, duration: float) -> void:
	_slow_mult = minf(_slow_mult, mult)
	_slow_timer = maxf(_slow_timer, duration)


func apply_armor_break() -> void:
	_armor_delta -= 2.0


func add_armor_delta(delta: float) -> void:
	_armor_delta += delta


func apply_boss_reveal() -> void:
	_revealed_form = true
	_move_speed_bonus += 15.0
	_max_hp_override = maxf(current_hp, _effective_max_hp() * 0.6)
	if _sprite:
		_sprite.color = Color(0.85, 0.15, 0.35)
	if _hp_bar:
		_hp_bar.max_value = _effective_max_hp()
		_hp_bar.value = current_hp


func _effective_armor() -> float:
	return maxf(0.0, data.armor + _armor_delta)


func get_effective_max_hp() -> float:
	return _effective_max_hp()


func _effective_max_hp() -> float:
	var base := data.max_hp * _hp_multiplier()
	if _max_hp_override > 0.0:
		return _max_hp_override
	return base


func _die() -> void:
	if _is_boss and _boss_controller and _boss_controller.has_method("cleanup"):
		_boss_controller.cleanup()
	if _is_boss and context and context.morale:
		context.morale.on_boss_defeated()
	if context and context.hunt and data:
		context.hunt.on_enemy_slain(data)
	if context and context.economy:
		context.economy.apply_kill_rewards(data)
	if data.corruption_pressure > 0.0 and context and context.map_light:
		var region := context.map_light.get_region_for_position(global_position)
		context.map_light.apply_corruption_pressure(region, data.corruption_pressure)
	if context and context.bridge and data:
		context.bridge.enemy_died.emit(data.enemy_id)
	died.emit(self)
	if context and context.enemy_spawner:
		context.enemy_spawner.release_enemy(self)


func _on_reached_gate() -> void:
	if context and context.lives:
		var leak_damage := 2 if data.is_boss else 1
		context.lives.lose_life(leak_damage)
	reached_gate.emit(self)
	if context and context.enemy_spawner:
		context.enemy_spawner.release_enemy(self)


func _apply_corruption_trail() -> void:
	if data.corruption_pressure <= 0.0:
		return
	if randf() < 0.02 and context and context.map_light:
		var region := context.map_light.get_region_for_position(global_position)
		context.map_light.apply_corruption_pressure(region, 2.0)


func is_near_gate(threshold: float = 0.75) -> bool:
	return _follower.total_length > 0.0 and _follower.progress_distance >= _follower.total_length * threshold


func get_path_progress() -> float:
	return _follower.get_progress_distance()


func _hp_multiplier() -> float:
	if context:
		return float(context.runtime_modifiers.get("enemy_hp_mult", 1.0))
	return 1.0
