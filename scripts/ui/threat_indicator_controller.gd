class_name ThreatIndicatorController
extends Control

const NUDGE_COOLDOWN := 2.5
const NUDGE_STRENGTH := 0.18
const CHECK_INTERVAL := 0.2

var context: BattleContext = null
var camera: TouchCamera = null

var _check_timer: float = 0.0
var _nudge_cooldown: float = 0.0
var _edge_panels: Dictionary = {}
var _pulse: float = 0.0


func initialize(ctx: BattleContext, cam: TouchCamera) -> void:
	context = ctx
	camera = cam
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build_edge_indicators()


func _build_edge_indicators() -> void:
	for edge in ["top", "bottom", "left", "right"]:
		var panel := ColorRect.new()
		panel.name = edge.capitalize()
		panel.visible = false
		panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
		panel.color = Color(0.95, 0.35, 0.25, 0.75)
		match edge:
			"top":
				panel.set_anchors_preset(Control.PRESET_TOP_WIDE)
				panel.offset_bottom = 10.0
			"bottom":
				panel.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
				panel.offset_top = -10.0
			"left":
				panel.set_anchors_preset(Control.PRESET_LEFT_WIDE)
				panel.offset_right = 10.0
			"right":
				panel.set_anchors_preset(Control.PRESET_RIGHT_WIDE)
				panel.offset_left = -10.0
		add_child(panel)
		_edge_panels[edge] = panel


func _process(delta: float) -> void:
	if context == null or camera == null:
		return
	_pulse += delta * 4.0
	_nudge_cooldown = maxf(0.0, _nudge_cooldown - delta)
	_check_timer += delta
	if _check_timer < CHECK_INTERVAL:
		return
	_check_timer = 0.0
	_update_threats()


func _update_threats() -> void:
	var threat := _find_top_threat()
	for edge in _edge_panels:
		(_edge_panels[edge] as ColorRect).visible = false
	if threat == null:
		return
	var world_pos: Vector2 = threat.global_position
	if camera.is_world_visible(world_pos):
		return
	var edge_name := _edge_for_world(world_pos)
	if _edge_panels.has(edge_name):
		var panel := _edge_panels[edge_name] as ColorRect
		panel.visible = true
		var alpha := 0.45 + 0.35 * (0.5 + 0.5 * sin(_pulse))
		panel.color = Color(0.95, 0.35, 0.25, alpha)
	_maybe_nudge_camera(world_pos)


func _find_top_threat() -> Node2D:
	var best: Node2D = null
	var best_score := -1
	for node in context.active_enemies:
		if not (node is EnemyController):
			continue
		var enemy := node as EnemyController
		var score := _threat_score(enemy)
		if score > best_score:
			best_score = score
			best = enemy
	return best


func _threat_score(enemy: EnemyController) -> int:
	if enemy.is_near_gate(0.7):
		return 100
	if enemy.data and enemy.data.is_boss:
		return 80
	if enemy.data and enemy.data.tags.has("elite"):
		return 60
	return 0


func _edge_for_world(world_pos: Vector2) -> String:
	var rect := camera.get_visible_world_rect()
	var best_edge := "top"
	var best_dist := INF
	var candidates := {
		"left": world_pos.x - rect.position.x,
		"right": rect.end.x - world_pos.x,
		"top": world_pos.y - rect.position.y,
		"bottom": rect.end.y - world_pos.y,
	}
	for edge in candidates:
		if candidates[edge] < best_dist:
			best_dist = candidates[edge]
			best_edge = edge
	return best_edge


func _maybe_nudge_camera(world_pos: Vector2) -> void:
	if _nudge_cooldown > 0.0:
		return
	_nudge_cooldown = NUDGE_COOLDOWN
	var target := camera.global_position.lerp(world_pos, NUDGE_STRENGTH)
	camera.focus_on(target, true)
