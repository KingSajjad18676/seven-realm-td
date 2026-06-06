extends GutTest

const TOWER_SCENE := preload("res://scenes/prefabs/tower.tscn")

var _ctx: BattleContext = null
var _tower: TowerController = null
var _recovered: bool = false


func before_each() -> void:
	_recovered = false
	_ctx = BattleTestFixtures.context_with_level(self, 100, 8)
	var level := _ctx.level_data
	level.region_ids = ["region_north", "region_south"]
	BattleTestFixtures.attach_economy(self, _ctx)
	var map_light := MapLightManager.new()
	add_child(map_light)
	map_light.initialize(_ctx)
	_ctx.map_light = map_light
	_tower = TOWER_SCENE.instantiate() as TowerController
	add_child(_tower)
	var tower_data := ContentRegistry.get_tower("tower_archer")
	assert_not_null(tower_data, "Need archer tower data for hijack test")
	_tower.initialize(_ctx, tower_data.duplicate(true) as TowerData, Vector2(400, 300), "region_north", "tower_hijack_test")
	_ctx.bridge.region_light_changed.connect(func(region_id: String, light: int, _state: GameEnums.RegionLightState) -> void:
		if _tower.region_id == region_id:
			_tower.on_region_light_changed(light)
	)
	CombatEvents.tower_hijack_recovered.connect(_on_hijack_recovered)


func after_each() -> void:
	if CombatEvents.tower_hijack_recovered.is_connected(_on_hijack_recovered):
		CombatEvents.tower_hijack_recovered.disconnect(_on_hijack_recovered)
	_tower = null
	_ctx = null


func _on_hijack_recovered(_placement_id: String) -> void:
	_recovered = true


func test_region_cleanse_recovers_hijacked_tower() -> void:
	_tower.force_enter_hijacked()
	assert_eq(_tower.hijack_phase, GameEnums.HijackPhase.HIJACKED)
	var ok := _ctx.map_light.try_cleanse_region("region_north")
	assert_true(ok, "Cleanse should succeed with enough Sacred Fire")
	assert_eq(_tower.hijack_phase, GameEnums.HijackPhase.NONE, "Tower should leave hijack after cleanse")
	assert_true(_recovered, "Should emit tower_hijack_recovered")


func test_region_cleanse_recovers_hijack_warning() -> void:
	_tower.on_region_light_changed(0)
	assert_eq(_tower.hijack_phase, GameEnums.HijackPhase.WARNING)
	var ok := _ctx.map_light.try_cleanse_region("region_north")
	assert_true(ok)
	assert_eq(_tower.hijack_phase, GameEnums.HijackPhase.NONE)
	assert_true(_recovered)
