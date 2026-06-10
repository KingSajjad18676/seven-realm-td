class_name KavusFollyController
extends Node

const STRIKE_INTERVAL := 20.0
const BLAST_RADIUS := 72.0
const TRUE_DAMAGE := 500.0
const TELEGRAPH_SEC := 0.8

var context: BattleContext = null
var _strike_timer := STRIKE_INTERVAL
var _rng := RandomNumberGenerator.new()
var _vfx_root: Node2D = null
var _telegraph_pending := false


func initialize(ctx: BattleContext) -> void:
	context = ctx
	_strike_timer = STRIKE_INTERVAL
	_rng.randomize()
	if context and context.bridge:
		context.bridge.alert_message.emit(
			"Kay Kavus's flying throne — beware friendly fire!",
			95
		)


func set_vfx_root(root: Node2D) -> void:
	_vfx_root = root


func _process(delta: float) -> void:
	if context == null or context.state_controller == null:
		return
	if _telegraph_pending:
		return
	if context.state_controller.current_state != GameEnums.BattleState.WAVE_ACTIVE:
		return
	_strike_timer -= delta
	if _strike_timer <= 0.0:
		_strike_timer = STRIKE_INTERVAL
		_schedule_strike()


func _schedule_strike() -> void:
	if context == null or context.level_data == null:
		return
	var bounds := context.level_data.minimap_bounds
	var strike_pos := Vector2(
		_rng.randf_range(bounds.position.x + BLAST_RADIUS, bounds.position.x + bounds.size.x - BLAST_RADIUS),
		_rng.randf_range(bounds.position.y + BLAST_RADIUS, bounds.position.y + bounds.size.y - BLAST_RADIUS)
	)
	_telegraph_pending = true
	_show_telegraph(strike_pos)
	var tree := get_tree()
	if tree == null:
		_telegraph_pending = false
		_resolve_strike(strike_pos)
		return
	await tree.create_timer(TELEGRAPH_SEC).timeout
	_telegraph_pending = false
	if not is_instance_valid(self) or context == null:
		return
	if context.state_controller and context.state_controller.current_state != GameEnums.BattleState.WAVE_ACTIVE:
		return
	_resolve_strike(strike_pos)


func _show_telegraph(strike_pos: Vector2) -> void:
	if _vfx_root == null:
		return
	var marker := Line2D.new()
	marker.width = 3.0
	marker.default_color = Color(1.0, 0.35, 0.15, 0.85)
	var points := PackedVector2Array()
	for i in range(17):
		var angle := TAU * float(i) / 16.0
		points.append(strike_pos + Vector2(cos(angle), sin(angle)) * BLAST_RADIUS * 0.55)
	marker.points = points
	marker.z_index = 50
	_vfx_root.add_child(marker)
	var tree := get_tree()
	if tree:
		tree.create_timer(TELEGRAPH_SEC).timeout.connect(func() -> void:
			if is_instance_valid(marker):
				marker.queue_free()
		, CONNECT_ONE_SHOT)


func _resolve_strike(strike_pos: Vector2) -> void:
	_apply_blast_damage(strike_pos)
	_show_impact_vfx(strike_pos)
	if context and context.bridge:
		context.bridge.alert_message.emit("Kay Kavus's throne strikes!", 75)


func _apply_blast_damage(strike_pos: Vector2) -> void:
	if context == null:
		return
	for node in context.active_enemies:
		if not is_instance_valid(node):
			continue
		if node is EnemyController:
			var enemy: EnemyController = node
			if enemy.global_position.distance_to(strike_pos) <= BLAST_RADIUS:
				enemy.take_true_damage(TRUE_DAMAGE)
	if context.tower_manager:
		var to_destroy: Array[TowerController] = []
		for tower in context.tower_manager.towers:
			if tower == null or not is_instance_valid(tower):
				continue
			if tower.global_position.distance_to(strike_pos) <= BLAST_RADIUS:
				to_destroy.append(tower)
		for tower in to_destroy:
			context.tower_manager.destroy_tower(tower, false)


func _show_impact_vfx(strike_pos: Vector2) -> void:
	if _vfx_root == null:
		return
	var flash := ColorRect.new()
	flash.size = Vector2(BLAST_RADIUS * 2.0, BLAST_RADIUS * 2.0)
	flash.position = strike_pos - flash.size * 0.5
	flash.color = Color(1.0, 0.45, 0.1, 0.55 * AccessibilityHelper.flash_alpha_multiplier())
	flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	flash.z_index = 49
	_vfx_root.add_child(flash)
	var tree := get_tree()
	var lifetime := 0.35 if not AccessibilityHelper.should_reduce_flashes() else 0.15
	if tree:
		tree.create_timer(lifetime).timeout.connect(func() -> void:
			if is_instance_valid(flash):
				flash.queue_free()
		, CONNECT_ONE_SHOT)
