class_name TowerController
extends Node2D

signal tower_selected(tower: TowerController)

var context: BattleContext = null
var data: TowerData = null
var region_id: String = ""
var placement_id: String = ""
var level: int = 1
var gold_invested: int = 0
var hijack_phase: GameEnums.HijackPhase = GameEnums.HijackPhase.NONE
var resonance_links: Array[String] = []
var resonance_partners: Array[TowerController] = []
const LEVEL_DAMAGE_BONUS := 0.25
const LEVEL_RANGE_BONUS := 0.10
const QUAKE_BIND_RADIUS := 100.0
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
const PICK_PADDING := 8.0

@onready var _sprite: ColorRect = $Sprite
@onready var _range_area: Area2D = $RangeArea
@onready var _pick_area: Area2D = $PickArea


func _ready() -> void:
	if _pick_area:
		_pick_area.input_pickable = true
		_pick_area.input_event.connect(_on_pick_input)
	refresh_pick_area()


func initialize(
	ctx: BattleContext,
	tower_data: TowerData,
	world_pos: Vector2,
	p_region_id: String,
	p_placement_id: String
) -> void:
	context = ctx
	data = tower_data
	global_position = world_pos
	region_id = p_region_id
	placement_id = p_placement_id
	level = 1
	gold_invested = tower_data.build_cost
	hijack_phase = GameEnums.HijackPhase.NONE
	resonance_links.clear()
	resonance_partners.clear()
	_cooldown = 0.0
	_apply_forge_visuals()
	_update_efficiency()
	if data and data.attack_behavior == GameEnums.AttackBehavior.BARRACKS:
		_spawn_barracks_units()
	CombatEvents.tower_built.emit(tower_data.tower_id)


func has_resonance(combo_id: String) -> bool:
	return combo_id in resonance_links


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
	if context.runtime_modifiers.has("equipment_tower_rate_mult"):
		rate *= float(context.runtime_modifiers["equipment_tower_rate_mult"])
	var relic := _get_tower_relic()
	if relic and relic.tower_attack_rate_mult != 1.0:
		rate *= relic.tower_attack_rate_mult
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
	if context and context.map_light and region_id != "":
		if context.map_light.try_cleanse_region(region_id):
			_recover_from_hijack()
			return true
	return false


func _update_efficiency() -> void:
	if context and context.map_light and region_id != "":
		var light := context.map_light.get_light(region_id)
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
	var dmg := _compute_shot_damage(target)
	var impact := func() -> void:
		_apply_shot_impact(target, dmg)
	if context and context.tower_manager:
		context.tower_manager.spawn_projectile(self, target, impact)
	else:
		_apply_shot_impact(target, dmg)


func _compute_shot_damage(target: EnemyController) -> float:
	var dmg := data.damage * _efficiency * _forge_damage_mult * _level_damage_mult() * _tether_mult
	dmg *= MoraleController.get_damage_mult(context)
	if context.runtime_modifiers.has("tower_damage_mult"):
		dmg *= float(context.runtime_modifiers["tower_damage_mult"])
	if context.runtime_modifiers.has("attack_mult"):
		dmg *= float(context.runtime_modifiers["attack_mult"])
	var relic := _get_tower_relic()
	if relic and relic.tower_damage_mult != 1.0:
		dmg *= relic.tower_damage_mult
	if data.applies_burn or data.tower_id == "tower_sacred_fire":
		if context.runtime_modifiers.has("tower_fire_damage_mult"):
			dmg *= float(context.runtime_modifiers["tower_fire_damage_mult"])
	if context.runtime_modifiers.has("equipment_heavy_brute_mult") and data.tower_id == "tower_heavy" and target.has_tag("div_brute"):
		dmg *= float(context.runtime_modifiers["equipment_heavy_brute_mult"])
	if context.map_light and region_id != "" and context.map_light.is_region_collapsed(region_id):
		if context.runtime_modifiers.has("tower_damage_collapsed_mult"):
			dmg *= float(context.runtime_modifiers["tower_damage_collapsed_mult"])
	return dmg


func _apply_shot_impact(target: EnemyController, dmg: float) -> void:
	if target == null or not is_instance_valid(target) or target.current_hp <= 0.0:
		return
	target.take_damage(dmg)
	CombatEvents.tower_damage_dealt.emit(data.tower_id, dmg, target.data.enemy_id if target.data else "")
	if data.tower_id == "tower_archer" and context.runtime_modifiers.has("equipment_archer_armor_break"):
		target.add_armor_delta(-target.data.armor * float(context.runtime_modifiers["equipment_archer_armor_break"]) if target.data else 0.0)
	if context.runtime_modifiers.get("equipment_beam_cleanse", false) and context.map_light:
		var region := context.map_light.get_region_for_position(target.global_position)
		if region != "":
			context.map_light.repair_region_light(region, 15)
	if context.runtime_modifiers.get("equipment_fire_extra_shot", false) and (data.applies_burn or data.tower_id == "tower_sacred_fire"):
		target.take_damage(dmg * 0.85)
	if data.attack_behavior == GameEnums.AttackBehavior.TWIN:
		target.apply_venom(1, 5.0, 3.0, self)
	elif data.applies_burn:
		target.apply_burn(2.5)
		if context and context.naft_traps:
			context.naft_traps.try_ignite_from_fire(target, data)
	elif has_resonance("fire_string") and data.tower_id == "tower_archer":
		target.apply_burn(2.5)
	if data.applies_slow:
		_apply_slow_to(target)
	if data.armor_break:
		target.apply_armor_break()
	var relic := _get_tower_relic()
	if relic and relic.gate_lives_per_attack > 0.0 and context and context.lives:
		context.lives.restore_fraction(relic.gate_lives_per_attack)
	if has_resonance("quake_bind") and data.tower_id == "tower_heavy":
		_apply_quake_bind_shockwave(target.global_position)


func _fire_twin_at(primary: EnemyController) -> void:
	_fire_at(primary)
	var secondary := _pick_second_target(primary)
	if secondary == null:
		return
	var dmg := _compute_shot_damage(secondary)
	var impact := func() -> void:
		if secondary == null or not is_instance_valid(secondary) or secondary.current_hp <= 0.0:
			return
		secondary.take_damage(dmg)
		secondary.apply_venom(1, 5.0, 3.0, self)
	if context and context.tower_manager:
		context.tower_manager.spawn_projectile(self, secondary, impact)
	else:
		impact.call()


func _apply_slow_to(target: EnemyController) -> void:
	var slow_mult := 0.55
	if context.runtime_modifiers.has("control_slow_mult"):
		slow_mult = float(context.runtime_modifiers["control_slow_mult"])
	target.apply_slow(slow_mult, 1.5)


func _apply_quake_bind_shockwave(center: Vector2) -> void:
	if context == null:
		return
	var slow_mult := 0.55
	if context.runtime_modifiers.has("control_slow_mult"):
		slow_mult = float(context.runtime_modifiers["control_slow_mult"])
	for e in context.active_enemies:
		if e is EnemyController:
			var enemy: EnemyController = e
			if enemy.global_position.distance_to(center) <= QUAKE_BIND_RADIUS:
				enemy.apply_slow(slow_mult, 1.5)


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
	var scaled := unit_data.duplicate(true) as AllyUnitData
	var level_mult := 1.0 + float(level - 1) * 0.25
	scaled.max_hp *= level_mult
	scaled.damage *= level_mult
	var ally := AllyUnitController.new()
	context.tower_manager.units_root.add_child(ally)
	var offset := data.rally_offset + Vector2(index * 24 - 12, 0)
	ally.initialize(context, scaled, global_position + offset, self)
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
	p_region_id: String,
	preview_level: int = 1
) -> float:
	if tower_data == null:
		return 0.0
	var efficiency := 1.0
	if ctx and ctx.map_light and p_region_id != "":
		var light := ctx.map_light.get_light(p_region_id)
		efficiency = 1.0 if light >= 30 else float(light) / 30.0
	var forge_mult := 1.0
	if ForgeService:
		forge_mult = ForgeService.get_range_mult(tower_data.tower_id)
	var level_mult := 1.0 + float(preview_level - 1) * LEVEL_RANGE_BONUS
	var debuff_mult := 1.0
	if ctx and ctx.runtime_modifiers.has("vision_radius_mult"):
		debuff_mult = float(ctx.runtime_modifiers["vision_radius_mult"])
	var relic := _preview_relic_for_tower(ctx, tower_data.tower_id)
	if relic and relic.global_targeting and ctx and ctx.level_data:
		return _map_targeting_range(ctx.level_data)
	return tower_data.range * efficiency * forge_mult * level_mult * debuff_mult


func set_selected_visual(selected: bool) -> void:
	if _sprite == null:
		return
	_sprite.modulate = Color(1.25, 1.2, 1.05, 1.0) if selected else Color(1, 1, 1, 1)


func _effective_range() -> float:
	var relic := _get_tower_relic()
	if relic and relic.global_targeting and context and context.level_data:
		return _map_targeting_range(context.level_data)
	var mult := 1.0
	if context and context.runtime_modifiers.has("vision_radius_mult"):
		mult = float(context.runtime_modifiers["vision_radius_mult"])
	var range_val := data.range * _efficiency * _forge_range_mult * _level_range_mult() * mult
	if context and context.runtime_modifiers.has("tower_range_mult"):
		range_val *= float(context.runtime_modifiers["tower_range_mult"])
	if context and context.equipment_battle:
		range_val *= context.equipment_battle.get_tower_range_mult_near_hero(self)
	return range_val


func _get_tower_relic() -> RelicData:
	if context == null or context.run_modifiers == null or data == null:
		return null
	return context.run_modifiers.get_relic_for_tower(data.tower_id)


static func _preview_relic_for_tower(ctx: BattleContext, tower_id: String) -> RelicData:
	if ctx == null:
		return null
	if ctx.run_modifiers:
		return ctx.run_modifiers.get_relic_for_tower(tower_id)
	if ctx.launch_data and ctx.launch_data.tower_relic_slots.has(tower_id):
		var relic_id := str(ctx.launch_data.tower_relic_slots[tower_id])
		return ContentRegistry.get_relic(relic_id) if ContentRegistry else null
	return null


static func _map_targeting_range(level_data: LevelData) -> float:
	var bounds := level_data.minimap_bounds
	return bounds.size.length()


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
	refresh_pick_area()


func get_pick_radius() -> float:
	return get_visual_half_extent() + PICK_PADDING


func get_visual_half_extent() -> float:
	if _sprite != null:
		return _sprite.size.x * 0.5
	return 18.0


func refresh_pick_area() -> void:
	if _pick_area == null:
		_pick_area = get_node_or_null("PickArea") as Area2D
	if _pick_area == null:
		return
	var shape_node := _pick_area.get_node_or_null("CollisionShape2D") as CollisionShape2D
	if shape_node == null or not shape_node.shape is CircleShape2D:
		return
	(shape_node.shape as CircleShape2D).radius = get_pick_radius()


func _on_pick_input(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	var pressed := false
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		pressed = true
	elif event is InputEventScreenTouch and event.pressed:
		pressed = true
	if not pressed:
		return
	if context and context.tutorial_active and not context.tutorial_allows("build_pads"):
		return
	get_viewport().set_input_as_handled()
	tower_selected.emit(self)
	if context and context.tower_manager:
		context.tower_manager._on_tower_selected(self)


func trigger_hijack_warning() -> void:
	_start_hijack_warning()


func _start_hijack_warning() -> void:
	if hijack_phase != GameEnums.HijackPhase.NONE:
		return
	hijack_phase = GameEnums.HijackPhase.WARNING
	_hijack_timer = 3.5
	if _sprite:
		_sprite.color = Color(0.35, 0.15, 0.45)
	if context and context.map_light and placement_id != "":
		context.map_light.register_hijack_warning(placement_id)
	CombatEvents.tower_hijack_started.emit(placement_id)
	AnalyticsService.tower_hijack_started(placement_id)


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
	CombatEvents.tower_hijack_recovered.emit(placement_id)
	AnalyticsService.tower_hijack_recovered(placement_id)


func _process_hijack_attack(delta: float) -> void:
	_cooldown -= delta
	if _cooldown > 0.0:
		return
	if context and context.hero_manager and context.hero_manager.hero:
		context.hero_manager.hero.take_damage(8.0)
	_cooldown = 1.2
