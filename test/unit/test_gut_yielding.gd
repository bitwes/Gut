#-------------------------------------------------------------------------------
# All of these tests require some amount of user interaction or verifying of the
# output so they were moved into a different script for testing.
#-------------------------------------------------------------------------------
extends "res://addons/gut/test.gd"

var timer = Timer.new()

func prerun_setup():
	add_child(timer)
	timer.set_wait_time(1)
	timer.set_one_shot(true)

func setup():
	timer.set_wait_time(1)

func test_can_yield_using_built_in_timer():
	gut.p('yielding for 1 second')
	yield(gut.set_yield_time(1), 'timeout')
	gut.p('done yielding')
	gut.end_yielded_test()

func test_setting_yield_time_twice_resets_time():
	gut.p('yielding for 1 second')
	gut.set_yield_time(10)
	gut.set_yield_time(1)
	yield(gut, 'timeout')
	gut.p('done yielding')
	gut.end_yielded_test()

func test_wait_for_continue_click():
	gut.assert_eq(1, 1, 'some simple assert')
	gut.pause_before_teardown()

func test_can_pause_twice():
	gut.assert_eq(2, 2, 'Another simple assert')
	gut.pause_before_teardown()

func test_will_wait_when_yielding():
	timer.set_wait_time(5)
	gut.p('yielding for 5 seconds')
	timer.start()
	yield(timer, 'timeout')
	gut.p('done yielding')
	gut.end_yielded_test()

func test_can_pause_after_yielding():
	gut.p('yielding for 1 second')
	timer.start()
	yield(timer, 'timeout')
	gut.p('done yielding')
	gut.end_yielded_test()
	gut.pause_before_teardown()

func test_can_call_pause_before_yielding():
	gut.pause_before_teardown()
	gut.p('yielding for 1 second')
	timer.start()
	yield(timer, 'timeout')
	gut.p('done yielding')
	gut.end_yielded_test()

func test_returning_int_does_not_cause_yield():
	return 9

func test_returning_string_does_not_cause_yield():
	return 'nine'

func test_returning_object_does_not_cause_yield():
	var thing = Node2D.new()
	return thing

func test_new_yield():
	yield(yield_for(1, 'first yield'), 'timeout')
	yield(yield_for(1, 'waiting around for stuff'), YIELD)
	end_test()

func test_passing_assert_ends_yield():
	yield(yield_for(0.5), YIELD)
	assert_true(true)

func test_failing_assert_ends_yield():
	yield(yield_for(0.5), YIELD)
	assert_false(true, 'This should fail.')

func test_pending_ends_yield():
	yield(yield_for(0.5), YIELD)
	pending('this is pending but should end test')
