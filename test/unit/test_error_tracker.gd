extends GutTest

var _added_tracker


func before_each():
	_added_tracker = GutErrorTracker.new()
	OS.add_logger(_added_tracker)
	_added_tracker.errors.items.clear()


func after_each():
	OS.remove_logger(_added_tracker)
	_added_tracker = null


func _divide_these(a, b):
	return a / b

func _assert_a_equals_b(a, b, extra_text):
	assert(a == b, extra_text)


func test_can_make_one():
	var inst = GutErrorTracker.new()
	assert_not_null(inst)


func test_add_gut_error_adds_error_to_none():
	var inst = GutErrorTracker.new()
	var err = inst.add_gut_error('this is an error')

	assert_eq(err.code, 'this is an error', 'code')
	assert_eq(err.error_type, GutErrorTracker.GUT_ERROR_TYPE, 'error_type')
	assert_true(err.is_gut_error(), 'is_gut_error')
	assert_eq(inst.errors.items[GutErrorTracker.NO_TEST][0], err, 'tracked')
	assert_false(err.is_engine_error(), 'is_engine_error')


func test_when_adding_gut_error_during_a_test_addtional_info_filled_in():
	var inst = GutErrorTracker.new()
	inst.start_test('test_when_adding_gut_error_during_a_test_addtional_info_filled_in')
	var err = inst.add_gut_error('error in a test')

	assert_eq(err.function, 'test_when_adding_gut_error_during_a_test_addtional_info_filled_in')
	assert_eq(err.file, "res://test/unit/test_error_tracker.gd")
	# use between because the line number keeps changing as I work and a range
	# is a good enough check that we are getting an expected value back.
	assert_between(err.line, 40, 60, 'this can break if this file changes')
	assert_eq(err.backtrace[0].function, 'test_when_adding_gut_error_during_a_test_addtional_info_filled_in')


func test_when_engine_error_data():
	_divide_these(22, 'foo')
	var last_error = _added_tracker.errors.items[GutErrorTracker.NO_TEST][0]
	assert_not_null(last_error)
	assert_true(last_error.is_engine_error())


func test_when_push_error_data():
	push_error("manually pushed error")
	var last_error = _added_tracker.errors.items[GutErrorTracker.NO_TEST][0]
	assert_not_null(last_error)
	assert_true(last_error.is_push_error())


# func test_assert_fails_data():
# 	_assert_a_equals_b('foo', 'bar', '')
# 	var err = _added_tracker.errors.items[GutErrorTracker.NO_TEST][0]
# 	assert_not_null(err)
# 	assert_true(err.is_assert())
# 	assert_eq(err.error_type, Logger.ERROR_TYPE_SCRIPT)


# func test_assert_fails_data_with_assert_text():
# 	_assert_a_equals_b('foo', 'bar', '')
# 	var err = _added_tracker.errors.items[GutErrorTracker.NO_TEST][0]
# 	assert_true(err.is_assert())


func test_should_fail_true_for_gut_error():
	_added_tracker.treat_gut_errors_as = GutErrorTracker.TREAT_AS.NOTHING
	_added_tracker.start_test('test')
	_added_tracker.add_gut_error('this is a gut error')
	assert_false(_added_tracker.should_test_fail_from_errors('test'))


func test_should_fail_true_for_gut_error_when_flag_set():
	# _added_tracker.treat_gut_errors_as = GutErrorTracker.TREAT_AS.FAILURE
	_added_tracker.start_test('test')
	_added_tracker.add_gut_error('this is a gut error')
	assert_true(_added_tracker.should_test_fail_from_errors('test'))


func test_should_fail_false_for_engine_error():
	_added_tracker.treat_engine_errors_as = GutErrorTracker.TREAT_AS.NOTHING
	_added_tracker.start_test('test')
	_divide_these('word', 'sentence')
	assert_false(_added_tracker.should_test_fail_from_errors('test'))


func test_should_fail_true_for_engine_error_when_flag_set():
	# _added_tracker.treat_engine_errors_as = GutErrorTracker.TREAT_AS.FAILURE
	_added_tracker.start_test('test')
	_divide_these('word', 'sentence')
	assert_true(_added_tracker.should_test_fail_from_errors('test'))


func test_should_fail_false_for_push_error():
	_added_tracker.treat_push_error_as = GutErrorTracker.TREAT_AS.NOTHING
	_added_tracker.start_test('test')
	push_error("this is a push error")
	assert_false(_added_tracker.should_test_fail_from_errors('test'))


func test_should_fail_true_for_push_error_when_flag_set():
	# _added_tracker.treat_push_error_as = GutErrorTracker.TREAT_AS.FAILURE
	_added_tracker.start_test('test')
	push_error("this is a push error")
	assert_true(_added_tracker.should_test_fail_from_errors('test'))


func test_should_fail_finds_second_error():
	# _added_tracker.treat_gut_errors_as = GutErrorTracker.TREAT_AS.FAILURE
	_added_tracker.start_test('test')
	push_error('this is the first error')
	_added_tracker.add_gut_error('this is a gut error')
	assert_true(_added_tracker.should_test_fail_from_errors('test'))


func test_should_fail_does_not_push_for_engine_error():
	_added_tracker.treat_push_error_as = GutErrorTracker.TREAT_AS.NOTHING
	_added_tracker.treat_gut_errors_as = GutErrorTracker.TREAT_AS.NOTHING
	_added_tracker.start_test('test')
	push_error('this is the first error')
	_added_tracker.add_gut_error('this is a gut error')
	assert_false(_added_tracker.should_test_fail_from_errors('test'))


# var fail_text_params = ParameterFactory.named_parameters(
# 	['error_fail', 'gut_fail', 'push_fail', 'do_error', 'do_push', 'do_gut'],
# 	[GutErrorTracker.TREAT_AS.FAILURE, GutErrorTracker.TREAT_AS.NOTHING, GutErrorTracker.TREAT_AS.NOTHING,
# 		true, false, false]
# )
# func test_fail_text(params=use_parameters(fail_text_params)):
# 	_added_tracker.treat_engine_errors_as = params.error_fail


func test_fail_text_includes_all_by_default():
	push_error('push nope')
	_added_tracker.add_gut_error('gut error nope')
	_divide_these('nope', 44)

	var error_text = _added_tracker.get_fail_text_for_errors()

	assert_string_contains(error_text, 'Invalid operands')
	assert_string_contains(error_text, 'gut error nope')
	assert_string_contains(error_text, 'push nope')


func test_fail_text_can_exclude_push():
	_added_tracker.treat_push_error_as = GutErrorTracker.TREAT_AS.NOTHING

	push_error('push nope')
	_added_tracker.add_gut_error('gut error nope')
	_divide_these('nope', 44)

	var error_text = _added_tracker.get_fail_text_for_errors()

	assert_string_contains(error_text, 'Invalid operands')
	assert_string_contains(error_text, 'gut error nope')
	assert_eq(error_text.find("push nope"), -1)


func test_fail_text_can_exclude_engine_error():
	_added_tracker.treat_engine_errors_as = GutErrorTracker.TREAT_AS.NOTHING

	push_error('push nope')
	_added_tracker.add_gut_error('gut error nope')
	_divide_these('nope', 44)

	var error_text = _added_tracker.get_fail_text_for_errors()

	assert_eq(error_text.find('Invalid operands'), -1)
	assert_string_contains(error_text, 'gut error nope')
	assert_string_contains(error_text, 'push nope')


func test_fail_text_can_exclude_gut_error():
	_added_tracker.treat_gut_errors_as = GutErrorTracker.TREAT_AS.NOTHING

	push_error('push nope')
	_added_tracker.add_gut_error('gut error nope')
	_divide_these('nope', 44)

	var error_text = _added_tracker.get_fail_text_for_errors()

	assert_string_contains(error_text, 'Invalid operands')
	assert_eq(error_text.find('gut error nope'), -1)
	assert_string_contains(error_text, 'push nope')
