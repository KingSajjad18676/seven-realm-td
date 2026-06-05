class_name BossControllerFactory
extends RefCounted

## Returns a boss brain for stable enemy_id values.


static func create(enemy_id: String) -> RefCounted:
	match enemy_id:
		"enemy_lion_boss":
			return LionBossController.new()
		"enemy_thirst_manifest":
			return ThirstBossController.new()
		"enemy_azhdaha":
			return AzhdahaBossController.new()
		"enemy_sorceress":
			return SorceressBossController.new()
		"enemy_olad_champion":
			return OladBossController.new()
		"enemy_arzhang_div":
			return ArzhangBossController.new()
		"enemy_white_div":
			return WhiteDivBossController.new()
		"enemy_zahhak":
			return ZahhakBossController.new()
		_:
			return LionBossController.new()
