class_name TowerManager
extends Node

signal tower_spot_opened(spot: BuildSpot)

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
		spot.spot_selected.connect(_on_spot_selected)
		if ctx.map_light:
			var light := ctx.map_light.get_light(spot.region_id)
			# Connect region updates via bootstrap


func try_build_on_spot(spot: BuildSpot) -> bool:
	if spot.occupied or context == null or context.economy == null:
		return false
	var tower_data := ContentRegistry.get_tower(selected_tower_id)
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
		tower_spot_opened.emit(spot)
		return
	try_build_on_spot(spot)
