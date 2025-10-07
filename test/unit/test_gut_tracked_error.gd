extends GutInternalTester

func test_can_make_one():
	var gte = GutTrackedError.new()
	assert_not_null(gte)


func test_contains_text_true_when_code_contains_text():
	var gte = GutTrackedError.new()
	gte.code = 'look here'
	assert_true(gte.contains_text('ok he'))


func test_contains_text_true_when_rationale_has_text():
	var gte = GutTrackedError.new()
	gte.rationale = 'ok, I looked'
	assert_true(gte.contains_text(', i '))


# -------------
# push_error
# -------------
func test_is_push_error_false_by_default():
	var gte = GutTrackedError.new()
	assert_false(gte.is_push_error())


func test_is_push_error_true_when_function_is_push_error():
	var gte = GutTrackedError.new()
	gte.function = "push_error"
	assert_true(gte.is_push_error())


func test_push_error_name():
	var gte = GutTrackedError.new()
	gte.function = "push_error"
	assert_eq(gte.get_error_type_name(), 'push_error')


# -------------
# engine error
# -------------
func test_is_engine_error_false_by_default():
	var gte = GutTrackedError.new()
	assert_false(gte.is_engine_error())


func test_is_engine_error_when_it_has_correct_error_type_and_not_push():
	var gte = GutTrackedError.new()
	gte.function = 'some_function_somewhere'
	gte.error_type = 0
	assert_true(gte.is_engine_error())


func test_is_engine_error_false_when_push_warning():
	var gte = GutTrackedError.new()
	gte.function = 'push_warning'
	assert_false(gte.is_engine_error())


func test_engine_error_name():
	var gte = GutTrackedError.new()
	gte.function = 'some_function_somewhere'
	gte.error_type = 1
	assert_eq(gte.get_error_type_name(), 'engine-1')


# -------------
# push_warning
# -------------
func test_is_push_warning_false_by_default():
	var gte = GutTrackedError.new()
	assert_false(gte.is_push_warning())


func test_is_push_warning_true_when_function_is_push_warning():
	var gte = GutTrackedError.new()
	gte.function = 'push_warning'
	assert_true(gte.is_push_warning())


func test_push_warning_name():
	var gte = GutTrackedError.new()
	gte.function = 'push_warning'
	assert_eq(gte.get_error_type_name(), 'push_warning')