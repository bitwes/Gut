extends GutTest

func test_push_warning():
	push_warning("Warning, live without warning")
	assert_false(is_passing() and is_failing(), "no status")
	assert_engine_error_count(0)


func test_external_push_warning():
	var f = func():
		push_warning('May impare your ability to operate machinery')

	f.call()

	assert_false(is_passing() and is_failing(), "no status")
	assert_engine_error_count(0)


func do_a_warning():
	push_warning("Get your philosophy from a bumper sticker")


func test_warn_from_another_method():
	do_a_warning()
	assert_false(is_passing() and is_failing(), "no status")
	assert_engine_error_count(0)


func test_fails_because_error_already_handled():
	push_error("This is a push error")
	# This marks the error as handled.
	assert_push_error_count(1)
	# This will fail because GUT cannot find a matching unhandled error
	assert_push_error("is a push")


func divide_wrecklessly(top, bottom):
	return top / bottom


func assign_a_to_string_and_b_to_int(a, b):
	var string_a : String = a
	var int_b : int = b


func test_demo_engine_type_error():
	assign_a_to_string_and_b_to_int(Object.new(), 'asdf')
	divide_wrecklessly('some words', Node)


func test_demo_push_error():
	push_error("This is a push error")
	assert_push_error_count(1)


func test_demo_assert_push_error_count():
	push_error("This is a push error")
	assert_push_error_count(1)

func test_demo_assert_push_error():
	push_error("This is a push error")
	assert_push_error("this is")
