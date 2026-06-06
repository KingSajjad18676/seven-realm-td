class_name BattleResultsFormatter
extends RefCounted

const REASON_LABELS := {
	"waves_cleared": "All waves cleared",
	"gate_breached": "The gate fell",
	"lives_depleted": "Lives depleted",
	"throne_breached": "The throne fell",
	"debug": "Debug shortcut",
	"safe_retreat": "Retreated to Kaveh's Forge — materials banked",
}


static func format_reason(reason: String) -> String:
	if REASON_LABELS.has(reason):
		return REASON_LABELS[reason]
	return reason.replace("_", " ").capitalize()


static func format_fate_card(card_id: String) -> String:
	if card_id.is_empty():
		return "None"
	if ContentRegistry:
		var card := ContentRegistry.get_fate_card(card_id)
		if card and not card.title.is_empty():
			return card.title
	return card_id.replace("_", " ").capitalize()


static func format_rewards(economy: BattleEconomy) -> String:
	if economy == null:
		return ""
	var earned := economy.forge_materials_earned
	if earned.is_empty():
		return ""
	var lines: PackedStringArray = PackedStringArray()
	lines.append("Star Iron earned:")
	for mat_id in earned.keys():
		var mat_name := ForgeService.get_material_name(str(mat_id)) if ForgeService else str(mat_id)
		lines.append("  %s +%d" % [mat_name, int(earned[mat_id])])
	return "\n".join(lines)


static func format_summary(summary: Dictionary, ctx: BattleContext, victory: bool = true) -> String:
	if summary.is_empty():
		return ""
	var lines: PackedStringArray = PackedStringArray()
	lines.append("Fate: %s" % format_fate_card(str(summary.get("fate_card", ""))))
	var morale := int(summary.get("morale", 0))
	var max_m := MoraleController.MAX_MORALE
	if ctx and ctx.morale:
		morale = ctx.morale.current
	lines.append("Morale: %d/%d" % [morale, max_m])
	if bool(summary.get("objective_done", false)):
		lines.append("Objective: Complete")
	elif bool(summary.get("objective_failed", false)):
		lines.append("Objective: Failed")
	var vows_honored := int(summary.get("vows_honored", 0))
	var vows_total := int(summary.get("vows_total", 0))
	if vows_total > 0:
		lines.append("Vows honored: %d/%d" % [vows_honored, vows_total])
	if not victory:
		lines.append("Unbanked Star Iron from this battle was lost.")
	var guidance := format_forge_defeat_guidance(ctx, victory)
	if not guidance.is_empty():
		lines.append(guidance)
	return "\n".join(lines)


static func format_forge_defeat_guidance(ctx: BattleContext, victory: bool) -> String:
	if victory or ctx == null or ctx.level_data == null or ForgeService == null:
		return ""
	var level_id := ctx.level_data.level_id
	if not ForgeService.forge_gate_applies_to_level(level_id):
		return ""
	if not ForgeService.is_under_forge_recommendation(level_id):
		return ""
	var expected := ForgeService.expected_forge_level_for(level_id)
	var current := ForgeService.get_average_forge_level_floor()
	return (
		"Forge your towers at Kaveh's Forge (need avg Lv %d, you: Lv %d).\n"
		+ "Replay earlier Labours for Star Iron, then try again."
		% [expected, current]
	)
