extends GutTest


class TestDefaults:
	extends GutTest

	func test_gut_uses_utils_error_tracker_by_default():
		var g = autofree(GutMain.new())
		assert_eq(g.error_tracker, GutUtils.get_error_tracker())


class TestStuff:
	extends GutInternalTester

	var _gut = null

	func before_all():
		gut.error_tracker.disabled = true
		verbose = false
		DynamicGutTest.should_print_source = verbose


	func before_each():
		_gut = add_child_autofree(new_gut(verbose))
		OS.add_logger(_gut.error_tracker)


	func after_each():
		OS.remove_logger(_gut.error_tracker)


	func after_all():
		gut.error_tracker.disabled = false

	var _src_push_error = """
	func test_with_push_error():
		push_error('pushed error')
		assert_true(true, 'passing assert')
	"""

	var _src_gut_error = """
	func test_with_gut_error():
		_lgr.error('this is a gut error')
		assert_true(true, 'passing assert')
	"""

	var _src_script_error_in_called_method = """
	func divide_them(a, b):
		return a / b

	func test_with_script_error():
		divide_them('one', 44)
		assert_true(true, 'passing assert')
	"""

	# this one has to fool the parser with "get_first" otherwise the parser
	# will catch it and it errors on making the script.
	var _src_script_error_in_test = """
	func get_first():
		return "one"

	func test_with_script_error():
		var a = get_first() / 44
		assert_true(true, 'passing assert')
	"""

	func test_push_error_causes_failure():
		var s = autofree(DynamicGutTest.new())
		s.add_source(_src_push_error)
		var t = s.run_test_in_gut(_gut)
		assert_eq(t.failing, 1, 'one failing')
		assert_eq(t.passing, 1, 'one passing')


	func test_pushed_errors_included_in_summary_error_count():
		var s = DynamicGutTest.new()
		s.add_source(_src_push_error)
		var t = s.run_test_in_gut(_gut)

		assert_eq(t.errors, 1, 'one error')


	func test_gut_error_causes_failure():
		var s = autofree(DynamicGutTest.new())
		s.add_source(_src_gut_error)
		var t = s.run_test_in_gut(_gut)
		assert_eq(t.failing, 1, 'one failing')
		assert_eq(t.passing, 1, 'one passing')


	func test_script_error_causes_failure():
		var s = autofree(DynamicGutTest.new())
		s.add_source(_src_script_error_in_called_method)
		var t = s.run_test_in_gut(_gut)
		assert_eq(t.failing, 1, 'one failing')
		assert_eq(t.passing, 1, 'one passing')


	func test_script_error_in_test_causes_failure():
		var s = autofree(DynamicGutTest.new())
		s.add_source(_src_script_error_in_test)
		var t = s.run_test_in_gut(_gut)
		assert_eq(t.failing, 1, 'one failing')
		assert_eq(t.passing, 0, 'no passing because of early exit from error')


