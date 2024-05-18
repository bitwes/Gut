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
		assert_between(counter.time, .48, .52)

	func test_wait_to_ends_at_max_wait_if_signal_not_emitted():
		var signaler = add_child_autoqfree(TimedSignaler.new())
		await wait_for_signal(signaler.the_signal, 1)
		assert_between(counter.time, .9, 1.1)

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
		var is_freed = func(): return not is_instance_valid(node)
		var signaler = add_child_autoqfree(TimedSignaler.new())
		signaler.the_signal.connect(node.queue_free)
		signaler.emit_after(.1)

		await assert_eventually(is_freed, 1.0)

		assert_between(counter.time, 0, .2)
		assert_freed(node)

# ------------------------------------
# Could not get these to trigger the error I was trying to replicate.  This was
# a useful exercies though and I'm not ready to part with this code.  So it is
# here as an example of using parameterized tests to control the order of the
# execution of tests with different behavior per iteration.
# ------------------------------------
# class TestYieldTimerResetAfterSignalEmitted:
# 	extends GutTest

# 	var _wait_data = ParameterFactory.named_parameters(
# 		['kind', 'time'],
# 		[
# 			['s', 3.0],
# 			['t', 4.0],
# 		])

# 	var _counter = null
# 	func before_each():
# 		_counter = add_child_autoqfree(Counter.new())


# 	func test_one(param=use_parameters(_wait_data)):
# 		print('time left = ', gut._yield_timer.time_left)
# 		var signaler = add_child_autoqfree(TimedSignaler.new())
# 		var t = param.time

# 		if(param.kind == 's'):
# 			signaler.emit_after(t)
# 			await wait_for_signal(signaler.the_signal, t + 2)
# 		else:
# 			await wait_seconds(t)

# 		assert_between(_counter.time, t - 0.1, t + 0.1)
# 		print('time left = ', gut._yield_timer.time_left)