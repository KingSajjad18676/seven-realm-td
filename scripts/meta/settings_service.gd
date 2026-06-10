extends Node

var music_volume: float = 0.8
var sfx_volume: float = 0.8
var reduced_particles: bool = false
var ui_scale: float = 1.0
var high_contrast: bool = false
var reduced_shake: bool = false
var reduced_flashes: bool = false
var subtitles_enabled: bool = true
var left_handed: bool = false
var vibration_enabled: bool = true
var game_speed: float = 1.0


func _ready() -> void:
	load_from_save()


func load_from_save() -> void:
	if not SaveSystem:
		return
	music_volume = float(SaveSystem.get_setting("music_volume", 0.8))
	sfx_volume = float(SaveSystem.get_setting("sfx_volume", 0.8))
	reduced_particles = bool(SaveSystem.get_setting("reduced_particles", false))
	ui_scale = float(SaveSystem.get_accessibility("ui_scale", 1.0))
	high_contrast = bool(SaveSystem.get_accessibility("high_contrast", false))
	reduced_shake = bool(SaveSystem.get_accessibility("reduced_shake", false))
	reduced_flashes = bool(SaveSystem.get_accessibility("reduced_flashes", false))
	subtitles_enabled = bool(SaveSystem.get_accessibility("subtitles", true))
	left_handed = bool(SaveSystem.get_accessibility("left_handed", false))
	vibration_enabled = bool(SaveSystem.get_accessibility("vibration", true))


func apply_settings() -> void:
	if SaveSystem:
		SaveSystem.set_setting("music_volume", music_volume)
		SaveSystem.set_setting("sfx_volume", sfx_volume)
		SaveSystem.set_setting("reduced_particles", reduced_particles)
