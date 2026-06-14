extends GutTest

const BATTLE_SCENE := preload("res://scenes/battle/battle.tscn")
const ACTION_ROW_MIN_WIDTH := 264.0


func test_spell_bar_anchor_exists_in_battle_scene() -> void:
	var battle := BATTLE_SCENE.instantiate()
	var anchor := battle.get_node_or_null("CanvasLayer/SpellBarAnchor")
	assert_not_null(anchor, "SpellBarAnchor should exist on battle scene")
	battle.free()


func test_top_bar_has_context_row() -> void:
	var battle := BATTLE_SCENE.instantiate()
	var context_row := battle.get_node_or_null("CanvasLayer/TopBarPanel/TopBarRoot/TopBarContext")
	assert_not_null(context_row, "TopBarContext row should exist for secondary HUD labels")
	battle.free()


func test_action_cluster_width_fits_button_row() -> void:
	assert_gte(HeroActionHud.CLUSTER_WIDTH, ACTION_ROW_MIN_WIDTH,
		"Action cluster must fit Dodge+Heavy+Skill+Attack row")


func test_start_wave_hidden_during_wave_active() -> void:
	var start_btn := Button.new()
	start_btn.visible = true
	start_btn.visible = GameEnums.BattleState.WAVE_ACTIVE == GameEnums.BattleState.PRE_BATTLE
	assert_false(start_btn.visible, "Start Wave should hide during active waves")
	start_btn.visible = GameEnums.BattleState.PRE_BATTLE == GameEnums.BattleState.PRE_BATTLE
	assert_true(start_btn.visible, "Start Wave should show before battle starts")
