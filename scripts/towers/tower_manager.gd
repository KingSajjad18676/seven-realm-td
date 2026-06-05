class_name TowerManager
extends Node

signal tower_spot_opened(spot: BuildSpot)
signal build_radial_requested(spot: BuildSpot)

var context: BattleContext = null
var build_spots: Array[BuildSpot] = []
var towers: Array[TowerController] = []
var tower_scene: PackedScene = preload("res://scenes/prefabs/tower.tscn")
var projectile_scene: PackedScene = preload("res://scenes/prefabs/projectile.tscn")
var towers_root: Node2D = null
var projectiles_root: Node2D = null
var _projectile_pool: ObjectPool = null
var selected_tower_id: String = "tower_archer"


func initialize(ctx: BattleContext, spots: Array[BuildSpot], t_root: Node2D, p_root: Node2D) -> void:
	context = ctx
	build_spots = spots
	towers_root = t_root
	projectiles_root = p_root
	_projectile_pool = ObjectPool.new(projectile_scene, p_root, 12)
	for spot in build_spots:
		spot.battle_context = ctx
		spot.spot_selected.connect(_on_spot_selected)
		if ctx.map_light:
			var light := ctx.map_light.get_light(spot.region_id)
			# Connect region updates via bootstrap


func find_spot_at(world_pos: Vector2, radius: float = 36.0) -> BuildSpot:
	var best: BuildSpot = null
	var best_dist := radius
	for spot in build_spots:
		if spot.occupied:
			continue
		var dist := world_pos.distance_to(spot.global_position)
		if dist <= best_dist:
			best_dist = dist
			best = spot
	return best


func find_spot_at_any(world_pos: Vector2, radius: float = -1.0) -> BuildSpot:
	var pick_radius := radius if radius > 0.0 else BuildPadVisuals.PAD_RADIUS + 8.0
	var best: BuildSpot = null
	var best_dist := pick_radius
	for spot in build_spots:
		var dist := world_pos.distance_to(spot.global_position)
		if dist <= best_dist:
			best_dist = dist
			best = spot
	return best


func try_select_spot_at_world(world_pos: Vector2) -> bool:
	var spot := find_spot_at_any(world_pos)
	if spot == null:
		return false
	_on_spot_selected(spot)
	return true


func try_build_on_spot(spot: BuildSpot, tower_id: String = "") -> bool:
	if context and context.tutorial_active and not context.tutorial_allows("build_pads"):
		return false
	if spot.occupied or context == null or context.economy == null:
		return false
	var tid := tower_id if tower_id != "" else selected_tower_id
	var tower_data := ContentRegistry.get_tower(tid)
	if tower_data == null:
		return false
	if not context.economy.spend_gold(tower_data.build_cost):
		if context.bridge:
			context.bridge.alert_message.emit("Not enough gold", 40)
		return false
	var node := tower_scene.instantiate() as TowerController
	towers_root.add_child(node)
	node.global_position = spot.global_position
	node.initialize(context, tower_data, spot)
	spot.set_occupied(node)
	towers.append(node)
	if context.map_light:
		node.on_region_light_changed(context.map_light.get_light(spot.region_id))
	return true


func try_upgrade_tower(tower: TowerController) -> bool:
	if tower == null:
		return false
	return tower.try_upgrade()


func replace_with_hybrid(keep_spot: BuildSpot, remove_spot: BuildSpot, hybrid_id: String) -> bool:
	if context == null or keep_spot == null or remove_spot == null:
		return false
	if keep_spot.tower == null or remove_spot.tower == null:
		return false
	var hybrid_data := ContentRegistry.get_tower(hybrid_id)
	if hybrid_data == null:
		return false
	var keep_tower := keep_spot.tower
	var invested := keep_tower.gold_invested + remove_spot.tower.gold_invested
	var keep_level := maxi(keep_tower.level, remove_spot.tower.level)
	towers.erase(remove_spot.tower)
	remove_spot.tower.queue_free()
	remove_spot.set_occupied(null)
	keep_tower.data = hybrid_data
	keep_tower.gold_invested = invested
	keep_tower.level = keep_level
	if keep_tower.has_method("_apply_forge_visuals"):
		keep_tower._apply_forge_visuals()
	return true


func try_sell_tower(tower: TowerController) -> bool:
	if tower == null or context == null or context.economy == null:
		return false
	if tower.hijack_phase != GameEnums.HijackPhase.NONE:
		if context.bridge:
			context.bridge.alert_message.emit("Cannot sell while hijacked", 40)
		return false
	var refund := tower.get_sell_refund()
	var tower_id := tower.data.tower_id if tower.data else ""
	if tower.build_spot:
		tower.build_spot.set_occupied(null)
	context.economy.add_gold(refund)
	towers.erase(tower)
	tower.queue_free()
	CombatEvents.tower_sold.emit(tower_id, refund)
	AnalyticsService.tower_sold(tower_id, refund)
	return true


func spawn_projectile(tower: TowerController, target: EnemyController) -> void:
	var proj := _projectile_pool.acquire() as ProjectileController
	if proj == null:
		return
	proj.launch(tower.global_position, target, tower.data.projectile_speed, tower.data.color)
	proj.hit_target.connect(func() -> void:
		_projectile_pool.release(proj)
	, CONNECT_ONE_SHOT)


func _on_spot_selected(spot: BuildSpot) -> void:
	if context == null:
		return
	if context.map_light:
		context.map_light.select_region(spot.region_id)
	if spot.occupied and spot.tower:
		if context.tutorial_active:
			return
		tower_spot_opened.emit(spot)
		return
	build_radial_requested.emit(spot)
