extends GutTest


func test_collect_to_cargo_payload() -> void:
	var drop := MaterialDrop.new()
	drop.material_id = "iron_falcon"
	drop.amount = 2
	var entity := CompanionEntity.new()
	var data := CompanionData.new()
	data.behavior = CompanionData.Behavior.CHEETAH_SCAVENGER
	entity.setup(BattleContext.new(), data)
	var payload := drop.collect_to_cargo(entity)
	assert_eq(int(payload.get("iron_falcon", 0)), 2)


func test_cargo_banks_at_hero() -> void:
	var behavior := CheetahScavengerBehavior.new()
	var ctx := BattleContext.new()
	ctx.economy = BattleEconomy.new()
	ctx.economy.initialize(ctx)
	var hero := HeroController.new()
	hero.global_position = Vector2(100, 100)
	var hm := HeroManager.new()
	hm.hero = hero
	ctx.hero_manager = hm
	var entity := CompanionEntity.new()
	var data := CompanionData.new()
	data.bank_radius = 48.0
	entity.global_position = Vector2(102, 100)
	entity.setup(ctx, data)
	behavior.bind(entity, ctx, data)
	behavior._cargo = {"iron_falcon": 3}
	behavior._state = CheetahScavengerBehavior.State.RETURN
	behavior._bank_cargo()
	assert_eq(int(ctx.economy.get_unbanked_materials().get("iron_falcon", 0)), 3)
