extends GutTest

var ShortcutButtonScene = load('res://addons/gut/gui/ShortcutButton.tscn')


func _make_button():
	return add_child_autofree(ShortcutButtonScene.instantiate())


func _make_key_shortcut():
	var event = InputEventKey.new()
	event.keycode = KEY_T
	event.ctrl_pressed = true
	var sc = Shortcut.new()
	sc.events.append(event)
	return sc


func test_get_shortcut_has_no_events_when_nothing_set():
	var btn = _make_button()
	var sc = btn.get_shortcut()
	assert_eq(sc.events.size(), 0)


func test_get_shortcut_has_no_valid_event_after_clear():
	var btn = _make_button()
	btn.set_shortcut(_make_key_shortcut())
	btn.clear_shortcut()
	assert_false(btn.get_shortcut().has_valid_event())


func test_get_shortcut_contains_event_when_set():
	var btn = _make_button()
	btn.set_shortcut(_make_key_shortcut())
	var sc = btn.get_shortcut()
	assert_eq(sc.events.size(), 1)
	assert_eq(sc.events[0].keycode, KEY_T)


func test_set_shortcut_round_trips_empty_shortcut():
	var btn = _make_button()
	btn.set_shortcut(btn.get_shortcut())
	assert_eq(btn.to_s(), '')
