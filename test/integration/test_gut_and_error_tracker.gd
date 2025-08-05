extends GutTest


class TestDefaults:
	extends GutInternalTester

	func test_gut_uses_utils_error_tracker_by_default():
		var g = autofree(Gut.new(GutLogger.new()))
		assert_eq(g.error_tracker, GutUtils.get_error_tracker())




class TestErrorFailures:
	extends GutInternalTester

	func should_skip_script():
		return skip_if_debugger_active()

	var _gut = null

	func before_all():
		gut.error_tracker.disabled = true
		verbose = false
		DynamicGutTest.should_print_source = verbose


	func before_each():
		_gut = add_child_autofree(new_gut(verbose))
		GutErrorTracker.register_logger(_gut.error_tracker)


	func after_each():
		GutErrorTracker.deregister_logger(_gut.error_tracker)


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




class TestErrorAsserts:
	extends GutInternalTester

	func should_skip_script():
		return skip_if_debugger_active()

	var _gut = null

	func before_all():
		verbose = false
		gut.error_tracker.disabled = true
		DynamicGutTest.should_print_source = verbose


	func before_each():
		_gut = add_child_autofree(new_gut(verbose))
		GutErrorTracker.register_logger(_gut.error_tracker)


	func after_each():
		GutErrorTracker.deregister_logger(_gut.error_tracker)


	func after_all():
		gut.error_tracker.disabled = false


	var _src_divide_them = """
	func divide_them(a, b):
		return a / b
	"""

# ---------------------
# Push error count
# ---------------------
	func test_asserting_one_push_error_prevents_failure():
		var test_func = func(me):
			push_error('error 1')
			me.assert_push_error(1)

		var s = autofree(DynamicGutTest.new())
		s.add_lambda_test(test_func, 'test_something')

		var t = s.run_test_in_gut(_gut)
		assert_eq(t.passing, 1)


	func test_asserting_two_push_error_prevents_failure():
		var test_func = func(me):
			push_error('error 1')
			push_error('error 2')
			me.assert_push_error(2)

		var s = autofree(DynamicGutTest.new())
		s.add_lambda_test(test_func, 'test_something')

		var t = s.run_test_in_gut(_gut)
		assert_eq(t.passing, 1)


	func test_asserting_non_matching_push_error_causes_failure():
		var test_func = func(me):
			push_error('error 1')
			push_error('error 2')
			push_error('error 3')
			me.assert_push_error(1)

		var s = autofree(DynamicGutTest.new())
		s.add_lambda_test(test_func, 'test_something')

		var t = s.run_test_in_gut(_gut)
		# 2 failures, one for assert and one for the unexpected errors that
		# were not handled by the assert
		assert_eq(t.failing, 2)
# ---------------------
# Push error text
# ---------------------
	func test_push_error_with_matching_text_prevents_failure():
		var test_func = func(me):
			push_error('_special_ text')
			me.assert_push_error('_special_')

		var s = autofree(DynamicGutTest.new())
		s.add_lambda_test(test_func, 'test_something')

		var t = s.run_test_in_gut(_gut)
		assert_eq(t.passing, 1)

	func test_push_error_with_non_matching_text_fails():
		var test_func = func(me):
			push_error('_special_ text')
			me.assert_push_error('nope')

		var s = autofree(DynamicGutTest.new())
		s.add_lambda_test(test_func, 'test_something')

		var t = s.run_test_in_gut(_gut)
		assert_eq(t.failing, 2)

	func test_push_error_with_matching_text_only_consumes_one():
		var test_func = func(me):
			push_error('_special_ one')
			push_error('_special_ two')
			me.assert_push_error('_special_')

		var s = autofree(DynamicGutTest.new())
		s.add_lambda_test(test_func, 'test_something')

		var t = s.run_test_in_gut(_gut)
		assert_eq(t.passing, 1)
		assert_eq(t.failing, 1)

	func test_push_error_can_assert_multiple_different_texts():
		var test_func = func(me):
			push_error('_special_ one')
			push_error('_special_ two')
			me.assert_push_error('one')
			me.assert_push_error('two')

		var s = autofree(DynamicGutTest.new())
		s.add_lambda_test(test_func, 'test_something')

		var t = s.run_test_in_gut(_gut)
		assert_eq(t.passing, 2)
		assert_eq(t.failing, 0)

# ---------------------
# Engine error count
# ---------------------
	func test_asserting_engine_error_prevents_failure():
		var test_func = func(me):
			me.divide_them(1, 'b')
			me.assert_engine_error(1)

		var s = autofree(DynamicGutTest.new())
		s.add_source(_src_divide_them)
		s.add_lambda_test(test_func, 'test_something')

		var t = s.run_test_in_gut(_gut)
		assert_eq(t.passing, 1)

	func test_asserting_multiple_engine_error_prevents_failure():
		var test_func = func(me):
			me.divide_them(1, 'b')
			me.divide_them(1, 'b')
			me.divide_them(1, 'b')
			me.assert_engine_error(3)

		var s = autofree(DynamicGutTest.new())
		s.add_source(_src_divide_them)
		s.add_lambda_test(test_func, 'test_something')

		var t = s.run_test_in_gut(_gut)
		assert_eq(t.passing, 1)

	func test_asserting_non_matching_count_causes_two_failures():
		var test_func = func(me):
			me.divide_them(1, 'b')
			me.divide_them(1, 'b')
			me.divide_them(1, 'b')
			me.assert_engine_error(2)

		var s = autofree(DynamicGutTest.new())
		s.add_source(_src_divide_them)
		s.add_lambda_test(test_func, 'test_something')

		var t = s.run_test_in_gut(_gut)
		# 2 failures, one for assert and one for the unexpected errors that
		# were not handled by the assert
		assert_eq(t.failing, 2)


# ---------------------
# Engine error text
# ---------------------
	func test_engine_with_matching_text_prevents_failure():
		var test_func = func(me):
			me.divide_them(1, 'b')
			me.assert_engine_error('Invalid operands')

		var s = autofree(DynamicGutTest.new())
		s.add_source(_src_divide_them)
		s.add_lambda_test(test_func, 'test_something')

		var t = s.run_test_in_gut(_gut)
		assert_eq(t.passing, 1)

	func test_engine_with_non_matching_text_fails():
		var test_func = func(me):
			me.divide_them(1, 'b')
			me.assert_engine_error('nope')

		var s = autofree(DynamicGutTest.new())
		s.add_source(_src_divide_them)
		s.add_lambda_test(test_func, 'test_something')

		var t = s.run_test_in_gut(_gut)
		assert_eq(t.failing, 2)

	func test_engine_with_matching_text_only_consumes_one():
		var test_func = func(me):
			me.divide_them(1, 'b')
			me.divide_them(1, 'b')
			me.assert_engine_error('Invalid operands')

		var s = autofree(DynamicGutTest.new())
		s.add_source(_src_divide_them)
		s.add_lambda_test(test_func, 'test_something')

		var t = s.run_test_in_gut(_gut)
		assert_eq(t.passing, 1)
		assert_eq(t.failing, 1)

	func test_engine_can_assert_multiple_different_texts():
		var test_func = func(me):
			me.divide_them(1, 'b')
			me.divide_them(1, 0)
			me.assert_engine_error('Invalid operands')
			me.assert_engine_error('Division by zero')

		var s = autofree(DynamicGutTest.new())
		s.add_source(_src_divide_them)
		s.add_lambda_test(test_func, 'test_something')

		var t = s.run_test_in_gut(_gut)
		assert_eq(t.passing, 2)
		assert_eq(t.failing, 0)



# ---------------------
# misc
# ---------------------
	func test_can_assert_multiple_error_types():
		var test_func = func(me):
			me.divide_them(1, 'b')
			me.divide_them(1, 'b')
			push_error('push error 1')
			me.assert_engine_error(2)
			me.assert_push_error(1)

		var s = autofree(DynamicGutTest.new())
		s.add_source(_src_divide_them)
		s.add_lambda_test(test_func, 'test_something')

		var t = s.run_test_in_gut(_gut)
		assert_eq(t.passing, 2)


# ---------------------
# get_errors
# ---------------------
	func test_can_get_all_errors_that_occur():
		var test_func = func(me):
			me.divide_them(1, 'b')
			me.divide_them(1, 'b')
			push_error('pushe error 1')
			var errs = me.get_errors()
			me.assert_eq(errs.size(), 3)

		var s = autofree(DynamicGutTest.new())
		s.add_source(_src_divide_them)
		s.add_lambda_test(test_func, 'test_something')

		var t = s.run_test_in_gut(_gut)
		assert_eq(t.passing, 1, 'pass count')
		# Errors are not consumed so they still cause errors.
		assert_eq(t.failing, 1, 'fail count')


	func test_can_mark_all_errors_handled_manually():
		var test_func = func(me):
			me.divide_them(1, 'b')
			me.divide_them(1, 'b')
			push_error('pushe error 1')
			var errs = me.get_errors()
			me.assert_eq(errs.size(), 3)
			for e in errs:
				e.handled = true

		var s = autofree(DynamicGutTest.new())
		s.add_source(_src_divide_them)
		s.add_lambda_test(test_func, 'test_something')

		var t = s.run_test_in_gut(_gut)
		assert_eq(t.passing, 1, 'pass count')
		# Errors are not consumed so they still cause errors.
		assert_eq(t.failing, 0, 'fail count')


	func test_parameterized_tests_do_not_compound_error_counts():
		var src_test_with_params = """
		var params = [1, 2, 3, 4, 5]
		func test_parameterized_and_errors(p=use_parameters(params)):
			push_error(str("Error ", p))
			assert_push_error(1)
		"""

		var s = autofree(DynamicGutTest.new())
		s.add_source(src_test_with_params)

		var t = s.run_test_in_gut(_gut)
		assert_eq(t.passing, 5, '5 params, 1 assert each: pass count')
		assert_eq(t.failing, 0, 'fail count')

