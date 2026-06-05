class_name BattleResultsFormatter
extends RefCounted

const REASON_LABELS := {
	"waves_cleared": "All waves cleared",
	"gate_breached": "The gate fell",
	"lives_depleted": "Lives depleted",
	"debug": "Debug shortcut",
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


static func format_summary(summary: Dictionary, ctx: BattleContext) -> String:
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
	return "\n".join(lines)
