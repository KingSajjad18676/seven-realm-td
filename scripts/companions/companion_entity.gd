class_name CompanionEntity
extends CharacterBody2D

var data: CompanionData = null
var context: BattleContext = null

@onready var _sprite: ColorRect = $Sprite
@onready var _hp_bar: ProgressBar = $HPBar


func setup(ctx: BattleContext, companion_data: CompanionData) -> void:
	context = ctx
	data = companion_data
	z_index = 9
	if _sprite and data:
		_sprite.color = data.color
	var sprite_path := data.sprite_path if data else ""
	if sprite_path != "":
		VisualAssetLoader.apply_sprite(self, sprite_path, data.color, Vector2(24, 24))


func collects_material_drops() -> bool:
	return data != null and data.behavior == CompanionData.Behavior.CHEETAH_SCAVENGER
