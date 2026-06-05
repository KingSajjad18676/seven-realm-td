class_name TowerSpotPanelController
extends Panel

var context: BattleContext = null
var _spot: BuildSpot = null

@onready var _title_label: Label = %TitleLabel
@onready var _upgrade_btn: Button = %UpgradeButton
@onready var _sell_btn: Button = %SellButton
@onready var _purify_btn: Button = %PurifyButton
@onready var _close_btn: Button = %CloseButton


func initialize(ctx: BattleContext) -> void:
	context = ctx
	visible = false
	if _upgrade_btn:
		_upgrade_btn.pressed.connect(_on_upgrade)
	if _sell_btn:
		_sell_btn.pressed.connect(_on_sell)
	if _purify_btn:
		_purify_btn.pressed.connect(_on_purify)
	if _close_btn:
		_close_btn.pressed.connect(_on_close)


func show_for_spot(spot: BuildSpot) -> void:
	_spot = spot
	if spot == null or spot.tower == null:
		hide_panel()
		return
	_refresh()
	visible = true


func hide_panel() -> void:
	_spot = null
	visible = false


func refresh_panel() -> void:
	_refresh()


func _refresh() -> void:
	if _spot == null or _spot.tower == null or _spot.tower.data == null:
		return
	var tower := _spot.tower
	var td := tower.data
	var hijacked := tower.hijack_phase != GameEnums.HijackPhase.NONE

	if _title_label:
		_title_label.text = "%s  Lv %d/%d" % [td.display_name, tower.level, td.max_level]

	var actions_enabled := _can_act()

	if _purify_btn:
		_purify_btn.visible = hijacked
		_purify_btn.disabled = not actions_enabled

	if _upgrade_btn:
		_upgrade_btn.visible = not hijacked
		if tower.can_upgrade():
			_upgrade_btn.text = "Upgrade  %dG  (Lv %d→%d)" % [
				tower.get_upgrade_cost(),
				tower.level,
				tower.level + 1,
			]
			_upgrade_btn.disabled = not actions_enabled
		else:
			_upgrade_btn.text = "Max level"
			_upgrade_btn.disabled = true

	if _sell_btn:
		_sell_btn.visible = not hijacked
		_sell_btn.text = "Sell  +%dG" % tower.get_sell_refund()
		_sell_btn.disabled = not actions_enabled or hijacked


func _can_act() -> bool:
	if context == null or context.state_controller == null:
		return false
	var state := context.state_controller.current_state
	return state == GameEnums.BattleState.PRE_BATTLE or state == GameEnums.BattleState.WAVE_ACTIVE


func _on_upgrade() -> void:
	if _spot == null or _spot.tower == null or context == null or context.tower_manager == null:
		return
	if context.tower_manager.try_upgrade_tower(_spot.tower):
		_refresh()


func _on_sell() -> void:
	if _spot == null or _spot.tower == null or context == null or context.tower_manager == null:
		return
	if context.tower_manager.try_sell_tower(_spot.tower):
		hide_panel()


func _on_purify() -> void:
	if _spot == null or _spot.tower == null:
		return
	if _spot.tower.try_recover_hijack():
		_refresh()


func _on_close() -> void:
	hide_panel()
