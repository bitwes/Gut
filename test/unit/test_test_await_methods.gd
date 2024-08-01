extends GutTest

class TimedSignaler:
	extends Node2D

	signal the_signal

	var _timer = null

	func _ready():
		_timer = Timer.new()
		add_child(_timer)
		_timer.timeout.connect(_on_timer_timeout)
		_timer.one_shot = true

	func _on_timer_timeout():
		print(self, " emitting the_signal")
		the_signal.emit()

	func emit_after(time):
		_timer.set_wait_time(time)
		_timer.start()


class Counter:
	extends Node

	var time = 0.0
	var frames = 0

	func _physics_process(delta):
		time += delta
		frames += 1


class PredicateMethods:
	var times_called = 0
	func called_x_times(x):
		times_called += 1
		return times_called == x


class TestYeOldYieldMethods:
	extends GutTest

	var counter = null
	func before_each():
		counter = add_child_autoqfree(Counter.new())

	func test_wait_frames_waits_for_x_frames():
		await yield_frames(30)
		assert_between(counter.frames, 29, 31)

	func test_wait_to_ends_when_signal_emitted():
		var signaler = add_child_autoqfree(TimedSignaler.new())
		signaler.emit_after(.5)
		await yield_to(signaler, 'the_signal', 10)
		assert_between(counter.time, .48, .52)

	func test_wait_to_ends_at_max_wait_if_signal_not_emitted():
		var signaler = add_child_autoqfree(TimedSignaler.new())
		await yield_to(signaler, 'the_signal', 1)
		assert_between(counter.time, .9, 1.1)

	func test_wait_for_waits_for_x_seconds():
		await wait_seconds(.5)
		assert_between(counter.time, .49, .52)



class TestTheNewWaitMethods:
	extends GutTest

	var counter = null
	func before_each():
		counter = add_child_autoqfree(Counter.new())

	func test_wait_for_waits_for_x_seconds():
		await wait_seconds(.5)
		assert_between(counter.time, .49, .52)

	func test_wait_frames_waits_for_x_frames():
		await wait_frames(30)
		assert_between(counter.frames, 29, 31)

	func test_wait_to_ends_when_signal_emitted():
		var signaler = add_child_autoqfree(TimedSignaler.new())
		signaler.emit_after(.5)
		await wait_for_signal(signaler.the_signal, 10)
		assert_almost_eq(counter.time, .5, .05)
		assert_false(did_wait_timeout(), 'did_wait_timeout')

	func test_wait_to_ends_at_max_wait_if_signal_not_emitted():
		var signaler = add_child_autoqfree(TimedSignaler.new())
		await wait_for_signal(signaler.the_signal, 1)
		assert_between(counter.time, .9, 1.1)
		assert_true(did_wait_timeout(), 'did_wait_timeout')

	func test_wait_for_signal_returns_true_when_signal_emitted():
		var signaler = add_child_autoqfree(TimedSignaler.new())
		signaler.emit_after(.5)
		var result = await wait_for_signal(signaler.the_signal, 10)
		assert_true(result)

	func test_wait_for_signal_returns_false_when_signal_not_emitted():
		var signaler = add_child_autoqfree(TimedSignaler.new())
		signaler.emit_after(10)
		var result = await wait_for_signal(signaler.the_signal, .5)
		assert_false(result)


	func test_wait_until_waits_ends_when_method_returns_true():
		var all_is_good = func():
			return counter.time > .25

		await wait_until(all_is_good, .5)
		assert_almost_eq(counter.time, .25, .05)
		assert_false(did_wait_timeout(), 'did_wait_timeout')

	func test_wait_until_times_out():
		var all_is_good = func():
			return false

		await wait_until(all_is_good, .5)
		assert_almost_eq(counter.time, .5, .05)
		assert_true(did_wait_timeout(), 'did_wait_timeout')

	func test_wait_until_returns_true_when_it_finishes():
		var all_is_good = func():
			return counter.time > .25

		var result = await wait_until(all_is_good, .5)
		assert_true(result)

	func test_wait_until_returns_false_when_it_times_out():
		var all_is_good = func():
			return false

		var result = await wait_until(all_is_good, .5)
		assert_false(result)


	func test_wait_until_accepts_time_between():
		var pred_methods = PredicateMethods.new()
		var method = pred_methods.called_x_times.bind(10)

		await wait_until(method, 1.1, .25)
		assert_eq(pred_methods.times_called, 4)


	func test_wait_until_resets_time_between_counter():
		var pred_methods = PredicateMethods.new()
		var method = pred_methods.called_x_times.bind(10)

		await wait_until(method, 1.1, .75)
		pred_methods.times_called = 0
		await wait_until(method, 1.1, .2)
		assert_eq(pred_methods.times_called, 5)
