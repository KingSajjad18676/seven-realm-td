@tool
extends EditorScript

## Run from editor: Project → Tools → Export Equipment .tres
## Writes catalog-built equipment, sets, and daily missions to resources/data/.


func _run() -> void:
	var dirs := [
		"res://resources/data/equipment/",
		"res://resources/data/equipment_sets/",
		"res://resources/data/daily_missions/",
	]
	for path in dirs:
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(path))
	for piece in ContentCatalog.build_equipment_pieces():
		var file_path := "res://resources/data/equipment/%s.tres" % piece.piece_id
		ResourceSaver.save(piece, file_path)
	for set_data in ContentCatalog.build_equipment_sets():
		var file_path := "res://resources/data/equipment_sets/%s.tres" % set_data.set_id
		ResourceSaver.save(set_data, file_path)
	for mission in ContentCatalog.build_daily_mission_definitions():
		var file_path := "res://resources/data/daily_missions/%s.tres" % mission.mission_id
		ResourceSaver.save(mission, file_path)
	print("Exported equipment content .tres files.")
