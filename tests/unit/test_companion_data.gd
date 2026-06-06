extends GutTest


func test_shrine_companions_exist() -> void:
	for companion_id in CompanionPickHelper.SHRINE_COMPANION_IDS:
		var found := false
		for companion in ContentCatalog.build_companions():
			if companion.companion_id == companion_id:
				found = true
				assert_true(companion.is_shrine_pick(), companion_id)
				break
		assert_true(found, companion_id)


func test_build_companions_fallback() -> void:
	var built := ContentCatalog.build_companions()
	assert_eq(built.size(), 3)
