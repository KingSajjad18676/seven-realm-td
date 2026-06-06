class_name EquipmentSetRules
extends RefCounted


static func apply_rule(rule_id: String, service: EquipmentBattleService) -> void:
	if service == null or service.context == null:
		return
	var ctx := service.context
	match rule_id:
		"rakhsh_dash_knockdown":
			ctx.runtime_modifiers["equipment_dash_knockdown"] = true
		"rakhsh_tower_range_near_hero":
			pass
		"rakhsh_spectral_horse":
			ctx.runtime_modifiers["equipment_spectral_horse"] = true
		"thirst_forge_token_drop":
			ctx.runtime_modifiers["equipment_forge_drop_bonus"] = 0.10
		"thirst_tower_refund", "thirst_tower_sell_bonus":
			pass
		"azhdaha_melee_burn", "azhdaha_fire_nova":
			pass
		"azhdaha_fire_extra_shot":
			ctx.runtime_modifiers["equipment_fire_extra_shot"] = true
		"mazandaran_melee_slow", "mazandaran_toxic_explosion":
			pass
		"mazandaran_archer_armor_break":
			ctx.runtime_modifiers["equipment_archer_armor_break"] = 0.20
		"kaveh_periodic_shield", "kaveh_heavy_vs_brute", "kaveh_gate_rebuild":
			if rule_id == "kaveh_heavy_vs_brute":
				ctx.runtime_modifiers["equipment_heavy_brute_mult"] = 2.0
		"arzhang_cleave", "arzhang_combat_tower_haste", "arzhang_blood_frenzy":
			pass
		"simurgh_cleanse_discount":
			ctx.runtime_modifiers["cleanse_cost_mult"] = float(ctx.runtime_modifiers.get("cleanse_cost_mult", 1.0)) * 0.5
		"simurgh_beam_cleanse":
			ctx.runtime_modifiers["equipment_beam_cleanse"] = true
		"simurgh_wings_dash_cleanse":
			ctx.runtime_modifiers["equipment_wings_cleanse"] = true


static func trigger_fire_nova(service: EquipmentBattleService) -> void:
	if service == null or service.context == null:
		return
	var ctx := service.context
	var hero: HeroController = ctx.hero_manager.hero if ctx.hero_manager else null
	if hero == null:
		return
	var radius := 200.0
	var killed := 0
	for e in ctx.active_enemies.duplicate():
		if not e is EnemyController:
			continue
		var enemy: EnemyController = e
		if enemy._is_boss:
			continue
		if hero.global_position.distance_to(enemy.global_position) <= radius:
			enemy.take_damage(9999.0, false)
			killed += 1
	if ctx.bridge:
		ctx.bridge.alert_message.emit("Azhdaha's fire nova! %d foes vaporized!" % killed, 60)


static func trigger_blood_frenzy(service: EquipmentBattleService) -> void:
	if service == null or service.context == null:
		return
	var ctx := service.context
	ctx.runtime_modifiers["hero_invincible"] = true
	ctx.runtime_modifiers["hero_attack_rate_mult"] = float(ctx.runtime_modifiers.get("hero_attack_rate_mult", 1.0)) * 2.0
	if ctx.bridge:
		ctx.bridge.alert_message.emit("Blood Frenzy!", 50)
	var tree := service.get_tree()
	if tree:
		tree.create_timer(5.0).timeout.connect(func() -> void:
			if is_instance_valid(ctx):
				ctx.runtime_modifiers.erase("hero_invincible")
		, CONNECT_ONE_SHOT)


static func spawn_toxic_cloud(service: EquipmentBattleService, pos: Vector2) -> void:
	if service == null or service.context == null:
		return
	var cloud := EquipmentToxicCloud.new()
	cloud.global_position = pos
	if service.get_parent():
		service.get_parent().add_child(cloud)
	cloud.setup(service.context, 2.0, 90.0)


static func try_wings_cleanse(service: EquipmentBattleService, target_pos: Vector2) -> bool:
	if service == null or not service.has_rule("simurgh_wings_dash_cleanse"):
		return false
	var ctx := service.context
	if ctx == null or ctx.map_light == null or ctx.hero_manager == null:
		return false
	var hero: HeroController = ctx.hero_manager.hero
	if hero == null:
		return false
	var region_id := ctx.map_light.find_region_at(target_pos)
	if region_id == "":
		return false
	hero.global_position = target_pos
	ctx.map_light.force_cleanse_region(region_id)
	if ctx.bridge:
		ctx.bridge.alert_message.emit("Simurgh wings — region cleansed!", 55)
	return true


static func on_mount_dash_through(service: EquipmentBattleService, hero: HeroController) -> void:
	if service == null or not service.has_rule("rakhsh_dash_knockdown") or hero == null:
		return
	for e in hero.context.active_enemies if hero.context else []:
		if not e is EnemyController:
			continue
		var enemy: EnemyController = e
		if enemy._is_boss or enemy.data == null:
			continue
		if enemy.data.max_hp > 80.0:
			continue
		if hero.global_position.distance_to(enemy.global_position) <= 40.0:
			enemy.apply_slow(0.0, 1.5)
			enemy.apply_path_knockback(20.0)
			CombatEvents.enemy_stunned.emit("hero_dash", enemy.data.enemy_id)


static func spectral_horse_charge(service: EquipmentBattleService, hero: HeroController) -> void:
	if service == null or not service.has_rule("rakhsh_spectral_horse") or hero == null or hero.context == null:
		return
	var ctx := hero.context
	var dir := Vector2.RIGHT
	if hero.velocity.length_squared() > 1.0:
		dir = hero.velocity.normalized()
	elif hero._has_target:
		dir = (hero._move_target - hero.global_position).normalized()
	for e in ctx.active_enemies:
		if not e is EnemyController:
			continue
		var enemy: EnemyController = e
		var rel := enemy.global_position - hero.global_position
		if absf(rel.dot(dir)) > 30.0:
			continue
		if rel.length() > 180.0:
			continue
		enemy.take_damage(hero.data.skill_damage * 1.5, false)
		enemy.apply_slow(0.0, 3.0)
		CombatEvents.enemy_stunned.emit("spectral_horse", enemy.data.enemy_id)
	if ctx.bridge:
		ctx.bridge.alert_message.emit("Spectral horse tramples!", 45)
