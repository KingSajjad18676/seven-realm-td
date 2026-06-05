class_name LabourModeFactory
extends RefCounted

const SCRIPTS := {
	"mode_lion": "res://scripts/battle/labours/mode_lion.gd",
	"mode_thirst": "res://scripts/battle/labours/mode_thirst.gd",
	"mode_dragon": "res://scripts/battle/labours/mode_dragon.gd",
	"mode_temptress": "res://scripts/battle/labours/mode_temptress.gd",
	"mode_demons": "res://scripts/battle/labours/mode_demons.gd",
	"mode_rescue": "res://scripts/battle/labours/mode_rescue.gd",
	"mode_blindness": "res://scripts/battle/labours/mode_blindness.gd",
	"mode_zahhak": "res://scripts/battle/labours/mode_zahhak.gd",
}


static func create(level: LevelData) -> LabourMode:
	if level == null or level.labour_mode_id == "":
		return null
	var path: String = SCRIPTS.get(level.labour_mode_id, "")
	if path == "" or not ResourceLoader.exists(path):
		return null
	var script := load(path) as Script
	if script == null:
		return null
	var mode: LabourMode = script.new() as LabourMode
	if mode:
		mode.mode_id = level.labour_mode_id
	return mode


static func labour_mode_id_for_level(level_id: String) -> String:
	match level_id:
		"level_01":
			return "mode_lion"
		"level_02":
			return "mode_thirst"
		"level_03":
			return "mode_dragon"
		"level_04":
			return "mode_temptress"
		"level_05":
			return "mode_demons"
		"level_06":
			return "mode_rescue"
		"level_07":
			return "mode_blindness"
		"level_08_damavand":
			return "mode_zahhak"
		_:
			return ""
