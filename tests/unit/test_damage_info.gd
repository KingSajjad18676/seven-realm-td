extends GutTest


func test_create_factory_defaults() -> void:
	var info := DamageInfo.create(12.0)
	assert_eq(info.amount, 12.0)
	assert_eq(info.damage_type, GameEnums.DamageType.PHYSICAL)
	assert_true(info.source_tags.is_empty())
	assert_false(info.applies_burn)


func test_create_with_tags_and_type() -> void:
	var tags: Array[String] = ["tower", "fire"]
	var info := DamageInfo.create(5.0, GameEnums.DamageType.FIRE, tags)
	assert_eq(info.damage_type, GameEnums.DamageType.FIRE)
	assert_eq(info.source_tags.size(), 2)
