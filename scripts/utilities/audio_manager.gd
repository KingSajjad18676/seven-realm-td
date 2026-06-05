extends Node

var _warning_cooldown: float = 0.0


func play_sfx(_sfx_id: String) -> void:
	# Placeholder until art lands.
	pass


func play_warning() -> void:
	if _warning_cooldown > 0.0:
		return
	_warning_cooldown = 1.5
	play_sfx("warning")


func _process(delta: float) -> void:
	if _warning_cooldown > 0.0:
		_warning_cooldown = maxf(0.0, _warning_cooldown - delta)
