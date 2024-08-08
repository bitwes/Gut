# Mocking Input
One of the first things you should consider when mocking input is "maybe I shouldn't mock input".  Mocking input can be slow, tedious, and error prone, __especially when testing mouse interactions__.  For example, if you are trying to validate how a button click is handled, it's much faster, easier, and reliable to emit the `pressed` signal for the button instead of simulating the mouse input to click the button.

There are examples on handling mouse input and alternative approaches below.

In general, testing mouse input is cumbersome and should be avoided when possible.  There are plenty fo reasons to use it (some covered below) but you should defer to invoking logic more directly when possible.

As of 9.3.1 you can use `GutInputSender` instead of `InputSender`. It's the same thing.  `GutInputSender` is just a class_name introduced in 9.3.1 for all your strict-typing and auto-complete happiness.




## Alright, I Want to Mock Input


### Not Using GutInputSender
If you want to move the mouse somewhere in your tests you can use `DisplayServer.warp_mouse()` to move the mouse to a position.  This is functionally the same as moving the mouse and what `GutInputSender` uses when `mouse_warp` is enabled.

You can create your own `InputEvent*` instances and pass them to whatever you want or pass them to `Input.parse_input_event()` to simulate input.

`GutInputFactory` is a static class with convenience methods for creating `InputEvent*` instances which you can use however you like.


### Using GutInputSender
`GutInputSender` (the newly introduced class name for `InputSender`) creates and sends `InputEvent*` instances to any number of receivers, including `Input`.  It has utilities for scripting a list of inputs that playback in real time (similar to how you would use a tween).  As well as methods to reset input state when using `Input` as a receiver.

There are two common ways to process input.
1.  Use `_input`, `_gui_input`, `_unhandled_input` to receive events and process them.
2.  Use the `Input` singleton to detect user input in `_process` and/or `_physics_process`.
3.  Both of these or neither of these via some other way that you should tell me about.

`GutInputSender` is compatable with both approaches but usage is different.  When using the various `input` methods `GutInputSender` can send events directly to those methods.  When using `Input`, `GutInputSender` must interact with a global singleton which has additional steps to ensure state does not leak from test to test.

See [Input-Sender](Input-Sender) for `GutInputSender` class reference.

See [`Input` as a receiver](Input-Sender-Input-Singleton) when your object directly references `Input` to process input.

See [Input Methods](Input-Sender-Input-Methods) if you are using `_input`, `_gui_input`, and/or `_unhandled_input` to process input.




## Examples
### Down Right Fierce (a Street Fighter fireball test)
This example assumes input is being handled through  `_input()`.

```gdscript
func test_throw_fireball():
	var player = add_child_autofree(Ryu.instantiate())
	var sender = GutInputSender.new(player)

	sender\
		.action_down("down").hold_frames(5)\
		.action_down("down-forward").hold_frames(5)\
		# no "hold" calls since the fireball comes out when
		# forward + punch is pressed.  With no "hold" or
		# "wait" between forward and fierce-punch this
		# means they will be sent on the same frame.
		.action_down("forward").\
		.action_down("fierce-punch").\
		.wait_frames(5)
	await sender.idle

	assert_true(player.is_doing_hadouken)
```
You could take this a step farther and make this a parameterized test which passes values to `hold_frames` so that you can test different input timings.


### Overlapping Down/UP and Sending Keys
In the above example we use `hold_frames` to hold an action down for a duration.  This works for sequential input, but if you need to layer inputs in your tests then you can call the various "down" and "up" methods.  This example uses `key_down`/`key_up` but the same approach works for `action_down`/`action_up` and any other "down"/"up" methods.

```gdscript
func test_foo():
    var player = add_child_autofree(Player.new())
    var sender = InputSender.new(player)

    # press a, then b, then release a, then release b
    sender.key_down("a").wait_secs(.1)\
        .key_down(KEY_B).wait_secs(.1)\
        .key_up("a").wait_secs(.1)\
        .key_up(KEY_B)
    await sender.idle

    assert_true(player.something_happened())
```


### Handling Mouse-enter/exit
This example uses `Input` as a receiver.  Since `Input` is a global singleton we have to take additiional steps to make sure that input states, such as a button/action being down, do not leak between tests.

This also uses `mouse_warp` which causes the cursor to to move to the location of any `mouse_` events.  This is required to test enter/exit events.

For a test like this you should probably just emit `mouse_enter`/`mouse_exit` signals in the test, but maybe you are testing something more complicated.
```gdscript
extends GutTest

# 256 x 256 sprite with collision shape over most of it.  The sprite
# is a public @onready variable named `sprite`.
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

	assert_eq(rb.sprite.modulate, Color(1, 1, 1))```
```




## Not Mocking Mouse Input
I want to mock input just as much as you do.  It sounds cool and fun and looks neat.  I want to watch that mouse move around and click things.  Unfortunately, in many cases it is overkill, slow, and overly complicated.  It is better to test our objects more directly even if means making something public that wouldn't normally be, or being sneaky and operating on private properies.


### Emitting Signals vs Input Mocking (a very short case study)
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
			.hold_secs(.1)\
			.wait_frames(5)
		await _sender.idle

		assert_gt(my_object.counter, orig_count)

	func test_button_disabled_when_counter_hits_ten():
		var my_object = add_child_autofree(MyObject.new())
		my_object.counter = 9

		# click twice to make sure it increments to 10 but
		# then not past it.
		_sender.mouse_left_button_down(my_object.button.global_position)\
			.hold_secs(.1)\
			# click 2
			.mouse_left_button_down()\
			.hold_secs(.1)\
			.wait_frames(5)
		await _sender.idle

		assert_eq(my_object.counter, 10)
```
Using mouse input to test the button is more complicated and slower.  It is also a case of "testing the framework" since we are not handling the input events ourselves and relying of functionality provided by the `Button`.  In this scenario we want to test how we are using/manipulating the button, not how the button handles the mouse, so it's better to not mock input.




## Faking mouse position
You might be using `get_viewport().get_mouse_position()` to determine where the mouse is.  Instead of mocking the input to move the mouse, we can restructure the code to make sending it values easier.

One approach would be to make the methods that operate on mouse position public and have them accept the mouse's position.  This is probably the cleanest approach, but could make tests too verbose when performing integration tests with complicated mouse interations.

Another approach is to create a wrapper method in your object to get the mouse position.  You can then create a paritial double of that object and stub the return value.  This requires stubbing a "private" method, which is bad practice in general...but since we cannot stub the viewport this is about the only choice.

MyObject
```gdscript
extends Node2D
...
func _where_is_the_mouse():
	return get_viewport().get_mouse_position()
...
```
test_my_object
```gdscript
func test_when_mouse_is_at_100_100_something_happens():
	var my_object = add_child_autofree(parital_double(MyObject).new())
	stub(my_object._where_is_the_mouse).to_return(Vector2(100, 100))
	# wait some frames for my_object to process the mouse position
	await wait_frames(5)
	assert_true(my_object.something_happened())
```



All the Input links:
* [Input Sender](Input-Sender)
* [Input Sender Using input Virtual Methods](Input-Sender-Input-Methods)
* [Input Sender Using the Input Singleton](Input-Sender-Input-Singleton)
* [Input Factory](Input-Factory)