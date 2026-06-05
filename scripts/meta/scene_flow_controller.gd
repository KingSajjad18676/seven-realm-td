extends Node

const BOOT := "res://scenes/boot/boot.tscn"
const MAIN_MENU := "res://scenes/main_menu/main_menu.tscn"
const FORGE := "res://scenes/main_menu/kaveh_forge.tscn"
const WORLD_MAP := "res://scenes/world_map/world_map.tscn"
const BATTLE := "res://scenes/battle/battle.tscn"
const ROGUELITE_MAP := "res://scenes/roguelite_map/roguelite_map.tscn"

var pending_launch: BattleLaunchData = null
var pending_roguelite_run: RogueliteRunState = null
var pending_alert: String = ""
var _fade_layer: CanvasLayer = null
var _fade_rect: ColorRect = null
var _is_transitioning: bool = false


func _ready() -> void:
	_ensure_fade_overlay()


func _ensure_fade_overlay() -> void:
	if _fade_layer != null:
		if _fade_rect:
			_fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		return
	_fade_layer = CanvasLayer.new()
	_fade_layer.layer = 100
	_fade_layer.name = "SceneFadeLayer"
	add_child(_fade_layer)
	_fade_rect = ColorRect.new()
	_fade_rect.color = Color(0, 0, 0, 0)
	_fade_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	_fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fade_layer.add_child(_fade_rect)


func go_to_boot() -> void:
	_change_scene(BOOT)


func go_to_main_menu() -> void:
	_change_scene(MAIN_MENU)


func go_to_world_map() -> void:
	_change_scene(WORLD_MAP)


func go_to_forge() -> void:
	_change_scene(FORGE)


func go_to_roguelite_map(start_new_run: bool = false) -> void:
	if start_new_run:
		pending_roguelite_run = RogueliteRunState.new()
		pending_roguelite_run.generate_run()
	_change_scene(ROGUELITE_MAP)


func clear_roguelite_run() -> void:
	pending_roguelite_run = null


func consume_pending_alert() -> String:
	var msg := pending_alert
	pending_alert = ""
	return msg


func go_to_battle(launch: BattleLaunchData) -> void:
	if launch and launch.is_hunt_mode and ForgeService and ForgeService.is_damavand_level(launch.level_id):
		if not ForgeService.can_enter_damavand():
			pending_alert = "Forge an Elite tower at Kaveh's Forge before Hunt for Zahhak."
			go_to_world_map()
			return
	pending_launch = launch
	_change_scene(BATTLE)


func _change_scene(path: String) -> void:
	if _is_transitioning:
		return
	_is_transitioning = true
	_ensure_fade_overlay()
	_fade_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	var tween := create_tween()
	tween.tween_property(_fade_rect, "color:a", 1.0, 0.25)
	tween.tween_callback(func() -> void:
		get_tree().change_scene_to_file(path)
	)
	tween.tween_property(_fade_rect, "color:a", 0.0, 0.35)
	tween.tween_callback(func() -> void:
		_is_transitioning = false
		_fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	)
