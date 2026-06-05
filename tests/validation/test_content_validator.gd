extends GutTest


func test_bootstrap_catalog_has_no_errors() -> void:
	var catalog := ContentTestUtils.build_catalog()
	var errors := ContentValidator.validate(catalog)
	assert_true(errors.is_empty(), "expected no validation errors, got: %s" % str(errors))


func test_invalid_catalog_reports_missing_enemy() -> void:
	var catalog := ContentTestUtils.make_invalid_catalog()
	var errors := ContentValidator.validate(catalog)
	var found := false
	for err in errors:
		if "enemy_missing" in err:
			found = true
			break
	assert_true(found, "expected unknown enemy error")
	assert_true(errors.size() >= 3, "expected multiple validation failures")


func test_duplicate_ids_reported() -> void:
	var catalog := BootstrapContent.new()
	var tower_a := TowerData.new()
	tower_a.tower_id = "tower_dup"
	var tower_b := TowerData.new()
	tower_b.tower_id = "tower_dup"
	catalog.towers = [tower_a, tower_b]
	var errors := ContentValidator.validate(catalog)
	var found := false
	for err in errors:
		if "duplicate tower" in err:
			found = true
			break
	assert_true(found)
