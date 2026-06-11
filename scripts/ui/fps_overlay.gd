class_name PerformanceOverlay
extends CanvasLayer

var _context: BattleContext = null
var _expanded: bool = true

@onready var _label: Label = $Label


func _ready() -> void:
	layer = 90
	visible = OS.is_debug_build()
	if _label:
		_label.add_theme_font_size_override("font_size", 10)
		_label.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 0.85))
		_label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0))
		_label.add_theme_constant_override("outline_size", 2)
		_label.mouse_filter = Control.MOUSE_FILTER_STOP
		_label.gui_input.connect(_on_label_input)
	_refresh_layout()


func bind_context(ctx: BattleContext) -> void:
	_context = ctx


func set_expanded(expanded: bool) -> void:
	_expanded = expanded
	_refresh_layout()


func _on_label_input(event: InputEvent) -> void:
	if not OS.is_debug_build():
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		set_expanded(not _expanded)
		get_viewport().set_input_as_handled()
	elif event is InputEventScreenTouch and event.pressed:
		set_expanded(not _expanded)
		get_viewport().set_input_as_handled()


func _refresh_layout() -> void:
	if _label == null:
		return
	if _expanded:
		_label.offset_left = 8.0
		_label.offset_top = 668.0
		_label.offset_right = 420.0
		_label.offset_bottom = 712.0
		_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	else:
		_label.offset_left = 8.0
		_label.offset_top = 688.0
		_label.offset_right = 88.0
		_label.offset_bottom = 712.0


func _process(_delta: float) -> void:
	if not visible or _label == null:
		return
	var fps := Engine.get_frames_per_second()
	if not _expanded:
		_label.text = "FPS %d" % fps
		return
	var enemies := _context.active_enemies.size() if _context else 0
	var towers := _context.tower_manager.towers.size() if _context and _context.tower_manager else 0
	var projectiles := _context.tower_manager.get_active_projectile_count() if _context and _context.tower_manager else 0
	var state := "—"
	if _context and _context.state_controller:
		state = GameEnums.BattleState.keys()[_context.state_controller.current_state]
	_label.text = "FPS %d | Enemies %d | Towers %d | Proj %d | %s" % [
		fps, enemies, towers, projectiles, state
	]
