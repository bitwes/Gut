#-------------------------------------------------------------------------------
# All of these tests require some amount of user interaction or verifying of the
# output.
#-------------------------------------------------------------------------------
extends "res://addons/gut/test.gd"

class TimedSignaler:
	extends Node2D

	signal the_signal
	var _timer = null

	func _ready():
		_timer = Timer.new()
		add_child(_timer)
		_timer.connect('timeout', self, '_on_timer_timeout')
		_timer.one_shot = true

	func _on_timer_timeout():
		emit_signal('the_signal')

	func emit_after(time):
		_timer.set_wait_time(time)
		_timer.start()

var timer = null


func before_all():
	timer = Timer.new()
	add_child(timer)
	timer.set_wait_time(1)
	timer.set_one_shot(true)

func before_each():
	timer.set_wait_time(1)

func test_can_yield_using_built_in_timer():
	gut.p('yielding for 1 second')
	yield(gut.set_yield_time(1), 'timeout')
	gut.p('done yielding')

func test_setting_yield_time_twice_resets_time():
	gut.p('yielding for 1 second')
	gut.set_yield_time(10)
	gut.set_yield_time(1)
	yield(gut, 'timeout')
	gut.p('done yielding')

func test_wait_for_continue_click():
	assert_eq(1, 1, 'some simple assert')
	gut.pause_before_teardown()

func test_can_pause_twice():
	assert_eq(2, 2, 'Another simple assert')
	gut.pause_before_teardown()

func test_will_wait_when_yielding():
	timer.set_wait_time(5)
	gut.p('yielding for 5 seconds')
	timer.start()
	yield(timer, 'timeout')
	gut.p('done yielding')

func test_can_pause_after_yielding():
	gut.p('yielding for 1 second')
	timer.start()
	yield(timer, 'timeout')
	gut.p('done yielding')
	gut.pause_before_teardown()

func test_can_call_pause_before_yielding():
	gut.pause_before_teardown()
	gut.p('yielding for 1 second')
	timer.start()
	yield(timer, 'timeout')
	gut.p('done yielding')

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

func test_passing_assert_ends_yield():
	yield(yield_for(0.5), YIELD)
	assert_true(true)

func test_failing_assert_ends_yield():
	yield(yield_for(0.5), YIELD)
	assert_false(true, 'This should fail.')

func test_pending_ends_yield():
	yield(yield_for(0.5), YIELD)
	pending('this is pending but should end test')

func test_can_yield_to_signal():
	var signaler = TimedSignaler.new()
	add_child(signaler)
	signaler.emit_after(.5)
	yield(yield_to(signaler, 'the_signal', 10), YIELD)
	assert_true(true, 'we got here')

func test_after_yield_to_gut_disconnects_from_signal():
	var signaler = TimedSignaler.new()
	add_child(signaler)
	signaler.emit_after(.5)
	yield(yield_to(signaler, 'the_signal', 1), YIELD)
	assert_false(signaler.is_connected('the_signal', gut, '_yielding_callback'))
	remove_child(signaler)

func test_yield_to__will_disconnect_after_yield_finishes_and_signal_wasnt_emitted():
	var signaler = TimedSignaler.new()
	add_child(signaler)
	yield(yield_to(signaler, 'the_signal', 1), YIELD)
	# Changing the yield to be deferred means that we have to wait again for
	# the deferred to kick in before checking this.
	yield(yield_for(.1), YIELD)
	assert_false(signaler.is_connected('the_signal', gut, '_yielding_callback'))
	remove_child(signaler)

func test_yield_to__will_wait_max_time():
	var signaler = TimedSignaler.new()
	add_child(signaler)
	yield(yield_to(signaler, 'the_signal', 2), YIELD)
	assert_true(true, 'we got here')
	remove_child(signaler)

func test_yield_to__will_stop_timer_when_signal_emitted():
	var signaler = TimedSignaler.new()
	add_child(signaler)
	signaler.emit_after(.5)
	yield(yield_to(signaler, 'the_signal', 2), YIELD)
	assert_eq(gut._yield_timer.time_left, 0.0)
	remove_child(signaler)

func test_yield_to__watches_signals():
	var signaler = TimedSignaler.new()
	add_child(signaler)
	watch_signals(signaler)
	signaler.emit_after(.5)
	yield(yield_to(signaler, 'the_signal', 5), YIELD)
	assert_signal_emitted(signaler, 'the_signal')
	remove_child(signaler)

func test_what_is_wrong():
	var signaler = TimedSignaler.new()
	add_child(signaler)
	watch_signals(signaler)
	signaler.emit_after(0.5)
	yield(yield_for(1), YIELD)
	assert_signal_emitted(signaler, 'the_signal')

func test_with_parameters(p=use_parameters([['a', 'a'], ['b', 'b'], ['c', 'c']])):
	yield(yield_for(1), YIELD)
	assert_eq(p[0], p[1])

func test_can_pause_between_each_parameterized_test(p=use_parameters([1, 2, 3])):
	assert_between(p, -10, 10)
	pause_before_teardown()
