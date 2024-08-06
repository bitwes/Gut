# Mocking Input
One of the first things you should consider when mocking input is "maybe I shouldn't mock input".  Mocking input can be slow, tedious, and error prone, especially when testing mouse interactions.  For example, if you are trying to validate how a button click is handled, it's much faster, easier, and reliable to emit the `pressed` signal for the button instead of simulating the mouse input to click the button.

There are examples below on handling mouse input and alternative approaches below.

In general, testing mouse input is cumbersome and should be avoided when possible.  There are reasons to use it (covered below) but you should defer to invoking logic more directly when possible.


## Usage
The `InputSender` class operates on one or more receivers.  It will create and send `InputEvent` instances to all of its receivers.

There are two ways you could be processing your input.  You could be using the various `input` methods to receive input events and process them.  The other way is to interact with the `Input` singleton and detect input in the `_process` and `_physics_process` methods.  `InputSender` works with both approaches, but using `InputSender` differs for each approach.


Use [`Input` as a receiver](Input-Sender-Input-Singleton):  If you directly reference `Input` in your object.  _(You can use this approach even if you are not refrencing `Input` directly but it is more complicated.)_

Use [Input Methods](Input-Sender-Input-Methods):  If you are handling `InputEvent`s through `_input`, `_gui_input`, and/or `_unhandled_input`.If not, you can use either approach, but using `Input` is more complicated so you should use the  approach.


## Working around Testing Input
I want to mock input just as much as you do.  It sounds cool and fun and looks neat.  I want to watch that mouse move around and click things.  Unfortunately, in many cases it is overkill, slow, and overly complicated.  It is better to test our objects more directly even if means making something public that wouldn't normally be, or being sneaky and operating on private properies.

### Emit signals manually and check properties whenever possible, instead of simulating clicks.
Here's MyObject and two inner-test-classes that test
* the button on MyObject increments the counter
* the button becomes disabled when the counter is incremented to 10 or more.

MyObject does not handle any input events directly, just the signals and properties of a `Button`.  In these kinds of scenarios it is better to use signals and properties instead of simulating input.

```gdscript
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


# ----------------------------------------------
# Testing using the pressed signal and disabled properties instead of
# simulating clicks.  This tests MyObject's logic more directly.
# ----------------------------------------------
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

# ----------------------------------------------
# Testing by mocking mouse input.
# Note:
# * Don't touch the mouse while these tests are running or they
#   will fail.
# * These tests will always fail in headless mode.
# ----------------------------------------------
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
```
Using mouse input to test the button is more complicated and slower.  It is also a case of "testing the framework" since we are not handling the input events ourselves and relying of functionality provided by the `Button`.  In this scenario we want to test how we are using/manipulating the button, not how the button handles the mouse, so it's better to not mock input.



* wrappers for things that get the mouse position (`get_viewport().get_mouse_position()`) that you can double/stub.














## When to Use Mouse Mocking
There are a lot of reasons to use mouse input mocking.  This is not an exhaustive list.


### Cases I can think of where mocking input is useful in unit tests:
You are testing input handling that you have created, such as:
* Dragging objects (strictly that follow the mouse when dragged, not dragging them into something else)
* Logic when mouse enters/exits

Cases for integration tests
* Layering logic, where things should/shouldn't recieve mouse events when they are in front/behind other objects.
* Complex mouse handling logic (or things I can't think of right now).


## Notes
* You should probably avoid having to send mouse inputs to `Input` as much as possible.
* Mocking input in unit tests is more suited to test controller/keyboard/action input.
* When running tests that send InputEvents to `Input` you must refrain from touching the mouse or keyboard or it may make the test fail.
* Tests that send `InputEvent`s to `Input` cannot be run head `--headless` mode.



The Input mocking is more useful when you have implemented complicated logic in your input handling. Like if you have made your own "pressed" event on an Area2D by

If you are:
* handling mouse enter/exit
* handling mouse buttons' pressed events (left/right/center buttons up/down)
* detecting a click manually through `input` events and emitting your own signal.


* [Input Sender](Input-Sender)
* [Input Sender Using Input Methods](Input-Sender-Input-Methods)
* [Input Sender Using Input Singleton](Input-Sender-Input-Singleton)
* [Input Factory](Input-Factory)