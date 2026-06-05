class_name BattleTestFixtures
extends RefCounted


static func minimal_context(test_root: Node) -> BattleContext:
	var ctx := BattleContext.new()
	var bridge := BattleContextBridge.new()
	test_root.add_child(bridge)
	bridge.context = ctx
	ctx.bridge = bridge
	return ctx


static func context_with_level(test_root: Node, starting_gold: int = 100, starting_sf: int = 5) -> BattleContext:
	var ctx := minimal_context(test_root)
	var level := LevelData.new()
	level.level_id = "test_level"
	level.starting_gold = starting_gold
	level.starting_sacred_fire = starting_sf
	ctx.level_data = level
	return ctx


static func attach_economy(test_root: Node, ctx: BattleContext) -> BattleEconomy:
	var economy := BattleEconomy.new()
	test_root.add_child(economy)
	economy.initialize(ctx)
	ctx.economy = economy
	return economy


static func attach_morale(test_root: Node, ctx: BattleContext) -> MoraleController:
	var morale := MoraleController.new()
	test_root.add_child(morale)
	morale.initialize(ctx)
	ctx.morale = morale
	return morale


static func attach_objectives(test_root: Node, ctx: BattleContext) -> ObjectiveController:
	var objectives := ObjectiveController.new()
	test_root.add_child(objectives)
	objectives.initialize(ctx)
	ctx.objectives = objectives
	return objectives


static func attach_hunt(test_root: Node, ctx: BattleContext) -> HuntController:
	var hunt := HuntController.new()
	test_root.add_child(hunt)
	hunt.initialize(ctx)
	ctx.hunt = hunt
	return hunt


static func attach_run_modifiers(test_root: Node, ctx: BattleContext) -> RunModifierService:
	var mods := RunModifierService.new()
	test_root.add_child(mods)
	mods.initialize(ctx)
	ctx.run_modifiers = mods
	return mods


static func make_objective(goal_type: String, goal_count: int = 1) -> ObjectiveData:
	var obj := ObjectiveData.new()
	obj.objective_id = "test_%s" % goal_type
	obj.title = "Test %s" % goal_type
	obj.goal_type = goal_type
	obj.goal_count = goal_count
	obj.gold_reward = 10
	return obj


static func make_vow(goal_type: String, penalty: int = 5) -> ObjectiveData:
	var obj := ObjectiveData.new()
	obj.objective_id = "test_vow_%s" % goal_type
	obj.title = "Test Vow"
	obj.description = "Test vow description"
	obj.goal_type = goal_type
	obj.is_vow = true
	obj.sacred_fire_reward = 2
	obj.morale_reward = 8
	obj.penalty_morale = penalty
	return obj


static func make_enemy(
	enemy_id: String,
	tags: Array[String] = [],
	is_boss: bool = false,
	gold: int = 8,
	sf: int = 0,
	material_id: String = "",
	material_drop: int = 0
) -> EnemyData:
	var data := EnemyData.new()
	data.enemy_id = enemy_id
	data.tags = tags
	data.is_boss = is_boss
	data.gold_reward = gold
	data.sacred_fire_reward = sf
	data.forge_material_id = material_id
	data.forge_material_drop = material_drop
	return data
