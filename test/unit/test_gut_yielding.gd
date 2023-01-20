extends GutTest
#-------------------------------------------------------------------------------
# All of these tests require some amount of user interaction or verifying of the
# output.
#-------------------------------------------------------------------------------


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

class TimeSignalerParam:
	extends TimedSignaler

	var _emitted_param

	func _init(emitted_param = 1):
		_emitted_param = emitted_param

	func _on_timer_timeout():
		emit_signal('the_signal', _emitted_param)

class TimedSignalerMaxParams:
	extends TimedSignaler

	func _on_timer_timeout():
		emit_signal('the_signal', 1, 2, 3, 4, 5, 6, 7, 8, 9)


class TestPauseBeforeTeardown:
	extends "res://addons/gut/test.gd"
	var timer = null

	func before_all():
		timer = Timer.new()
		timer.set_one_shot(true)
		add_child(timer)

	func after_all():
		timer.free()

	func before_each():
		timer.set_wait_time(1)

	func test_wait_for_continue_click():
		gut.p('should have had to press continue')
		assert_eq(1, 1, 'some simple assert')
		gut.pause_before_teardown()

	func test_can_pause_twice():
		gut.p('should have had to press continue')
		assert_eq(2, 2, 'Another simple assert')
		gut.pause_before_teardown()

	func test_can_pause_after_yielding():
		pass_test('should have seen a pause and press continue')
		gut.p('yielding for 1 second')
		timer.start()
		yield(timer, 'timeout')
		gut.p('done yielding')
		gut.pause_before_teardown()

	func test_can_call_pause_before_yielding():
		pass_test('should  see a pause')
		gut.pause_before_teardown()
		gut.p('yielding for 1 second')
		timer.start()
		yield(timer, 'timeout')
		gut.p('done yielding')

	func test_can_pause_between_each_parameterized_test(p=use_parameters([1, 2, 3])):
		assert_between(p, -10, 10)
		pause_before_teardown()



class TestYieldsInTests:
	extends "res://addons/gut/test.gd"
	var timer = null

	func before_all():
		timer = Timer.new()
		add_child(timer)
		timer.set_wait_time(1)
		timer.set_one_shot(true)

	func after_all():
		timer.free()

	func before_each():
		timer.set_wait_time(1)

	func test_can_yield_using_built_in_timer():
		pass_test('should have seen a pause')
		gut.p('yielding for 1 second')
		yield(gut.set_yield_time(1), 'timeout')
		gut.p('done yielding')

	func test_setting_yield_time_twice_resets_time():
		pass_test('should have seen a pause')
		gut.p('yielding for 1 second')
		gut.set_yield_time(10)
		gut.set_yield_time(1)
		yield(gut, 'timeout')
		gut.p('done yielding')

	func test_will_wait_when_yielding():
		pass_test('should have seen a pause')
		timer.set_wait_time(5)
		gut.p('yielding for 5 seconds')
		timer.start()
		yield(timer, 'timeout')
		gut.p('done yielding')

	func test_returning_int_does_not_cause_yield():
		pass_test('this should not cause error')
		return 9

	func test_returning_string_does_not_cause_yield():
		pass_test('this should not cause error')
		return 'nine'

	func test_returning_object_does_not_cause_yield():
		pass_test('this should not cause error')
		var thing = autofree(Node2D.new())
		return thing

	func test_what_is_wrong():
		var signaler = add_child_autoqfree(TimedSignaler.new())
		watch_signals(signaler)
		signaler.emit_after(0.5)
		yield(yield_for(1), YIELD)
		assert_signal_emitted(signaler, 'the_signal')

	func test_with_parameters(p=use_parameters([['a', 'a'], ['b', 'b'], ['c', 'c']])):
		yield(yield_for(1), YIELD)
		assert_eq(p[0], p[1])



class TestYieldFor:
	extends "res://addons/gut/test.gd"

	func test_new_yield():
		pass_test('should  see two 1 second pauses')
		yield(yield_for(1, 'first yield'), 'timeout')
		yield(yield_for(1, 'waiting around for stuff'), YIELD)

	func test_passing_assert_ends_yield():
		yield(yield_for(0.5), YIELD)
		pass_test('yield should stop.')

	func test_failing_assert_ends_yield():
		yield(yield_for(0.5), YIELD)
		fail_test('yield should stop for this failure')

	func test_pending_ends_yield():
		yield(yield_for(0.5), YIELD)
		pending('this is pending but should end test')

	func test_output_for_long_yields():
		yield(yield_for(2), YIELD)
		pass_test('Visually check this')



class TestYieldTo:
	extends "res://addons/gut/test.gd"

	func test_can_yield_to_signal():
		var signaler = add_child_autoqfree(TimedSignaler.new())
		signaler.emit_after(.5)
		yield(yield_to(signaler, 'the_signal', 10), YIELD)
		pass_test('we got here')

	func test_after_yield_to_gut_disconnects_from_signal():
		var signaler = add_child_autoqfree(TimedSignaler.new())
		signaler.emit_after(.5)
		yield(yield_to(signaler, 'the_signal', 1), YIELD)
		assert_false(signaler.is_connected('the_signal', gut, '_yielding_callback'))

	func test_yield_to__will_disconnect_after_yield_finishes_and_signal_wasnt_emitted():
		var signaler = add_child_autoqfree(TimedSignaler.new())
		yield(yield_to(signaler, 'the_signal', 1), YIELD)
		# Changing the yield to be deferred means that we have to wait again for
		# the deferred to kick in before checking this.
		yield(yield_for(.1), YIELD)
		assert_false(signaler.is_connected('the_signal', gut, '_yielding_callback'))

	func test_yield_to__will_wait_max_time():
		var signaler = add_child_autoqfree(TimedSignaler.new())
		yield(yield_to(signaler, 'the_signal', 2), YIELD)
		pass_test('we got here')

	func test_yield_to__will_stop_timer_when_signal_emitted():
		var signaler = add_child_autoqfree(TimedSignaler.new())
		signaler.emit_after(.5)
		yield(yield_to(signaler, 'the_signal', 2), YIELD)
		assert_eq(gut._yield_timer.time_left, 0.0)

	func test_yield_to__watches_signals():
		var signaler = add_child_autoqfree(TimedSignaler.new())
		watch_signals(signaler)
		signaler.emit_after(.5)
		yield(yield_to(signaler, 'the_signal', 5), YIELD)
		assert_signal_emitted(signaler, 'the_signal')

	func test_yield_to_works_on_signals_with_parameters():
		var signaler = add_child_autoqfree(TimeSignalerParam.new())
		watch_signals(signaler)
		signaler.emit_after(.5)
		yield(yield_to(signaler, 'the_signal', 5), YIELD)
		assert_signal_emitted(signaler, 'the_signal')

	func test_yield_to_works_on_signals_with_max_parameters():
		var signaler = add_child_autoqfree(TimedSignalerMaxParams.new())
		watch_signals(signaler)
		signaler.emit_after(.5)
		yield(yield_to(signaler, 'the_signal', 5), YIELD)
		assert_signal_emitted(signaler, 'the_signal')

	func test_yield_to_works_on_signals_that_emit_false():
		var signaler = add_child_autoqfree(TimeSignalerParam.new(false))
		watch_signals(signaler)
		signaler.emit_after(.5)
		yield(yield_to(signaler, 'the_signal', 5), YIELD)
		assert_signal_emitted(signaler, 'the_signal')


class TestYieldFrames:
	extends "res://test/gut_test.gd"

	var _frame_count = 0

	func _physics_process(delta):
		_frame_count += 1

	func before_each():
		_frame_count = 0

	func test_can_yield_using_set_yield_frames():
		yield(gut.set_yield_frames(10), YIELD)
		pass_test('we got here')

	func test_yield_frames_waits_x_frames():
		yield(yield_frames(5), YIELD)
		assert_eq(_frame_count, 5)

	func test_renders_message():
		yield(yield_frames(120, 'this is the output.'), YIELD)
		pass_test("did you look at the output?")

	func test_yield_frames_zero_generates_error():
		var err_count = get_error_count(gut)
		yield(yield_frames(0, 'whaterver'), YIELD)
		assert_eq(get_error_count(gut), err_count + 1)

	func test_yield_frames_neg_number_generates_error():
		var err_count = get_error_count(gut)
		yield(yield_frames(-1, 'whatever'), YIELD)
		assert_eq(get_error_count(gut), err_count + 1)



