class_name BattleLoadingOverlay
extends Control

const GENERIC_TIPS := [
	"Sacred Fire purifies hijacked towers.",
	"Bank materials at Pardeh before the next wave.",
	"Range rings show tower reach on build pads.",
	"Regional light affects corruption spread.",
]

const LEVEL_TIPS := {
	"level_00_tutorial": "Learn tower placement and Sacred Fire cleanse.",
	"level_01": "Rakhsh keeps watch — ambushes strike from the flanks.",
	"level_02": "Defend the oasis; cleanse restores your hero.",
	"level_03": "Azhdaha burrows — watch for emerge telegraphs.",
	"level_04": "Illusions mimic real foes until cleansed.",
	"level_05": "A second cave front opens mid-battle.",
	"level_06": "Reach Kay Kavus before the fortress falls.",
	"level_07": "Blindness fades when the White Div falls.",
	"level_08_damavand": "Break binding chains before facing Zahhak.",
}

@onready var _background: ColorRect = %Background
@onready var _splash: TextureRect = %Splash
@onready var _title: Label = %TitleLabel
@onready var _progress: ProgressBar = %ProgressBar
@onready var _percent: Label = %PercentLabel
@onready var _tip: Label = %TipLabel


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	set_anchors_preset(Control.PRESET_FULL_RECT)


func show_loading(level: LevelData) -> void:
	if level == null:
		return
	_background.color = VisualAssetLoader.map_terrain_color(level.level_id)
	_title.text = level.display_name if level.display_name != "" else level.level_id
	_progress.value = 0.0
	_percent.text = "0%"
	_tip.text = _pick_tip(level.level_id)

	var splash_path := VisualAssetLoader.loading_sprite(level.level_id)
	if splash_path != "" and ResourceLoader.exists(splash_path):
		var tex := load(splash_path) as Texture2D
		if tex:
			_splash.texture = tex
			_splash.visible = true
		else:
			_splash.visible = false
	else:
		_splash.visible = false

	visible = true


func hide_loading() -> void:
	visible = false
	_splash.texture = null


func set_progress(ratio: float) -> void:
	var clamped := clampf(ratio, 0.0, 1.0)
	_progress.value = clamped * 100.0
	_percent.text = "%d%%" % int(round(clamped * 100.0))


func _pick_tip(level_id: String) -> String:
	if LEVEL_TIPS.has(level_id):
		return LEVEL_TIPS[level_id]
	if GENERIC_TIPS.is_empty():
		return ""
	return GENERIC_TIPS[randi() % GENERIC_TIPS.size()]
