If you aren't sure about coroutines and using `await`, [Godot explains it pretty well](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_basics.html#awaiting-for-signals-or-coroutines).  GUT supports coroutines, so you can `await` at anytime in your tests.  GUT also provides some handy methods to make awaiting easier.

If you want to pause test execution for some amount of time/frames or until a signal is emitted use `await` and one of GUT's "wait" methods:
* `wait_for_signal`
* `wait_seconds`
* `wait_frames`.

Calling `await` without using one of GUT's "wait" methods is discouraged.  When you use these methods, GUT provides output to indicate that execution is paused.  If you don't use them it can look like your tests have hung up.

# wait_for_signal
```
wait_for_signal(sig, max_wait, msg=''):
```
This method will pause execution until a signal is emitted or until `max_wait` seconds have passed, whichever comes first.  Using `wait_for_signal` is better than just using `await my_obj.my_signal` since tests will continue to run if the signal is never emitted.

`wait_for_signal` internally calls `watch_signals` for the object, so you can skip that step when asserting signals have been emitted.

The optional `msg` parameter is logged so you know why test execution is paused.
``` gdscript
my_object.do_something()
# wait for my_object to emit the signal 'my_signal'
# or 5 seconds, whichever comes first.
await wait_for_signal(my_object.my_signal, 5)
assert_signal_emitted(my_object, 'my_signal', \
                     'Maybe it did, maybe it didnt, but we still got here.')
```

# wait_seconds
```
wait_seconds(time, msg=''):
```
Sometimes you just want to pause for some amount of time.  Use `wait_seconds` instead of making timers.

The optional `msg` parameter is logged so you know why test execution is paused.
``` gdscript
func test_wait_for_a_bit():
	my_object = ObjectToTest.new()
	my_object.do_something()
	# wait 2.8 seconds then continue running the test
	await wait_seconds(2.8)
	gut.assert_eq(my_object.some_property, 'some value')
```

# wait_frames
```
wait_frames(frames, msg=''):
```

This is just like `wait_seconds` but instead of counting seconds it counts frames.  Due to order of operations, this may wait +/- 1 frames, but sholdn't ever be 0.  This can be very useful if you use `call_deferred` in any of the objects under test, or need to wait a frame or two for `_process` to run.

The optional `msg` parameter is logged so you know why test execution is paused.
``` gdscript
func test_wait_for_some_frames():
	my_object = ObjectToTest.new()
	my_object.do_something()
	# wait 2 frames before continue test execution
	await wait_frames(2)
	gut.assert_eq(my_object.some_property, 'some value')
```


# pause_before_teardown
Sometimes, as you are developing your tests you may want to verify something before the any of the teardown methods are called or just look at things a bit.  If you call `pause_before_teardown()` anywhere in your test then GUT will pause execution until you press the "Continue" button in the GUT GUI.  You can also specify an option to ignore all calls to `pause_before_teardown` through the GUT Panel, command line, or `.gutconfig` in case you get lazy and don't want to remove them.  You should always remove them, but I know you won't because I didn't so I made that an option.