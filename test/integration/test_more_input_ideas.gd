extends GutTest


class DraggableButton:
	extends Button

	var _mouse_down = false

	func _gui_input(event):
		if(event is InputEventMouseButton):
			_mouse_down = event.pressed
		elif(event is InputEventMouseMotion and _mouse_down):
			position += event.relative


var _sender_inp = InputSender.new(Input)


func after_each():
	_sender_inp.release_all()
	_sender_inp.clear()


func _print_emitted_signals(thing):
	_signal_watcher.print_signal_summary(thing)





func test_clicking_two_buttons_triggers_focus_events_with_click_at():
	var btn = Button.new()
	watch_signals(btn)
	btn.size = Vector2(100, 100)
	btn.position = Vector2(50, 50)
	add_child_autofree(btn)

	var btn2 = Button.new()
	watch_signals(btn2)
	btn2.size = Vector2(100, 100)
	btn2.position = Vector2(160, 50)
	add_child_autofree(btn2)

	var sender = _sender_inp
	sender.mouse_warp = true

	var start_pos = Vector2(100, 75)
	for i in 11:
		var new_pos = start_pos + Vector2(i * 10, 0)
		await sender.mouse_left_click_at(new_pos).idle

	assert_signal_emitted(btn, 'focus_entered')
	assert_signal_emitted(btn, 'focus_exited')
	assert_signal_emitted(btn2, 'focus_entered')
	if(is_failing()):
		_print_emitted_signals(btn)
		_print_emitted_signals(btn2)


func test_clicking_two_buttons_triggers_focus_events_with_click_ctrl():
	var btn = Button.new()
	watch_signals(btn)
	btn.size = Vector2(100, 100)
	btn.position = Vector2(50, 50)
	add_child_autofree(btn)

	var btn2 = Button.new()
	watch_signals(btn2)
	btn2.size = Vector2(100, 100)
	btn2.position = Vector2(160, 50)
	add_child_autofree(btn2)

	var sender = _sender_inp
	sender.mouse_warp = true

	var start_pos = Vector2(100, 75)
	for i in 10:
		if(i % 2 ==0):
			sender.mouse_left_click_on(btn)
		else:
			sender.mouse_left_click_on(btn2)

	await sender.idle
	assert_signal_emit_count(btn, 'focus_entered', 5)
	assert_signal_emit_count(btn, 'focus_exited', 5)
	assert_signal_emit_count(btn2, 'focus_entered', 5)
	assert_signal_emit_count(btn2, 'focus_exited', 4)

	if(is_failing()):
		_print_emitted_signals(btn)
		_print_emitted_signals(btn2)


#     50 ->|         |<- 150
func test_clicking_things_with_input_as_receiver():
	var btn = Button.new()
	watch_signals(btn)
	btn.size = Vector2(100, 100)
	btn.position = Vector2(50, 50)
	add_child_autofree(btn)

	var sender = _sender_inp
	sender.mouse_warp = false

	var start_pos = Vector2i(25, 75)
	var frames_to_wait = 10
	for i in 15:
		var new_pos = start_pos + Vector2i(i * 10, 0)
		await sender.wait_frames(frames_to_wait)\
			.mouse_left_button_down(new_pos)\
			.hold_frames(frames_to_wait)\
			.wait_frames(frames_to_wait).idle

	_print_emitted_signals(btn)
	assert_signal_emitted(btn, 'pressed')
	assert_signal_emitted(btn, 'button_down')
	assert_signal_emitted(btn, 'button_up')
	assert_signal_emitted(btn, 'gui_input')
	assert_signal_emitted(btn, 'focus_entered')


func test_clicking_things_with_button_as_receiver():
	var btn = Button.new()
	watch_signals(btn)
	btn.size = Vector2(100, 100)
	btn.position = Vector2(50, 50)
	add_child_autofree(btn)

	var sender = InputSender.new(btn)
	sender.mouse_warp = true

	var start_pos = Vector2i(25, 75)
	for i in 15:
		var new_pos = start_pos + Vector2i(i * 10, 0)
		await sender.wait_frames(1)\
			.mouse_left_button_down(new_pos)\
			.hold_frames(1)\
			.wait_frames(1).idle

	_print_emitted_signals(btn)
	assert_signal_not_emitted(btn, 'pressed')
	assert_signal_not_emitted(btn, 'button_down')
	assert_signal_not_emitted(btn, 'button_up')
	assert_signal_not_emitted(btn, 'gui_input')
	assert_signal_not_emitted(btn, 'focus_entered')
	assert_signal_not_emitted(btn, 'focus_exited')
