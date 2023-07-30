extends GutInternalTester


class TestLogging:
	extends GutInternalTester

	var _gut = null

	func before_each():
		_gut = Gut.new()
		_gut._should_print_versions = false
		_gut.log_level = 0
		add_child(_gut)

	func after_each():
		remove_child(_gut)

	func test_gut_sets_doublers_logger():
		assert_eq(_gut.get_doubler().get_logger(), _gut.logger, 'Doubler logger')
		assert_eq(_gut.get_doubler()._method_maker.get_logger(), _gut.logger, 'MethodMaker logger')

	func test_gut_sets_stubber_logger():
		assert_eq(_gut.get_stubber().get_logger(), _gut.logger)

	# This test makes assertion using THIS test script instance since it would
	# be super hard to get a test object that was being run.
	func test_gut_sets_logger_on_tests():
		assert_eq(gut.logger, get_logger())

	func test_gut_sets_logger_on_test_collector():
		assert_eq(_gut._test_collector.get_logger(), _gut.logger)

	func test_gut_sets_logger_on_spy():
		assert_eq(_gut.get_spy().get_logger(), _gut.logger)

	func test_method_maker_has_same_logger():
		var mm = _gut.get_doubler()._method_maker
		assert_eq(mm.get_logger(), _gut.logger)

	func test_test_colledtor_has_same_logger():
		assert_eq(_gut.get_test_collector().get_logger(), _gut.logger)
