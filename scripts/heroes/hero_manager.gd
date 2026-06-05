class_name HeroManager
extends Node

var context: BattleContext = null
var hero: HeroController = null
var hero_scene: PackedScene = preload("res://scenes/prefabs/hero.tscn")
var heroes_root: Node2D = null


func initialize(ctx: BattleContext, root: Node2D) -> void:
	context = ctx
	heroes_root = root
	var hero_data := ContentRegistry.get_hero(ctx.level_data.hero_id if ctx.level_data else "rostam")
	if hero_data == null:
		return
	hero = hero_scene.instantiate() as HeroController
	heroes_root.add_child(hero)
	var start := ctx.level_data.spawn_position + Vector2(0, 80) if ctx.level_data else Vector2.ZERO
	hero.initialize(ctx, hero_data, start)


func handle_ground_tap(pos: Vector2) -> void:
	if hero == null or context == null:
		return
	if context.tower_manager:
		for spot in context.tower_manager.build_spots:
			if spot.occupied and spot.tower and pos.distance_to(spot.global_position) < 40.0:
				hero.tether_to_tower(spot.tower)
				return
	hero.move_to(pos)
