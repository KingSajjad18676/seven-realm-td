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
	_cooldown -= delta
	if _cooldown > 0.0:
		return
	var target := _pick_target()
	if target == null:
		return
	_fire_at(target)
	var rate := data.attack_rate * _efficiency
	if context.runtime_modifiers.has("attack_mult"):
		rate *= float(context.runtime_modifiers["attack_mult"])
	if context.runtime_modifiers.has("tower_attack_rate_mult"):
		rate *= float(context.runtime_modifiers["tower_attack_rate_mult"])
	rate *= MoraleController.get_rate_mult(context)
	_cooldown = 1.0 / maxf(0.1, rate)


func on_region_light_changed(light: int) -> void:
	if light <= 0:
		_start_hijack_warning()
	else:
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
			in_range.append(e)
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
	var info := DamageInfo.create(dmg)
	info.applies_burn = data.applies_burn
	info.applies_slow = data.applies_slow
	if data.applies_slow and context.runtime_modifiers.has("control_slow_mult"):
		info.applies_slow = true
	info.armor_break = data.armor_break
	target.take_damage(info.amount)
	if info.applies_burn:
		target.apply_burn(2.5)
	if info.applies_slow:
		var slow_mult := 0.55
		if context.runtime_modifiers.has("control_slow_mult"):
			slow_mult = float(context.runtime_modifiers["control_slow_mult"])
		target.apply_slow(slow_mult, 1.5)
	if info.armor_break:
		target.apply_armor_break()


func _level_damage_mult() -> float:
	return 1.0 + float(level - 1) * LEVEL_DAMAGE_BONUS


func _level_range_mult() -> float:
	return 1.0 + float(level - 1) * LEVEL_RANGE_BONUS


func _effective_range() -> float:
	return data.range * _efficiency * _forge_range_mult * _level_range_mult()


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
