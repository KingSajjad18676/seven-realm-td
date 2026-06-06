class_name GauntletHudWidget
extends Panel

var _timer_label: Label = null
var _delta_label: Label = null
var _labour_label: Label = null
var _split_bar: HBoxContainer = null
var _ghost_marker: ColorRect = null
var _segment_count := 7


func _ready() -> void:
	visible = false
	set_anchors_preset(Control.PRESET_TOP_WIDE)
	offset_left = 280.0
	offset_top = 4.0
	offset_right = -280.0
	offset_bottom = 52.0
	var root := VBoxContainer.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_theme_constant_override("separation", 2)
	add_child(root)
	_timer_label = Label.new()
	_timer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_timer_label.add_theme_font_size_override("font_size", 22)
	root.add_child(_timer_label)
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 12)
	root.add_child(row)
	_labour_label = Label.new()
	_labour_label.add_theme_font_size_override("font_size", 14)
	row.add_child(_labour_label)
	_delta_label = Label.new()
	_delta_label.add_theme_font_size_override("font_size", 14)
	row.add_child(_delta_label)
	_split_bar = HBoxContainer.new()
	_split_bar.custom_minimum_size = Vector2(420, 8)
	_split_bar.add_theme_constant_override("separation", 2)
	root.add_child(_split_bar)
	for i in _segment_count:
		var seg := ColorRect.new()
		seg.custom_minimum_size = Vector2(56, 6)
		seg.color = Color(0.25, 0.28, 0.32, 0.9)
		seg.name = "Seg%d" % i
		_split_bar.add_child(seg)
	_ghost_marker = ColorRect.new()
	_ghost_marker.custom_minimum_size = Vector2(4, 10)
	_ghost_marker.color = Color(0.7, 0.85, 1.0, 0.55)
	_ghost_marker.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_split_bar.add_child(_ghost_marker)


func setup(_run: GauntletRunState, _pb: Dictionary) -> void:
	visible = true


func refresh(elapsed_ms: int, labour_index: int, pb: Dictionary) -> void:
	if _timer_label:
		_timer_label.text = GauntletGhostController.format_time_ms(elapsed_ms)
	if _labour_label:
		_labour_label.text = "L%d/7" % (labour_index + 1)
	if _delta_label:
		var delta := GauntletGhostController.delta_vs_pb(elapsed_ms, pb)
		if int(pb.get("total_ms", 0)) <= 0:
			_delta_label.text = "No PB"
			_delta_label.modulate = Color(0.75, 0.75, 0.75)
		else:
			_delta_label.text = GauntletGhostController.format_delta_sec(delta)
			_delta_label.modulate = (
				GauntletGhostController.AHEAD_COLOR if delta < 0
				else GauntletGhostController.BEHIND_COLOR
			)
	_update_split_bar(elapsed_ms, labour_index, pb)


func _update_split_bar(elapsed_ms: int, labour_index: int, pb: Dictionary) -> void:
	if _split_bar == null:
		return
	for i in _segment_count:
		var seg := _split_bar.get_node_or_null("Seg%d" % i) as ColorRect
		if seg == null:
			continue
		if i < labour_index:
			seg.color = Color(0.35, 0.75, 0.45, 0.95)
		elif i == labour_index:
			seg.color = Color(0.85, 0.7, 0.25, 0.95)
		else:
			seg.color = Color(0.25, 0.28, 0.32, 0.9)
	if _ghost_marker and _split_bar:
		var progress := GauntletGhostController.ghost_labour_progress(elapsed_ms, pb)
		var bar_w := _split_bar.size.x
		if bar_w <= 0.0:
			bar_w = 420.0
		var x := clampf(progress / float(_segment_count), 0.0, 1.0) * bar_w - 2.0
		_ghost_marker.position = Vector2(x, -2.0)
