extends GutTest

func test_push_warning():
	push_warning("Warning, live without warning")
	assert_false(is_passing() and is_failing(), "no status")
	assert_engine_error(0)


func test_external_push_warning():
	var f = func():
		push_warning('May impare your ability to operate machinery')

	f.call()

	assert_false(is_passing() and is_failing(), "no status")
	assert_engine_error(0)


func do_a_warning():
	push_warning("Get your philosophy from a bumper sticker")


func test_warn_from_another_method():
	do_a_warning()
	assert_false(is_passing() and is_failing(), "no status")
	assert_engine_error(0)