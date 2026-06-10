class_name HeroManager
extends Node

var context: BattleContext = null
var hero: HeroController = null
var heroes: Array[HeroController] = []
var hero_scene: PackedScene = preload("res://scenes/prefabs/hero.tscn")
var heroes_root: Node2D = null


func initialize(ctx: BattleContext, root: Node2D) -> void:
	context = ctx
	heroes_root = root
	if ctx.launch_data and ctx.launch_data.is_brothers_mode:
		return
	_spawn_solo_hero(ctx.level_data.hero_id if ctx.level_data else "rostam")


func initialize_brothers(hero_ids: Array[String]) -> void:
	_clear_heroes()
	for i in hero_ids.size():
		var hero_id := hero_ids[i]
		var ctrl := _spawn_hero(hero_id, _brothers_start_position(i))
		if ctrl:
			ctrl.player_index = i
			heroes.append(ctrl)
	if not heroes.is_empty():
		hero = heroes[0]


func _spawn_solo_hero(hero_id: String) -> void:
	_clear_heroes()
	var ctrl := _spawn_hero(hero_id, _hero_start_position(context.level_data if context else null))
	if ctrl:
		ctrl.player_index = 0
		heroes.append(ctrl)
		hero = ctrl


func _spawn_hero(hero_id: String, start: Vector2) -> HeroController:
	var catalog_hero := ContentRegistry.get_hero(hero_id)
	if catalog_hero == null or heroes_root == null:
		return null
	var hero_data := catalog_hero.duplicate(true) as HeroData
	_apply_selected_skill(hero_data)
	var ctrl := hero_scene.instantiate() as HeroController
	if ctrl == null:
		push_error("HeroManager: failed to instantiate hero prefab")
		return null
	heroes_root.add_child(ctrl)
	ctrl.initialize(context, hero_data, start)
	return ctrl


func _apply_selected_skill(hero_data: HeroData) -> void:
	if hero_data == null or SaveSystem == null:
		return
	var selected := SaveSystem.get_hero_skill_selected()
	if selected == "" or not ContentCatalog.is_valid_hero_skill_id(selected):
		return
	if not SaveSystem.is_hero_skill_unlocked(selected):
		return
	hero_data.skill_id = selected


func _clear_heroes() -> void:
	for h in heroes:
		if is_instance_valid(h):
			h.queue_free()
	heroes.clear()
	hero = null


func _hero_start_position(level: LevelData) -> Vector2:
	if level == null:
		return Vector2.ZERO
	level.ensure_routes_migrated()
	var pts := level.get_route()
	if pts.size() >= 2:
		return pts[pts.size() - 2].lerp(pts[pts.size() - 1], 0.72)
	return level.gate_position + Vector2(-100, 0)


func _brothers_start_position(slot_index: int) -> Vector2:
	var base := _hero_start_position(context.level_data if context else null)
	return base + Vector2(-80.0 if slot_index == 0 else 80.0, 0.0)


func get_living_heroes() -> Array[HeroController]:
	var living: Array[HeroController] = []
	for h in heroes:
		if h and is_instance_valid(h) and not h.is_dead():
			living.append(h)
	return living


func get_hero_for_slot(slot_index: int) -> HeroController:
	for h in heroes:
		if h and h.player_index == slot_index:
			return h
	return hero


func get_controlled_hero() -> HeroController:
	if is_brothers_mode() and context and context.coop_players:
		return get_hero_for_slot(context.coop_players.focused_player_index)
	return hero


func is_brothers_mode() -> bool:
	return context != null and context.launch_data != null and context.launch_data.is_brothers_mode


func apply_move_input(vec: Vector2) -> void:
	var target := get_controlled_hero()
	if target and is_instance_valid(target):
		target.set_move_input(vec)


func cancel_hero_move() -> void:
	for h in get_living_heroes():
		h.cancel_move()
