extends GutTest


func test_known_boss_ids_return_expected_types() -> void:
	assert_is(BossControllerFactory.create("enemy_lion_boss"), LionBossController)
	assert_is(BossControllerFactory.create("enemy_thirst_manifest"), ThirstBossController)
	assert_is(BossControllerFactory.create("enemy_azhdaha"), AzhdahaBossController)
	assert_is(BossControllerFactory.create("enemy_sorceress"), SorceressBossController)
	assert_is(BossControllerFactory.create("enemy_olad_champion"), OladBossController)
	assert_is(BossControllerFactory.create("enemy_arzhang_div"), ArzhangBossController)
	assert_is(BossControllerFactory.create("enemy_white_div"), WhiteDivBossController)
	assert_is(BossControllerFactory.create("enemy_zahhak"), ZahhakBossController)


func test_unknown_enemy_falls_back_to_lion() -> void:
	assert_is(BossControllerFactory.create("enemy_unknown"), LionBossController)
