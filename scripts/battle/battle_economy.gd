class_name BattleEconomy
extends Node

var context: BattleContext = null
var gold: int = 0
var sacred_fire: int = 0
var forge_materials_earned: Dictionary = {}


func get_unbanked_materials() -> Dictionary:
	if _uses_coop_wallets():
		return context.coop_players.get_merged_materials()
	return forge_materials_earned.duplicate()


func collect_material(material_id: String, amount: int, player_index: int = -1) -> void:
	if material_id == "" or amount <= 0:
		return
	if _uses_coop_wallets():
		var slot_index := player_index
		if slot_index < 0 and context.coop_players:
			slot_index = context.coop_players.focused_player_index
		context.coop_players.add_material(slot_index, material_id, amount)
		return
	forge_materials_earned[material_id] = int(forge_materials_earned.get(material_id, 0)) + amount
	_emit_materials()


func clear_unbanked_materials() -> void:
	forge_materials_earned.clear()
	if context and context.coop_players and context.coop_players.is_active():
		context.coop_players.clear_all_unbanked_materials()
	_emit_materials()


func initialize(ctx: BattleContext) -> void:
	context = ctx
	if ctx.level_data:
		gold = ctx.level_data.starting_gold
		if not _uses_coop_wallets():
			sacred_fire = ctx.level_data.starting_sacred_fire
	_emit()


func can_afford_gold(cost: int) -> bool:
	return gold >= cost


func spend_gold(cost: int) -> bool:
	if not can_afford_gold(cost):
		return false
	gold -= cost
	if MissionProgressTracker:
		MissionProgressTracker.record_gold_snapshot(gold, true)
	_emit()
	return true


func add_gold(amount: int) -> void:
	gold += amount
	if MissionProgressTracker:
		MissionProgressTracker.record_gold_snapshot(gold, false)
	_emit()


func can_afford_sacred_fire(cost: int, player_index: int = -1) -> bool:
	if _uses_coop_wallets():
		var slot_index := _resolve_player_index(player_index)
		return context.coop_players.can_afford_sacred_fire(slot_index, cost)
	return sacred_fire >= cost


func spend_sacred_fire(cost: int, player_index: int = -1) -> bool:
	if _uses_coop_wallets():
		var slot_index := _resolve_player_index(player_index)
		if not context.coop_players.spend_sacred_fire(slot_index, cost):
			return false
		CombatEvents.cleanse_used.emit("")
		return true
	if not can_afford_sacred_fire(cost):
		return false
	sacred_fire -= cost
	_emit()
	CombatEvents.cleanse_used.emit("")
	return true


func add_sacred_fire(amount: int, player_index: int = -1) -> void:
	if amount <= 0:
		return
	if _uses_coop_wallets():
		context.coop_players.add_sacred_fire(_resolve_player_index(player_index), amount)
		return
	sacred_fire += amount
	_emit()


func set_sacred_fire(amount: int) -> void:
	sacred_fire = maxi(0, amount)
	_emit()


func apply_kill_rewards(enemy_data: EnemyData, reward_pos: Vector2 = Vector2.INF) -> void:
	if enemy_data == null:
		return
	add_gold(enemy_data.gold_reward)
	if enemy_data.sacred_fire_reward > 0:
		var slot_index := _slot_nearest_to_position(reward_pos)
		add_sacred_fire(enemy_data.sacred_fire_reward, slot_index)
	CombatEvents.enemy_killed.emit(
		enemy_data.enemy_id,
		enemy_data.gold_reward,
		enemy_data.sacred_fire_reward
	)


func _uses_coop_wallets() -> bool:
	return (
		context != null
		and context.coop_players != null
		and context.coop_players.is_active()
	)


func _resolve_player_index(player_index: int) -> int:
	if player_index >= 0:
		return player_index
	if context and context.coop_players:
		return context.coop_players.focused_player_index
	return 0


func _slot_nearest_to_position(pos: Vector2) -> int:
	if not _uses_coop_wallets() or pos == Vector2.INF:
		return _resolve_player_index(-1)
	if context.hero_manager == null:
		return 0
	var best_slot := 0
	var best_dist := INF
	for hero in context.hero_manager.get_living_heroes():
		var dist := hero.global_position.distance_squared_to(pos)
		if dist < best_dist:
			best_dist = dist
			best_slot = hero.player_index
	return best_slot


func _emit() -> void:
	if context and context.bridge:
		context.bridge.gold_changed.emit(gold)
		if _uses_coop_wallets():
			var focused := context.coop_players.get_focused_slot()
			if focused:
				context.bridge.sacred_fire_changed.emit(focused.sacred_fire)
		else:
			context.bridge.sacred_fire_changed.emit(sacred_fire)


func _emit_materials() -> void:
	if context and context.bridge:
		context.bridge.materials_changed.emit(get_unbanked_materials())
