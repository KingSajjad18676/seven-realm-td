extends Control

@onready var _play_btn: Button = %PlayButton
@onready var _forge_btn: Button = %ForgeButton
@onready var _settings_btn: Button = %SettingsButton
@onready var _daily_btn: Button = %DailyButton
@onready var _alert_label: Label = %AlertLabel
@onready var _settings_panel: Panel = %SettingsPanel


func _ready() -> void:
	if _play_btn:
		_play_btn.pressed.connect(_on_play)
	if _forge_btn:
		_forge_btn.pressed.connect(_on_forge)
	if _settings_btn:
		_settings_btn.pressed.connect(_on_settings)
	if _daily_btn:
		_daily_btn.pressed.connect(_on_daily)
	_show_pending_alert()


func _show_pending_alert() -> void:
	if _alert_label == null or SceneFlowController == null:
		return
	var msg := SceneFlowController.consume_pending_alert()
	if msg != "":
		_alert_label.text = msg
		_alert_label.visible = true
	else:
		_alert_label.visible = false


func _on_forge() -> void:
	SceneFlowController.go_to_forge()


func _on_play() -> void:
	if SaveSystem and not SaveSystem.is_tutorial_completed():
		var launch := BattleLaunchData.new()
		launch.level_id = "level_00_tutorial"
		SceneFlowController.go_to_battle(launch)
		return
	SceneFlowController.go_to_world_map()


func _on_settings() -> void:
	if _settings_panel:
		_settings_panel.visible = not _settings_panel.visible


func _on_daily() -> void:
	if DailyTaleService:
		DailyTaleService.launch_daily_battle()
