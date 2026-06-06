extends GutTest


func test_pulse_repairs_light() -> void:
	var ctx := BattleContext.new()
	var level := LevelData.new()
	level.region_ids = ["region_a"]
	ctx.level_data = level
	ctx.map_light = MapLightManager.new()
	ctx.map_light.initialize(ctx)
	ctx.map_light.apply_corruption_pressure("region_a", 60.0)
	var hero := HeroController.new()
	hero.global_position = Vector2(50, 50)
	var hm := HeroManager.new()
	hm.hero = hero
	ctx.hero_manager = hm
	var entity := CompanionEntity.new()
	var data := CompanionData.new()
	data.pulse_light_amount = 50
	entity.setup(ctx, data)
	var behavior := SimurghOrbiterBehavior.new()
	behavior.bind(entity, ctx, data)
	behavior._pulse_light()
	assert_eq(ctx.map_light.get_light("region_a"), 90)
