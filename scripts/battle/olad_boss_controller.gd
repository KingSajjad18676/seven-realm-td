class_name OladBossController
extends RefCounted

enum Phase { PATROL, CHARGE, RALLY }

var _enemy: EnemyController = null
var _phase: Phase = Phase.PATROL
var _phase_timer: float = 0.0


func attach(enemy: EnemyController) -> void:
	_enemy = enemy
	_phase_timer = 2.5


func tick(delta: float) -> void:
	_phase_timer -= delta
	if _phase_timer > 0.0:
		return
	match _phase:
		Phase.PATROL:
			_phase = Phase.CHARGE
			_phase_timer = 0.7
			_alert("Olad charges the gate!", 90)
		Phase.CHARGE:
			if _enemy and _enemy.context and _enemy.context.lives:
				_enemy.context.lives.lose_life(_enemy.scaled_boss_gate_leak(1))
			_phase = Phase.RALLY
			_phase_timer = 1.5
			_alert("Champion rally — corruption along route!", 85)
		Phase.RALLY:
			if _enemy and _enemy.context and _enemy.context.map_light:
				var region := _enemy.context.map_light.get_region_for_position(_enemy.global_position)
				_enemy.context.map_light.apply_corruption_pressure(region, 10.0)
			_phase = Phase.PATROL
			_phase_timer = 4.0


func get_speed_mult() -> float:
	return 1.6 if _phase == Phase.CHARGE else 0.85


func blocks_tower_damage() -> bool:
	return _phase == Phase.RALLY


func _alert(msg: String, prio: int) -> void:
	if _enemy and _enemy.context and _enemy.context.bridge:
		_enemy.context.bridge.alert_message.emit(msg, prio)
