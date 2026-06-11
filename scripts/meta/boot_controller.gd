extends Control

const PRIVACY_PANEL_SCENE := preload("res://scenes/ui/privacy_panel.tscn")

@onready var _title: Label = $TitleLabel
@onready var _status: Label = $StatusLabel


func _ready() -> void:
	if DisplayServer.has_feature(DisplayServer.FEATURE_ORIENTATION):
		DisplayServer.screen_set_orientation(DisplayServer.SCREEN_LANDSCAPE)
	if _status:
		_status.text = "Loading Rostam 7 Labours..."
	await get_tree().create_timer(0.6).timeout
	SaveSystem.load_save()
	SettingsService.load_from_save()
	if SaveSystem and not SaveSystem.has_privacy_accepted():
		await _show_privacy_gate()
	AnalyticsService.session_start()
	SceneFlowController.go_to_main_menu()


func _show_privacy_gate() -> void:
	if _title:
		_title.visible = false
	if _status:
		_status.visible = false
	var panel := PRIVACY_PANEL_SCENE.instantiate() as Control
	if panel == null:
		return
	panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	panel.offset_left = 0.0
	panel.offset_top = 0.0
	panel.offset_right = 0.0
	panel.offset_bottom = 0.0
	add_child(panel)
	if panel.has_signal("privacy_accepted"):
		await panel.privacy_accepted
	else:
		await get_tree().create_timer(0.1).timeout
