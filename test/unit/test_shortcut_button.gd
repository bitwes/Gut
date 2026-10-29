extends GutInternalTester


var ButtonScene = load('res://addons/gut/gui/ShortcutButton.tscn')
var button = null


func before_each():
	button = add_child_autofree(ButtonScene.instantiate())
	button._on_SetButton_pressed()


func press_key(keycode, ctrl = false, shift = false):
	var event = InputEventKey.new()
	event.keycode = keycode
	event.pressed = true
	event.ctrl_pressed = ctrl
	event.shift_pressed = shift
	button._unhandled_key_input(event)


func test_unmodified_function_keys_are_valid(keycode = use_parameters([KEY_F1, KEY_F4, KEY_F12, KEY_F35])):
	press_key(keycode)
	assert_true(button.is_valid())
	assert_false(button._ctrls.save_button.disabled)
	assert_eq(button.to_s(), OS.get_keycode_string(keycode))


func test_non_function_keys_still_require_modifiers(keycode = use_parameters([KEY_A, KEY_ESCAPE, KEY_F1 - 1, KEY_F35 + 1])):
	press_key(keycode)
	assert_false(button.is_valid())
	assert_true(button._ctrls.save_button.disabled)


func test_ctrl_shortcuts_remain_valid(keycode = use_parameters([KEY_A, KEY_F4])):
	press_key(keycode, true)
	assert_true(button.is_valid())
	assert_true(button.get_input_event().ctrl_pressed)


func test_shift_only_shortcuts_remain_invalid(keycode = use_parameters([KEY_A, KEY_F4])):
	press_key(keycode, false, true)
	assert_false(button.is_valid())
	assert_true(button._ctrls.save_button.disabled)


func test_modifier_keycode_without_modifier_flags_is_not_valid():
	press_key(KEY_SHIFT)
	assert_false(button.is_valid())


func test_save_function_key_and_restore_shortcut():
	press_key(KEY_F4)
	button._on_SaveButton_pressed()
	assert_false(button._editing)
	var shortcut = button.get_shortcut()
	assert_eq(shortcut.events[0].keycode, KEY_F4)
	button.clear_shortcut()
	button.set_shortcut(shortcut)
	assert_eq(button.to_s(), 'F4')
	assert_true(button.is_valid())


func test_cancel_restores_previous_shortcut():
	press_key(KEY_A, true)
	button._on_SaveButton_pressed()
	button._on_SetButton_pressed()
	press_key(KEY_F4)
	button.cancel()
	assert_eq(button.get_input_event().keycode, KEY_A)
	assert_true(button.get_input_event().ctrl_pressed)
	assert_false(button._editing)


func test_released_key_does_not_replace_function_shortcut():
	press_key(KEY_F4)
	var event = InputEventKey.new()
	event.keycode = KEY_A
	event.pressed = false
	button._unhandled_key_input(event)
	assert_eq(button.get_input_event().keycode, KEY_F4)


func test_function_shortcut_matches_key_after_config_file_round_trip():
	press_key(KEY_F4)
	button._on_SaveButton_pressed()
	var config = ConfigFile.new()
	config.set_value('main', 'shortcut', button.get_shortcut())
	var path = 'user://i820_shortcut_test.cfg'
	assert_eq(config.save(path), OK)
	var restored = ConfigFile.new()
	assert_eq(restored.load(path), OK)
	button.clear_shortcut()
	button.set_shortcut(restored.get_value('main', 'shortcut'))
	var event = InputEventKey.new()
	event.keycode = KEY_F4
	event.pressed = true
	assert_true(button.get_shortcut().matches_event(event))
	assert_true(button.is_valid())
	assert_eq(button.to_s(), 'F4')
	assert_eq(DirAccess.remove_absolute(path), OK)
