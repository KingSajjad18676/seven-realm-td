extends CanvasLayer

@onready var _label: Label = $Label


func _ready() -> void:
	layer = 90
	visible = OS.is_debug_build()
	if _label:
		_label.text = "FPS: --"
		_label.offset_left = 8.0
		_label.offset_top = 688.0
		_label.offset_right = 88.0
		_label.offset_bottom = 712.0
		_label.add_theme_font_size_override("font_size", 10)


func _process(_delta: float) -> void:
	if not visible or _label == null:
		return
	_label.text = "FPS: %d" % Engine.get_frames_per_second()
