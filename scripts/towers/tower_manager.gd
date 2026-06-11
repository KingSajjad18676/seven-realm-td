class_name TowerManager
extends Node

signal tower_opened(tower: TowerController)
signal build_radial_requested(world_pos: Vector2, region_id: String)

var context: BattleContext = null
var towers: Array[TowerController] = []
var tower_scene: PackedScene = preload("res://scenes/prefabs/tower.tscn")
var projectile_scene: PackedScene = preload("res://scenes/prefabs/projectile.tscn")
var towers_root: Node2D = null
var projectiles_root: Node2D = null
var units_root: Node2D = null
var _projectile_pool: ObjectPool = null
var selected_tower_id: String = "tower_archer"
var _next_placement_index: int = 0


func initialize(ctx: BattleContext, t_root: Node2D, p_root: Node2D, u_root: Node2D = null) -> void:
	context = ctx
	towers_root = t_root
	projectiles_root = p_root
	units_root = u_root if u_root else t_root
	_projectile_pool = ObjectPool.new(projectile_scene, p_root, 12)


func find_tower_at(world_pos: Vector2, radius: float = -1.0) -> TowerController:
	var best: TowerController = null
	var best_dist := -1.0
	for tower in towers:
		if not is_instance_valid(tower):
			continue
		var pick_radius := radius if radius > 0.0 else tower.get_pick_radius()
		var dist := world_pos.distance_to(tower.global_position)
		if dist <= pick_radius and (best == null or dist < best_dist):
			best_dist = dist
			best = tower
	return best


func is_valid_build_position(world_pos: Vector2) -> bool:
	if context == null or context.level_data == null:
		return false
	return TowerPlacementValidator.is_valid(world_pos, context.level_data, towers)


func try_select_at_world(world_pos: Vector2) -> bool:
	var tower := find_tower_at(world_pos)
	if tower != null:
		return _on_tower_selected(tower)
	if not is_valid_build_position(world_pos):
		return false
	return _request_build_radial(world_pos)


func try_build_at(world_pos: Vector2, tower_id: String = "") -> bool:
	if context and context.tutorial_active and not context.tutorial_allows("build_pads"):
		return false
	if context == null or context.economy == null or context.level_data == null:
		return false
	if not TowerPlacementValidator.is_valid(world_pos, context.level_data, towers):
		var reason := TowerPlacementValidator.rejection_reason(world_pos, context.level_data, towers)
		if context.bridge:
			context.bridge.alert_message.emit(reason if reason != "" else "Cannot build here", 45)
		return false
	var tid := tower_id if tower_id != "" else selected_tower_id
	var tower_data := ContentRegistry.get_tower(tid)
	if tower_data == null:
		return false
	var build_cost := tower_data.build_cost
	if tid == "tower_heavy" and context.runtime_modifiers.has("heavy_tower_cost_mult"):
		build_cost = int(roundf(float(build_cost) * float(context.runtime_modifiers["heavy_tower_cost_mult"])))
	if not context.economy.spend_gold(build_cost):
		if context.bridge:
			context.bridge.alert_message.emit("Not enough gold", 40)
		return false
	var region_id := _region_for_position(world_pos)
	var placement_id := "tower_%d" % _next_placement_index
	_next_placement_index += 1
	var node := tower_scene.instantiate() as TowerController
	towers_root.add_child(node)
	node.global_position = world_pos
	node.initialize(context, tower_data, world_pos, region_id, placement_id)
	towers.append(node)
	if context.equipment_battle:
		context.equipment_battle.on_tower_built(node, build_cost)
	if context.map_light:
		node.on_region_light_changed(context.map_light.get_light(region_id))
	if context.tower_resonance:
		context.tower_resonance.on_tower_placed(node)
	return true


func try_upgrade_tower(tower: TowerController) -> bool:
	if tower == null:
		return false
	return tower.try_upgrade()


func try_sell_tower(tower: TowerController) -> bool:
	if tower == null or context == null or context.economy == null:
		return false
	if tower.hijack_phase != GameEnums.HijackPhase.NONE:
		if context.bridge:
			context.bridge.alert_message.emit("Cannot sell while hijacked", 40)
		return false
	var refund := tower.get_sell_refund()
	var original_cost := tower.gold_invested
	var tower_id := tower.data.tower_id if tower.data else ""
	context.economy.add_gold(refund)
	if context.equipment_battle:
		context.equipment_battle.on_tower_sold(refund, original_cost)
	towers.erase(tower)
	tower.queue_free()
	if context.tower_resonance:
		context.tower_resonance.on_tower_removed(tower)
	CombatEvents.tower_sold.emit(tower_id, refund)
	AnalyticsService.tower_sold(tower_id, refund)
	return true


func destroy_tower(tower: TowerController, refund: bool = false) -> bool:
	if tower == null or context == null:
		return false
	if tower.hijack_phase != GameEnums.HijackPhase.NONE:
		return false
	var tower_id := tower.data.tower_id if tower.data else ""
	var refund_amount := tower.get_sell_refund() if refund else 0
	if refund and context.economy:
		context.economy.add_gold(refund_amount)
	towers.erase(tower)
	tower.queue_free()
	if context.tower_resonance:
		context.tower_resonance.on_tower_removed(tower)
	return true


func spawn_projectile(
	tower: TowerController,
	target: EnemyController,
	on_impact: Callable = Callable()
) -> void:
	var proj := _projectile_pool.acquire() as ProjectileController
	if proj == null:
		if on_impact.is_valid():
			on_impact.call()
		return
	proj.launch(tower.global_position, target, tower.data.projectile_speed, tower.data.color)
	proj.hit_target.connect(func() -> void:
		if on_impact.is_valid() and is_instance_valid(target) and target.current_hp > 0.0:
			on_impact.call()
		_projectile_pool.release(proj)
	, CONNECT_ONE_SHOT)


func get_active_projectile_count() -> int:
	return _projectile_pool.in_use_count() if _projectile_pool else 0


func _region_for_position(world_pos: Vector2) -> String:
	if context == null or context.level_data == null:
		return ""
	context.level_data.ensure_routes_migrated()
	return MapRegionUtils.region_for_position(
		world_pos,
		context.level_data.get_all_route_points(),
		context.level_data.region_ids
	)


func _on_tower_selected(tower: TowerController) -> bool:
	if context == null or tower == null:
		return false
	if context.map_light and tower.region_id != "":
		context.map_light.select_region(tower.region_id)
	if context.tutorial_active and not context.tutorial_allows("build_pads"):
		return false
	tower_opened.emit(tower)
	return true


func _request_build_radial(world_pos: Vector2) -> bool:
	if context == null:
		return false
	if context.tutorial_active and not context.tutorial_allows("build_pads"):
		return false
	var region_id := _region_for_position(world_pos)
	if context.map_light and region_id != "":
		context.map_light.select_region(region_id)
	build_radial_requested.emit(world_pos, region_id)
	return true
