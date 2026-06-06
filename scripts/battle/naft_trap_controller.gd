class_name NaftTrapController
extends Node

const SNAP_RADIUS := 40.0

var context: BattleContext = null
var effects_root: Node2D = null

var _hero_data: HeroData = null
var _charges: float = 0.0
var _refill_bank: float = 0.0
var _armed: bool = false
var _slicks: Array[NaftSlick] = []


func initialize(ctx: BattleContext, root: Node2D) -> void:
	context = ctx
	effects_root = root
	_refresh_hero_data()
	if _hero_data:
		_charges = float(_hero_data.naft_max_charges)


func is_enabled() -> bool:
	return _hero_data != null and _hero_data.secondary_skill_id == "rostam_naft"


func is_armed() -> bool:
	return _armed and is_enabled()


func get_charges() -> int:
	return int(floorf(_charges))


func get_max_charges() -> int:
	return _hero_data.naft_max_charges if _hero_data else 0


func toggle_arm() -> void:
	if not is_enabled() or not _can_use():
		return
	_armed = not _armed
	if _armed and context and context.bridge:
		context.bridge.alert_message.emit("Tap the path to spill Naft", 45)


func disarm() -> void:
	_armed = false


func try_place_at(world_pos: Vector2) -> bool:
	if not is_armed() or not _can_use():
		return false
	if _charges < 1.0:
		if context and context.bridge:
			context.bridge.alert_message.emit("Naft pouch empty", 35)
		_armed = false
		return false
	var snap := _snap_to_path(world_pos)
	if snap.is_empty():
		if context and context.bridge:
			context.bridge.alert_message.emit("Spill Naft on the enemy path", 40)
		return false
	_charges -= 1.0
	_armed = false
	_add_slick(snap)
	if context and context.bridge:
		context.bridge.alert_message.emit("Naft slick placed", 35)
	return true


func try_ignite_from_fire(target: EnemyController, tower_data: TowerData) -> void:
	if not is_enabled() or target == null or tower_data == null:
		return
	if not tower_data.applies_burn:
		return
	for slick in _slicks:
		if slick.state != NaftSlick.State.OIL:
			continue
		if slick.is_enemy_inside(target):
			_ignite_slick(slick)
			return


func _process(delta: float) -> void:
	if not is_enabled() or context == null:
		return
	if context.state_controller == null:
		return
	if context.state_controller.current_state != GameEnums.BattleState.WAVE_ACTIVE:
		return
	_refill_charges(delta)
	_tick_slicks(delta)


func _refill_charges(delta: float) -> void:
	if _hero_data == null:
		return
	var max_c := float(_hero_data.naft_max_charges)
	if _charges >= max_c:
		return
	_refill_bank += delta / maxf(0.1, _hero_data.naft_refill_sec)
	while _refill_bank >= 1.0 and _charges < max_c:
		_charges += 1.0
		_refill_bank -= 1.0


func _tick_slicks(delta: float) -> void:
	var i := _slicks.size() - 1
	while i >= 0:
		var slick := _slicks[i]
		slick.remaining_sec -= delta
		if slick.state == NaftSlick.State.OIL:
			_apply_oil_slow(slick)
		else:
			_apply_blaze_damage(slick, delta)
		if slick.remaining_sec <= 0.0:
			_remove_slick_at(i)
		i -= 1


func _apply_oil_slow(slick: NaftSlick) -> void:
	if _hero_data == null or context == null:
		return
	for e in context.active_enemies:
		if e is EnemyController and slick.is_enemy_inside(e):
			(e as EnemyController).apply_slow(_hero_data.naft_slow_mult, 0.25)


func _apply_blaze_damage(slick: NaftSlick, delta: float) -> void:
	if _hero_data == null or context == null:
		return
	var tick := _hero_data.naft_blaze_dps * delta
	for e in context.active_enemies:
		if e is EnemyController and slick.is_enemy_inside(e):
			(e as EnemyController).take_damage(tick)


func _ignite_slick(slick: NaftSlick) -> void:
	if slick.state != NaftSlick.State.OIL or _hero_data == null:
		return
	slick.state = NaftSlick.State.BLAZING
	slick.remaining_sec = _hero_data.naft_blaze_duration_sec
	_update_visual(slick)
	if context:
		for e in context.active_enemies:
			if e is EnemyController and slick.is_enemy_inside(e):
				(e as EnemyController).take_damage(_hero_data.naft_blaze_burst_damage)
	CombatEvents.naft_slick_ignited.emit(slick.route_id)
	if context and context.bridge:
		context.bridge.alert_message.emit("Naft ignited!", 45)


func _add_slick(snap: Dictionary) -> void:
	if _hero_data == null:
		return
	while _slicks.size() >= _hero_data.naft_max_active:
		_remove_slick_at(0)
	var slick := NaftSlick.new()
	slick.route_id = str(snap.get("route_id", ""))
	slick.path = snap.get("path", PackedVector2Array())
	slick.center_path_dist = float(snap.get("center_path_dist", 0.0))
	slick.half_length = _hero_data.naft_slick_half_length
	slick.state = NaftSlick.State.OIL
	slick.remaining_sec = _hero_data.naft_oil_duration_sec
	slick.visual = _create_visual(slick)
	if effects_root and slick.visual:
		effects_root.add_child(slick.visual)
	_slicks.append(slick)


func _remove_slick_at(index: int) -> void:
	if index < 0 or index >= _slicks.size():
		return
	var slick := _slicks[index]
	if slick.visual and is_instance_valid(slick.visual):
		slick.visual.queue_free()
	_slicks.remove_at(index)


func _snap_to_path(world_pos: Vector2) -> Dictionary:
	if context == null or context.level_data == null:
		return {}
	var level := context.level_data
	level.ensure_routes_migrated()
	var routes := level.path_routes
	var best_dist_sq := INF
	var best: Dictionary = {}
	if routes.is_empty():
		var path := level.get_route()
		var snap := _snap_on_path(path, world_pos, level.get_primary_route_id())
		if not snap.is_empty():
			return snap
		return {}
	for route in routes:
		var path := PackedVector2Array(route.points)
		var snap := _snap_on_path(path, world_pos, route.route_id)
		var d_sq := float(snap.get("dist_sq", INF))
		if d_sq < best_dist_sq:
			best_dist_sq = d_sq
			best = snap
	if best_dist_sq > SNAP_RADIUS * SNAP_RADIUS:
		return {}
	return best


func _snap_on_path(path: PackedVector2Array, world_pos: Vector2, route_id: String) -> Dictionary:
	if path.size() < 2:
		return {}
	var path_dist := PathFollower.closest_distance_on_path(path, world_pos)
	var on_path := PathFollower.position_at_distance(path, path_dist)
	var d_sq := world_pos.distance_squared_to(on_path)
	return {
		"route_id": route_id,
		"path": path,
		"center_path_dist": path_dist,
		"dist_sq": d_sq,
	}


func _create_visual(slick: NaftSlick) -> Node2D:
	var root := Node2D.new()
	root.name = "NaftSlickVisual"
	root.z_index = 3
	var line := Line2D.new()
	line.points = NaftSlick.build_segment_points(slick.path, slick.center_path_dist, slick.half_length)
	line.width = 22.0 if slick.state == NaftSlick.State.OIL else 30.0
	line.default_color = Color(0.35, 0.22, 0.08, 0.65) if slick.state == NaftSlick.State.OIL else Color(1.0, 0.45, 0.1, 0.85)
	line.joint_mode = Line2D.LINE_JOINT_ROUND
	line.begin_cap_mode = Line2D.LINE_CAP_ROUND
	line.end_cap_mode = Line2D.LINE_CAP_ROUND
	root.add_child(line)
	return root


func _update_visual(slick: NaftSlick) -> void:
	if slick.visual == null or not is_instance_valid(slick.visual):
		return
	for child in slick.visual.get_children():
		if child is Line2D:
			var line := child as Line2D
			line.width = 30.0
			line.default_color = Color(1.0, 0.45, 0.1, 0.85)


func _can_use() -> bool:
	if context == null or context.hero_manager == null:
		return false
	var hero := context.hero_manager.hero
	if hero == null or hero.is_dead():
		return false
	if context.tutorial_active and not context.tutorial_allows("skill"):
		return false
	return true


func _refresh_hero_data() -> void:
	_hero_data = null
	if context == null or context.hero_manager == null:
		return
	var hero := context.hero_manager.hero
	if hero and hero.data:
		_hero_data = hero.data


func clear_all() -> void:
	while not _slicks.is_empty():
		_remove_slick_at(0)
	_armed = false
