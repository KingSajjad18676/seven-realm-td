class_name TowerController
extends Node2D

var context: BattleContext = null
var data: TowerData = null
var build_spot: BuildSpot = null
var level: int = 1
var gold_invested: int = 0
var hijack_phase: GameEnums.HijackPhase = GameEnums.HijackPhase.NONE
const LEVEL_DAMAGE_BONUS := 0.25
const LEVEL_RANGE_BONUS := 0.10
var _cooldown: float = 0.0
var _hijack_timer: float = 0.0
var _efficiency: float = 1.0
var _forge_damage_mult: float = 1.0
var _forge_range_mult: float = 1.0
var _tether_mult: float = 1.0
var _hunger_stacks: int = 0
var _hunger_decay_timer: float = 0.0
var _allies: Array[AllyUnitController] = []
var _ally_respawn_timers: Array[float] = []
const HUNGER_MAX_STACKS := 10
const HUNGER_DECAY_SEC := 4.0

@onready var _sprite: ColorRect = $Sprite
@onready var _range_area: Area2D = $RangeArea


func initialize(ctx: BattleContext, tower_data: TowerData, spot: BuildSpot) -> void:
	context = ctx
	data = tower_data
	build_spot = spot
	level = 1
	gold_invested = tower_data.build_cost
	hijack_phase = GameEnums.HijackPhase.NONE
	_cooldown = 0.0
	_apply_forge_visuals()
	_update_efficiency()
	if data and data.attack_behavior == GameEnums.AttackBehavior.BARRACKS:
		_spawn_barracks_units()
	CombatEvents.tower_built.emit(tower_data.tower_id)


func _process(delta: float) -> void:
	if context == null or data == null:
		return
	if context.state_controller.current_state != GameEnums.BattleState.WAVE_ACTIVE:
		return
	if hijack_phase == GameEnums.HijackPhase.HIJACKED:
		_process_hijack_attack(delta)
		return
	if hijack_phase == GameEnums.HijackPhase.WARNING:
		_hijack_timer -= delta
		if _hijack_timer <= 0.0:
			_enter_hijacked()
		return
	if data and data.attack_behavior == GameEnums.AttackBehavior.BARRACKS:
		_process_barracks(delta)
		_tick_hunger_decay(delta)
		return
	_tick_hunger_decay(delta)
	_cooldown -= delta
	if _cooldown > 0.0:
		return
	var target := _pick_target()
	if target == null:
		return
	if data.attack_behavior == GameEnums.AttackBehavior.TWIN:
		_fire_twin_at(target)
	else:
		_fire_at(target)
	var rate := data.attack_rate * _efficiency
	if context.runtime_modifiers.has("attack_mult"):
		rate *= float(context.runtime_modifiers["attack_mult"])
	if context.runtime_modifiers.has("tower_attack_rate_mult"):
		rate *= float(context.runtime_modifiers["tower_attack_rate_mult"])
	rate *= MoraleController.get_rate_mult(context)
	rate *= _hunger_rate_mult()
	_cooldown = 1.0 / maxf(0.1, rate)


func on_region_light_changed(light: int) -> void:
	if light <= 0:
		_start_hijack_warning()
	else:
		if hijack_phase != GameEnums.HijackPhase.NONE:
			_recover_from_hijack()
		_efficiency = 1.0 if light >= 30 else float(light) / 30.0


func set_tether_bonus(mult: float) -> void:
	_tether_mult = mult


func can_upgrade() -> bool:
	if data == null or context == null or context.state_controller == null:
		return false
	if hijack_phase != GameEnums.HijackPhase.NONE:
		return false
	if level >= data.max_level:
		return false
	var state := context.state_controller.current_state
	return state == GameEnums.BattleState.PRE_BATTLE or state == GameEnums.BattleState.WAVE_ACTIVE


func get_upgrade_cost() -> int:
	if data == null:
		return 0
	return data.upgrade_cost * level


func get_sell_refund() -> int:
	if data == null:
		return 0
	return int(floor(float(gold_invested) * data.sell_refund_ratio))


func try_upgrade() -> bool:
	if not can_upgrade() or context == null or context.economy == null:
		return false
	var cost := get_upgrade_cost()
	if not context.economy.spend_gold(cost):
		if context.bridge:
			context.bridge.alert_message.emit("Not enough gold", 40)
		return false
	gold_invested += cost
	level += 1
	_apply_forge_visuals()
	if data and data.attack_behavior == GameEnums.AttackBehavior.BARRACKS:
		_spawn_barracks_units()
	CombatEvents.tower_upgraded.emit(data.tower_id, level)
	AnalyticsService.tower_upgraded(data.tower_id, level)
	return true


func try_recover_hijack() -> bool:
	if hijack_phase == GameEnums.HijackPhase.NONE:
		return false
	if context and context.map_light and build_spot:
		if context.map_light.try_cleanse_region(build_spot.region_id):
			_recover_from_hijack()
			return true
	return false


func _update_efficiency() -> void:
	if context and context.map_light and build_spot:
		var light := context.map_light.get_light(build_spot.region_id)
		on_region_light_changed(light)


func _pick_target() -> EnemyController:
	var enemies: Array = context.active_enemies if context else []
	var in_range: Array[EnemyController] = []
	for e in enemies:
		if e is EnemyController and global_position.distance_to(e.global_position) <= _effective_range():
			var enemy: EnemyController = e
			if enemy.is_targetable_by_tower():
				in_range.append(enemy)
	if in_range.is_empty():
		return null
	match data.target_mode:
		GameEnums.TargetMode.LAST:
			return in_range[in_range.size() - 1]
		GameEnums.TargetMode.STRONGEST:
			var best: EnemyController = in_range[0]
			for e in in_range:
				if e.current_hp > best.current_hp:
					best = e
			return best
		_:
			return in_range[0]


func _fire_at(target: EnemyController) -> void:
	if context and context.tower_manager:
		context.tower_manager.spawn_projectile(self, target)
	var dmg := data.damage * _efficiency * _forge_damage_mult * _level_damage_mult() * _tether_mult
	dmg *= MoraleController.get_damage_mult(context)
	if context.runtime_modifiers.has("tower_damage_mult"):
		dmg *= float(context.runtime_modifiers["tower_damage_mult"])
	if context.runtime_modifiers.has("attack_mult"):
		dmg *= float(context.runtime_modifiers["attack_mult"])
	target.take_damage(dmg)
	if data.attack_behavior == GameEnums.AttackBehavior.TWIN:
		target.apply_venom(1, 5.0, 3.0, self)
	elif data.applies_burn:
		target.apply_burn(2.5)
	if data.applies_slow:
		var slow_mult := 0.55
		if context.runtime_modifiers.has("control_slow_mult"):
			slow_mult = float(context.runtime_modifiers["control_slow_mult"])
		target.apply_slow(slow_mult, 1.5)
	if data.armor_break:
		target.apply_armor_break()


func _fire_twin_at(primary: EnemyController) -> void:
	_fire_at(primary)
	var secondary := _pick_second_target(primary)
	if secondary:
		if context and context.tower_manager:
			context.tower_manager.spawn_projectile(self, secondary)
		var dmg := data.damage * _efficiency * _forge_damage_mult * _level_damage_mult() * _tether_mult
		dmg *= MoraleController.get_damage_mult(context)
		if context.runtime_modifiers.has("tower_damage_mult"):
			dmg *= float(context.runtime_modifiers["tower_damage_mult"])
		secondary.take_damage(dmg)
		secondary.apply_venom(1, 5.0, 3.0, self)


func _pick_second_target(exclude: EnemyController) -> EnemyController:
	var enemies: Array = context.active_enemies if context else []
	var in_range: Array[EnemyController] = []
	for e in enemies:
		if e is EnemyController and e != exclude and global_position.distance_to(e.global_position) <= _effective_range():
			var enemy: EnemyController = e
			if enemy.is_targetable_by_tower():
				in_range.append(enemy)
	if in_range.is_empty():
		return null
	return in_range[0]


func on_venom_kill() -> void:
	_hunger_stacks = mini(_hunger_stacks + 1, HUNGER_MAX_STACKS)
	_hunger_decay_timer = HUNGER_DECAY_SEC


func _hunger_rate_mult() -> float:
	return 1.0 + float(_hunger_stacks) * 0.08


func _tick_hunger_decay(delta: float) -> void:
	if _hunger_stacks <= 0:
		return
	_hunger_decay_timer -= delta
	if _hunger_decay_timer <= 0.0:
		_hunger_stacks = maxi(0, _hunger_stacks - 1)
		_hunger_decay_timer = HUNGER_DECAY_SEC


func _spawn_barracks_units() -> void:
	_clear_allies()
	var count := data.max_units if data else 2
	for i in count:
		_spawn_single_ally(i)
		_ally_respawn_timers.append(0.0)


func _spawn_single_ally(index: int) -> void:
	if context == null or context.tower_manager == null or data == null:
		return
	var unit_id := data.upgraded_unit_id if level >= data.max_level else data.spawn_unit_id
	var unit_data := ContentCatalog.get_ally_unit(unit_id)
	if unit_data == null:
		return
	var ally := AllyUnitController.new()
	context.tower_manager.units_root.add_child(ally)
	var offset := data.rally_offset + Vector2(index * 24 - 12, 0)
	ally.initialize(context, unit_data, global_position + offset, self)
	ally.rally_position = global_position + offset
	while _allies.size() <= index:
		_allies.append(null)
	if _allies[index] and is_instance_valid(_allies[index]):
		context.active_allies.erase(_allies[index])
		_allies[index].queue_free()
	_allies[index] = ally
	if context:
		context.active_allies.append(ally)


func _process_barracks(delta: float) -> void:
	for i in _ally_respawn_timers.size():
		if i >= _allies.size():
			continue
		var ally: AllyUnitController = _allies[i]
		if ally and ally.is_alive():
			ally.rally_position = global_position + data.rally_offset + Vector2(i * 24 - 12, 0)
			continue
		_ally_respawn_timers[i] -= delta
		if _ally_respawn_timers[i] <= 0.0:
			_spawn_single_ally(i)
			_ally_respawn_timers[i] = data.unit_respawn_cooldown


func notify_ally_died(ally: AllyUnitController) -> void:
	var idx := _allies.find(ally)
	if idx >= 0:
		_allies[idx] = null
		if idx < _ally_respawn_timers.size():
			_ally_respawn_timers[idx] = data.unit_respawn_cooldown


func _clear_allies() -> void:
	for ally in _allies:
		if ally and is_instance_valid(ally):
			if context:
				context.active_allies.erase(ally)
			ally.queue_free()
	_allies.clear()
	_ally_respawn_timers.clear()


func _level_damage_mult() -> float:
	return 1.0 + float(level - 1) * LEVEL_DAMAGE_BONUS


func _level_range_mult() -> float:
	return 1.0 + float(level - 1) * LEVEL_RANGE_BONUS


func get_effective_range() -> float:
	if data == null:
		return 0.0
	return _effective_range()


static func compute_preview_range(
	ctx: BattleContext,
	tower_data: TowerData,
	region_id: String,
	preview_level: int = 1
) -> float:
	if tower_data == null:
		return 0.0
	var efficiency := 1.0
	if ctx and ctx.map_light:
		var light := ctx.map_light.get_light(region_id)
		efficiency = 1.0 if light >= 30 else float(light) / 30.0
	var forge_mult := 1.0
	if ForgeService:
		forge_mult = ForgeService.get_range_mult(tower_data.tower_id)
	var level_mult := 1.0 + float(preview_level - 1) * LEVEL_RANGE_BONUS
	var debuff_mult := 1.0
	if ctx and ctx.runtime_modifiers.has("vision_radius_mult"):
		debuff_mult = float(ctx.runtime_modifiers["vision_radius_mult"])
	return tower_data.range * efficiency * forge_mult * level_mult * debuff_mult


func set_selected_visual(selected: bool) -> void:
	if _sprite == null:
		return
	_sprite.modulate = Color(1.25, 1.2, 1.05, 1.0) if selected else Color(1, 1, 1, 1)


func _effective_range() -> float:
	var mult := 1.0
	if context and context.runtime_modifiers.has("vision_radius_mult"):
		mult = float(context.runtime_modifiers["vision_radius_mult"])
	return data.range * _efficiency * _forge_range_mult * _level_range_mult() * mult


func _apply_forge_visuals() -> void:
	if data == null or _sprite == null:
		return
	_forge_damage_mult = 1.0
	_forge_range_mult = 1.0
	var tier := 1
	var elite := false
	if ForgeService:
		_forge_damage_mult = ForgeService.get_damage_mult(data.tower_id)
		_forge_range_mult = ForgeService.get_range_mult(data.tower_id)
		tier = ForgeService.get_visual_tier(data.tower_id)
		elite = ForgeService.is_elite(data.tower_id)
	if context:
		var run_bonus := int(context.runtime_modifiers.get("run_upgrade_%s" % data.tower_id, 0))
		if run_bonus > 0:
			_forge_damage_mult += float(run_bonus) * 0.08
	var size := 36.0
	if ForgeService:
		size = ForgeService.get_forge_size(tier, elite)
	size += float(level - 1) * 4.0
	var color := data.color
	if ForgeService:
		color = ForgeService.get_forge_color(data.color, tier, elite)
	var sp := data.sprite_path
	if sp == "":
		sp = VisualAssetLoader.khan1_sprite(data.tower_id)
	VisualAssetLoader.apply_sprite(self, sp, color, Vector2(size, size))


func trigger_hijack_warning() -> void:
	_start_hijack_warning()


func _start_hijack_warning() -> void:
	if hijack_phase != GameEnums.HijackPhase.NONE:
		return
	hijack_phase = GameEnums.HijackPhase.WARNING
	_hijack_timer = 3.5
	if _sprite:
		_sprite.color = Color(0.35, 0.15, 0.45)
	if context and context.map_light and build_spot:
		context.map_light.register_hijack_warning(build_spot.spot_id)
	var spot_id := build_spot.spot_id if build_spot else ""
	CombatEvents.tower_hijack_started.emit(spot_id)
	AnalyticsService.tower_hijack_started(spot_id)
	if context and context.objectives:
		context.objectives.on_hijack()


func force_enter_hijacked() -> void:
	if hijack_phase == GameEnums.HijackPhase.WARNING:
		_enter_hijacked()


func _enter_hijacked() -> void:
	hijack_phase = GameEnums.HijackPhase.HIJACKED
	if _sprite:
		_sprite.color = Color(0.2, 0.1, 0.35)


func _recover_from_hijack() -> void:
	if hijack_phase == GameEnums.HijackPhase.NONE:
		return
	hijack_phase = GameEnums.HijackPhase.RECOVERING
	if _sprite and data:
		_apply_forge_visuals()
	hijack_phase = GameEnums.HijackPhase.NONE
	_update_efficiency()
	var spot_id := build_spot.spot_id if build_spot else ""
	CombatEvents.tower_hijack_recovered.emit(spot_id)
	AnalyticsService.tower_hijack_recovered(spot_id)


func _process_hijack_attack(delta: float) -> void:
	_cooldown -= delta
	if _cooldown > 0.0:
		return
	if context and context.hero_manager and context.hero_manager.hero:
		context.hero_manager.hero.take_damage(8.0)
	_cooldown = 1.2
