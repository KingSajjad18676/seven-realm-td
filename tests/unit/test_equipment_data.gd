extends GutTest


func test_equipment_piece_slot_key() -> void:
	assert_eq(EquipmentPieceData.slot_key(EquipmentPieceData.SlotType.WEAPON), "weapon")
	assert_eq(EquipmentPieceData.slot_key(EquipmentPieceData.SlotType.TALISMAN), "talisman")


func test_catalog_has_28_pieces_and_7_sets() -> void:
	assert_eq(ContentCatalog.build_equipment_pieces().size(), 28)
	assert_eq(ContentCatalog.build_equipment_sets().size(), 7)
	assert_eq(ContentCatalog.build_daily_mission_definitions().size(), 10)
