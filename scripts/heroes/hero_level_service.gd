class_name HeroLevelService
extends Node

const MAX_LEVEL := 10
const XP_BASE := 60.0
const XP_EXPONENT := 1.4
const DAMAGE_PER_LEVEL := 0.08
const HP_PER_LEVEL := 0.10

var context: BattleContext = null
var _xp: int = 0
var _level: int = 1


func initialize(ctx: BattleContext) -> void:
	context = ctx
	_apply_level_modifiers()
	if not CombatEvents.enemy_killed.is_connected(_on_enemy_killed):
		CombatEvents.enemy_killed.connect(_on_enemy_killed)


func get_level() -> int:
	return _level


func get_xp_progress() -> float:
	if _level >= MAX_LEVEL:
		return 1.0
	var needed := xp_to_next_level(_level)
	if needed <= 0:
		return 1.0
	return clampf(float(_xp) / float(needed), 0.0, 1.0)


func xp_to_next_level(level: int = -1) -> int:
	var lvl := level if level > 0 else _level
	if lvl >= MAX_LEVEL:
		return 0
	return int(round(XP_BASE * pow(float(lvl), XP_EXPONENT)))


func get_damage_mult() -> float:
	return 1.0 + float(_level - 1) * DAMAGE_PER_LEVEL


func get_hp_mult() -> float:
	return 1.0 + float(_level - 1) * HP_PER_LEVEL


func _on_enemy_killed(enemy_id: String, _gold: int, _sf: int) -> void:
	_grant_xp(_xp_for_kill(enemy_id))


func _xp_for_kill(enemy_id: String) -> int:
	var enemy := ContentRegistry.get_enemy(enemy_id) if ContentRegistry else null
	var base := 8
	if enemy:
		if enemy.is_boss:
			base = 120
		elif enemy.max_hp >= 100.0:
			base = 25
		else:
			base = 8 + int(enemy.max_hp / 20.0)
	var level_id := context.level_data.level_id if context and context.level_data else "level_01"
	var khan_idx := ContentCatalog.khan_index(level_id)
	var khan_scale := 1.0 + maxf(0.0, float(khan_idx - 1)) * 0.05
	return maxi(1, int(round(float(base) * khan_scale)))


func _grant_xp(amount: int) -> void:
	if amount <= 0 or _level >= MAX_LEVEL:
		return
	_xp += amount
	while _level < MAX_LEVEL and _xp >= xp_to_next_level(_level):
		_xp -= xp_to_next_level(_level)
		_level += 1
		_on_level_up()


func _on_level_up() -> void:
	_apply_level_modifiers()
	_heal_heroes_on_level_up()
	if context and context.bridge:
		context.bridge.alert_message.emit("Hero level %d!" % _level, 50)


func _apply_level_modifiers() -> void:
	if context == null:
		return
	context.runtime_modifiers["hero_level_damage_mult"] = get_damage_mult()
	context.runtime_modifiers["hero_level_hp_mult"] = get_hp_mult()


func _heal_heroes_on_level_up() -> void:
	if context == null or context.hero_manager == null:
		return
	for hero in context.hero_manager.get_living_heroes():
		if hero.has_method("apply_level_hp_bonus"):
			hero.apply_level_hp_bonus()
