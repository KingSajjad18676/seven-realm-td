extends GutTest

var _service: HeroLevelService
var _context: BattleContext


func before_each() -> void:
	_context = BattleContext.new()
	var level := LevelData.new()
	level.level_id = "level_01"
	_context.level_data = level
	_context.runtime_modifiers = {}
	_service = HeroLevelService.new()
	add_child_autofree(_service)
	_service.initialize(_context)


func test_xp_curve_increases_with_level() -> void:
	assert_gt(_service.xp_to_next_level(1), _service.xp_to_next_level(10))


func test_kill_grants_xp_and_levels_up() -> void:
	var needed := _service.xp_to_next_level(1)
	for i in needed:
		_service._grant_xp(1)
	assert_eq(_service.get_level(), 2)
	assert_almost_eq(_context.runtime_modifiers.get("hero_level_damage_mult", 1.0), 1.08, 0.001)


func test_damage_mult_scales_with_level() -> void:
	_service._level = 5
	_service._apply_level_modifiers()
	assert_almost_eq(_service.get_damage_mult(), 1.0 + 4.0 * HeroLevelService.DAMAGE_PER_LEVEL, 0.001)
