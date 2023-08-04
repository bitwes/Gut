extends GutTest

class SuperButton:
	extends Button

	func p(s1='', s2='', s3='', s4='', s5='', s6=''):
		print(s1, s2, s3, s4, s5, s6)

	func pevent(txt, event):
		return
		print(txt, ':  ', event)
		# if(event is InputEventMouse):
		# 	print(txt, ':  ', event.position, event.global_position)
		# else:
		# 	print(txt, ':  ', event)

	func _gui_input(event):
		pevent('gui:      ', event)

	func _input(event):
		pevent('input:     ', event)

	func _unhandled_input(event):
		pevent('unhandled:  ', event)


class DraggableButton:
	extends SuperButton

	var _mouse_down = false

	func _gui_input(event):
		super._gui_input(event)
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
	return




var drag_durations = ParameterFactory.named_parameters(['duration'], [0, .5, 1])
func test_drag_something_with_drag(p = use_parameters(drag_durations)):
	var btn = DraggableButton.new()
	watch_signals(btn)
	btn.size = Vector2(100, 100)
	btn.position = Vector2(50, 50)
	add_child_autofree(btn)

	var sender = _sender_inp
	sender.set_auto_flush_input(true)
	sender.mouse_warp = false
	sender.draw_mouse = true

	var expected_pos = btn.position + Vector2(30, 0)
	sender.mouse_left_button_drag(btn.position + Vector2(10, 10), Vector2(30, 0), p.duration)
	await sender.idle
	assert_eq(btn.position, expected_pos, 'After first drag')

	expected_pos = btn.position + Vector2(0, 50)
	sender.mouse_left_button_drag_control(btn, Vector2(0, 50), p.duration)
	await sender.idle
	assert_eq(btn.position, expected_pos, 'After second drag')

	expected_pos = btn.position + Vector2(50, 50)
	sender.mouse_left_button_drag_control(btn, Vector2(50, 50), p.duration)
	await sender.idle
	assert_eq(btn.position, expected_pos, 'After third drag')


func test_clicking_two_buttons_triggers_focus_events_with_click_at():
	var btn = SuperButton.new()
	watch_signals(btn)
	btn.size = Vector2(100, 100)
	btn.position = Vector2(50, 50)
	add_child_autofree(btn)

	var btn2 = SuperButton.new()
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
	var btn = SuperButton.new()
	watch_signals(btn)
	btn.size = Vector2(100, 100)
	btn.position = Vector2(50, 50)
	add_child_autofree(btn)

	var btn2 = SuperButton.new()
	watch_signals(btn2)
	btn2.size = Vector2(100, 100)
	btn2.position = Vector2(160, 50)
	add_child_autofree(btn2)

	var sender = _sender_inp
	sender.mouse_warp = true

	var start_pos = Vector2(100, 75)
	for i in 10:
		if(i % 2 ==0):
			sender.mouse_left_click_ctrl(btn)
		else:
			sender.mouse_left_click_ctrl(btn2)

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
	var btn = SuperButton.new()
	watch_signals(btn)
	btn.size = Vector2(100, 100)
	btn.position = Vector2(50, 50)
	add_child_autofree(btn)

	var sender = _sender_inp
	sender.mouse_warp = false

	var start_pos = Vector2i(25, 75)
	for i in 15:
		var new_pos = start_pos + Vector2i(i * 10, 0)
		await sender.wait_frames(1)\
			.mouse_left_button_down(new_pos)\
			.hold_frames(1)\
			.wait_frames(1).idle

	_print_emitted_signals(btn)
	assert_signal_emitted(btn, 'pressed')
	assert_signal_emitted(btn, 'button_down')
	assert_signal_emitted(btn, 'button_up')
	assert_signal_emitted(btn, 'gui_input')


func test_clicking_things_with_button_as_receiver():
	var btn = SuperButton.new()
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

	GutUtils.pretty_print(_lgr._deprecated_calls)

