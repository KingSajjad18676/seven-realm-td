extends GutTest


func before_each() -> void:
	if SaveSystem:
		SaveSystem.test_reset_to_defaults()


func test_grant_and_equip_piece() -> void:
	assert_not_null(EquipmentService)
	EquipmentService.grant_piece("equip_rakhsh_lion_bone_club")
	assert_true(EquipmentService.is_owned("equip_rakhsh_lion_bone_club"))
	assert_true(EquipmentService.equip_piece("equip_rakhsh_lion_bone_club"))
	var equipped := EquipmentService.get_equipped_map()
	assert_eq(str(equipped.get("weapon", "")), "equip_rakhsh_lion_bone_club")


func test_set_count() -> void:
	EquipmentService.grant_piece("equip_rakhsh_lion_bone_club")
	EquipmentService.grant_piece("equip_rakhsh_mantle_steed")
	EquipmentService.equip_piece("equip_rakhsh_lion_bone_club")
	EquipmentService.equip_piece("equip_rakhsh_mantle_steed")
	assert_eq(EquipmentService.count_equipped_for_set("set_rakhsh_vigor"), 2)


func test_boss_drop_duplicate_tokens() -> void:
	var tokens_before := SaveSystem.get_forge_tokens()
	EquipmentService.grant_piece("equip_rakhsh_lion_bone_club")
	EquipmentService.grant_boss_drops("level_01")
	assert_gt(SaveSystem.get_forge_tokens(), tokens_before)
