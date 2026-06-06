extends Node

## Tracks daily mission counters from combat events and battle summaries.


var _battle_metrics: Dictionary = {}
var _hero_damage_taken: bool = false
var _hero_damage_this_wave: bool = false


func _ready() -> void:
	CombatEvents.enemy_killed.connect(_on_enemy_killed)
	CombatEvents.cleanse_used.connect(_on_cleanse_used)
	CombatEvents.hero_damaged.connect(_on_hero_damaged)
	CombatEvents.hero_melee_kill.connect(_on_hero_melee_kill)
	CombatEvents.tower_damage_dealt.connect(_on_tower_damage)
	CombatEvents.enemy_stunned.connect(_on_enemy_stunned)
	CombatEvents.tower_built.connect(_on_tower_built)
	CombatEvents.tower_upgraded.connect(_on_tower_upgraded)
	CombatEvents.wave_started.connect(_on_wave_started)
	CombatEvents.wave_completed.connect(_on_wave_completed)
	CombatEvents.battle_started.connect(_on_battle_started)
	CombatEvents.battle_completed.connect(_on_battle_completed)


func _default_battle_metrics() -> Dictionary:
	return {
		"melee_kills": 0,
		"archer_damage": 0,
		"stun_count": 0,
		"max_upgraded_towers": 0,
		"peak_unspent_gold": 0,
		"gold_spent": false,
		"current_gold": 0,
		"untouchable_wave": false,
		"pristine_boss_wave": false,
	}


func _on_battle_started(_level_id: String) -> void:
	_battle_metrics = _default_battle_metrics()
	_hero_damage_taken = false
	_hero_damage_this_wave = false


func _on_battle_completed(victory: bool, _level_id: String) -> void:
	if not victory:
		return
	_flush_lifetime_missions()
	_eval_per_battle_missions()


func _on_enemy_killed(enemy_id: String, _gold: int, _sf: int) -> void:
	if _is_div_enemy(enemy_id):
		_add_lifetime("total_div_kills", 1)


func _is_div_enemy(enemy_id: String) -> bool:
	return enemy_id.contains("div") or enemy_id.contains("white_div")


func _on_cleanse_used(_region_id: String) -> void:
	_add_lifetime("total_cleanses", 1)


func _on_hero_damaged(_amount: float) -> void:
	_hero_damage_taken = true
	_hero_damage_this_wave = true


func _on_wave_started(_wave_index: int) -> void:
	_hero_damage_this_wave = false


func _on_wave_completed(_wave_index: int) -> void:
	if not _hero_damage_this_wave:
		_battle_metrics["untouchable_wave"] = true


func _on_hero_melee_kill(_enemy_id: String) -> void:
	_battle_metrics["melee_kills"] = int(_battle_metrics.get("melee_kills", 0)) + 1


func _on_tower_damage(tower_id: String, amount: float, _enemy_id: String) -> void:
	if tower_id == "tower_archer":
		_battle_metrics["archer_damage"] = int(_battle_metrics.get("archer_damage", 0)) + int(amount)


func _on_enemy_stunned(_source: String, _enemy_id: String) -> void:
	_battle_metrics["stun_count"] = int(_battle_metrics.get("stun_count", 0)) + 1


func _on_tower_built(_tower_id: String) -> void:
	_battle_metrics["gold_spent"] = true


func _on_tower_upgraded(_tower_id: String, new_level: int) -> void:
	if new_level >= 3:
		var current := int(_battle_metrics.get("max_upgraded_towers", 0))
		_battle_metrics["max_upgraded_towers"] = current + 1


func record_gold_snapshot(gold: int, spent_since_last: bool) -> void:
	if spent_since_last:
		_battle_metrics["gold_spent"] = true
	if not bool(_battle_metrics.get("gold_spent", false)):
		_battle_metrics["peak_unspent_gold"] = maxi(int(_battle_metrics.get("peak_unspent_gold", 0)), gold)


func record_forge_tokens_spent(amount: int) -> void:
	_add_lifetime("total_forge_tokens_spent", amount)


func _add_lifetime(key: String, delta: int) -> void:
	if not SaveSystem:
		return
	SaveSystem.add_mission_lifetime(key, delta)
	_sync_lifetime_missions(key)


func _sync_lifetime_missions(key: String) -> void:
	if not DailyMissionService or not ContentRegistry:
		return
	for def in ContentRegistry.get_all_daily_mission_defs():
		if def.tracking_key != key:
			continue
		var value := SaveSystem.get_mission_lifetime(key)
		DailyMissionService.sync_lifetime_mission(def.mission_id, value)


func _flush_lifetime_missions() -> void:
	for key in ["total_div_kills", "total_cleanses", "total_forge_tokens_spent"]:
		_sync_lifetime_missions(key)


func _eval_per_battle_missions() -> void:
	if not DailyMissionService or not ContentRegistry:
		return
	for def in ContentRegistry.get_all_daily_mission_defs():
		var progress := 0
		match def.tracking_key:
			"untouchable_wave":
				progress = 1 if bool(_battle_metrics.get("untouchable_wave", false)) else 0
			"run_max_upgraded_towers":
				progress = int(_battle_metrics.get("max_upgraded_towers", 0))
			"run_peak_unspent_gold":
				progress = int(_battle_metrics.get("peak_unspent_gold", 0))
			"run_melee_kills":
				progress = int(_battle_metrics.get("melee_kills", 0))
			"run_archer_damage":
				progress = int(_battle_metrics.get("archer_damage", 0))
			"run_stun_count":
				progress = int(_battle_metrics.get("stun_count", 0))
			"pristine_boss_wave":
				progress = 1 if bool(_battle_metrics.get("pristine_boss_wave", false)) else 0
			_:
				continue
		DailyMissionService.update_mission_progress(def.mission_id, progress)


func notify_pristine_boss_wave() -> void:
	_battle_metrics["pristine_boss_wave"] = true
