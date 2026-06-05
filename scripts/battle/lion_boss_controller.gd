class_name LionBossController
extends RefCounted

enum Phase { PATROL, TELEGRAPH_CLAW, TELEGRAPH_POUNCE, ROAR }

var _enemy: EnemyController = null
var _phase: Phase = Phase.PATROL
var _phase_timer: float = 0.0
var _roar_cooldown: float = 6.0


func attach(enemy: EnemyController) -> void:
	_enemy = enemy
	_phase = Phase.PATROL
	_phase_timer = 3.0


func tick(delta: float) -> void:
	_phase_timer -= delta
	_roar_cooldown -= delta
	if _phase_timer > 0.0:
		return
	match _phase:
		Phase.PATROL:
			_start_telegraph(Phase.TELEGRAPH_CLAW, "Lion prepares claw strike!")
		Phase.TELEGRAPH_CLAW:
			_execute_claw()
		Phase.TELEGRAPH_POUNCE:
			_execute_pounce()
		Phase.ROAR:
			_execute_roar()


func get_speed_mult() -> float:
	match _phase:
		Phase.TELEGRAPH_CLAW, Phase.TELEGRAPH_POUNCE:
			return 0.2
		Phase.ROAR:
			return 0.5
	return 1.0


func blocks_tower_damage() -> bool:
	return _phase == Phase.ROAR


func cleanup() -> void:
	if _enemy and _enemy.context:
		_enemy.context.runtime_modifiers.erase("tower_damage_mult")


func _start_telegraph(next: Phase, msg: String) -> void:
	_phase = next
	_phase_timer = 1.2
	if _enemy and _enemy.context and _enemy.context.bridge:
		_enemy.context.bridge.alert_message.emit(msg, 85)


func _execute_claw() -> void:
	if _enemy and _enemy.context and _enemy.context.map_light:
		var region := _enemy.context.map_light.get_region_for_position(_enemy.global_position)
		_enemy.context.map_light.apply_corruption_pressure(region, 12.0)
	_phase = Phase.TELEGRAPH_POUNCE
	_phase_timer = 1.0
	if _enemy and _enemy.context and _enemy.context.bridge:
		_enemy.context.bridge.alert_message.emit("Lion pounce incoming — move Rostam!", 90)


func _execute_pounce() -> void:
	if _enemy and _enemy.context and _enemy.context.hero_manager:
		var hero := _enemy.context.hero_manager.hero
		if hero and hero.global_position.distance_to(_enemy.global_position) < 100.0:
			hero.take_damage(_enemy.scaled_boss_damage(25.0))
	_phase = Phase.ROAR if _roar_cooldown <= 0.0 else Phase.PATROL
	_phase_timer = 2.0 if _phase == Phase.ROAR else 4.0


func _execute_roar() -> void:
	_roar_cooldown = 10.0
	if _enemy and _enemy.context and _enemy.context.bridge:
		_enemy.context.bridge.alert_message.emit("Lion roar — towers weakened briefly!", 85)
	if _enemy and _enemy.context:
		_enemy.context.runtime_modifiers["tower_damage_mult"] = 0.75
		_enemy.get_tree().create_timer(4.0).timeout.connect(func() -> void:
			if _enemy and _enemy.context:
				_enemy.context.runtime_modifiers.erase("tower_damage_mult")
		, CONNECT_ONE_SHOT)
	_phase = Phase.PATROL
	_phase_timer = 5.0
