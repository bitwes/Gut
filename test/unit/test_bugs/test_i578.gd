extends GutTest

class InputSingletonTracker:
	extends Node
	var input_frames = []

	var _frame_counter = 0

	func _process(delta):
		_frame_counter += 1
		if Input.is_anything_pressed():
			input_frames.append(_frame_counter)

class TestInputSingleton:
	extends "res://addons/gut/test.gd"
	var _sender = InputSender.new(Input)

	func before_all():
		InputMap.add_action("jump")

	func after_all():
		InputMap.erase_action("jump")

	func after_each():
		_sender.release_all()
		_sender.clear()

	func test_raw_input_press():
		var r = add_child_autofree(InputSingletonTracker.new())

		Input.action_press("jump")
		await wait_frames(10)
		Input.action_release("jump")

		assert_gt(r.input_frames.size(), 1, 'input size')
	
	func test_input_sender_press():
		var r = add_child_autofree(InputSingletonTracker.new())

		_sender.action_down("jump").hold_for('10f')
		await wait_for_signal(_sender.idle, 5)

		assert_gt(r.input_frames.size(), 1, 'input size')
