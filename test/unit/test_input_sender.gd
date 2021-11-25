extends "res://addons/gut/test.gd"


class HasInputEvents:
	extends Control

	var input_event = null
	var gui_event = null
	var unhandled_event = null

	func _input(event):
		input_event = event
	func _gui_input(event):
		gui_event = event
	func _unhandled_input(event):
		unhandled_event = event


class MissingGuiInput:
	extends Node

	var input_event = null
	var unhandled_event = null

	func _input(event):
		input_event = event
	func _unhandled_input(event):
		unhandled_event = event

class InputTracker:
	extends Node
	var inputs = []
	var input_frames = []

	var _frame_counter = 0

	func _process(delta):
		_frame_counter += 1

	func _input(event):
		inputs.append(event)
		input_frames.append(_frame_counter)

class TestTheBasics:
	extends "res://addons/gut/test.gd"

	func test_can_make_one():
		assert_not_null(InputSender.new())

	func test_add_receiver():
		var sender = InputSender.new()
		var r = autofree(Node.new())
		sender.add_receiver(r)
		assert_eq(sender.get_receivers(), [r])

	func test_can_init_with_a_receiver():
		var r = autofree(Node.new())
		var sender = InputSender.new(r)
		assert_eq(sender.get_receivers(), [r])


class TestCreateKeyEvents:
	extends "res://addons/gut/test.gd"

	func test_key_up_sends_event():
		var r = autofree(HasInputEvents.new())
		var sender = InputSender.new(r)
		sender.key_up("C")
		assert_eq(r.input_event.scancode, KEY_C)

	func test_key_up_returns_self():
		var sender = InputSender.new()
		assert_eq(sender.key_up('c'), sender)

	func test_key_down_sends_event():
		var r = autofree(HasInputEvents.new())
		var sender = InputSender.new(r)
		sender.key_down(KEY_Q)
		assert_eq(r.input_event.scancode, KEY_Q)

	func test_key_down_returns_self():
		var sender = InputSender.new()
		assert_eq(sender.key_down('c'), sender)

	func test_key_echo_sends_a_duplicate_of_last_key():
		var r = autofree(InputTracker.new())
		var sender = InputSender.new(r)
		sender.key_down("a")
		sender.key_echo()
		assert_eq(r.inputs.size(), 2)

	func test_key_echo_is_an_echo():
		var r = autofree(InputTracker.new())
		var sender = InputSender.new(r)
		sender.key_down("a")
		sender.key_echo()
		assert_true(r.inputs[1].echo)

	func test_echoed_key_is_a_dupe():
		var r = autofree(InputTracker.new())
		var sender = InputSender.new(r)
		sender.key_down("a")
		sender.key_echo()
		assert_ne(r.inputs[0], r.inputs[1])

	func test_if_no_last_key_echo_does_nothing():
		var r = autofree(InputTracker.new())
		var sender = InputSender.new(r)
		sender.key_echo()
		assert_eq(r.inputs.size(), 0)

	func test_echo_key_returns_self():
		var sender = InputSender.new()
		assert_eq(sender.key_echo(), sender)


class TestCreateActionEvents:
	extends "res://addons/gut/test.gd"

	func test_action_up_sends_event():
		var r = autofree(HasInputEvents.new())
		var sender = InputSender.new(r)
		sender.action_up("foo", .5)
		assert_eq(r.input_event.action, "foo")

	func test_aciton_up_returns_self():
		var sender = InputSender.new()
		assert_eq(sender.action_up("foo", .5), sender)

	func test_action_down_sends_event():
		var r = autofree(HasInputEvents.new())
		var sender = InputSender.new(r)
		sender.action_down("foo", .5)
		assert_eq(r.input_event.action, "foo")

	func test_action_down_returns_self():
		var sender = InputSender.new()
		assert_eq(sender.action_down("foo", .5), sender)


class TestMouseButtons:
	extends "res://addons/gut/test.gd"

	func assert_mouse_event_sends_event(method):
		var r = autofree(HasInputEvents.new())
		var sender = InputSender.new(r)
		var returned = sender.call(method, Vector2(22, 22))
		assert_eq(r.input_event.position, Vector2(22, 22), 'event sent')
		assert_eq(returned, sender, "self returned")

	func test_lmb_down():
		assert_mouse_event_sends_event("mouse_left_button_down")

	func test_lmb_up():
		assert_mouse_event_sends_event("mouse_left_button_up")

	func test_double_clickk():
		assert_mouse_event_sends_event("mouse_double_click")

	func test_rmb_down():
		assert_mouse_event_sends_event("mouse_right_button_down")

	func test_rmb_up():
		assert_mouse_event_sends_event("mouse_right_button_up")


class TestMouseMotion:
	extends "res://addons/gut/test.gd"

	func test_mouse_motion_sends_event():
		var r = autofree(InputTracker.new())
		var sender = InputSender.new(r)
		sender.mouse_motion(Vector2(100, 100), Vector2(50, 50))
		assert_eq(r.inputs[0].position, Vector2(100, 100), "position")
		assert_eq(r.inputs[0].global_position, Vector2(50, 50), "global_position")

	func test_mouse_motion_returns_self():
		var sender = InputSender.new()
		assert_eq(sender.mouse_motion(Vector2(1,1)), sender)

	func test_mouse_relative_motion_sends_event():
		var r = autofree(InputTracker.new())
		var sender = InputSender.new(r)
		sender.mouse_relative_motion(Vector2(100, 100))
		assert_eq(r.inputs[0].position, Vector2(100, 100), "position")

	func test_mouse_relative_returns_self():
		var sender = InputSender.new()
		assert_eq(sender.mouse_relative_motion(Vector2(1,1)), sender)

	func test_mouse_relative_motion_uses_motion_from_mouse_motion():
		var r = autofree(InputTracker.new())
		var sender = InputSender.new(r)
		sender\
			.mouse_motion(Vector2(10, 10), Vector2(50, 50))\
			.mouse_relative_motion(Vector2(3, 3))

		assert_eq(r.inputs[1].position, Vector2(13, 13))

	func test_mouse_relative_motion_uses_motion_from_last_relative_motion():
		var r = autofree(InputTracker.new())
		var sender = InputSender.new(r)
		sender\
			.mouse_motion(Vector2(10, 10), Vector2(50, 50))\
			.mouse_relative_motion(Vector2(3, 3))\
			.mouse_relative_motion(Vector2(1, 1))

		assert_eq(r.inputs[-1].position, Vector2(14, 14))

	func test_mouse_relative_motion_sets_speed():
		var r = autofree(InputTracker.new())
		var sender = InputSender.new(r)
		sender\
			.mouse_motion(Vector2(10, 10), Vector2(50, 50))\
			.mouse_relative_motion(Vector2(3, 3), Vector2(1, 1))

		assert_eq(r.inputs[-1].speed, Vector2(1, 1))

	# inferred tests:  mouse_set_position returns self and it does not send the
	# event
	func test_mouse_set_position_sets_last_mouse_motion():
		var r = autofree(InputTracker.new())
		var sender = InputSender.new(r)

		sender\
			.mouse_set_position(Vector2(10, 10), Vector2(20, 20))\
			.mouse_relative_motion(Vector2(5, 5))

		assert_eq(r.inputs[0].position, Vector2(15, 15), 'position')
		assert_eq(r.inputs[0].global_position, Vector2(25, 25), 'global_position')


class TestSendEvent:
	extends "res://addons/gut/test.gd"


	func test_send_event_returns_self():
		var sender = InputSender.new()
		var e = InputEventKey.new()
		var ret_val = sender.send_event(e)
		assert_eq(ret_val, sender)

	func test_sends_event_to_input():
		var r = autofree(HasInputEvents.new())
		var sender = InputSender.new(r)
		var event = InputEventKey.new()
		sender.send_event(event)
		assert_eq(r.input_event, event)

	func test_sends_event_to_gui_input():
		var r = autofree(HasInputEvents.new())
		var sender = InputSender.new(r)
		var event = InputEventKey.new()
		sender.send_event(event)
		assert_eq(r.gui_event, event)

	func test_sends_event_to_unhandled_input():
		var r = autofree(HasInputEvents.new())
		var sender = InputSender.new(r)
		var event = InputEventKey.new()
		sender.send_event(event)
		assert_eq(r.unhandled_event, event)

	func test_sends_event_to_multiple_receivers():
		var r1 = autofree(HasInputEvents.new())
		var r2 = autofree(HasInputEvents.new())
		var sender = InputSender.new(r1)
		sender.add_receiver(r2)

		var event = InputEventKey.new()
		sender.send_event(event)

		assert_eq(r1.input_event, event)
		assert_eq(r2.input_event, event)

	func test_works_if_gui_event_missing():
		var r = autofree(MissingGuiInput.new())
		var sender = InputSender.new(r)
		var event = InputEventKey.new()
		sender.send_event(event)
		pass_test("we got here")

	func test_works_if_no_input_methods_exist_on_object():
		var r = Reference.new()
		var sender = InputSender.new(r)
		var event = InputEventKey.new()
		sender.send_event(event)
		pass_test("we got here")

	func test_sends_events_to_Input():
		var sender = InputSender.new(Input)
		# not a receiver, in the tree so Input will send events it gets with
		# parse_input_event to _input and _unhandled_input
		var thing = HasInputEvents.new()
		add_child_autofree(thing)

		var event = InputEventKey.new()
		event.pressed = true
		event.scancode = KEY_Y
		sender.send_event(event)

		assert_true(Input.is_key_pressed(KEY_Y), 'is_pressed')

		# illustrate that sending events to Input will also cause _input
		# and _unhandled_inpu to fire on anything in the tree.
		assert_eq(thing.input_event, event, '_input event')
		assert_eq(thing.unhandled_event, event, '_unhandled event')
		assert_null(thing.gui_event, 'gui event')


class TestSequence:
	extends "res://addons/gut/test.gd"

	func test_when_recoding_events_are_not_sent():
		var r = autofree(HasInputEvents.new())
		var sender = InputSender.new(r)

		sender.wait_frames(1)
		sender.key_down(KEY_Q)
		assert_null(r.input_event)

	func test_emits_signal_when_play_ends():
		var r = add_child_autofree(InputTracker.new())
		var sender = InputSender.new(r)
		watch_signals(sender)

		var e1 = InputEventAction.new()
		e1.set_action("foo")
		var e2 = InputEventAction.new()
		e2.set_action("bar")

		sender.wait_frames(1)
		sender.send_event(e1)
		sender.send_event(e2)

		yield(yield_to(sender, "playback_finished", 2), YIELD)
		assert_signal_emitted(sender, 'playback_finished')

	func test_playback_adds_delays():
		var r = add_child_autofree(InputTracker.new())
		var sender = InputSender.new(r)

		var cust_event = InputEventAction.new()
		cust_event.action = "foobar"

		sender\
			.key_down(KEY_1)\
			.wait(.5)\
			.key_up(KEY_1)\
			.wait(.5)\
			.send_event(cust_event)

		assert_eq(r.inputs.size(), 1, "first input sent")

		yield(yield_for(.7), YIELD)
		assert_eq(r.inputs.size(), 2, "second input sent")

		yield(yield_to(sender, 'playback_finished', 5), YIELD)
		assert_eq(r.inputs.size(), 3, "last input sent")

	func test_can_wait_frames():
		var r = add_child_autofree(InputTracker.new())
		var sender = InputSender.new(r)

		var cust_event = InputEventAction.new()
		cust_event.action = "foobar"

		sender\
			.key_down(KEY_1)\
			.wait_frames(30)\
			.key_up(KEY_1)\
			.wait_frames(30)\
			.send_event(cust_event)

		assert_eq(r.inputs.size(), 1, "first input sent")

		yield(yield_for(.7), YIELD)
		assert_eq(r.inputs.size(), 2, "second input sent")

		yield(yield_to(sender, 'playback_finished', 5), YIELD)
		assert_eq(r.inputs.size(), 3, "last input sent")

	func test_non_delayed_events_happen_on_the_same_frame_when_delayed_seconds():
		var r = add_child_autofree(InputTracker.new())
		var sender = InputSender.new(r)

		sender\
			.key_down("z")\
			.wait(.5)\
			.key_down("a")\
			.key_down("b")\
			.wait(.5)\
			.key_down("c")

		yield(yield_to(sender, "playback_finished", 2), YIELD)
		assert_eq(r.input_frames[1], r.input_frames[2])
		assert_eq(r.inputs[1].scancode, KEY_A)
		assert_eq(r.inputs[2].scancode, KEY_B)

	func test_non_delayed_events_happen_on_the_same_frame_when_delayed_frames():
		var r = add_child_autofree(InputTracker.new())
		var sender = InputSender.new(r)

		sender\
			.key_down("a")\
			.wait_frames(10)\
			.key_up("a")\
			.key_down("b")\
			.wait_frames(20)\
			.key_down("c")

		yield(yield_to(sender, "playback_finished", 2), YIELD)
		assert_eq(r.input_frames[1], r.input_frames[2])
		assert_eq(r.inputs[1].scancode, KEY_A)
		assert_eq(r.inputs[2].scancode, KEY_B)

	func test_mouse_relative_motion_works_with_waits():
		var r = add_child_autofree(InputTracker.new())
		var sender = InputSender.new(r)

		sender\
			.mouse_relative_motion(Vector2(1, 1))\
			.wait_frames(1)\
			.mouse_relative_motion(Vector2(2, 2))\
			.wait_frames(1)\
			.mouse_relative_motion(Vector2(3, 3))

		yield(yield_to(sender, "playback_finished", 5), YIELD)
		assert_eq(r.inputs[2].position, Vector2(6, 6))
