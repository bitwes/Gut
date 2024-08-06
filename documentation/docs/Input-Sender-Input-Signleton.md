# Using `Input` as a Receiver

## When to Use this Approach
It is important to understand the different ways to use the `InputSender` and their benefits/drawbacks.  This is covered in general in Mocking-Input.  Please read that before continuing.

## Gotchas
* When using `Input` as a receiver, everything in the tree gets the signals AND any inputs from hardware as well.  It's best not to touch anything when running these tests.
* When using a class level `InputSender` (required for this type of testing) __do not forget__ to call `release_all` and `clear` between tests, as well as at 1 frame `await`.  Failing to do so will cause input to leak from test to test causing unreliable results.
* These tests will not pass when in `--headless` mode.  If you have a CI/CD pipeline you should either exclude these tests or add the following to each input testing script/Inner-Test-Class:
```gdscript
func should_skip_script():
	if DisplayServer.get_name() == "headless":
		return "Skip Input tests when running headless"
```

## How-to
When `Input` is used as a receiver `Input` will send all inputs it receives from the `InputSender` to every object that has been added to the tree.  `Input` will treat all the events it gets exactly the same as if the events were triggered from hardware.  This means all the `is_action_just_pressed` and similar functions will work the same.  The `InputEvent` instances will also be sent to the various `_input` methods on objects in the tree in whatever order `Input` desires.

Using `Input` makes testing objects that handle input via `_process` or `_process_delta` much easier but you have to be a little careful when using it though.  Since the `Input` instance is global and retains its state for the duration of the test run.

1.  You should declare your `InputSender` instance at the class level.  You will need access to it in the `after_each` method.
1.  Call `release_all` on the `InputSender` in `after_each`.  This makes sure that `Input` doesn't think that a button is pressed when you don't expect it to be.  If `Input` thinks a button is pressed, it will not send any "down" events until it gets an "up" event.
1.  Call `clear` on the `InputSender` in `after_each`.  This clears out any state the `InputSender` has.  It tracks inputs so that functions like `hold_for` can create dynamic "up" events, as well as various other things.  Calling `clear` makes sure that `InputSender` state does not leak from one test to another.
1.  You must ALWAYS await before making an assert or your objects will not get a chance to process the frame the `Input` was sent on (`_process` and `_physics_process` will not be called without a await).

``` gdscript
var _sender = InputSender.new(Input)

func after_each():
    _sender.release_all()
    _sender.clear()

func test_shoot():
    var player = Player.new()

    _sender.action_down("shoot").wait_frames(1)
    await(_sender.idle)

    assert_true(player.is_shooting())
```


## Examples
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
    await wait_frames(1)


# In this test we press and hold the jump button for .1 seconds then wait
# another .3 seconds for the jump to take take place.  We then assert that
# the character has moved up between 4 and 5 pixels.
func test_tapping_jump_jumps_certain_height():
    var player = add_child_autofree(Player.new())

    _sender.action_down("jump").hold_for(.1).wait(.3)
    await(_sender.idle)

    assert_between(player.position.y, 4, 5)


# This is similar to the other test but we hold jump for longer and then
# verify the player jumped higher.
func test_holding_jump_jumps_higher():
    var player = add_child_autofree(Player.new())

    _sender.action_down("jump").hold_for(.75)
    await(_sender.idle)

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
    await(_sender.idle)

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
    await(_sender.idle)

    assert_gt(player.velocity.x, 0)
```
