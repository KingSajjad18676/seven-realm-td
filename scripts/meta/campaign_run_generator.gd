class_name CampaignRunGenerator
extends RefCounted

const ACT_LEVELS: Array[String] = [
	"level_01", "level_02", "level_03", "level_04",
	"level_05", "level_06", "level_07",
]

const SKIRMISH_WAVES := 15
const THRONE_SPAWN_CHANCE := 0.2
const MAX_THRONES_PER_RUN := 2


static func generate(run_seed: int) -> Array[Dictionary]:
	var rng := RandomNumberGenerator.new()
	rng.seed = run_seed
	var nodes: Array[Dictionary] = []
	var y_step := 120.0
	var x_spread := 180.0
	var prev_boss_id := ""
	var throne_count := 0

	for act in range(1, 4):
		var level_id := ACT_LEVELS[act - 1]
		var base_x := 120.0
		var base_y := 80.0 + float(act - 1) * y_step * 2.5

		var skirmish_id := "act%d_skirmish" % act
		var skirmish := {
			"id": skirmish_id,
			"type": CampaignRunState.NODE_SKIRMISH,
			"level_id": level_id,
			"act": act,
			"label": "Skirmish %d" % act,
			"position": {"x": base_x, "y": base_y},
			"edges": [],
			"cleared": false,
			"grants_tower_pick": false,
		}
		nodes.append(skirmish)

		var branch_a_id := "act%d_anvil" % act
		var branch_b_id := "act%d_shrine" % act
		var anvil := {
			"id": branch_a_id,
			"type": CampaignRunState.NODE_ANVIL,
			"level_id": level_id,
			"act": act,
			"label": "Anvil %d" % act,
			"position": {"x": base_x + x_spread, "y": base_y + y_step * 0.5},
			"edges": [],
			"cleared": false,
			"grants_tower_pick": act >= 2,
		}
		var shrine := {
			"id": branch_b_id,
			"type": CampaignRunState.NODE_SHRINE,
			"level_id": level_id,
			"act": act,
			"label": "Shrine %d" % act,
			"position": {"x": base_x + x_spread * 2.0, "y": base_y + y_step * 0.5},
			"edges": [],
			"cleared": false,
			"grants_tower_pick": false,
		}
		nodes.append(anvil)
		nodes.append(shrine)

		var skirmish_edges: Array = [branch_a_id, branch_b_id]
		var boss_id := "act%d_boss" % act
		var boss := {
			"id": boss_id,
			"type": CampaignRunState.NODE_LABOUR_BOSS,
			"level_id": level_id,
			"act": act,
			"label": "Labour Boss %d" % act,
			"position": {"x": base_x + x_spread, "y": base_y + y_step * 1.5},
			"edges": [],
			"cleared": false,
			"grants_tower_pick": false,
		}
		nodes.append(boss)

		if act >= 2 and throne_count < MAX_THRONES_PER_RUN and rng.randf() < THRONE_SPAWN_CHANCE:
			var throne_id := "act%d_throne_kavus" % act
			var throne := {
				"id": throne_id,
				"type": CampaignRunState.NODE_THRONE_KAVUS,
				"level_id": level_id,
				"act": act,
				"label": "Throne of Kavus",
				"position": {"x": base_x + x_spread * 1.5, "y": base_y + y_step * 0.25},
				"edges": [boss_id],
				"cleared": false,
				"grants_tower_pick": false,
			}
			nodes.append(throne)
			skirmish_edges.append(throne_id)
			throne_count += 1

		skirmish["edges"] = skirmish_edges

		if rng.randf() > 0.5:
			anvil["edges"] = [boss_id]
			shrine["edges"] = [boss_id]
		else:
			anvil["edges"] = [boss_id]
			shrine["edges"] = [boss_id]

		if prev_boss_id != "":
			var prev_boss := _find_node(nodes, prev_boss_id)
			if not prev_boss.is_empty():
				prev_boss["edges"] = [skirmish_id]
		prev_boss_id = boss_id

	# Acts 4-7 as additional skirmish+boss chains toward finale
	for act in range(4, 8):
		var level_id := ACT_LEVELS[act - 1]
		var base_y := 80.0 + float(act) * y_step * 1.8
		var skirmish_id := "act%d_skirmish" % act
		var boss_id := "act%d_boss" % act
		var skirmish_edges: Array = [boss_id]
		var skirmish := {
			"id": skirmish_id,
			"type": CampaignRunState.NODE_SKIRMISH,
			"level_id": level_id,
			"act": act,
			"label": "Skirmish %d" % act,
			"position": {"x": 120.0, "y": base_y},
			"edges": skirmish_edges,
			"cleared": false,
			"grants_tower_pick": act == 5,
		}
		var boss := {
			"id": boss_id,
			"type": CampaignRunState.NODE_LABOUR_BOSS,
			"level_id": level_id,
			"act": act,
			"label": "Labour %d" % act,
			"position": {"x": 300.0, "y": base_y + y_step * 0.6},
			"edges": [],
			"cleared": false,
			"grants_tower_pick": false,
		}
		if act <= 6 and throne_count < MAX_THRONES_PER_RUN and rng.randf() < THRONE_SPAWN_CHANCE:
			var throne_id := "act%d_throne_kavus" % act
			var throne := {
				"id": throne_id,
				"type": CampaignRunState.NODE_THRONE_KAVUS,
				"level_id": level_id,
				"act": act,
				"label": "Throne of Kavus",
				"position": {"x": 210.0, "y": base_y + y_step * 0.35},
				"edges": [boss_id],
				"cleared": false,
				"grants_tower_pick": false,
			}
			nodes.append(throne)
			skirmish_edges.append(throne_id)
			throne_count += 1
		skirmish["edges"] = skirmish_edges
		nodes.append(skirmish)
		nodes.append(boss)
		if prev_boss_id != "":
			var prev_boss := _find_node(nodes, prev_boss_id)
			if not prev_boss.is_empty():
				var edges: Array = prev_boss.get("edges", [])
				edges.append(skirmish_id)
				prev_boss["edges"] = edges
		prev_boss_id = boss_id

	var finale_y := 80.0 + 8.0 * y_step * 1.8 + y_step * 2.0
	var finale_id := "finale_damavand"
	var finale := {
		"id": finale_id,
		"type": CampaignRunState.NODE_FINALE,
		"level_id": "level_08_damavand",
		"act": 8,
		"label": "Damavand Binding",
		"position": {"x": 480.0, "y": finale_y},
		"edges": [],
		"cleared": false,
		"grants_tower_pick": false,
	}
	nodes.append(finale)
	if prev_boss_id != "":
		var last_boss := _find_node(nodes, prev_boss_id)
		if not last_boss.is_empty():
			last_boss["edges"] = [finale_id]

	return nodes


static func _find_node(nodes: Array[Dictionary], node_id: String) -> Dictionary:
	for n in nodes:
		if str(n.get("id", "")) == node_id:
			return n
	return {}
