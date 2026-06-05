class_name WhiteDivBossController
extends RefCounted

enum Phase { PATROL, BLIZZARD, SHATTER }

var _enemy: EnemyController = null
var _phase: Phase = Phase.PATROL
var _phase_timer: float = 0.0


func attach(enemy: EnemyController) -> void:
	_enemy = enemy
	_phase_timer = 3.0


func tick(delta: float) -> void:
	_phase_timer -= delta
	if _phase_timer > 0.0:
		return
	match _phase:
		Phase.PATROL:
			_phase = Phase.BLIZZARD
			_phase_timer = 1.2
			_alert("Div-e Sepid blizzard — slows all towers!", 86)
		Phase.BLIZZARD:
			if _enemy and _enemy.context:
				_enemy.context.runtime_modifiers["tower_attack_rate_mult"] = 0.65
			_phase = Phase.SHATTER
			_phase_timer = 1.0
			_alert("Ice shatter — hero frozen if close!", 88)
		Phase.SHATTER:
			if _enemy and _enemy.context:
				_enemy.context.runtime_modifiers.erase("tower_attack_rate_mult")
			if _enemy and _enemy.context and _enemy.context.hero_manager:
				var hero := _enemy.context.hero_manager.hero
				if hero and hero.global_position.distance_to(_enemy.global_position) < 85.0:
					hero.take_damage(28.0)
					if _enemy.context:
						_enemy.context.runtime_modifiers["hero_move_speed_mult"] = 0.6
						_enemy.get_tree().create_timer(2.5).timeout.connect(func() -> void:
							if _enemy and _enemy.context:
								_enemy.context.runtime_modifiers.erase("hero_move_speed_mult")
						, CONNECT_ONE_SHOT)
			_phase = Phase.PATROL
			_phase_timer = 4.8


func get_speed_mult() -> float:
	return 0.5 if _phase == Phase.BLIZZARD else 1.0


func blocks_tower_damage() -> bool:
	return _phase == Phase.BLIZZARD


func cleanup() -> void:
	if _enemy and _enemy.context:
		_enemy.context.runtime_modifiers.erase("tower_attack_rate_mult")
		_enemy.context.runtime_modifiers.erase("hero_move_speed_mult")


func _alert(msg: String, prio: int) -> void:
	if _enemy and _enemy.context and _enemy.context.bridge:
		_enemy.context.bridge.alert_message.emit(msg, prio)
