extends Panel

@onready var _music: HSlider = %MusicSlider
@onready var _sfx: HSlider = %SfxSlider
@onready var _ui_scale: HSlider = %UiScaleSlider
@onready var _particles: CheckBox = %ReducedParticles
@onready var _contrast: CheckBox = %HighContrast
@onready var _shake: CheckBox = %ReducedShake
@onready var _restore: Button = %RestorePurchases
@onready var _close: Button = %CloseButton


func _ready() -> void:
	visible = false
	_load()
	if _close:
		_close.pressed.connect(func() -> void: visible = false)
	if _restore:
		_restore.pressed.connect(_on_restore)
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


func _on_restore() -> void:
	if StoreService:
		StoreService.restore_purchases()
