class_name EquipmentBattleService
extends Node

const NEAR_HERO_RANGE := 120.0

var context: BattleContext = null
var equipped_pieces: Array[EquipmentPieceData] = []
var active_rules: Array[String] = []
var set_counts: Dictionary = {}
var battle_flags: Dictionary = {}

var _shield_timer: float = 0.0
var _shield_hp: float = 0.0
var _hero_in_combat: bool = false
var _combat_timer: float = 0.0
var _fire_nova_used: bool = false
var _damage_speed_bonus: float = 0.0


func initialize(ctx: BattleContext, piece_ids: Array[String]) -> void:
	context = ctx
	equipped_pieces.clear()
	active_rules.clear()
	set_counts.clear()
	battle_flags.clear()
	if ContentRegistry:
		for pid in piece_ids:
			var piece := ContentRegistry.get_equipment_piece(str(pid))
			if piece:
				equipped_pieces.append(piece)
	_apply_base_stats()
	_resolve_set_rules()


func _apply_base_stats() -> void:
	if context == null:
		return
	var mods := context.runtime_modifiers
	for piece in equipped_pieces:
		for key in piece.stat_modifiers.keys():
			var val: Variant = piece.stat_modifiers[key]
			if val is bool:
				mods[key] = val
			elif key.ends_with("_mult") and val is float:
				mods[key] = float(mods.get(key, 1.0)) * float(val)
			elif val is float or val is int:
				mods[key] = float(mods.get(key, 0.0)) + float(val)


func _resolve_set_rules() -> void:
	var counts: Dictionary = {}
	for piece in equipped_pieces:
		counts[piece.set_id] = int(counts.get(piece.set_id, 0)) + 1
	set_counts = counts
	for set_id in counts.keys():
		var count: int = counts[set_id]
		var set_data := ContentRegistry.get_equipment_set(str(set_id)) if ContentRegistry else null
		if set_data == null:
			continue
		if count >= 2 and set_data.two_piece_rule_id != "":
			active_rules.append(set_data.two_piece_rule_id)
		if count >= 3 and set_data.three_piece_rule_id != "":
			active_rules.append(set_data.three_piece_rule_id)
		if count >= 4 and set_data.four_piece_rule_id != "":
			active_rules.append(set_data.four_piece_rule_id)
	for rule_id in active_rules:
		EquipmentSetRules.apply_rule(rule_id, self)


func has_rule(rule_id: String) -> bool:
	return rule_id in active_rules


func _process(delta: float) -> void:
	if context == null:
		return
	_tick_shield(delta)
	_tick_combat_state(delta)
	if has_rule("arzhang_combat_tower_haste"):
		if _hero_in_combat:
			context.runtime_modifiers["equipment_tower_rate_mult"] = 1.15
		else:
			context.runtime_modifiers.erase("equipment_tower_rate_mult")
	if has_rule("kaveh_periodic_shield"):
		_shield_timer -= delta
		if _shield_timer <= 0.0:
			_shield_timer = 10.0
			_shield_hp = 40.0
			if context.bridge:
				context.bridge.alert_message.emit("Kaveh's shield rises!", 35)


func _tick_combat_state(delta: float) -> void:
	if context == null or context.hero_manager == null or context.hero_manager.hero == null:
		return
	var hero: HeroController = context.hero_manager.hero
	var near_enemy := false
	for e in context.active_enemies:
		if e is EnemyController and hero.global_position.distance_to(e.global_position) < 100.0:
			near_enemy = true
			break
	if near_enemy:
		_hero_in_combat = true
		_combat_timer = 2.0
	elif _combat_timer > 0.0:
		_combat_timer -= delta
	else:
		_hero_in_combat = false


func _tick_shield(delta: float) -> void:
	pass


func absorb_shield_damage(amount: float) -> float:
	if _shield_hp <= 0.0:
		return amount
	var absorbed := minf(amount, _shield_hp)
	_shield_hp -= absorbed
	return amount - absorbed


func notify_hero_damaged(amount: float) -> void:
	if has_rule("arzhang_flayed_speed") or _has_stat("hero_damage_speed_boost"):
		_damage_speed_bonus = minf(0.5, _damage_speed_bonus + amount * 0.002)
		if context:
			context.runtime_modifiers["hero_move_speed_mult"] = 1.0 + _damage_speed_bonus


func notify_hero_hp_changed(old_hp: float, new_hp: float, max_hp: float) -> void:
	if has_rule("azhdaha_fire_nova") and not _fire_nova_used:
		if old_hp / max_hp > 0.2 and new_hp / max_hp <= 0.2:
			_fire_nova_used = true
			EquipmentSetRules.trigger_fire_nova(self)


func notify_hero_melee_hit(enemy: EnemyController, damage: float) -> void:
	if enemy == null:
		return
	if has_rule("azhdaha_melee_burn"):
		enemy.apply_burn(3.0)
	if has_rule("mazandaran_melee_slow"):
		enemy.apply_slow(0.7, 2.0)
	if has_rule("arzhang_cleave"):
		_apply_cleave(enemy, damage)


func notify_hero_kill(enemy: EnemyController) -> void:
	if enemy == null or context == null:
		return
	if _has_stat("hero_lifesteal_on_kill") and context.hero_manager and context.hero_manager.hero:
		var hero: HeroController = context.hero_manager.hero
		var heal := hero.data.max_hp * float(context.runtime_modifiers.get("hero_lifesteal_on_kill", 0.01))
		hero.heal(heal)


func notify_enemy_death(enemy: EnemyController) -> void:
	if enemy == null:
		return
	if has_rule("mazandaran_toxic_explosion") and enemy.has_active_debuff():
		EquipmentSetRules.spawn_toxic_cloud(self, enemy.global_position)


func on_tower_built(tower: TowerController, cost: int) -> void:
	if has_rule("thirst_tower_refund") and context and context.economy:
		var refund := int(roundf(float(cost) * 0.10))
		context.economy.add_gold(refund)


func on_tower_sold(refund: int, original_cost: int) -> void:
	if not has_rule("thirst_tower_sell_bonus"):
		return
	if bool(battle_flags.get("thirst_sell_used", false)):
		return
	battle_flags["thirst_sell_used"] = true
	if context and context.economy:
		context.economy.add_gold(original_cost * 2 - refund)
	if context and context.lives:
		context.lives.heal_life(1)


func on_tether_activated() -> void:
	if has_rule("arzhang_blood_frenzy"):
		EquipmentSetRules.trigger_blood_frenzy(self)


func get_tower_range_mult_near_hero(tower: TowerController) -> float:
	if not has_rule("rakhsh_tower_range_near_hero") or context == null or context.hero_manager == null:
		return 1.0
	var hero: HeroController = context.hero_manager.hero
	if hero == null or tower == null:
		return 1.0
	if hero.global_position.distance_to(tower.global_position) <= NEAR_HERO_RANGE:
		return 1.10
	return 1.0


func try_gate_rebuild() -> bool:
	if not has_rule("kaveh_gate_rebuild") or bool(battle_flags.get("kaveh_gate_used", false)):
		return false
	if context == null or context.economy == null or context.lives == null:
		return false
	battle_flags["kaveh_gate_used"] = true
	var gold := context.economy.gold
	context.economy.spend_gold(gold)
	context.lives.current_lives = 1
	context.lives._emit()
	if context.bridge:
		context.bridge.alert_message.emit("Kaveh rebuilds the Gate!", 80)
	return true


func _apply_cleave(primary: EnemyController, damage: float) -> void:
	if context == null or context.hero_manager == null or context.hero_manager.hero == null:
		return
	var hero: HeroController = context.hero_manager.hero
	var facing := (primary.global_position - hero.global_position).normalized()
	for e in context.active_enemies:
		if e == primary or not e is EnemyController:
			continue
		var enemy: EnemyController = e
		var to_enemy := (enemy.global_position - hero.global_position).normalized()
		if facing.dot(to_enemy) >= 0.0 and hero.global_position.distance_to(enemy.global_position) <= 70.0:
			enemy.take_damage(damage * 0.75, false)


func _has_stat(key: String) -> bool:
	if context == null:
		return false
	return context.runtime_modifiers.has(key) and bool(context.runtime_modifiers[key])
