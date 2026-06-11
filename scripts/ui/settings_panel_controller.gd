extends Panel

signal settings_changed

@onready var _music: HSlider = %MusicSlider
@onready var _sfx: HSlider = %SfxSlider
@onready var _ui_scale: HSlider = %UiScaleSlider
@onready var _particles: CheckBox = %ReducedParticles
@onready var _contrast: CheckBox = %HighContrast
@onready var _shake: CheckBox = %ReducedShake
@onready var _flashes: CheckBox = %ReducedFlashes
@onready var _subtitles: CheckBox = %Subtitles
@onready var _left_hand: CheckBox = %LeftHanded
@onready var _vibration: CheckBox = %Vibration
@onready var _restore: Button = %RestorePurchases
@onready var _privacy: Button = %PrivacyButton
@onready var _close: Button = %CloseButton

const PRIVACY_PANEL_SCENE := preload("res://scenes/ui/privacy_panel.tscn")


func _ready() -> void:
	visible = false
	_load()
	if _close:
		_close.pressed.connect(func() -> void: visible = false)
	if _restore:
		_restore.pressed.connect(_on_restore)
	if _privacy:
		_privacy.pressed.connect(_on_privacy)
	if _music:
		_music.value_changed.connect(_save)
	if _sfx:
		_sfx.value_changed.connect(_save)
	if _ui_scale:
		_ui_scale.value_changed.connect(_save)
	if _particles:
		_particles.toggled.connect(_save)
	if _contrast:
		_contrast.toggled.connect(_save)
	if _shake:
		_shake.toggled.connect(_save)
	if _flashes:
		_flashes.toggled.connect(_save)
	if _subtitles:
		_subtitles.toggled.connect(_save)
	if _left_hand:
		_left_hand.toggled.connect(_save)
	if _vibration:
		_vibration.toggled.connect(_save)


func _load() -> void:
	if not SaveSystem:
		return
	if _music:
		_music.value = float(SaveSystem.get_setting("music_volume", 0.8))
	if _sfx:
		_sfx.value = float(SaveSystem.get_setting("sfx_volume", 0.8))
	if _ui_scale:
		_ui_scale.value = float(SaveSystem.get_accessibility("ui_scale", 1.0))
	if _particles:
		_particles.button_pressed = bool(SaveSystem.get_setting("reduced_particles", false))
	if _contrast:
		_contrast.button_pressed = bool(SaveSystem.get_accessibility("high_contrast", false))
	if _shake:
		_shake.button_pressed = bool(SaveSystem.get_accessibility("reduced_shake", false))
	if _flashes:
		_flashes.button_pressed = bool(SaveSystem.get_accessibility("reduced_flashes", false))
	if _subtitles:
		_subtitles.button_pressed = bool(SaveSystem.get_accessibility("subtitles", true))
	if _left_hand:
		_left_hand.button_pressed = bool(SaveSystem.get_accessibility("left_handed", false))
	if _vibration:
		_vibration.button_pressed = bool(SaveSystem.get_accessibility("vibration", true))


func _save(_v: Variant = null) -> void:
	if not SaveSystem:
		return
	if _music:
		SaveSystem.set_setting("music_volume", _music.value)
		SettingsService.music_volume = _music.value
	if _sfx:
		SaveSystem.set_setting("sfx_volume", _sfx.value)
		SettingsService.sfx_volume = _sfx.value
	if _particles:
		SaveSystem.set_setting("reduced_particles", _particles.button_pressed)
		SettingsService.reduced_particles = _particles.button_pressed
	if _ui_scale:
		SaveSystem.set_accessibility("ui_scale", _ui_scale.value)
	if _contrast:
		SaveSystem.set_accessibility("high_contrast", _contrast.button_pressed)
	if _shake:
		SaveSystem.set_accessibility("reduced_shake", _shake.button_pressed)
	if _flashes:
		SaveSystem.set_accessibility("reduced_flashes", _flashes.button_pressed)
	if _subtitles:
		SaveSystem.set_accessibility("subtitles", _subtitles.button_pressed)
	if _left_hand:
		SaveSystem.set_accessibility("left_handed", _left_hand.button_pressed)
	if _vibration:
		SaveSystem.set_accessibility("vibration", _vibration.button_pressed)
	if SettingsService:
		SettingsService.load_from_save()
	if AudioManager and AudioManager.has_method("apply_settings_volumes"):
		AudioManager.apply_settings_volumes()
	settings_changed.emit()


func _on_restore() -> void:
	if StoreService:
		StoreService.restore_purchases()


func _on_privacy() -> void:
	var panel := PRIVACY_PANEL_SCENE.instantiate() as Control
	if panel == null:
		return
	get_tree().root.add_child(panel)
	panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	panel.offset_left = 0.0
	panel.offset_top = 0.0
	panel.offset_right = 0.0
	panel.offset_bottom = 0.0
