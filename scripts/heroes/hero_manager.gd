class_name HeroManager
extends Node

var context: BattleContext = null
var hero: HeroController = null
var hero_scene: PackedScene = preload("res://scenes/prefabs/hero.tscn")
var heroes_root: Node2D = null


func initialize(ctx: BattleContext, root: Node2D) -> void:
	context = ctx
	heroes_root = root
	var catalog_hero := ContentRegistry.get_hero(ctx.level_data.hero_id if ctx.level_data else "rostam")
	if catalog_hero == null:
		return
	var hero_data := catalog_hero.duplicate(true) as HeroData
	hero = hero_scene.instantiate() as HeroController
	if hero == null:
		push_error("HeroManager: failed to instantiate hero prefab")
		return
	heroes_root.add_child(hero)
	var start := _hero_start_position(ctx.level_data)
	hero.initialize(ctx, hero_data, start)


func _hero_start_position(level: LevelData) -> Vector2:
	if level == null:
		return Vector2.ZERO
	var pts := level.path_points
	if pts.size() >= 2:
		return pts[pts.size() - 2].lerp(pts[pts.size() - 1], 0.72)
	return level.gate_position + Vector2(-100, 0)


func cancel_hero_move() -> void:
	if hero:
		hero.cancel_move()


func handle_ground_tap(pos: Vector2) -> void:
	if hero == null or context == null:
		return
	if context.tutorial_active and not context.tutorial_allows("battlefield"):
		return
	if context.tower_manager:
		for spot in context.tower_manager.build_spots:
			if spot.occupied and spot.tower and pos.distance_to(spot.global_position) < 40.0:
				hero.tether_to_tower(spot.tower)
				return
	hero.move_to(pos)
