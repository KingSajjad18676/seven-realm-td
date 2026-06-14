class_name SubtitleOverlay
extends Label

const DISPLAY_SEC := 2.8

var _timer: float = 0.0


func _ready() -> void:
	name = "SubtitleOverlay"
	set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	offset_top = -88.0
	offset_bottom = -56.0
	offset_left = 80.0
	offset_right = -300.0
	horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	add_theme_font_size_override("font_size", 13)
	add_theme_color_override("font_color", Color(1.0, 0.98, 0.9))
	add_theme_color_override("font_outline_color", Color(0.05, 0.05, 0.08))
	add_theme_constant_override("outline_size", 3)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false
	text = ""


func show_subtitle(msg: String) -> void:
	if not AccessibilityHelper.subtitles_enabled() or msg.is_empty():
		return
	text = msg
	visible = true
	_timer = DISPLAY_SEC


func _process(delta: float) -> void:
	if _timer <= 0.0:
		return
	_timer -= delta
	if _timer <= 0.0:
		visible = false
		text = ""
