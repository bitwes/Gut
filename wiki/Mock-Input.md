# <div class="warning">This page has not been updated for GUT 9.0.0 or Godot 4.  There could be incorrect information here.</div>
# Input Sender
The `InputSender` class can be used to send `InputEvent*` events to various objects.  It also allows you to script out a series of inputs and play them back in real time.  You could use it to:
* Verify that jump height depends on how long the jump button is pressed.
* Double tap a direction performs a dash.
* Down, Down-Forward, Forward + punch throws a fireball.

And much much more.

# Methods
|
[add_receiver](#add_receiver)|
[get_receivers](#get_receivers)|
[release_all](#release_all)|
[clear](#clear)|
[is_idle](#is_idle)|
[wait](#wait)|
[wait_frames](#wait_frames)|
[wait_secs](#wait_secs)|
[hold_for](#hold_for)|
[mouse_set_position](#mouse_set_position)|
[set_auto_flush_input](#set_auto_flush_input)|
[get_auto_flush_input](#get_auto_flush_input)|

# Sending InputEvents
|
[send_event](#send_event)|
[action_down](#action_down)|
[action_up](#action_up)|
[key_down](#key_down)|
[key_echo](#key_echo)|
[key_up](#key_up)|
[mouse_double_click](#mouse_double_click)|
[mouse_left_button_down](#mouse_left_button_down)|
[mouse_left_button_up](#mouse_left_button_up)|
[mouse_motion](#mouse_motion)|
[mouse_relative_motion](#mouse_relative_motion)|
[mouse_right_button_down](#mouse_right_button_down)|
[mouse_right_button_up](#mouse_right_button_up)|

# Signals
* `idle` - Emitted when all events in the input queue have been sent.


# Usage
The `InputSender` class operates on one or more receivers.  It will create and send `InputEvent` instances to all of its receivers.

There are two ways you could be processing your input.  You could be using the `_input` events to receive input events and process them.  The other way is to interact with the `Input` global and detect input in the `_process` and `_physics_process` methods.  `InputSender` works with both approaches, but using `InputSender` differs for each approach.  Read the sections below to learn the best way to use `InputSender` with your game.

## Using an Object as a Receiver
When you use an instance of an object as a receiver, `InputSender` will send `InputEvent` instances to the various `input` methods.  They will be called in this order:
1.  `_input`
1.  `_gui_input`
1.  `_unhandled_input`

When there are multiple receivers, each receiver will be called in the order they were added.  All three `_input` methods will be called on each receiver then the `InputSender` will move to the next receiver.

When using objects as receivers it is recommended that each test create its own instance of `InputSender`.  `InputSender` retains information about what actions/buttons/etc have been pressed.  By creating a new instance in each test, you don't have to worry about clearing this state between tests.

If you are processing input by directly interacting with the `Input` global, then you should follow the instructions in the next section.
``` gdscript
func test_shoot():
    var player = Player.new()
    var sender = InputSender.new(player)

    sender.action_down("shoot")
    assert_true(player.is_shooting())
```

## Using `Input` as a Receiver
!!! <b>`Input.use_accumualted_input` DISCLAIMER <b/>!!!

In Godot 3.4 `Input.use_accumualted_input` is disabled by default (even though the documentation indicates otherwise).  In Godot 3.5 it is enabled by default.  This changes the way that `Input` buffers events that are sent to it.  See the section below about `use_accumulated_input` before continuing.
<hr>


When `Input` is used as a receiver `Input` will send all inputs it receives from the `InputSender` to every object that has been added to the tree.  `Input` will treat all the events it gets exactly the same as if the events were triggered from hardware.  This means all the `is_action_just_pressed` and similar functions will work the same.  The `InputEvent` instances will also be sent to the various `_input` methods on objects in the tree in whatever order `Input` desires.

Using `Input` makes testing objects that handle input via `_process` or `_process_delta` much easier but you have to be a little careful when using it though.  Since the `Input` instance is global and retains its state for the duration of the test run.

1.  You should declare your `InputSender` instance at the class level.  You will need access to it in the `after_each` method.
1.  Call `release_all` on the `InputSender` in `after_each`.  This makes sure that `Input` doesn't think that a button is pressed when you don't expect it to be.  If `Input` thinks a button is pressed, it will not send any "down" events until it gets an "up" event.
1.  Call `clear` on the `InputSender` in `after_each`.  This clears out any state the `InputSender` has.  It tracks inputs so that functions like `hold_for` can create dynamic "up" events, as well as various other things.  Calling `clear` makes sure that `InputSender` state does not leak from one test to another.
1.  You must ALWAYS yield before making an assert or your objects will not get a chance to process the frame the `Input` was sent on (`_process` and `_physics_process` will not be called without a yield).

``` gdscript
var _sender = InputSender.new(Input)

func after_each():
    _sender.release_all()
    _sender.clear()

func test_shoot():
    var player = Player.new()

    _sender.action_down("shoot").wait_frames(1)
    yield(_sender, 'idle')

    assert_true(player.is_shooting())
```


## Chaining Input Events
The `InputSender` methods return the instance so you can chain multiple calls together to script out a sequence of inputs.  The sequence is immediately started.  When the sequence finishes the `'idle'` signal is emitted.

```
var player = Player.new()
var sender = InputSender.new(player)

# press a, then b, then release a, then release b
sender.key_down("a").wait(.1)\
    .key_down(KEY_B).wait(.1)\
    .key_up("a").wait(.1)\
    .key_up(KEY_B)
yield(sender, 'idle')
```
The `InputSender` will emit the `idle` signal when all inputs in a sequence have been sent and all `waits` have expired.

Any events that do not have a `wait` or `hold_for` call in between them will be fired on the same frame.
```
# checking for is_action_just_pressed for "jump" and "fire" will be true in the same frame.
sender.action-down("jump").action_down("fire")
```

You can use a trailing `wait` to give the result of the input time to play out
```
# wait an extra .2 seconds at the end so that asserts will be run after the
# shooting animation finishes.
sender.action_down("shoot").hold_for(1).wait(.2)
yield(sender, 'idle')
```


# Examples
These are examples of scripting out inputs and sending them to `Input`.  The `Player` class in these examples would be handling input in `_process` or `_process_physics`.

``` gdscript
extends GutTest

# When sending events to Input the InputSender instance should be defined at
# the class level so that you can easily clear it between tests in after_each.
var _sender = InputSender.new(Input)

# IMPORTANT:  When using Input as the receiver of events you should always
#             release_all and clear the InputSender so that any
#             actions/keys/buttons that are not released in a test are released
#             before the next test runs.  "down" events will not be sent by
#             Input if the action/button/etc is currently "down".
func after_each():
    _sender.release_all()
    _sender.clear()


# In this test we press and hold the jump button for .1 seconds then wait
# another .3 seconds for the jump to take take place.  We then assert that
# the character has moved up between 4 and 5 pixels.
func test_tapping_jump_jumps_certain_height():
    var player = add_child_autofree(Player.new())

    _sender.action_down("jump").hold_for(.1).wait(.3)
    yield(_sender, 'idle')

    assert_between(player.position.y, 4, 5)


# This is similar to the other test but we hold jump for longer and then
# verify the player jumped higher.
func test_holding_jump_jumps_higher():
    var player = add_child_autofree(Player.new())

    _sender.action_down("jump").hold_for(.75)
    yield(_sender, 'idle')

    assert_between(player.position.y, 7, 8)


# This tests throwing a fireball, like with Ryu or Ken from Street Fighter.
# Note that there is not a hold_for after "forward" and the key_down for
# fierce punch (FP) immediately after.  This means the "forward" motion AND
# FP are pressed in the same frame.
func test_fireball_input():
    var player = add_child_autofree(Player.new())

    _sender.action_down("down").hold_for("2f")\
        .action_down("down_forward").hold_for("2f")\
        .action_down("forward").key_down("FP")
    yield(_sender, 'idle')

    assert_true(player.is_throwing_fireball())


# In this example we are testing that two actions in combination cause the
# player to slide.  Note that there is no release of the actions in this
# test.  This is a good example of why using release_all in after_each makes
# the tests simpler to write and prevents leaking of inputs from one test to
# another.
func test_holding_down_and_jump_does_slide():
    var player = add_child_autofree(Player.new())

    _sender.action_down("down").wait("1f")\
        .action_down("jump").wait("2f")
    yield(_sender, 'idle')

    assert_gt(player.velocity.x, 0)
```


# Gotchas
* When using `Input` as a receiver, everything in the tree gets the signals AND any actual inputs from hardware will be sent as well.  It's best not to touch anything when running these tests.
* If you use a class level `InputSender` and forget to call `release_all` and `clear` between tests then things will eventually start behaving weird and your tests will pass/fail in unpredictable ways.

## Understanding Input.use_accumulated_input
When `use_accumualted_input` is enabled, `Input` waits to process input until the end of a frame.  This means that if you do not flush the buffer or there are no "waits" or calls to `yield` before you test how input was processed then your tests will fail.

### Testing with use_accumulated_input
#### Recommended approaches
1.  If you game does not want to have `use_accumulated_input` enabled, then disable it in a an Autoload.  GUT loads autoloads before running so this will disable it for all tests.
1.  Always have a trailing `wait` when sending input `_sender.key_down('a').wait('10f')`.  In testing, 6 frames wasn't enough but 7 was _(for reasons I don't understand but probably should so I made I used 10 frames for good measure)_.
1.  After sending all your input, call `Input.flush_buffered_events`.  Only use this in the specific cases where you know you want to send inputs immediately since this is NOT how your game will actually receive inputs.

#### Other ways that aren't so good.
If you use these approaches you should quarantine these tests in their own Inner Class or script so that they do not influence other tests that do not expect the buffer to be constantly flushed or `use_accumulated_input` to be disabled.
1.  In GUT 7.4.0 `InputSender` has an `auto_flush_input` property which is disabled by default.  When enabled this will call `Input.flush_buffered_events` after each input sent through an `InputSender`.  This is a bit dangerous since this can cause some of your tests to not test the way your game will receive input when playing the game.
1.  You can disable `use_accumulated_input` in `before_all` and re-enable in `after_all`.  Just like with `auto_flush_input`, this has the potential to not test all inputs the same way as your game will get them when playing the game.

### Examples
The following assume `use_accumulated_input` is enabled and uses Godot 3.5 syntax.  In 3.4 you have to call `set_use_accumulated_input`.  There is no way to check the value of this flag in 3.4.
```gdscript
extends GutTest

var _sender = InputSender.new(Input)

func before_all():
    InputMap.add_action("jump")

func after_each():
    _sender.release_all()
    _sender.clear()

func test_when_uai_enabled_input_not_processed_immediately():
    _sender.key_down('a')
    assert_false(Input.is_key_pressed(KEY_A))

func test_when_uai_enabled_just_pressed_is_not_processed_immediately():
    _sender.action_down('jump')
    assert_false(Input.is_action_just_pressed('jump'))

func test_when_uai_enabled_waiting_makes_button_pressed():
    # wait 10 frames.  In testing, 6 frames failed, but 7 passed.  Added 3 for
    # good measure.
    _sender.key_down(KEY_Y).wait('10f')
    yield(_sender, 'idle')
    assert_true(_sender.is_key_pressed(KEY_Y))
    assert_true(Input.is_key_pressed(KEY_Y))

func test_when_uai_enabled_flushig_buffer_sends_input_immediatly():
    _sender.key_down('a')
    Input.flush_buffered_events()
    assert_true(Input.is_key_pressed(KEY_A))

func test_disabling_uai_sends_input_immediately():
    Input.use_accumulated_input = false
    _sender.key_down('a')
    assert_true(Input.is_key_pressed(KEY_A))
    # re-enable so we don't ruin other tests
    Input.use_accumulated_input = true

func test_when_uai_enabled_flushing_buffer_just_pressed_is_processed_immediately():
    _sender.action_down('jump')
    Input.flush_buffered_events()
    assert_true(Input.is_action_just_pressed('jump'))
```


# Functions
__<a name="new">new(receiver=null)</a>__<br/>
The optional receiver will be added to the list of receivers.

__<a name="add_receiver">add_receiver(obj)</a>__<br/>
Add an object to receive input events.

__<a name="get_receivers">get_receivers()</a>__<br/>
Returns the receivers that have been added.

__<a name="release_all">release_all()</a>__<br/>
Releases all `InputEventKey`, `InputEventAction`, and `InputEventMouseButton` events that have passed through the `InputSender`.  These events could have been generated via the various `_down` methods or passed to `send_event`.

This will send the "release" event (`pressed = false`) to all receivers.  This should be done between each test when using `Input` as a receiver.

__<a name="clear">clear()</a>__<br/>
Clears the input queue and any state such as the last event sent and any pressed actions/buttons.  Does not clear the list of receivers.

This should be done between each test when the `InputSender` is a class level variable so that state does not leak between tests.

__<a name="is_idle">is_idle()</a>__<br/>
Returns true if the input queue has items to be processed, false if not.

__<a name="wait">wait(t)</a>__<br/>
Adds a delay between the last input queue item added and any queue item added next.  By default this will wait `t` seconds.  You can specify a number of frames to wait by passing a string composed of a number and "f".  For example `wait("5f")` will wait 5 frames.

__<a name="wait_frames">wait_frames(num_frames)</a>__<br/>
Same as `wait` but only accepts a number of frames to wait.

__<a name="wait_secs">wait_secs(num_secs)</a>__<br/>
Same as `wait` but only accepts a number of seconds to wait.

__<a name="hold_for">hold_for(duration)</a>__<br/>
This is a special `wait` that will emit the previous input queue item with `pressed = false` after a delay.  If you pass a number then it will wait that many seconds.  You can also use the `"4f"` format to wait a specific number of frames.

For example `sender.action_down('jump').hold_for("10f")` will cause two `InputEventAction` instances to be sent.  The "jump-down" event from `action_down` and then a "jump-up" event after 10 frames.

__<a name="mouse_set_position">mouse_set_position(position, global_position=null)</a>__<br/>
Sets the mouse's position.  This does not send an event.  This position will be used for the next call to `mouse_relative_motion`.

__<a name="set_auto_flush_input">set_auto_flush_input(val)</a>__<br/>
Enable/Disable auto flushing of input.  When enabled the `InputSender` will call `Input.flush_buffered_events` after each event is sent.  See the `use_accumulated_input` section for more information.

__<a name="get_auto_flush_input">get_auto_flush_input()</a>__<br/>
Get it.

# Sending InputEvents
__<a name="send_event">send_event(event)</a>__<br/>
Create your own event and use this to send it to all receivers.

__<a name="key_down">key_down(which)</a>__<br/>
Sends a `InputEventKey` event with `pressed` = `true`.  `which` can be a character or a `KEY_*` constant.

__<a name="key_up">key_up(which)</a>__<br/>
Sends a `InputEventKey` event with `pressed` = `false`.  `which` can be a character or a `KEY_*` constant.

__<a name="key_echo">key_echo()</a>__<br/>
Sends an echo `InputEventKey` event of the last key event.


__<a name="action_down">action_down(which, strength=1.0)</a>__<br/>
Sends a "action down" `InputEventAction` instance.  `which` is the name of the action defined in the Key Map.

__<a name="action_up">action_up(which, strength=1.0)</a>__<br/>
Sends a "action up" `InputEventAction` instance.  `which` is the name of the action defined in the Key Map.

__<a name="mouse_left_button_down">mouse_left_button_down(position, global_position=null)</a>__<br/>
Sends a "button down" `InputEventMouseButton` for the left mouse button.

__<a name="mouse_left_button_up">mouse_left_button_up(position, global_position=null)</a>__<br/>
Sends a "button up" `InputEventMouseButton` for the left mouse button.

__<a name="mouse_double_click">mouse_double_click(position, global_position=null)</a>__<br/>
Sends a "double click" `InputEventMouseButton` for the left mouse button.

__<a name="mouse_right_button_down">mouse_right_button_down(position, global_position=null)</a>__<br/>
Sends a "button down" `InputEventMouseButton` for the right mouse button.

__<a name="mouse_right_button_up">mouse_right_button_up(position, global_position=null)</a>__<br/>
Sends a "button up" `InputEventMouseButton` for the right mouse button.

__<a name="mouse_motion(">mouse_motion(position, global_position=null)</a>__<br/>
Sends a "InputEventMouseMotion" to move the mouse the specified positions.

__<a name="mouse_relative_motion">mouse_relative_motion(offset, speed=Vector2(0, 0))</a>__<br/>
Sends a "InputEventMouseMotion" that moves the mouse `offset` from the last `mouse_motion` or `mouse_set_position` call.
