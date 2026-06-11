extends GutTest

const BATTLE_SCENE := preload("res://scenes/battle/battle.tscn")


func test_spell_bar_parents_to_center_anchor_not_action_cluster() -> void:
	var launch := BattleLaunchData.new()
	launch.level_id = "level_01"
	launch.auto_start = false
	SceneFlowController.pending_launch = launch
	var battle := BATTLE_SCENE.instantiate()
	add_child(battle)
	await get_tree().process_frame
	await get_tree().process_frame
	var hud := battle.get_node_or_null("CanvasLayer") as BattleHudController
	assert_not_null(hud)
	var spell_bar := hud.get_node_or_null("SpellBarAnchor/SpellBar") as Control
	assert_not_null(spell_bar, "SpellBar should live under SpellBarAnchor")
	var action_cluster := hud.get_node_or_null("HeroActionHud/ActionCluster") as Control
	if action_cluster:
		assert_false(spell_bar.is_inside_tree() and spell_bar.get_parent() == action_cluster,
			"SpellBar must not be reparented into ActionCluster")
