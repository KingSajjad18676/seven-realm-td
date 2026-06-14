class_name RegionStatusHud
extends HBoxContainer

## Color-safe corruption region indicators (high contrast mode).

const STATE_GLYPH: Dictionary = {
	GameEnums.RegionLightState.STABLE: "[=]",
	GameEnums.RegionLightState.PRESSURED: "[!]",
	GameEnums.RegionLightState.CRITICAL: "[!!]",
	GameEnums.RegionLightState.COLLAPSED: "[X]",
}

var _context: BattleContext = null
var _chips: Dictionary = {}


func setup(ctx: BattleContext) -> void:
	_context = ctx
	name = "RegionStatusHud"
	add_theme_constant_override("separation", 6)
	set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	offset_top = 48.0
	offset_bottom = 68.0
	offset_left = 200.0
	offset_right = -200.0
	alignment = BoxContainer.ALIGNMENT_CENTER
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	if ctx and ctx.bridge:
		ctx.bridge.region_light_changed.connect(_on_region_changed)
	_rebuild_chips()
	_refresh_visibility()


func refresh_accessibility() -> void:
	_refresh_visibility()
	for chip in _chips.values():
		if chip is Label:
			_apply_chip_style(chip as Label)


func _refresh_visibility() -> void:
	visible = AccessibilityHelper.is_high_contrast() and not _chips.is_empty()


func _rebuild_chips() -> void:
	for child in get_children():
		child.queue_free()
	_chips.clear()
	if _context == null or _context.level_data == null:
		return
	for region_id in _context.level_data.region_ids:
		var chip := Label.new()
		chip.add_theme_font_size_override("font_size", 11)
		chip.text = "%s %s" % [region_id, STATE_GLYPH[GameEnums.RegionLightState.STABLE]]
		_apply_chip_style(chip)
		add_child(chip)
		_chips[region_id] = chip
		if _context.map_light:
			var state := _context.map_light.get_state(region_id)
			chip.text = "%s %s" % [region_id, STATE_GLYPH.get(state, "[?]")]


func _on_region_changed(region_id: String, light: int, state: GameEnums.RegionLightState) -> void:
	if not _chips.has(region_id):
		return
	var chip: Label = _chips[region_id]
	chip.text = "%s %s %d" % [region_id, STATE_GLYPH.get(state, "[?]"), light]
	_apply_chip_style(chip)
	_refresh_visibility()


func _apply_chip_style(chip: Label) -> void:
	if AccessibilityHelper.is_high_contrast():
		chip.add_theme_color_override("font_color", Color(1.0, 1.0, 0.85))
		chip.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0))
		chip.add_theme_constant_override("outline_size", 2)
	else:
		chip.remove_theme_color_override("font_color")
		chip.remove_theme_color_override("font_outline_color")
		chip.remove_theme_constant_override("outline_size")
