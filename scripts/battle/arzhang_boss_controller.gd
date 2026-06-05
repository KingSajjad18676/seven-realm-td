class_name ArzhangBossController
extends RefCounted

enum Phase { PATROL, FORTIFY, SIEGE }

var _enemy: EnemyController = null
var _phase: Phase = Phase.PATROL
var _phase_timer: float = 0.0


func attach(enemy: EnemyController) -> void:
	_enemy = enemy
	_phase_timer = 3.2


func tick(delta: float) -> void:
	_phase_timer -= delta
	if _phase_timer > 0.0:
		return
	match _phase:
		Phase.PATROL:
			_phase = Phase.FORTIFY
			_phase_timer = 1.4
			_alert("Arzhang fortifies — towers deal half damage!", 87)
		Phase.FORTIFY:
			if _enemy and _enemy.context:
				_enemy.context.runtime_modifiers["tower_damage_mult"] = 0.5
			_phase = Phase.SIEGE
			_phase_timer = 1.0
			_alert("Siege slam — move hero to intercept!", 90)
		Phase.SIEGE:
			if _enemy and _enemy.context:
				_enemy.context.runtime_modifiers.erase("tower_damage_mult")
			if _enemy and _enemy.context and _enemy.context.hero_manager:
				var hero := _enemy.context.hero_manager.hero
				if hero and hero.global_position.distance_to(_enemy.global_position) < 100.0:
					hero.take_damage(35.0)
			_phase = Phase.PATROL
			_phase_timer = 5.0


func get_speed_mult() -> float:
	return 0.3 if _phase == Phase.FORTIFY else 0.75


func blocks_tower_damage() -> bool:
	return _phase == Phase.FORTIFY


func cleanup() -> void:
	if _enemy and _enemy.context:
		_enemy.context.runtime_modifiers.erase("tower_damage_mult")


func _alert(msg: String, prio: int) -> void:
	if _enemy and _enemy.context and _enemy.context.bridge:
		_enemy.context.bridge.alert_message.emit(msg, prio)
