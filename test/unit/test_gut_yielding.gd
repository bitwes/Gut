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
