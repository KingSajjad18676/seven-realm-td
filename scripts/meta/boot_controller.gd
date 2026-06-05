extends Node

@onready var _status: Label = $StatusLabel


func _ready() -> void:
	AnalyticsService.session_start()
	if _status:
		_status.text = "Loading Rostam 7 Labours..."
	await get_tree().create_timer(0.6).timeout
	SaveSystem.load_save()
	SettingsService.load_from_save()
	SceneFlowController.go_to_main_menu()
