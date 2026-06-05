class_name SorceressBossController
extends RefCounted

enum Phase { PATROL, HEX, FEAST }

var _enemy: EnemyController = null
var _phase: Phase = Phase.PATROL
var _phase_timer: float = 0.0


func attach(enemy: EnemyController) -> void:
	_enemy = enemy
	_phase_timer = 2.8


func tick(delta: float) -> void:
	_phase_timer -= delta
	if _phase_timer > 0.0:
		return
	match _phase:
		Phase.PATROL:
			_phase = Phase.HEX
			_phase_timer = 1.0
			_alert("Sorceress hex — hijack risk rises!", 86)
		Phase.HEX:
			if _enemy and _enemy.context and _enemy.context.tower_manager:
				for spot in _enemy.context.tower_manager.build_spots:
					if spot.tower and randf() < 0.25:
						spot.tower.trigger_hijack_warning()
			_phase = Phase.FEAST
			_phase_timer = 1.3
			_alert("Feast of shadows — cleanse a region!", 88)
		Phase.FEAST:
			if _enemy and _enemy.context and _enemy.context.map_light:
				for region_id in _enemy.context.level_data.region_ids:
					_enemy.context.map_light.apply_corruption_pressure(region_id, 6.0)
			_phase = Phase.PATROL
			_phase_timer = 4.2


func get_speed_mult() -> float:
	return 0.4 if _phase == Phase.HEX else 0.9


func blocks_tower_damage() -> bool:
	return false


func _alert(msg: String, prio: int) -> void:
	if _enemy and _enemy.context and _enemy.context.bridge:
		_enemy.context.bridge.alert_message.emit(msg, prio)
