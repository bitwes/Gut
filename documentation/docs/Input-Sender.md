
# Input Sender
The `InputSender` class can be used to send `InputEvent*` events to various objects (recievers).  It also allows you to script out a series of inputs and play them back in real time.  You could use it to:
* Verify that jump height depends on how long the jump button is pressed.
* Double tap a direction performs a dash.
* Move the mouse around and click things.

And much much more.

As of 9.3.1 you can use `GutInputSender` instead of `InputSender`.  It's the same thing, but `GutInputSender` is a `class_name` so you may have less warnings and auto-complete will work.

__Warning__<br>
If you move the Godot window to a different monitor while tests are running it can cause input tests to fail.  [This issue](https://github.com/bitwes/Gut/issues/643) has more details.


### Chaining Input Events (Input Sequence)
You can chain multiple calls together to script out a sequence of inputs, similar to how you would interact with a `Tween`.  The sequence is immediately started, you do not have to explicitly start it.  When the sequence finishes the `idle` signal is emitted.

```
var player = Player.new()
var sender = InputSender.new(player)

# press a, then b, then release a, then release b
sender.key_down("a").wait_secs(.1)\
    .key_down(KEY_B).wait_secs(.1)\
    .key_up("a").wait_secs(.1)\
    .key_up(KEY_B)
await(sender.idle)
```

The `InputSender` will emit the `idle` signal when all inputs in a sequence have been sent and all `waits` have expired.

Any events created that do not have a `wait*` or `hold*` call in between them will be sent on the same frame.

```gdscript
# checking for is_action_just_pressed for "jump" and "fire" will be true in the same frame.
sender.action-down("jump").action_down("fire")
```

You can use a trailing `wait_frames`/`wait_secs` to give the result of the input time to play out
```gdscript
# wait an extra .2 seconds at the end so that asserts will be run after the
# shooting animation finishes.
sender.action_down("shoot")\
    .hold_secs(1)\
    .wait_secs(.2)
await(sender.idle)
```

## Signals
* `idle` - Emitted when all events in the input queue have been sent.


## Properties
* `auto_flush_input` - Default false.  You probably should not enable this.  This can help work around not using `Input.use_accumulated_input`.  In most cases, enabling this, means that objects under test will not receive events with the same timing they will when playing the game.
* `mouse_warp` - Default false.  When enabled, any mouse event will cause the actual mouse cursor to move to the location of the event.  This is required for testing some events like mouse enter/exit.  Moving the mouse while using this will likely cause tests to fail.
* `draw_mouse` - Default true.  Draws a mouse crosshair that also has button indicators.  It's crude right now, but usefult.


## Methods
### new
`new(receiver=null)</a>`<br>
The optional receiver will be added to the list of receivers.

### add_receiver
`add_receiver(obj)`<br>
Add an object to receive input events.

### get_receivers
`get_receivers()`<br>
Returns the receivers that have been added.

### release_all
`release_all()`<br>
Releases all `InputEventKey`, `InputEventAction`, and `InputEventMouseButton` events that have passed through the `InputSender`.  These events could have been generated via the various `_down` methods or passed to `send_event`.

This will send the "release" event (`pressed = false`) to all receivers.  This should be done between each test when using `Input` as a receiver.

### clear
`clear`<br>
Clears the input queue and any state such as the last event sent and any pressed actions/buttons.  Does not clear the list of receivers.

This should be done between each test when the `InputSender` is a class level variable so that state does not leak between tests.

### is_idle
`is_idle()`<br>
Returns true if the input queue has items to be processed, false if not.


### wait_frames
`wait_frames(num_frames)`<br>
Adds a delay of `num_frames` between the last input queue item added and any queue item added next.

### wait_secs
`wait_secs(num_secs)`<br>
Same as `wait_frames` but creates a delay of `num_secs` seconds instead of frames.

### wait_seconds
Alias for `wait_secs`


### hold_frames
`hold_frames(frames)`<br>
This is a special `wait` that will emit the previous input queue item with `pressed = false` after a delay.

For example `sender.action_down('jump').hold_frames(10)` will cause two `InputEventAction` instances to be sent.  The "jump-down" event from `action_down` and then another action 10 frames later with  pressed false.


### hold_secs
`hold_secs(num_secs)`<br>
Same as `hold_frames` but holds for a number of seconds instead of frames.


### hold_seconds
Alias for hold_secs


### mouse_set_position
`mouse_set_position(position, global_position=null)`<br>
Sets the mouse's position.  This does not send an event.  This position will be used for the next call to `mouse_relative_motion`.

### set_auto_flush_input
`set_auto_flush_input(val)`<br>
Enable/Disable auto flushing of input.  When enabled the `InputSender` will call `Input.flush_buffered_events` after each event is sent.  See the `use_accumulated_input` section for more information.

__<a name="get_auto_flush_input">get_auto_flush_input()</a>__<br/>
Get it.

### send_event
`send_event(event)`<br>
Create your own event and use this to send it to all receivers.

### key_down
`key_down(which)`<br>
Sends a `InputEventKey` event with `pressed` = `true`.  `which` can be a character or a `KEY_*` constant.

### key_up
`key_up(which)`<br>
Sends a `InputEventKey` event with `pressed` = `false`.  `which` can be a character or a `KEY_*` constant.

### key_echo
`key_echo()`<br>
Sends an echo `InputEventKey` event of the last key event.

### action_down
`action_down(which, strength=1.0)`<br>
Sends a "action down" `InputEventAction` instance.  `which` is the name of the action defined in the Key Map.

### action_up
`action_up(which, strength=1.0)`<br>
Sends a "action up" `InputEventAction` instance.  `which` is the name of the action defined in the Key Map.

### mouse_left_button_down
`mouse_left_button_down(position, global_position=null)`<br>
Sends a "button down" `InputEventMouseButton` for the left mouse button.

### mouse_left_button_up
`mouse_left_button_up(position, global_position=null)`<br>
Sends a "button up" `InputEventMouseButton` for the left mouse button.

### mouse_double_click
`mouse_double_click(position, global_position=null)`<br>
Sends a "double click" `InputEventMouseButton` for the left mouse button.

### mouse_right_button_down
`mouse_right_button_down(position, global_position=null)`<br>
Sends a "button down" `InputEventMouseButton` for the right mouse button.

### mouse_right_button_up
`mouse_right_button_up(position, global_position=null)`<br>
Sends a "button up" `InputEventMouseButton` for the right mouse button.

### mouse_motion
`mouse_motion(position, global_position=null)`<br>
Sends a "InputEventMouseMotion" to move the mouse the specified positions.

### mouse_relative_motion
`mouse_relative_motion(offset, speed=Vector2(0, 0))`<br>
Sends a "InputEventMouseMotion" that moves the mouse `offset` from the last `mouse_motion` or `mouse_set_position` call.
