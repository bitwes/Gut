extends GutInternalTester

func _make_gut_config():
	var gc = GutUtils.GutConfig.new()
	gc.logger = GutUtils.GutLogger.new()
	if(gut.log_level < 2):
		gc.logger.disable_all_printers(true)
	gc.logger.set_gut(gut)
	return gc


func test_can_make_one():
	var gc = GutUtils.GutConfig.new()
	assert_not_null(gc)


func test_double_strategy_defaults_to_include_native():
	var gc = GutUtils.GutConfig.new()
	assert_eq(gc.default_options.double_strategy, 'SCRIPT_ONLY')


func test_all_error_types_are_treated_as_errors_by_default():
	var gc = GutUtils.GutConfig.new()

	var expected_values = [gc.FAIL_ERROR_TYPE_ENGINE, gc.FAIL_ERROR_TYPE_GUT, gc.FAIL_ERROR_TYPE_PUSH_ERROR]
	for val in expected_values:
		assert_has(gc.default_options.failure_error_types, val, str('failure_error_types has ', val))

	assert_eq(gc.default_options.failure_error_types.size(), expected_values.size(), 'number of elements')


func test_errors_when_config_file_cannot_be_found():
	var gc = _make_gut_config()
	gc.load_options('res://some_file_that_dne.json')
	assert_tracked_gut_error(gc, 1)


func test_does_not_error_when_default_file_missing():
	var gc = _make_gut_config()
	gc.load_options('res://.gutconfig.json')
	pass_test('no errors should have occurred')


func test_does_not_error_when_default_editor_file_missing():
	var gc = _make_gut_config()
	gc.load_options(GutUtils.EditorGlobals.editor_run_gut_config_path)
	assert_tracked_gut_error(gc, 0)


func test_errors_when_file_cannot_be_parsed():
	var gc = _make_gut_config()
	gc.load_options('res://addons/gut/gut.gd')
	assert_tracked_gut_error(gc)


func test_errors_when_path_cannot_be_written_to():
	var gc = _make_gut_config()
	gc.write_options("user://some_path/that_does/not_exist/dot.json")
	assert_tracked_gut_error(gc)


class TestApplyOptions:
	extends GutInternalTester

	func test_gut_gets_double_strategy_when_applied():
		var gc = GutUtils.GutConfig.new()
		var g = autofree(new_gut(verbose))
		g.log_level = gut.log_level

		gc.options.double_strategy = GutUtils.DOUBLE_STRATEGY.SCRIPT_ONLY
		gc.apply_options(g)
		assert_eq(g.double_strategy, gc.options.double_strategy)


	func test_gut_gets_default_when_value_invalid():
		var gc = GutUtils.GutConfig.new()
		var g = autofree(new_gut(verbose))
		g.log_level = gut.log_level

		g.double_strategy = GutUtils.DOUBLE_STRATEGY.SCRIPT_ONLY
		gc.options.double_strategy = 'invalid value'
		gc.apply_options(g)
		assert_eq(g.double_strategy, GutUtils.DOUBLE_STRATEGY.SCRIPT_ONLY)


	func test_failure_error_type_engine_sets_error_tracker_option_true_when_it_exists():
		var gc = GutUtils.GutConfig.new()
		var g = autofree(new_gut(verbose))

		gc.options.failure_error_types = [gc.FAIL_ERROR_TYPE_ENGINE]
		gc.apply_options(g)

		assert_eq(g.error_tracker.treat_engine_errors_as, GutUtils.TREAT_AS.FAILURE)


	func test_failure_error_type_engine_sets_error_tracker_option_false_when_missing():
		var gc = GutUtils.GutConfig.new()
		var g = autofree(new_gut(verbose))

		gc.options.failure_error_types = []
		gc.apply_options(g)

		assert_eq(g.error_tracker.treat_engine_errors_as, GutUtils.TREAT_AS.NOTHING)


	func test_failure_error_type_push_error_sets_error_tracker_option_true_when_it_exists():
		var gc = GutUtils.GutConfig.new()
		var g = autofree(new_gut(verbose))

		gc.options.failure_error_types = [gc.FAIL_ERROR_TYPE_PUSH_ERROR]
		gc.apply_options(g)

		assert_eq(g.error_tracker.treat_push_error_as, GutUtils.TREAT_AS.FAILURE)


	func test_failure_error_type_push_error_sets_error_tracker_option_false_when_missing():
		var gc = GutUtils.GutConfig.new()
		var g = autofree(new_gut(verbose))

		gc.options.failure_error_types = []
		gc.apply_options(g)

		assert_eq(g.error_tracker.treat_push_error_as, GutUtils.TREAT_AS.NOTHING)


	func test_failure_error_type_gut_sets_error_tracker_option_true_when_it_exists():
		var gc = GutUtils.GutConfig.new()
		var g = autofree(new_gut(verbose))

		gc.options.failure_error_types = [gc.FAIL_ERROR_TYPE_GUT]
		gc.apply_options(g)

		assert_eq(g.error_tracker.treat_gut_errors_as, GutUtils.TREAT_AS.FAILURE)


	func test_failure_error_type_gut_sets_error_tracker_option_false_when_missing():
		var gc = GutUtils.GutConfig.new()
		var g = autofree(new_gut(verbose))

		gc.options.failure_error_types = []
		gc.apply_options(g)

		assert_eq(g.error_tracker.treat_gut_errors_as, GutUtils.TREAT_AS.NOTHING)


	func test_errors_do_not_cause_failure_is_deprecated():
		var gc = GutUtils.GutConfig.new()
		var g = autofree(new_gut(verbose))
		gc.logger = g.logger

		gc.options.errors_do_not_cause_failure = true
		gc.apply_options(g)
		assert_deprecated(gc)


