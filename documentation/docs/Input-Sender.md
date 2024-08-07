
# Input Sender
The `InputSender` class can be used to send `InputEvent*` events to various objects (recievers).  It also allows you to script out a series of inputs and play them back in real time.  You could use it to:
* Verify that jump height depends on how long the jump button is pressed.
* Double tap a direction performs a dash.
* Move the mouse around and click things.

And much much more.

As of 9.3.1 you can use `GutInputSender` instead of `InputSender`.  It's the same thing, but `GutInputSender` is a `class_name` so you may have less warnings and auto-complete will work.

__Warning__<br>
If you move the Godot window to a different monitor while tests are running it can cause input tests to fail.  [This issue](https://github.com/bitwes/Gut/issues/643) has more details.


## Signals
* `idle` - Emitted when all events in the input queue have been sent.


## Properties
* `auto_flush_input` - Default false.  You probably should not enable this.  This can help work around not using `Input.use_accumulated_input`.  In most cases, enabling this, means that objects under test will not receive events with the same timing they will when playing the game.
* `mouse_warp` - Default false.  When enabled, any mouse event will cause the actual mouse cursor to move to the location of the event.  This is required for testing some events like mouse enter/exit.  Moving the mouse while using this will likely cause tests to fail.
* `draw_mouse` - Default true.  Draws a mouse crosshair that also has button indicators.  It's crude right now, but usefult.


### Chaining Input Events
The `InputSender` methods return the instance so you can chain multiple calls together to script out a sequence of inputs.  The sequence is immediately started.  When the sequence finishes the `'idle'` signal is emitted.

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

Any events that do not have a `wait*` or `hold*` call in between them will be fired on the same frame.
```gdscript
# checking for is_action_just_pressed for "jump" and "fire" will be true in the same frame.
sender.action-down("jump").action_down("fire")
```

You can use a trailing `wait` to give the result of the input time to play out
```gdscript
# wait an extra .2 seconds at the end so that asserts will be run after the
# shooting animation finishes.
sender.action_down("shoot").hold_secs(1).wait_secs(.2)
await(sender.idle)
```


## Understanding Input.use_accumulated_input
When `use_accumulated_input` is enabled (it is by default), `Input` waits to process input until the end of a frame.  This means that if you do not flush the buffer or there are no "waits" or calls to `await` before you test how input was processed then your tests will fail.

### Testing with use_accumulated_input
`Input.use_accumulated_input` is enabled by default.  There are cases where you may have disabled this for your game.


#### Recommended approaches
1.  If you game does not want to have `use_accumulated_input` enabled, then disable it in a an Autoload.  GUT loads autoloads before running so this will disable it for all tests.
1.  Always have a trailing `wait` when sending input `_sender.key_down('a').wait_frames(10)`.  In testing, 6 frames wasn't enough but 7 was _(for reasons I don't understand but probably should so I used 10 frames for good measure)_.
1.  After sending all your input, call `Input.flush_buffered_events`.  Only use this in the specific cases where you know you want to send inputs immediately since this is NOT how your game will actually receive inputs.

#### Other ways that aren't so good.
If you use these approaches you should quarantine these tests in their own Inner Class or script so that they do not influence other tests that do not expect the buffer to be constantly flushed or `use_accumulated_input` to be disabled.
1.  In GUT 7.4.0 `InputSender` has an `auto_flush_input` property which is disabled by default.  When enabled this will call `Input.flush_buffered_events` after each input sent through an `InputSender`.  This is a bit dangerous since this can cause some of your tests to not test the way your game will receive input when playing the game.
1.  You can disable `use_accumulated_input` in `before_all` and re-enable in `after_all`.  Just like with `auto_flush_input`, this has the potential to not test all inputs the same way as your game will get them when playing the game.

### Examples
The following assume `use_accumulated_input` is enabled and uses Godot 3.5 syntax.  In 3.4 you have to call `set_use_accumulated_input`.  There is no way to check the value of this flag in 3.4.
```gdscript
extends GutTest

extends GutTest

var _sender = InputSender.new(Input)
var _orig_accum_input = Input.use_accumulated_input

func before_all():
    InputMap.add_action("jump")
    Input.use_accumulated_input = true
    await wait_frames(1)

func after_each():
    _sender.release_all()
    _sender.clear()

func after_all():
    Input.use_accumulated_input = _orig_accum_input
    InputMap.erase_action("jump") # I added this too, probably the right thing to do.

func test_when_uai_enabled_input_not_processed_immediately():
    _sender.key_down('a')
    assert_false(Input.is_key_pressed(KEY_A))

func test_when_uai_enabled_waiting_makes_button_pressed():
    # wait 10 frames.  In testing, 6 frames failed, but 7 passed.  Added 3 for
    # good measure.
    _sender.key_down(KEY_Y).wait_frames(10)
    await(_sender.idle)
    assert_true(_sender.is_key_pressed(KEY_Y))
    assert_true(Input.is_key_pressed(KEY_Y))

func test_when_uai_enabled_flushig_buffer_sends_input_immediatly():
    _sender.key_down('a')
    Input.flush_buffered_events()
    assert_true(Input.is_key_pressed(KEY_A))

func test_when_uai_enabled_flushing_buffer_just_pressed_is_processed_immediately():
    _sender.action_down('jump')
    Input.flush_buffered_events()
    assert_true(Input.is_action_just_pressed('jump'))
```


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
