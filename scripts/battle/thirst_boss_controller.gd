class_name ThirstBossController
extends RefCounted

enum Phase { PATROL, MIRAGE, DROUGHT, SURGE }

var _enemy: EnemyController = null
var _phase: Phase = Phase.PATROL
var _phase_timer: float = 0.0


func attach(enemy: EnemyController) -> void:
	_enemy = enemy
	_phase = Phase.PATROL
	_phase_timer = 2.5


func tick(delta: float) -> void:
	_phase_timer -= delta
	if _phase_timer > 0.0:
		return
	match _phase:
		Phase.PATROL:
			_start(Phase.MIRAGE, "Thirst mirage — corruption spreads!")
		Phase.MIRAGE:
			_do_mirage()
		Phase.DROUGHT:
			_do_drought()
		Phase.SURGE:
			_do_surge()


func get_speed_mult() -> float:
	match _phase:
		Phase.MIRAGE, Phase.DROUGHT:
			return 0.35
		Phase.SURGE:
			return 1.35
	return 1.0


func blocks_tower_damage() -> bool:
	return _phase == Phase.MIRAGE


func _start(next: Phase, msg: String) -> void:
	_phase = next
	_phase_timer = 1.1
	_alert(msg, 85)


func _do_mirage() -> void:
	if _enemy and _enemy.context and _enemy.context.map_light:
		for region_id in _enemy.context.level_data.region_ids:
			_enemy.context.map_light.apply_corruption_pressure(region_id, 8.0)
	_phase = Phase.DROUGHT
	_phase_timer = 1.2
	_alert("Drought — Sacred Fire drain on nearby towers!", 88)


func _do_drought() -> void:
	if _enemy and _enemy.context and _enemy.context.map_light and _enemy.context.tower_manager:
		for spot in _enemy.context.tower_manager.build_spots:
			if spot.tower == null:
				continue
			var light := _enemy.context.map_light.get_light(spot.region_id)
			if light < 50 and _enemy.context.economy:
				_enemy.context.economy.spend_sacred_fire(1)
	_phase = Phase.SURGE
	_phase_timer = 0.8
	_alert("Thirst surge — hero must intercept!", 90)


func _do_surge() -> void:
	if _enemy and _enemy.context and _enemy.context.hero_manager:
		var hero := _enemy.context.hero_manager.hero
		if hero and hero.global_position.distance_to(_enemy.global_position) < 110.0:
			hero.take_damage(_enemy.scaled_boss_damage(18.0))
	_phase = Phase.PATROL
	_phase_timer = 4.5


func _alert(msg: String, prio: int) -> void:
	if _enemy and _enemy.context and _enemy.context.bridge:
		_enemy.context.bridge.alert_message.emit(msg, prio)
