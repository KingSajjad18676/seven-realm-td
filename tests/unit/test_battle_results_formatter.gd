extends GutTest


func test_format_reason_known_ids() -> void:
	assert_eq(BattleResultsFormatter.format_reason("waves_cleared"), "All waves cleared")
	assert_eq(BattleResultsFormatter.format_reason("gate_breached"), "The gate fell")
	assert_eq(BattleResultsFormatter.format_reason("debug"), "Debug shortcut")


func test_format_reason_unknown_prettifies() -> void:
	assert_eq(BattleResultsFormatter.format_reason("boss_defeated"), "Boss defeated")


func test_format_fate_card_empty() -> void:
	assert_eq(BattleResultsFormatter.format_fate_card(""), "None")
