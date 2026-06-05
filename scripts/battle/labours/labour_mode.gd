class_name LabourMode
extends Node

var context: BattleContext = null
var mode_id: String = ""


func initialize(ctx: BattleContext) -> void:
	context = ctx


func macro_role_for(wave_index: int) -> int:
	return CampaignWaveTemplates.macro_role_for_wave_index(wave_index)


func act_index_for(wave_index: int) -> int:
	return CampaignWaveTemplates.act_index_for_wave_index(wave_index)


func is_trap_phase(wave_index: int) -> bool:
	var role := macro_role_for(wave_index)
	return role >= CampaignWaveTemplates.MacroRole.TRAP_A and role <= CampaignWaveTemplates.MacroRole.TRAP_B


func is_hijack_phase(wave_index: int) -> bool:
	var role := macro_role_for(wave_index)
	return role >= CampaignWaveTemplates.MacroRole.HIJACK_A and role <= CampaignWaveTemplates.MacroRole.HIJACK_C


func is_bait_phase(wave_index: int) -> bool:
	var role := macro_role_for(wave_index)
	return role <= CampaignWaveTemplates.MacroRole.BAIT_C


func on_wave_started(_wave_index: int) -> void:
	pass


func on_wave_completed(_wave_index: int) -> void:
	pass


func on_enemy_died(_enemy_id: String, _enemy: EnemyController = null) -> void:
	pass


func on_boss_defeated() -> void:
	pass


func on_cleanse(_region_id: String) -> void:
	pass
