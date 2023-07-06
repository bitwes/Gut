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
		_timer.connect('timeout',Callable(self,'_on_timer_timeout'))
		_timer.one_shot = true

	func _on_timer_timeout():
		print(self, ':  emitting the_signal')
		the_signal.emit()

	func emit_after(time):
		_timer.set_wait_time(time)
		_timer.start()

class TimeSignalerParam:
	extends TimedSignaler

	func _on_timer_timeout():
		print(self, ':  emitting the_signal')
		emit_signal('the_signal', 1)

class TimedSignalerMaxParams:
	extends TimedSignaler

	func _on_timer_timeout():
		emit_signal('the_signal', 1, 2, 3, 4, 5, 6, 7, 8, 9)

class Counter:
	extends Node

	var time = 0.0
	var frames = 0

	func _process(delta):
		time += delta
		frames += 1


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
		gut.pause_before_teardown()
		pass_test('Got here')

	func test_can_pause_twice():
		gut.p('should have had to press continue')
		gut.pause_before_teardown()
		pass_test('Got here')

	func test_can_pause_after_yielding():
		pass_test('should have seen a pause and press continue')
		gut.p('yielding for 1 second')
		timer.start()
		await timer.timeout
		gut.p('done yielding')
		gut.pause_before_teardown()

	func test_can_call_pause_before_yielding():
		pass_test('should  see a pause')
		gut.pause_before_teardown()
		gut.p('yielding for 1 second')
		timer.start()
		await timer.timeout
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

	func before_each():
		timer.set_wait_time(1)


	func after_all():
		timer.free()


	func test_can_yield_using_built_in_timer():
		pass_test('should have seen a pause')
		gut.p('yielding for 1 second')
		await gut.set_wait_time(1)
		gut.p('done yielding')

	func test_setting_yield_time_twice_resets_time():
		pass_test('should have seen a pause')
		gut.p('yielding for 1 second')
		gut.set_wait_time(10)
		await gut.set_wait_time(1)
		gut.p('done yielding')

	func test_will_wait_when_yielding():
		pass_test('should have seen a pause')
		timer.set_wait_time(5)
		gut.p('yielding for 5 seconds')
		timer.start()
		await timer.timeout
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
		await wait_seconds(1)
		assert_signal_emitted(signaler, 'the_signal')

	func test_with_parameters(p=use_parameters([['a', 'a'], ['b', 'b'], ['c', 'c']])):
		await wait_seconds(1)
		assert_eq(p[0], p[1])



class TestWaitSeconds:
	extends "res://addons/gut/test.gd"
	var counter = null

	func before_each():
		counter = add_child_autoqfree(Counter.new())

	func test_new_yield():
		await wait_seconds(1, 'first yield')
		await wait_seconds(1, 'waiting around for stuff')
		assert_gt(counter.time, 1.9, 'should  see two 1 second pauses')

	func test_passing_assert_ends_yield():
		await wait_seconds(0.5)
		assert_gt(counter.time, .49, 'yield should stop')

	func test_failing_assert_ends_yield():
		await wait_seconds(0.5)
		assert_gt(counter.time, 999.0, 'Testing that GUT continues after failing assert; ignore failing unless value not ~.5.')

	func test_pending_ends_yield():
		await wait_seconds(0.5)
		pending(str('Testing Gut continues after yield.  ', counter.time, ' should be ~.5.'))

	func test_output_for_long_yields():
		gut.p('Visually check this')
		await wait_seconds(2)
		assert_gt(counter.time, 1.9, 'Visually check this')



class TestYieldTo:
	extends "res://addons/gut/test.gd"


	var counter = null

	func before_each():
		counter = add_child_autoqfree(Counter.new())

	func test_can_yield_to_signal():
		var signaler = add_child_autoqfree(TimedSignaler.new())
		signaler.emit_after(.5)
		await wait_for_signal(signaler.the_signal, 10)
		assert_gt(counter.time, .49)

	func test_after_yield_to_gut_disconnects_from_signal():
		var signaler = add_child_autoqfree(TimedSignaler.new())
		signaler.emit_after(.5)
		await wait_for_signal(signaler.the_signal, 1)
		await wait_seconds(.1)
		assert_false(signaler.is_connected('the_signal',Callable(gut,'_yielding_callback')))

	func test_yield_to__will_disconnect_after_yield_finishes_and_signal_wasnt_emitted():
		var signaler = add_child_autoqfree(TimedSignaler.new())
		await wait_for_signal(signaler.the_signal, 1)
		# Changing the yield to be deferred means that we have to wait again for
		# the deferred to kick in before checking this.
		await wait_seconds(.1)
		assert_false(signaler.is_connected('the_signal',Callable(gut,'_yielding_callback')))

	func test_yield_to__will_wait_max_time():
		var signaler = add_child_autoqfree(TimedSignaler.new())
		await wait_for_signal(signaler.the_signal, 2)
		assert_gt(counter.time, 1.9)

	func test_yield_to__will_stop_timer_when_signal_emitted():
		var signaler = add_child_autoqfree(TimedSignaler.new())
		signaler.emit_after(.5)
		await wait_for_signal(signaler.the_signal, 2)
		assert_false(gut._awaiter.is_waiting())

	func test_yield_to__watches_signals():
		var signaler = add_child_autoqfree(TimedSignaler.new())
		watch_signals(signaler)
		signaler.emit_after(.5)
		await wait_for_signal(signaler.the_signal, 5)
		assert_signal_emitted(signaler, 'the_signal')
		# Note, Gut waits another 4 frames for the signal to propigate to other
		# objects so we check agains.58
		assert_between(counter.time, .48, .54)

	func test_yield_to_works_on_signals_with_parameters():
		var signaler = add_child_autoqfree(TimeSignalerParam.new())
		watch_signals(signaler)
		signaler.emit_after(.5)
		await wait_for_signal(signaler.the_signal, 5)
		assert_signal_emitted(signaler, 'the_signal')
		# Note, Gut waits another 4 frames for the signal to propigate to other
		# objects so we check agains.58
		assert_lt(counter.time, .54)

	func test_yield_to_works_on_signals_with_max_parameters():
		var signaler = add_child_autoqfree(TimedSignalerMaxParams.new())
		watch_signals(signaler)
		signaler.emit_after(.5)
		await wait_for_signal(signaler.the_signal, 5)
		assert_signal_emitted(signaler, 'the_signal')
		# Note, Gut waits another .05 for the signal to propigate to other
		# objects so we check agains.58
		assert_lt(counter.time, .58)



class TestWaitFrames:
	extends "res://test/gut_test.gd"

	var _frame_count = 0

	func after_each():
		gut.treat_error_as_failure = true

	func _physics_process(delta):
		_frame_count += 1

	func before_each():
		_frame_count = 0

	func test_can_await_using_wait_frames():
		await gut.set_wait_frames(10)
		pass_test('we got here')

	func test_waits_x_frames(p=use_parameters([5, 10, 15, 20])):
		await wait_frames(p)
		assert_between(_frame_count, p - 1, p + 1)

	func test_renders_message():
		await wait_frames(120, 'this is the output.')
		assert_between(_frame_count, 118, 122)
		pass_test("did you look at the output?")

	func test_zero_generates_error():
		gut.treat_error_as_failure = false
		var err_count = get_error_count(gut)
		await wait_frames(0, 'whaterver')
		assert_eq(get_error_count(gut), err_count + 1)

	func test_neg_number_generates_error():
		gut.treat_error_as_failure = false
		var err_count = get_error_count(gut)
		await wait_frames(-1, 'whatever')
		assert_eq(get_error_count(gut), err_count + 1)



