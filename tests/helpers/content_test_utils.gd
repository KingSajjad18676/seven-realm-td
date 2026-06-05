class_name ContentTestUtils
extends RefCounted


static func build_catalog() -> BootstrapContent:
	return ContentCatalog.build_bootstrap()


static func collect_ids(items: Array, field: String) -> Array[String]:
	var ids: Array[String] = []
	for item in items:
		if item != null:
			ids.append(str(item.get(field)))
	return ids


static func make_invalid_catalog() -> BootstrapContent:
	var content := BootstrapContent.new()
	var enemy := EnemyData.new()
	enemy.enemy_id = "enemy_test"
	content.enemies = [enemy]
	var level := LevelData.new()
	level.level_id = "bad_level"
	var wave := WaveData.new()
	wave.spawn_groups = [{"enemy_id": "enemy_missing", "count": 1}]
	level.waves = [wave]
	content.levels = [level]
	return content
