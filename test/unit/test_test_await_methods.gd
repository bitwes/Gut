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


class TestOldYieldMethods:
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

	func test_wait_until_accepts_string_as_thrid_arg():
		var pred_methods = PredicateMethods.new()
		var method = pred_methods.called_x_times.bind(10)

		await wait_until(method, 1.1, 'DID YOU SEE THIS?')
		pass_test("Check output for DID YOU SEE THIS?")

	func test_wait_until_accepts_time_between():
		var pred_methods = PredicateMethods.new()
		var method = pred_methods.called_x_times.bind(10)

		await wait_until(method, 1.1, .25)
		assert_eq(pred_methods.times_called, 4)

	func test_wait_until_accepts_time_between_then_msg():
		var pred_methods = PredicateMethods.new()
		var method = pred_methods.called_x_times.bind(10)

		await wait_until(method, 1.1, .25, 'DID YOU SEE THIS?')
		assert_eq(pred_methods.times_called, 4)

	func test_assert_eventually_accepts_string_as_thrid_arg():
		var test = add_child_autoqfree(GutTest.new())
		var pred_methods = PredicateMethods.new()
		var method = pred_methods.called_x_times.bind(10)

		await test.assert_eventually(method, 1.1, 'DID YOU SEE THIS?')
		pass_test("Check output for DID YOU SEE THIS?")

	func test_assert_eventually_accepts_time_between():
		var test = add_child_autoqfree(GutTest.new())
		var pred_methods = PredicateMethods.new()
		var method = pred_methods.called_x_times.bind(4)

		await test.assert_eventually(method, 1.1, .25)
		assert_eq(pred_methods.times_called, 4)

	func test_assert_eventually_accepts_time_between_then_msg():
		var test = add_child_autoqfree(GutTest.new())
		var pred_methods = PredicateMethods.new()
		var method = pred_methods.called_x_times.bind(10)

		await test.assert_eventually(method, 1.1, .25, 'DID YOU SEE THIS?')
		assert_eq(pred_methods.times_called, 4)









	func test_assert_eventually_waits_until_predicate_function_returns_true():
		var some_node = add_child_autoqfree(Node.new())
		var is_named_foo = func(): return some_node.name == 'foo'
		var signaler = add_child_autoqfree(TimedSignaler.new())
		signaler.the_signal.connect(func(): some_node.name = 'foo')
		signaler.emit_after(.1)

		assert_false(is_named_foo.call())
		await assert_eventually(is_named_foo, 1.0)
		assert_true(is_named_foo.call())

		assert_between(counter.time, .09, .15)

	# TODO: Keep an eye on the Github issue, until Godot fixes the error log
	# This test passes, but prints the error log:
	# 	ERROR: Lambda capture at index 0 was freed. Passed "null" instead
	# Godot issue: https://github.com/godotengine/godot/issues/85947
	func test_wait_until_is_compatible_with_checking_if_an_object_is_freed():
		var node = add_child_autoqfree(Node.new())
		# TODO: If we ever expose _utils.is_freed() in GUT's public API, we could swap it in here
		# It makes the test pass without any error logs
		# To add it to the API:
		# 	- add it in addons/gut/test.gd
		# 	- document in https://gut.readthedocs.io/en/latest/Asserts-and-Methods.html#utilities
		# For now let's keep is_instance_valid to demo what a GUT user would probably use
		var is_freed = func(): return not is_instance_valid(node)
		var signaler = add_child_autoqfree(TimedSignaler.new())
		signaler.the_signal.connect(node.queue_free)
		signaler.emit_after(.1)

		await assert_eventually(is_freed, 1.0)

		assert_between(counter.time, 0.0, .2)
		assert_freed(node)
