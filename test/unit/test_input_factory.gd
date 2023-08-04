extends GutTest


class TestCreateKeyEvents:
	extends GutTest

	func test_key_up_creates_event_for_key():
		var event = InputFactory.key_up(KEY_A)
		assert_is(event, InputEventKey, 'is InputEventKey')
		assert_eq(event.keycode, KEY_A)
		assert_false(event.pressed, "pressed")

	func test_key_up_converts_lowercase_string_to_keycode():
		var event = InputFactory.key_up('a')
		assert_eq(event.keycode, KEY_A)

	func test_key_up_converts_uppercase_string_to_keycode():
		var event = InputFactory.key_up('A')
		assert_eq(event.keycode, KEY_A)

	func test_key_down_creates_event_for_key():
		var event = InputFactory.key_down(KEY_B)
		assert_is(event, InputEventKey, 'is InputEventKey')
		assert_eq(event.keycode, KEY_B)
		assert_true(event.pressed, "pressed")

	func test_key_down_converts_lowercase_string_to_keycode():
		var event = InputFactory.key_down('z')
		assert_eq(event.keycode, KEY_Z)


class TestCreateActionEvents:
	extends GutTest

	func test_action_up_creates_correct_class():
		var e = InputFactory.action_up("foo", 1.0)
		assert_is(e, InputEventAction)

	func test_action_up_sets_properties():
		var e = InputFactory.action_up("foo", .5)
		assert_eq(e.action, "foo", "action name")
		assert_eq(e.pressed, false, "pressed")
		assert_eq(e.strength, .5, 'strength')

	func test_action_up_defaults_strength():
		var e = InputFactory.action_up("foo")
		assert_eq(e.strength, 1.0)

	func test_action_down_creates_correct_class():
		var e = InputFactory.action_down("foo", 1.0)
		assert_is(e, InputEventAction)

	func test_action_down_sets_properties():
		var e = InputFactory.action_down("foo", .5)
		assert_eq(e.action, "foo", "action name")
		assert_eq(e.pressed, true, "pressed")
		assert_eq(e.strength, .5, 'strength')

	func test_action_down_defaults_strength():
		var e = InputFactory.action_down("foo")
		assert_eq(e.strength, 1.0)


class TestMouseButtons:
	extends GutTest

	func assert_mouse_event_props(method, pressed, button_index):
		var event = InputFactory.call(method, (Vector2(10, 10)))
		assert_is(event, InputEventMouseButton, 'correct class')
		assert_eq(event.position, Vector2(10, 10), 'position')
		assert_eq(event.pressed, pressed, 'pressed')
		assert_eq(event.button_index, button_index, 'button_index')

	func assert_mouse_event_positions(method):
		var event = InputFactory.call(method, Vector2(10, 10), Vector2(11, 11))
		assert_eq(event.position, Vector2(10, 10), "position")
		assert_eq(event.global_position, Vector2(11, 11), "global position")

	func test_lmb_down():
		assert_mouse_event_props("mouse_left_button_down", true, MOUSE_BUTTON_LEFT)
		assert_mouse_event_positions("mouse_left_button_down")

	func test_lmb_up():
		assert_mouse_event_props("mouse_left_button_up", false, MOUSE_BUTTON_LEFT)
		assert_mouse_event_positions("mouse_left_button_up")

	func test_double_clickk():
		assert_mouse_event_props("mouse_double_click", false, MOUSE_BUTTON_LEFT)
		assert_mouse_event_positions("mouse_double_click")
		var event = InputFactory.mouse_double_click(Vector2(1, 1))
		assert_true(event.double_click, "double click")

	func test_rmb_down():
		assert_mouse_event_props("mouse_right_button_down", true, MOUSE_BUTTON_RIGHT)
		assert_mouse_event_positions("mouse_right_button_down")

	func test_rmb_up():
		assert_mouse_event_props("mouse_right_button_up", false, MOUSE_BUTTON_RIGHT)
		assert_mouse_event_positions("mouse_right_button_up")

class TestMouseMotion:
	extends GutTest

	func test_creates_correct_event_type():
		var e = InputFactory.mouse_motion(Vector2(1, 1))
		assert_is(e, InputEventMouseMotion)

	func test_properties_are_set():
		var e = InputFactory.mouse_motion(Vector2(1, 1))
		assert_eq(e.position, Vector2(1, 1), 'position')
		assert_eq(e.global_position, Vector2(0, 0), 'default global_position')

	func test_can_specify_global_position():
		var e = InputFactory.mouse_motion(Vector2(1, 1), Vector2(2, 2))
		assert_eq(e.global_position, Vector2(2, 2), 'global_position')

	func test_mouse_relative_motion_makes_new_base_motion_without_last_event():
		var e = InputFactory.mouse_relative_motion(Vector2(10, 10))
		assert_eq(e.position, Vector2(10, 10))

	func test_mouse_relative_offsets_last_event_position_and_global_position():
		var last_event = InputFactory.mouse_motion(Vector2(10, 10), Vector2(20, 20))
		var relative = InputFactory.mouse_relative_motion(Vector2(2, 2), last_event)
		assert_eq(relative.position, Vector2(12, 12), 'position')
		assert_eq(relative.global_position, Vector2(22, 22), 'global_position')

	func test_mouse_relative_sets_relative_to_offset():
		var last_event = InputFactory.mouse_motion(Vector2(10, 10), Vector2(20, 20))
		var relative = InputFactory.mouse_relative_motion(Vector2(2, 2), last_event)
		assert_eq(relative.relative, Vector2(2, 2), 'position')

	func test_mouse_relative_sets_speed_defaults_to_zero_zero():
		var last_event = InputFactory.mouse_motion(Vector2(10, 10), Vector2(20, 20))
		var relative = InputFactory.mouse_relative_motion(Vector2(2, 2), last_event)
		assert_eq(relative.velocity, Vector2(0, 0))

	func test_mouse_relatvie_sets_speed_when_specified():
		var last_event = InputFactory.mouse_motion(Vector2(10, 10), Vector2(20, 20))
		var relative = InputFactory.mouse_relative_motion(Vector2(2, 2), last_event, Vector2(1, 1))
		assert_eq(relative.velocity, Vector2(1, 1))

	func test_mouse_relative_sets_speed_when_last_motion_not_sent():
		var event = InputFactory.mouse_relative_motion(Vector2(1, 1), null, Vector2(10, 10))
		assert_eq(event.velocity, Vector2(10, 10))


class TestJoypadButton:
	extends GutTest

	func test_creates_joypad_button_event():
		var e = InputFactory.joypad_button(1, true)
		assert_is(e, InputEventJoypadButton)

	func test_sets_values():
		var e = InputFactory.joypad_button(1, true, .5)
		assert_eq(e.button_index, 1, 'button index')
		assert_eq(e.pressed, true, 'pressed')
		assert_eq(e.pressure, .5, 'pressure')

	# Ensure that values are ok with the engine, if this fails then the method
	# should validate input.
	func test_can_make_event_with_invalid_button_indexes():
		var e = InputFactory.joypad_button(-5, true)
		assert_eq(e.button_index, -5, 'less than -1')

		e = InputFactory.joypad_button(JOY_BUTTON_MAX + 1, false)
		assert_eq(e.button_index, JOY_BUTTON_MAX + 1, 'more than max')


class TestJoypadMotion:
	extends GutTest

	func test_creates_joypad_motion_event():
		var e = InputFactory.joypad_motion(1, .5)
		assert_is(e, InputEventJoypadMotion)

	func test_sets_values():
		var e = InputFactory.joypad_motion(2, .9)
		assert_eq(e.axis, 2, 'axis')
		assert_between(e.axis_value, .89, .91, 'axis_valued')

	# This test generates an engine error.
	func test_can_make_event_with_invalid_values():
		var e = InputFactory.joypad_motion(JOY_AXIS_MAX + 1, 5.0)
		assert_eq(e.axis_value, 5.0, 'axis_value')
		# Engine prevents this from being set to an invalid value.  If this
		# assert fails then the behavior of joypad_motion should be re-evaluated
		# since the engine behavior has changed.
		assert_eq(e.axis, 0, 'axis')




class TestMagnifyGesture:
	extends GutTest

	func test_creates_magnify_gesture_event():
		var e = InputFactory.magnify_gesture(Vector2(1,1))
		assert_is(e, InputEventMagnifyGesture)

	func test_sets_values():
		var e = InputFactory.magnify_gesture(Vector2(10, 10), .5)
		assert_eq(e.position, Vector2(10, 10), 'position')
		assert_eq(e.factor, .5, 'factor')

	func test_factor_defaults_to_1():
		var e = InputFactory.magnify_gesture(Vector2(10, 10))
		assert_eq(e.factor, 1.0, 'factor')



class TestPanGesture:
	extends GutTest

	func test_creates_pan_gesture_event():
		var e = InputFactory.pan_gesture(Vector2(1,1), Vector2(2, 2))
		assert_is(e, InputEventPanGesture)

	func test_sets_values():
		var e = InputFactory.pan_gesture(Vector2(10, 10), Vector2(1, 1))
		assert_eq(e.position, Vector2(10, 10), 'position')
		assert_eq(e.delta, Vector2(1, 1), 'delta')

