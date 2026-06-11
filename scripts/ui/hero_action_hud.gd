class_name HeroActionHud
extends Control

const SPELL_BAR_CLEARANCE := 56.0

signal attack_pressed
signal heavy_pressed
signal dodge_pressed
signal skill_pressed
signal naft_pressed

var _joystick: VirtualJoystick = null
var _action_cluster: VBoxContainer = null
var _attack_btn: Button = null
var _heavy_btn: Button = null
var _dodge_btn: Button = null
var _skill_btn: Button = null
var _naft_btn: Button = null
var _hero_chip: PanelContainer = null
var _hero_portrait: TextureRect = null
var _hero_hp_bar: ProgressBar = null
var _hero_name_label: Label = null
var _hero_level_label: Label = null
var _hero_xp_bar: ProgressBar = null
var _skill_readiness_bar: ProgressBar = null
var _tether_label: Label = null
var _context: BattleContext = null
var _left_handed: bool = false


func setup(ctx: BattleContext) -> void:
	_context = ctx
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_build_joystick()
	_build_action_cluster()
	_build_hero_chip()
	apply_layout(AccessibilityHelper.is_left_handed())


func get_move_vector() -> Vector2:
	if _joystick:
		return _joystick.get_direction()
	return Vector2.ZERO


func apply_layout(left_handed: bool) -> void:
	_left_handed = left_handed
	if _joystick:
		_joystick.set_corner(left_handed)
	if _action_cluster:
		var bottom := SPELL_BAR_CLEARANCE
		var cluster_height := 220.0
		if left_handed:
			_action_cluster.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT)
			_action_cluster.offset_left = 12.0
			_action_cluster.offset_top = -(cluster_height + bottom)
			_action_cluster.offset_right = 220.0
			_action_cluster.offset_bottom = -bottom
		else:
			_action_cluster.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
			_action_cluster.offset_left = -220.0
			_action_cluster.offset_top = -(cluster_height + bottom)
			_action_cluster.offset_right = -12.0
			_action_cluster.offset_bottom = -bottom
	if _hero_chip:
		var chip_bottom := SPELL_BAR_CLEARANCE
		if left_handed:
			_hero_chip.offset_left = 12.0
			_hero_chip.offset_right = 222.0
		else:
			_hero_chip.offset_left = 150.0
			_hero_chip.offset_right = 360.0
		_hero_chip.offset_top = -(96.0 + chip_bottom)
		_hero_chip.offset_bottom = -chip_bottom


func refresh_hero_chip() -> void:
	if _context == null or _context.hero_manager == null:
		return
	var hero := _context.hero_manager.get_controlled_hero()
	if hero == null or hero.data == null:
		return
	if _hero_name_label:
		_hero_name_label.text = hero.data.display_name
	if _hero_level_label and _context.hero_level:
		_hero_level_label.text = "Lv %d" % _context.hero_level.get_level()
	if _hero_xp_bar and _context.hero_level:
		_hero_xp_bar.max_value = 1.0
		_hero_xp_bar.value = _context.hero_level.get_xp_progress()
	if _hero_hp_bar:
		var max_hp := hero.get_effective_max_hp() if hero.has_method("get_effective_max_hp") else hero.data.max_hp
		if _context.runtime_modifiers.has("hero_max_hp_mult") and not hero.has_method("get_effective_max_hp"):
			max_hp *= float(_context.runtime_modifiers["hero_max_hp_mult"])
		_hero_hp_bar.max_value = max_hp
		_hero_hp_bar.value = hero.current_hp
	if _tether_label:
		if hero.tethered_tower:
			_tether_label.text = "Tether: %d" % int(hero.tether_energy)
		else:
			_tether_label.text = "Tether: —"
	if _skill_readiness_bar and hero.data:
		var max_cd := maxf(hero.data.skill_cooldown, 0.01)
		var ready := 1.0 - clampf(hero.get_skill_cooldown_remaining() / max_cd, 0.0, 1.0)
		_skill_readiness_bar.value = ready
	_refresh_portrait(hero)


func refresh_skill_button_label() -> void:
	if _context == null or _context.hero_manager == null or _skill_btn == null:
		return
	var hero := _context.hero_manager.get_controlled_hero()
	if hero:
		var cd := hero.get_skill_cooldown_remaining()
		if cd > 0.05:
			_skill_btn.text = "%.1f" % cd
		else:
			_skill_btn.text = _skill_label(hero)


func refresh_action_buttons() -> void:
	if _context == null or _context.hero_manager == null:
		return
	var hero := _context.hero_manager.get_controlled_hero()
	if hero == null:
		return
	_set_cd_button(_attack_btn, hero.get_attack_cooldown_remaining(), "Attack")
	_set_cd_button(_heavy_btn, hero.get_heavy_cooldown_remaining(), "Heavy")
	_set_cd_button(_dodge_btn, hero.get_dodge_cooldown_remaining(), "Dodge")
	_set_cd_button(_skill_btn, hero.get_skill_cooldown_remaining(), _skill_label(hero))
	_refresh_naft()


func apply_tutorial_gating(allowed: Dictionary) -> void:
	var battlefield: bool = bool(allowed.get("battlefield", false))
	if _joystick:
		_joystick.mouse_filter = Control.MOUSE_FILTER_STOP if battlefield else Control.MOUSE_FILTER_IGNORE
	var skill_ok: bool = bool(allowed.get("skill", false))
	for btn in [_attack_btn, _heavy_btn, _dodge_btn, _skill_btn]:
		if btn:
			btn.disabled = not (battlefield or skill_ok)
	if _naft_btn:
		_naft_btn.disabled = not skill_ok


func clear_tutorial_gating() -> void:
	if _joystick:
		_joystick.mouse_filter = Control.MOUSE_FILTER_STOP
	for btn in [_attack_btn, _heavy_btn, _dodge_btn, _skill_btn, _naft_btn]:
		if btn:
			btn.disabled = false


func _build_joystick() -> void:
	_joystick = VirtualJoystick.new()
	_joystick.name = "VirtualJoystick"
	add_child(_joystick)


func _build_action_cluster() -> void:
	_action_cluster = VBoxContainer.new()
	_action_cluster.name = "ActionCluster"
	_action_cluster.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
	_action_cluster.offset_left = -220.0
	_action_cluster.offset_top = -(220.0 + SPELL_BAR_CLEARANCE)
	_action_cluster.offset_right = -12.0
	_action_cluster.offset_bottom = -SPELL_BAR_CLEARANCE
	_action_cluster.add_theme_constant_override("separation", 6)
	_action_cluster.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_action_cluster)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	row.alignment = BoxContainer.ALIGNMENT_END if not _left_handed else BoxContainer.ALIGNMENT_BEGIN
	row.name = "ActionRow"
	_action_cluster.add_child(row)

	_dodge_btn = _make_action_btn("Dodge", Vector2(56, 56))
	_dodge_btn.pressed.connect(func() -> void: dodge_pressed.emit())
	row.add_child(_dodge_btn)

	_heavy_btn = _make_action_btn("Heavy", Vector2(56, 56))
	_heavy_btn.pressed.connect(func() -> void: heavy_pressed.emit())
	row.add_child(_heavy_btn)

	_skill_btn = _make_action_btn("Skill", Vector2(56, 56))
	_skill_btn.pressed.connect(func() -> void: skill_pressed.emit())
	row.add_child(_skill_btn)

	_attack_btn = _make_action_btn("Attack", Vector2(72, 72))
	_attack_btn.pressed.connect(func() -> void: attack_pressed.emit())
	row.add_child(_attack_btn)

	_naft_btn = _make_action_btn("Naft", Vector2(56, 40))
	_naft_btn.pressed.connect(func() -> void: naft_pressed.emit())
	_action_cluster.add_child(_naft_btn)
	_naft_btn.visible = false


func _build_hero_chip() -> void:
	_hero_chip = PanelContainer.new()
	_hero_chip.name = "HeroChip"
	_hero_chip.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT)
	_hero_chip.offset_left = 150.0
	_hero_chip.offset_top = -(96.0 + SPELL_BAR_CLEARANCE)
	_hero_chip.offset_right = 360.0
	_hero_chip.offset_bottom = -SPELL_BAR_CLEARANCE
	add_child(_hero_chip)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	_hero_chip.add_child(row)

	_hero_portrait = TextureRect.new()
	_hero_portrait.custom_minimum_size = Vector2(48, 48)
	_hero_portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_hero_portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	row.add_child(_hero_portrait)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 4)
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(box)

	_hero_name_label = Label.new()
	_hero_name_label.add_theme_font_size_override("font_size", 12)
	_hero_name_label.text = "Rostam"
	box.add_child(_hero_name_label)

	_hero_level_label = Label.new()
	_hero_level_label.add_theme_font_size_override("font_size", 10)
	_hero_level_label.text = "Lv 1"
	box.add_child(_hero_level_label)

	_hero_hp_bar = ProgressBar.new()
	_hero_hp_bar.custom_minimum_size = Vector2(140, 14)
	_hero_hp_bar.max_value = 220.0
	_hero_hp_bar.value = 220.0
	_hero_hp_bar.show_percentage = false
	box.add_child(_hero_hp_bar)

	_hero_xp_bar = ProgressBar.new()
	_hero_xp_bar.custom_minimum_size = Vector2(140, 6)
	_hero_xp_bar.max_value = 1.0
	_hero_xp_bar.value = 0.0
	_hero_xp_bar.show_percentage = false
	box.add_child(_hero_xp_bar)

	_skill_readiness_bar = ProgressBar.new()
	_skill_readiness_bar.custom_minimum_size = Vector2(140, 6)
	_skill_readiness_bar.max_value = 1.0
	_skill_readiness_bar.value = 1.0
	_skill_readiness_bar.show_percentage = false
	_skill_readiness_bar.tooltip_text = "Skill readiness"
	box.add_child(_skill_readiness_bar)

	_tether_label = Label.new()
	_tether_label.add_theme_font_size_override("font_size", 10)
	_tether_label.text = "Tether: —"
	box.add_child(_tether_label)


func _refresh_portrait(hero: HeroController) -> void:
	if _hero_portrait == null or hero == null or hero.data == null:
		return
	var sprite_path := hero.data.sprite_path
	if sprite_path == "":
		sprite_path = VisualAssetLoader.khan1_sprite(hero.data.hero_id)
	if sprite_path != "" and ResourceLoader.exists(sprite_path):
		var tex := load(sprite_path) as Texture2D
		if tex:
			_hero_portrait.texture = tex
			return
	var fallback := VisualAssetLoader.make_portrait_texture(hero.data.hero_id, hero.data.color, 48)
	_hero_portrait.texture = fallback


func _make_action_btn(text: String, size: Vector2) -> Button:
	var btn := Button.new()
	btn.text = text
	btn.custom_minimum_size = size
	btn.add_theme_font_size_override("font_size", 11)
	btn.mouse_filter = Control.MOUSE_FILTER_STOP
	return btn


func _skill_label(hero: HeroController) -> String:
	if hero.data == null:
		return "Skill"
	match hero.data.skill_id:
		"zal_foresight":
			return "Foresight"
		"sohrab_rage":
			return "Rage"
		"gordafarid_volley":
			return "Volley"
		"esfandiyar_bulwark":
			return "Bulwark"
		_:
			return "Charge"


func _set_cd_button(btn: Button, cd: float, base_text: String) -> void:
	if btn == null:
		return
	if cd > 0.05:
		btn.text = "%.1f" % cd
		btn.disabled = true
	else:
		btn.text = base_text
		btn.disabled = false


func get_highlight_control(key: String) -> Control:
	match key:
		"joystick":
			return _joystick
		"attack":
			return _attack_btn
		"heavy":
			return _heavy_btn
		"dodge":
			return _dodge_btn
		"skill":
			return _skill_btn
		"naft":
			return _naft_btn
	return null


func _refresh_naft() -> void:
	if _naft_btn == null or _context == null:
		return
	var hero := _context.hero_manager.get_controlled_hero() if _context.hero_manager else null
	var has_naft := hero and hero.data and hero.data.secondary_skill_id == "rostam_naft"
	_naft_btn.visible = has_naft
	if not has_naft:
		return
	var traps := _context.naft_traps
	var max_c := traps.get_max_charges() if traps else 0
	var charges := traps.get_charges() if traps else 0
	var armed := traps.is_armed() if traps else false
	_naft_btn.text = "Naft %d/%d" % [charges, max_c]
	_naft_btn.modulate = Color(1.15, 1.0, 0.75) if armed else Color.WHITE
