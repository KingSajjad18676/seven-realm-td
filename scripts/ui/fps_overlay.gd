extends CanvasLayer

@onready var _label: Label = $Label


func _ready() -> void:
	layer = 90
	if _label:
		_label.text = "FPS: --"


func _process(_delta: float) -> void:
	if _label:
		_label.text = "FPS: %d" % Engine.get_frames_per_second()
