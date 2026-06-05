class_name ZahhakBossController
extends RefCounted

enum Phase { PATROL, SERPENTS, BINDING, FURY }

var _enemy: EnemyController = null
var _phase: Phase = Phase.PATROL
var _phase_timer: float = 0.0
var _binding_stacks: int = 0


func attach(enemy: EnemyController) -> void:
	_enemy = enemy
	_phase_timer = 2.0


func tick(delta: float) -> void:
	_phase_timer -= delta
	if _phase_timer > 0.0:
		return
	match _phase:
		Phase.PATROL:
			_phase = Phase.SERPENTS
			_phase_timer = 1.0
			_alert("Zahhak's serpents corrupt every region!", 90)
		Phase.SERPENTS:
			if _enemy and _enemy.context and _enemy.context.map_light:
				for region_id in _enemy.context.level_data.region_ids:
					_enemy.context.map_light.apply_corruption_pressure(region_id, 10.0)
			_phase = Phase.BINDING
			_phase_timer = 1.2
			_alert("Binding ritual — weaken Zahhak before the final strike!", 88)
		Phase.BINDING:
			_binding_stacks += 1
			if _enemy and _enemy.context:
				var hunt_bonus: float = float(_enemy.context.runtime_modifiers.get("hunt_binding_bonus", 0.0))
				var campaign_bonus := float(_enemy.context.runtime_modifiers.get("damavand_binding_progress", 0.0))
				var bonus := maxf(hunt_bonus, campaign_bonus)
				if bonus > 0.0:
					_enemy.take_damage(40.0 * bonus, false)
			_phase = Phase.FURY if _binding_stacks >= 2 else Phase.PATROL
			_phase_timer = 3.0 if _phase == Phase.PATROL else 1.0
		Phase.FURY:
			if _enemy and _enemy.context and _enemy.context.lives:
				_enemy.context.lives.lose_life(1)
			_alert("Zahhak's fury — gate pressure!", 92)
			_phase = Phase.PATROL
			_phase_timer = 5.0


func get_speed_mult() -> float:
	match _phase:
		Phase.BINDING:
			return 0.2
		Phase.FURY:
			return 1.2
	return 0.9


func blocks_tower_damage() -> bool:
	if _phase != Phase.BINDING:
		return false
	if _enemy == null or _enemy.context == null:
		return true
	if bool(_enemy.context.runtime_modifiers.get("hunt_mode", false)):
		var hunt_bonus: float = float(_enemy.context.runtime_modifiers.get("hunt_binding_bonus", 0.0))
		return hunt_bonus < 1.05
	var progress: float = float(_enemy.context.runtime_modifiers.get("damavand_binding_progress", 0.0))
	return progress < 1.0


func _alert(msg: String, prio: int) -> void:
	if _enemy and _enemy.context and _enemy.context.bridge:
		_enemy.context.bridge.alert_message.emit(msg, prio)
