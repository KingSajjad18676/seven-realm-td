class_name SorceressBossController
extends RefCounted

enum Phase { PATROL, HEX, FEAST, REVEALED }

var _enemy: EnemyController = null
var _phase: Phase = Phase.PATROL
var _phase_timer: float = 0.0
var _revealed: bool = false


func attach(enemy: EnemyController) -> void:
	_enemy = enemy
	_phase_timer = 2.8


func tick(delta: float) -> void:
	if not _revealed and _enemy and _enemy.data:
		var ratio := _enemy.current_hp / maxf(1.0, _enemy.data.max_hp)
		if ratio <= 0.5:
			_transform_revealed()
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
				for tower in _enemy.context.tower_manager.towers:
					if is_instance_valid(tower) and randf() < 0.25:
						tower.trigger_hijack_warning()
			_phase = Phase.FEAST
			_phase_timer = 1.3
			_alert("Feast of shadows — cleanse a region!", 88)
		Phase.FEAST:
			if _enemy and _enemy.context and _enemy.context.map_light:
				for region_id in _enemy.context.level_data.region_ids:
					_enemy.context.map_light.apply_corruption_pressure(region_id, 6.0)
			_phase = Phase.PATROL
			_phase_timer = 4.2 if not _revealed else 3.0
		Phase.REVEALED:
			if _enemy and _enemy.context and _enemy.context.map_light:
				var region := _enemy.context.map_light.get_region_for_position(_enemy.global_position)
				_enemy.context.map_light.apply_corruption_pressure(region, 14.0)
			_phase = Phase.PATROL
			_phase_timer = 3.5


func get_speed_mult() -> float:
	if _phase == Phase.REVEALED:
		return 1.15
	return 0.4 if _phase == Phase.HEX else 0.9


func blocks_tower_damage() -> bool:
	return _phase == Phase.REVEALED and _enemy and _enemy.current_hp > _enemy.get_effective_max_hp() * 0.25


func _transform_revealed() -> void:
	_revealed = true
	_phase = Phase.REVEALED
	_phase_timer = 1.0
	if _enemy == null:
		return
	_enemy.apply_boss_reveal()
	_alert("Illusion shattered — the fiend is revealed!", 92)


func _alert(msg: String, prio: int) -> void:
	if _enemy and _enemy.context and _enemy.context.bridge:
		_enemy.context.bridge.alert_message.emit(msg, prio)
