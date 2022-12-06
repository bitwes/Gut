extends GutTest

var Awaiter = load('res://addons/gut/awaiter.gd')

class Counter:
	extends Node

	var time = 0.0
	var frames = 0

	func _physics_process(delta):
		time += delta
		frames += 1

class Signaler:
	signal the_signal
	signal with_parameters(foo, bar)

func test_is_not_paused_by_default():
	var a = add_child_autofree(Awaiter.new())
	assert_false(a.is_waiting())

func test_wait_started_emitted_when_waiting_seconds():
	var a = add_child_autoqfree(Awaiter.new())
	watch_signals(a)
	a.wait_for(.5)
	assert_signal_emitted(a, 'wait_started')

func test_signal_emitted_after_half_second():
	# important that counter added to tree before awaiter.  If it is after, then
	# the last _process call for the counter will happen after the signal in
	# the awaiter is sent and the counts are off.
	var c = add_child_autoqfree(Counter.new())
	var a = add_child_autoqfree(Awaiter.new())
	watch_signals(a)
	a.wait_for(.5)
	await a.timeout
	assert_signal_emitted(a, 'timeout')
	assert_gt(c.time, .49, 'waited enough time')

func test_is_waiting_while_waiting_on_time():
	var c = add_child_autoqfree(Counter.new())
	var a = add_child_autoqfree(Awaiter.new())
	a.wait_for(.5)
	await get_tree().create_timer(.1).timeout
	assert_true(a.is_waiting())

func test_wait_started_emitted_when_waiting_frames():
	var a = add_child_autoqfree(Awaiter.new())
	watch_signals(a)
	a.wait_frames(10)
	assert_signal_emitted(a, 'wait_started')

func test_signal_emitted_after_10_frames():
	var c = add_child_autoqfree(Counter.new())
	var a = add_child_autoqfree(Awaiter.new())
	watch_signals(a)
	a.wait_frames(10)
	await a.timeout
	assert_signal_emitted(a, 'timeout')
	assert_eq(c.frames, 10, 'waited enough frames')

func test_is_waiting_while_waiting_on_frames():
	var c = add_child_autoqfree(Counter.new())
	var a = add_child_autoqfree(Awaiter.new())
	a.wait_frames(120)
	await get_tree().create_timer(.1).timeout
	assert_true(a.is_waiting())


func test_wait_started_emitted_when_waiting_on_signal():
	var s = Signaler.new()
	var a = add_child_autoqfree(Awaiter.new())
	watch_signals(a)
	a.wait_for_signal(s.the_signal, 10)
	assert_signal_emitted(a, 'wait_started')


func test_can_wait_for_signal():
	var s = Signaler.new()
	var a = add_child_autoqfree(Awaiter.new())
	watch_signals(a)
	a.wait_for_signal(s.the_signal, 10)
	await get_tree().create_timer(.5).timeout
	s.the_signal.emit()
	# gotta wait for the 2 additional frames
	await get_tree().create_timer(.05).timeout
	assert_signal_emitted(a, 'timeout')

func test_can_wait_for_signal_with_parameters():
	var s = Signaler.new()
	var a = add_child_autoqfree(Awaiter.new())
	watch_signals(a)
	a.wait_for_signal(s.with_parameters, 10)
	await get_tree().create_timer(.5).timeout
	s.with_parameters.emit(1, 2)
	# gotta wait for the 2 additional frames
	await get_tree().create_timer(.05).timeout
	assert_signal_emitted(a, 'timeout')


func test_after_wait_for_signal_signal_is_disconnected():
	var s = Signaler.new()
	var a = add_child_autoqfree(Awaiter.new())
	watch_signals(a)
	a.wait_for_signal(s.the_signal, 10)
	await get_tree().create_timer(.5).timeout
	s.the_signal.emit()
	assert_not_connected(s, a, 'the_signal')

func test_when_signal_not_emitted_max_time_is_waited():
	var s = Signaler.new()
	var a = add_child_autoqfree(Awaiter.new())
	watch_signals(a)
	a.wait_for_signal(s.the_signal, .5)
	await get_tree().create_timer(.8).timeout
	assert_signal_emitted(a, 'timeout')

func test_is_waiting_when_waiting_on_signal():
	var c = add_child_autoqfree(Counter.new())
	var s = Signaler.new()
	var a = add_child_autoqfree(Awaiter.new())
	watch_signals(a)
	a.wait_for_signal(s.the_signal, .5)
	await get_tree().create_timer(.1).timeout
	assert_true(a.is_waiting())

func test_is_not_paused_when_signal_emitted_before_max_time():
	var s = Signaler.new()
	var a = add_child_autoqfree(Awaiter.new())
	watch_signals(a)
	a.wait_for_signal(s.the_signal, 10)
	await get_tree().create_timer(.5).timeout
	s.the_signal.emit()
	# gotta wait for the 2 additional frames
	await get_tree().create_timer(.05).timeout
	assert_false(a.is_waiting())
