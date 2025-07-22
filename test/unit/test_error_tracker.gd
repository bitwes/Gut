extends GutTest

var _added_tracker = GutErrorTracker.new()

func before_all():
	OS.add_logger(_added_tracker)


func before_each():
	_added_tracker.errors.items.clear()


func after_all():
	OS.remove_logger(_added_tracker)

func _divide_these(a, b):
	return a / b

func _assert_a_equals_b(a, b):
	assert(a == b)


func test_can_make_one():
	var inst = GutErrorTracker.new()
	assert_not_null(inst)



func test_add_gut_error_adds_error_to_none():
	var inst = GutErrorTracker.new()
	var err = inst.add_gut_error('this is an error')

	assert_eq(err.code, 'this is an error', 'code')
	assert_eq(err.error_type, GutErrorTracker.GUT_ERROR_TYPE, 'error_type')
	assert_true(err.is_gut_error(), 'is_gut_error')
	assert_eq(err.get_error_category(), GutErrorTracker.ERROR_CATEGORY.GUT, 'category')
	assert_eq(inst.errors.items[GutErrorTracker.NO_TEST][0], err, 'tracked')
	assert_false(err.is_engine_error(), 'is_engine_error')


func test_when_adding_gut_error_during_a_test_addtional_info_filled_in():
	var inst = GutErrorTracker.new()
	inst.start_test('test_when_adding_gut_error_during_a_test_addtional_info_filled_in')
	var err = inst.add_gut_error('error in a test')

	assert_eq(err.function, 'test_when_adding_gut_error_during_a_test_addtional_info_filled_in')
	assert_eq(err.file, "res://test/unit/test_error_tracker.gd")
	assert_eq(err.line, 44, 'this can break if this file changes')
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


func test_assert_fails_data():
	_assert_a_equals_b('foo', 'bar')
	var last_error = _added_tracker.errors.items[GutErrorTracker.NO_TEST][0]
	assert_not_null(last_error)
	assert_true(last_error.is_assert())