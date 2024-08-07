extends GutTest

class MyObject:
	extends ColorRect

	var button = Button.new()
	var counter = 0

	func _ready():
		size = Vector2(100, 100)
		button.size = Vector2(50, 50)
		add_child(button)
		button.pressed.connect(_on_button_pressed)

	func _on_button_pressed():
		counter += 1
		button.disabled = counter >= 10


class TestUsingSignalsAndProperties:
	extends GutTest

	func test_counter_increased_when_button_pressed():
		var my_object = add_child_autofree(MyObject.new())
		var orig_count = my_object.counter
		my_object.button.pressed.emit()
		assert_gt(my_object.counter, orig_count)

	func test_button_disabled_when_counter_hits_ten():
		var my_object = add_child_autofree(MyObject.new())
		my_object.counter = 9
		my_object.button.pressed.emit()
		assert_true(my_object.button.disabled)



class TestUsingInputMocking:
	extends GutTest

	var _sender = InputSender.new(Input)

	func before_all():
		InputMap.add_action("test_action")

	func after_each():
		_sender.release_all()
		_sender.clear()
		await wait_frames(1)

	func after_all():
		InputMap.erase_action("test_action")

	# Don't touch the mouse while this is running or it might fail.
	# Always fails in headless mode.
	func test_counter_increased_when_button_pressed():
		var my_object = add_child_autofree(MyObject.new())
		var orig_count = my_object.counter

		_sender.mouse_left_button_down(my_object.button.global_position)\
			.hold_for(.1)\
			.wait_frames(5)
		await _sender.idle

		assert_gt(my_object.counter, orig_count)

	func test_button_disabled_when_counter_hits_ten():
		var my_object = add_child_autofree(MyObject.new())
		my_object.counter = 9

		# click twice to make sure it increments to 10 but
		# then not past it.
		_sender.mouse_left_button_down(my_object.button.global_position)\
			.hold_for(.1)\
			# click 2
			.mouse_left_button_down()\
			.hold_for(.1)\
			.wait_frames(5)
		await _sender.idle

		assert_eq(my_object.counter, 10)


class TestMouseAndRigidBody:
	extends GutTest

	# 256 x 256 sprite with collision shape over most of it.
	var GutRigidBody = load("res://test/resources/gut_rigid_body.tscn")

	var _sender = InputSender.new(Input)

	func before_all():
		_sender.mouse_warp = true

	func after_each():
		_sender.release_all()
		_sender.clear()
		await wait_frames(1)

	func test_mouse_enter_modulates_sprite():
		var rb = add_child_autofree(GutRigidBody.instantiate())
		# Must freeze or it will fall
		rb.freeze = true
		rb.position = Vector2(300, 300)

		_sender.mouse_motion(Vector2(140, 300))\
			.mouse_relative_motion(Vector2(100, 0))\
			.wait_frames(1)
		await _sender.idle

		assert_ne(rb.sprite.modulate, Color(1, 1, 1))

	func test_mouse_exit_removes_modulate():
		var rb = add_child_autofree(GutRigidBody.instantiate())
		rb.freeze = true
		rb.position = Vector2(300, 300)

		_sender.mouse_motion(Vector2(140, 300))\
			.mouse_relative_motion(Vector2(100, 0))\
			.wait_frames(10)\
			.mouse_relative_motion(Vector2(-100, 0))\
			.wait_frames(10)
		await _sender.idle

		assert_eq(rb.sprite.modulate, Color(1, 1, 1))

