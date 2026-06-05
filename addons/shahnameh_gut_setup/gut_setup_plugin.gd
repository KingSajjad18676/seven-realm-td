@tool
extends EditorPlugin

const SEED_CONFIG := "res://.gut_editor_config.json"

var _GutEditorGlobals = load("res://addons/gut/gui/editor_globals.gd")
var _GutConfig = load("res://addons/gut/gut_config.gd")


func _enter_tree() -> void:
	if not Engine.is_editor_hint():
		return
	if not FileAccess.file_exists(SEED_CONFIG):
		return
	_GutEditorGlobals.create_temp_directory()
	var dest: String = _GutEditorGlobals.editor_run_gut_config_path
	var cfg = _GutConfig.new()
	cfg.load_options(dest)
	if not cfg.options.dirs.is_empty() or not cfg.options.configured_dirs.is_empty():
		return
	if FileAccess.file_exists(dest):
		DirAccess.remove_absolute(dest)
	var copy_result := DirAccess.copy_absolute(SEED_CONFIG, dest)
	if copy_result != OK:
		push_warning("ShahnamehGutSetup: could not copy GUT config to %s (err %s)" % [dest, copy_result])
