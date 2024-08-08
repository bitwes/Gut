# Using an Object as a Receiver

## When to Use this Approach
It is important to understand the different ways to use the `InputSender` and their benefits/drawbacks.  This is covered in general in [Mocking-Input](Mocking-Input).  Please read that before continuing.

See [Input-Sender](Input-Sender) for details on the `GutInputSender` class.




## Gotchas
* If you use a class level `InputSender` (not recommended for this type of testing) and forget to call `release_all` and `clear` between tests then things will eventually start behaving weird and your tests will pass/fail in unpredictable ways.
* This approach sends `InputEvent` instances directly to the receivers. This is great for unit tests, but may not meet the requirements of integration testing.  If you need to test more complicated scenarios where the tree's state may change who gets input, you should use [`Input` as a receiver](Input-Sender-Input-Singleton)




## How-to
When you use an instance of an object as a receiver, `InputSender` will send `InputEvent` instances to the various `input` methods.  They will be called in this order:
1.  `_input`
1.  `_gui_input`
1.  `_unhandled_input`

When there are multiple receivers, each receiver will be called in the order they were added.  All three `_input` methods will be called on each receiver then the `InputSender` will move to the next receiver.

When using objects as receivers it is recommended that each test create its own instance of `InputSender`.  `InputSender` retains information about what actions/buttons/etc have been pressed.  By creating a new instance in each test, you don't have to worry about clearing this state between tests.

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
