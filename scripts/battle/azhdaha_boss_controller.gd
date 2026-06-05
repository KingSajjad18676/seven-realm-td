class_name AzhdahaBossController
extends RefCounted

enum Phase { PATROL, COIL, BREATH, SLAM }

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
			_phase = Phase.COIL
			_phase_timer = 1.0
			_alert("Azhdaha coils — armor hardens!", 85)
		Phase.COIL:
			if _enemy:
				_enemy.add_armor_delta(2.0)
			_phase = Phase.BREATH
			_phase_timer = 1.2
			_alert("Poison breath along the route!", 88)
		Phase.BREATH:
			if _enemy and _enemy.context and _enemy.context.map_light:
				var region := _enemy.context.map_light.get_region_for_position(_enemy.global_position)
				_enemy.context.map_light.apply_corruption_pressure(region, 14.0)
			_phase = Phase.SLAM
			_phase_timer = 0.9
		Phase.SLAM:
			if _enemy and _enemy.context and _enemy.context.hero_manager:
				var hero := _enemy.context.hero_manager.hero
				if hero and hero.global_position.distance_to(_enemy.global_position) < 95.0:
					hero.take_damage(30.0)
			_phase = Phase.PATROL
			_phase_timer = 5.0


func get_speed_mult() -> float:
	return 0.25 if _phase == Phase.COIL else 1.0


func blocks_tower_damage() -> bool:
	return _phase == Phase.COIL


func _alert(msg: String, prio: int) -> void:
	if _enemy and _enemy.context and _enemy.context.bridge:
		_enemy.context.bridge.alert_message.emit(msg, prio)
