extends GutTest


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

	func print_events():
		for e in inputs:
			print(e)



class TestDeprecatedMethods:
	extends GutInternalTester

	func _new_sender():
		var sender = InputSender.new(self)
		sender.logger = _utils.Logger.new()
		return sender

	func test_wait():
		var sender = _new_sender()
		sender.wait(1)
		assert_deprecated(sender, 1)

	func test_wait_secs():
		var sender = _new_sender()
		sender.wait_secs(1)
		assert_deprecated(sender, 1)

	func test_hold_for():
		var sender = _new_sender()
		sender.hold_for(1)
		assert_deprecated(sender, 1)




class TestTheBasics:
	extends GutTest

	func before_all():
		InputMap.add_action("jump")

	func after_all():
		InputMap.erase_action("jump")

	func test_can_make_one():
		assert_not_null(InputSender.new())

	func test_logger_accessors():
		var sender = InputSender.new()
		assert_property(sender, 'logger', sender._lgr, _utils.Logger.new())

	func test_set_get_auto_flush_input():
		assert_accessors(InputSender.new(), 'auto_flush_input', false, true)

	func test_add_receiver():
		var sender = InputSender.new()
		var r = autofree(Node.new())
		sender.add_receiver(r)
		assert_eq(sender.get_receivers(), [r])

	func test_can_init_with_a_receiver():
		var r = autofree(Node.new())
		var sender = InputSender.new(r)
		assert_eq(sender.get_receivers(), [r])

	func test_wait_parses_seconds():
		var sender = partial_double(InputSender).new()
		sender.wait('2s')
		assert_called(sender, 'wait_seconds', [2.0])

	func test_wait_parses_frames():
		var sender = partial_double(InputSender).new()
		sender.wait('3f')
		assert_called(sender, 'wait_frames', [3.0])

	func test_idle_by_default():
		var sender = InputSender.new()
		assert_true(sender.is_idle())

	func test_not_idle_when_items_in_queue():
		var sender = InputSender.new()
		sender.key_down("A").hold_seconds(.1)
		assert_false(sender.is_idle())

	func test_is_idle_when_an_event_sent_without_wait():
		var sender = InputSender.new()
		sender.key_down("B")
		assert_true(sender.is_idle())

	# knows too much, dunno a better way.
	func test_when_freed_all_tree_items_are_freed():
		var sender = InputSender.new()
		sender.key_down("B").wait_seconds(8)
		sender.key_up("B").wait_seconds(8)
		sender.key_down("B").wait_seconds(8)
		sender.key_up("B").wait_seconds(8)
		var parent_item = sender._tree_items_parent
		assert_gt(parent_item.get_child_count(), 0, 'just making sure there is something to free')

		# could not find a way to trigger this by unreferencing
		sender._notification(NOTIFICATION_PREDELETE)
		await wait_frames(5) # queue_free
		assert_freed(parent_item, 'sender item node parent')

	func test_is_key_pressed_false_by_default():
		var sender = InputSender.new()
		assert_false(sender.is_key_pressed("F"))

	func test_is_key_pressed_true_when_sent_key():
		var sender = InputSender.new()
		sender.key_down("F")
		assert_true(sender.is_key_pressed("F"))

	func test_is_action_pressed_false_by_default():
		var sender = InputSender.new()
		assert_false(sender.is_action_pressed("jump"))

	func test_is_action_pressed_true_when_action_sent():
		var sender = InputSender.new()
		sender.action_down("jump")
		assert_true(sender.is_action_pressed("jump"))

	func test_is_mouse_button_pressed_false_by_default():
		var sender = InputSender.new()
		assert_false(sender.is_mouse_button_pressed(MOUSE_BUTTON_LEFT))

	func test_is_mouse_button_pressed_true_when_button_sent():
		var sender = InputSender.new()
		sender.mouse_right_button_down(Vector2(1,1))
		assert_true(sender.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT))

	func test_warns_when_key_down_for_a_pressed_key():
		var sender = InputSender.new()
		var lgr = _utils.Logger.new()
		sender._lgr = lgr
		sender.key_down("S")
		sender.key_down("S")
		assert_eq(lgr.get_warnings().size(), 1)

	func test_does_now_warn_for_key_up():
		var sender = InputSender.new()
		var lgr = _utils.Logger.new()
		sender._lgr = lgr
		sender.key_down("S")
		sender.key_up("S")
		assert_eq(lgr.get_warnings().size(), 0)

	func test_does_not_warn_for_key_echos():
		var sender = InputSender.new()
		var lgr = _utils.Logger.new()
		sender._lgr = lgr
		sender.key_down("S")
		sender.key_echo()
		sender.key_echo()
		assert_eq(lgr.get_warnings().size(), 0)

	func test_warns_when_action_down_for_a_pressed_action():
		var sender = InputSender.new()
		var lgr = _utils.Logger.new()
		sender._lgr = lgr
		sender.action_down("jump")
		sender.action_down("jump")
		assert_eq(lgr.get_warnings().size(), 1)

	func test_does_not_warn_for_action_up():
		var sender = InputSender.new()
		var lgr = _utils.Logger.new()
		sender._lgr = lgr
		sender.action_down("jump")
		sender.action_up("jump")
		assert_eq(lgr.get_warnings().size(), 0)

	func test_warns_when_mouse_down_for_a_pressed_mouse_button():
		var sender = InputSender.new()
		var lgr = _utils.Logger.new()
		sender._lgr = lgr
		sender.mouse_right_button_down(Vector2(1,1))
		sender.mouse_right_button_down(Vector2(1,1))
		assert_eq(lgr.get_warnings().size(), 1)

	func test_does_not_warn_for_mouse_up():
		var sender = InputSender.new()
		var lgr = _utils.Logger.new()
		sender._lgr = lgr
		sender.mouse_right_button_down(Vector2(1,1))
		sender.mouse_right_button_up(Vector2(1,1))
		assert_eq(lgr.get_warnings().size(), 0)

	func test_does_not_warn_when_mouse_button_released():
		var sender = InputSender.new()
		var lgr = _utils.Logger.new()
		sender._lgr = lgr
		sender.mouse_right_button_down(Vector2(1,1))
		sender.mouse_right_button_up(Vector2(1,1))
		sender.mouse_right_button_down(Vector2(1,1))
		assert_eq(lgr.get_warnings().size(), 0)

	func test_warns_for_2nd_down_event_after_idle():
		var sender = InputSender.new()
		var lgr = _utils.Logger.new()
		sender._lgr = lgr

		sender.key_down("R").wait_seconds(.2)
		await sender.idle

		sender.key_down("R")
		assert_eq(lgr.get_warnings().size(), 1)

	func test_draw_mouse():
		var sender = InputSender.new(self)
		sender.mouse_warp = false
		sender.draw_mouse = true
		var pos = Vector2(200, 200)

		sender\
			.mouse_left_button_down(pos).wait_seconds(1)\
			.mouse_left_button_up()\
			.mouse_right_button_down().wait_seconds(1)\
			.mouse_right_button_up()\
			.mouse_relative_motion(Vector2(10, 10)).wait_seconds(.5)\
			.mouse_relative_motion(Vector2(10, 10)).wait_seconds(.5)\
			.mouse_left_button_down()\
			.mouse_relative_motion(Vector2(10, 10)).wait_seconds(.5)\
			.mouse_relative_motion(Vector2(10, 10)).wait_seconds(.5)\
			.mouse_left_button_up()\
			.mouse_right_button_down()\
			.mouse_relative_motion(Vector2(10, 10)).wait_seconds(.5)\
			.mouse_relative_motion(Vector2(10, 10)).wait_seconds(.5)\
			.mouse_right_button_up()\
			.mouse_left_button_down()\
			.mouse_right_button_down()\
			.wait_seconds(1)

		await sender.idle
		pass_test("You shoulda been watching things.")




class TestCreateKeyEvents:
	extends "res://addons/gut/test.gd"

	func test_key_up_sends_event():
		var r = autofree(HasInputEvents.new())
		var sender = InputSender.new(r)
		sender.key_up("C")
		assert_eq(r.input_event.keycode, KEY_C)

	func test_key_up_returns_self():
		var sender = InputSender.new()
		assert_eq(sender.key_up('c'), sender)

	func test_key_down_sends_event():
		var r = autofree(HasInputEvents.new())
		var sender = InputSender.new(r)
		sender.key_down(KEY_Q)
		assert_eq(r.input_event.keycode, KEY_Q)

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

	var events = ParameterFactory.named_parameters(
		['method_name', 'button_index', 'pressed'],
		[
			["mouse_left_button_down", MOUSE_BUTTON_LEFT, true],
			["mouse_left_button_up", MOUSE_BUTTON_LEFT, false],
			["mouse_right_button_down", MOUSE_BUTTON_RIGHT, true],
			["mouse_right_button_up", MOUSE_BUTTON_RIGHT, false],
			["mouse_double_click", MOUSE_BUTTON_LEFT, false]
		])
	func test_event_properties(p=use_parameters(events)):
		var r = autofree(HasInputEvents.new())
		var sender = InputSender.new(r)
		var returned = sender.call(p.method_name, Vector2(22, 22))
		assert_eq(r.input_event.position, Vector2(22, 22), 'event sent')
		assert_eq(returned, sender, "self returned")
		assert_eq(r.input_event.pressed, p.pressed, 'pressed')
		assert_eq(r.input_event.button_index, p.button_index, 'button index')

	func test_lmb_down_uses_default_mouse_positions():
		var r = autofree(HasInputEvents.new())
		var sender = InputSender.new(r)
		sender.mouse_left_button_down()
		assert_eq(r.input_event.position, Vector2(0, 0))

	func test_lmb_up_uses_default_mouse_positions():
		var r = autofree(HasInputEvents.new())
		var sender = InputSender.new(r)
		sender.mouse_left_button_up()
		assert_eq(r.input_event.position, Vector2(0, 0))

	func test_lmb_uses_last_mouse_position():
		var r = autofree(HasInputEvents.new())
		var sender = InputSender.new(r)
		sender.mouse_left_button_down(Vector2(1, 1), Vector2(2, 2))
		sender.mouse_left_button_up()
		sender.mouse_left_button_down()
		assert_eq(r.input_event.position, Vector2(1, 1))




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

		assert_eq(r.inputs[-1].velocity, Vector2(1, 1))

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




class TestJoypadButton:
	extends GutTest

	func test_sends_event():
		var r = autofree(InputTracker.new())
		var sender = InputSender.new(r)
		sender.joypad_button(1, true)
		assert_eq(r.inputs[0].button_index, 1, 'button_index')
		assert_eq(r.inputs[0].pressed, true, 'pressed')

	func test_returns_self():
		var sender = InputSender.new()
		var result = sender.joypad_button(2, false)
		assert_eq(result, sender)



class TestJoypadMotion:
	extends GutTest

	func test_sends_event():
		var r = autofree(InputTracker.new())
		var sender = InputSender.new(r)
		sender.joypad_motion(2, .5)
		assert_eq(r.inputs[0].axis,  2, 'axis')
		assert_eq(r.inputs[0].axis_value, .5, 'axis_value')

	func test_returns_self():
		var sender = InputSender.new()
		var result = sender.joypad_motion(2, .5)
		assert_eq(result, sender)


class TestMagnifyGesture:
	extends GutTest

	func test_sends_event():
		var r = autofree(InputTracker.new())
		var sender = InputSender.new(r)
		sender.magnify_gesture(Vector2(1, 1), .5)
		assert_eq(r.inputs[0].position,  Vector2(1, 1), 'position')
		assert_eq(r.inputs[0].factor, .5, 'factor')

	func test_returns_self():
		var sender = InputSender.new()
		var result = sender.magnify_gesture(Vector2(1, 1), .5)
		assert_eq(result, sender)


class TestPanGesture:
	extends GutTest

	func test_sends_event():
		var r = autofree(InputTracker.new())
		var sender = InputSender.new(r)
		sender.pan_gesture(Vector2(1, 1), Vector2(2, 2))
		assert_eq(r.inputs[0].position,  Vector2(1, 1), 'position')
		assert_eq(r.inputs[0].delta, Vector2(2, 2), 'delta')

	func test_returns_self():
		var sender = InputSender.new()
		var result = sender.pan_gesture(Vector2(1, 1), Vector2(2, 2))
		assert_eq(result, sender)




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
		var r = RefCounted.new()
		var sender = InputSender.new(r)
		var event = InputEventKey.new()
		sender.send_event(event)
		pass_test("we got here")

	func test_does_not_send_immediately_when_accumulate_and_not_auto_flushing_34():
		if(skip_if_godot_version_ne('3.4')):
			return

		var sender = InputSender.new(Input)
		sender.set_auto_flush_input(false)
		Input.set_use_accumulated_input(true)

		# not a receiver, in the tree so Input will send events it gets with
		# parse_input_event to _input and _unhandled_input
		var thing = HasInputEvents.new()
		add_child_autofree(thing)

		var event = InputEventKey.new()
		event.pressed = true
		event.keycode = KEY_Y
		sender.send_event(event)

		assert_false(Input.is_key_pressed(KEY_Y), 'is_pressed')
		Input.set_use_accumulated_input(false)


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

		await wait_for_signal(sender.idle, 2)
		assert_signal_emitted(sender, 'idle')

	func test_playback_adds_delays():
		var r = add_child_autofree(InputTracker.new())
		var sender = InputSender.new(r)

		var cust_event = InputEventAction.new()
		cust_event.action = "foobar"

		sender\
			.key_down(KEY_1)\
			.wait_seconds(.5)\
			.key_up(KEY_1)\
			.wait_seconds(.5)\
			.send_event(cust_event)

		assert_eq(r.inputs.size(), 1, "first input sent")

		await wait_seconds(.7)
		assert_eq(r.inputs.size(), 2, "second input sent")

		await wait_for_signal(sender.idle, 5)
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

		await wait_seconds(.7)
		assert_eq(r.inputs.size(), 2, "second input sent")

		await wait_for_signal(sender.idle, 5)
		assert_eq(r.inputs.size(), 3, "last input sent")

	func test_non_delayed_events_happen_on_the_same_frame_when_delayed_seconds():
		var r = add_child_autofree(InputTracker.new())
		var sender = InputSender.new(r)

		sender\
			.key_down("z")\
			.wait_seconds(.5)\
			.key_down("a")\
			.key_down("b")\
			.wait_seconds(.5)\
			.key_down("c")

		await wait_for_signal(sender.idle, 2)
		assert_eq(r.input_frames[1], r.input_frames[2])
		assert_eq(r.inputs[1].keycode, KEY_A)
		assert_eq(r.inputs[2].keycode, KEY_B)

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

		await wait_for_signal(sender.idle, 2)
		assert_eq(r.input_frames[1], r.input_frames[2])
		assert_eq(r.inputs[1].keycode, KEY_A)
		assert_eq(r.inputs[2].keycode, KEY_B)

	func test_mouse_relative_motion_works_with_waits():
		var r = add_child_autofree(InputTracker.new())
		var sender = InputSender.new(r)

		sender\
			.mouse_relative_motion(Vector2(1, 1))\
			.wait_frames(1)\
			.mouse_relative_motion(Vector2(2, 2))\
			.wait_frames(1)\
			.mouse_relative_motion(Vector2(3, 3))

		await wait_for_signal(sender.idle, 5)
		assert_eq(r.inputs[2].position, Vector2(6, 6))




class TestHoldFor:
	extends "res://addons/gut/test.gd"

	func test_action_hold_for():
		var r = add_child_autofree(InputTracker.new())
		var sender = InputSender.new(r)

		sender.action_down("jump").hold_frames(3)
		await wait_for_signal(sender.idle, 5)

		assert_eq(r.inputs.size(), 2, 'input size')
		var jump_pressed = r.inputs[0].action == "jump" and r.inputs[0].pressed
		assert_true(jump_pressed, "jump pressed is action 0")
		var jummp_released = r.inputs[1].action == "jump" and !(r.inputs[1].pressed)
		assert_true(jummp_released, "jump released is action 1")

	func test_key_hold_for():
		var r = add_child_autofree(InputTracker.new())
		var sender = InputSender.new(r)

		sender.key_down("F").hold_seconds(.5)
		await wait_for_signal(sender.idle, 5)

		assert_eq(r.inputs.size(), 2, 'input size')
		var f_pressed = r.inputs[0].keycode == KEY_F and r.inputs[0].pressed
		assert_true(f_pressed, "f pressed is action 0")
		var f_released = r.inputs[1].keycode == KEY_F and !(r.inputs[1].pressed)


	func test_mouse_left_hold_for():
		var r = add_child_autofree(InputTracker.new())
		var sender = InputSender.new(r)

		sender.mouse_left_button_down(Vector2(1, 1)).hold_seconds(.5)
		await wait_for_signal(sender.idle, 5)

		assert_eq(r.inputs.size(), 2, 'input size')
		var left_pressed = r.inputs[0].button_index == MOUSE_BUTTON_LEFT and r.inputs[0].pressed
		assert_true(left_pressed, "left mouse pressed")
		var left_released = r.inputs[1].button_index == MOUSE_BUTTON_LEFT and !(r.inputs[1].pressed)
		assert_true(left_released, 'left mouse released')




class TestReleaseAll:
	extends "res://addons/gut/test.gd"

	func before_all():
		InputMap.add_action("jump")

	func before_each():
		Input.flush_buffered_events()

	func after_all():
		InputMap.erase_action("jump")


	func test_release_all_returns_self():
		var sender = InputSender.new(Input)
		var result = sender.release_all()
		assert_eq(result, sender)

	func test_release_key():
		var sender = InputSender.new(Input)

		sender.key_down("F")
		sender.release_all()
		assert_false(Input.is_key_pressed(KEY_F), 'key f should not be pressed anymore')

	func test_release_all_does_not_release_keys_released():
		var r = add_child_autofree(InputTracker.new())
		var sender = InputSender.new(r)

		sender.key_down("F").hold_seconds(.2)
		await sender.idle
		sender.release_all()

		assert_eq(r.inputs.size(), 2)

	func test_release_action():
		var sender = InputSender.new(Input)

		sender.action_down("jump")
		sender.release_all()
		assert_false(Input.is_action_pressed("jump"), 'jump should have been released')

	func test_release_all_does_not_release_actions_released():
		var r = add_child_autofree(InputTracker.new())
		var sender = InputSender.new(r)

		sender.action_down("jump").hold_seconds(.2)
		await sender.idle
		sender.release_all()

		assert_eq(r.inputs.size(), 2)

	func test_release_mouse_button():
		var sender = InputSender.new(Input)

		sender.mouse_left_button_down(Vector2(0, 0))
		sender.release_all()
		assert_false(Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT))

	func test_release_all_does_not_release_mouse_buttons_released():
		var r = add_child_autofree(InputTracker.new())
		var sender = InputSender.new(r)

		sender.mouse_right_button_down(Vector2(1,1)).hold_seconds(.2)
		await sender.idle
		sender.release_all()

		assert_eq(r.inputs.size(), 2)




class TestClear:
	extends "res://addons/gut/test.gd"

	func test_is_idle_after_clear():
		var sender = InputSender.new()

		sender.key_down("F").hold_seconds(1)
		sender.clear()
		assert_true(sender.is_idle())

	func test_frees_queue_items():
		var sender = InputSender.new()

		sender.key_down("F").hold_seconds(1)
		var q_item = sender._input_queue[0]
		sender.clear()
		assert_freed(q_item, 'q_item')

	func test_clears_next_queue_item():
		var sender = InputSender.new()

		sender.key_down("R").hold_seconds(1)
		sender.clear()
		assert_null(sender._next_queue_item)

	func test_echo_does_not_echo_after_clear():
		var r = autofree(InputTracker.new())
		var sender = InputSender.new(r)

		sender.key_down("Q")
		sender.clear()
		sender.key_echo()
		assert_eq(r.inputs.size(), 1)

	func test_hold_for_does_nothing_after_clear():
		var r = autofree(InputTracker.new())
		var sender = InputSender.new(r)

		sender.key_down("Q")
		sender.clear()
		sender.hold_seconds(.1)
		await wait_seconds(.5)
		assert_eq(r.inputs.size(), 1)

	func test_relative_mouse_motion_uses_0_0_after_clear():
		var r = autofree(InputTracker.new())
		var sender = InputSender.new(r)

		sender.mouse_motion(Vector2(10, 10), Vector2(50, 50))
		sender.clear()
		sender.mouse_relative_motion(Vector2(3, 3))

		assert_eq(r.inputs[1].position, Vector2(3, 3))

	func test_release_all_releases_no_keys_after_clear():
		var r = autofree(InputTracker.new())
		var sender = InputSender.new(r)

		sender.key_down("U")
		sender.clear()
		sender.release_all()

		assert_eq(r.inputs.size(), 1)

	func test_release_all_releases_no_actions_after_clear():
		var r = autofree(InputTracker.new())
		var sender = InputSender.new(r)
		InputMap.add_action("jump")

		sender.action_down("jump")
		sender.clear()
		sender.release_all()

		assert_eq(r.inputs.size(), 1)
		InputMap.erase_action("jump")

	func test_release_all_releases_no_mouse_buttons_after_clear():
		var r = autofree(InputTracker.new())
		var sender = InputSender.new(r)

		sender.mouse_left_button_down(Vector2(0, 0))
		sender.clear()
		sender.release_all()

		assert_eq(r.inputs.size(), 1)




class TestAtScriptLevel:
	extends GutTest

	var _sender = InputSender.new(Input)

	func after_each():
		_sender.release_all()
		_sender.clear()

	func test_one():
		_sender.key_down("F").hold_seconds(.1)\
			.key_down("A").hold_seconds(.2)\
			.key_down("P")

		await _sender.idle
		assert_false(Input.is_key_pressed(KEY_F))

	func test_two():
		_sender.key_down("F").hold_seconds(.1)\
			.key_down("A").hold_seconds(.2)

		await _sender.idle
		assert_false(Input.is_key_pressed(KEY_F))

	func test_three():
		_sender.key_down("F").hold_seconds(.1)\
			.key_down("A").hold_seconds(.2)

		await _sender.idle
		assert_false(Input.is_key_pressed(KEY_F))



