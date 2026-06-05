extends CanvasLayer

@onready var _skip: Button = $Panel/VBox/SkipWave
@onready var _win: Button = $Panel/VBox/ForceWin
@onready var _gold: Button = $Panel/VBox/AddGold
@onready var _collapse: Button = $Panel/VBox/CollapseRegion


func _ready() -> void:
	add_to_group("debug_menu")
	visible = OS.is_debug_build()
	if _skip:
		_skip.pressed.connect(_on_skip)
	if _win:
		_win.pressed.connect(_on_win)
	if _gold:
		_gold.pressed.connect(_on_gold)
	if _collapse:
		_collapse.pressed.connect(_on_collapse)


func _find_battle() -> BattleContext:
	var root := get_tree().get_first_node_in_group("battle_root")
	if root and root.has_node("BattleContextBridge"):
		var bridge := root.get_node("BattleContextBridge") as BattleContextBridge
		return bridge.context if bridge else null
	return null


func _on_skip() -> void:
	var ctx := _find_battle()
	if ctx and ctx.wave_manager:
		ctx.wave_manager.current_wave_index = ctx.level_data.waves.size() - 2
		ctx.wave_manager._spawn_next_wave()


func _on_win() -> void:
	var ctx := _find_battle()
	if ctx and ctx.state_controller:
		ctx.state_controller.trigger_victory("debug")


func _on_gold() -> void:
	var ctx := _find_battle()
	if ctx and ctx.economy:
		ctx.economy.add_gold(100)


func _on_collapse() -> void:
	var ctx := _find_battle()
	if ctx and ctx.map_light:
		ctx.map_light.apply_corruption_pressure("region_north", 120.0)
