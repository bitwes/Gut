# Awaiting
If you aren't sure about coroutines and using `await`, [Godot explains it pretty well](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_basics.html#awaiting-for-signals-or-coroutines).  GUT supports coroutines, so you can `await` at anytime in your tests.  GUT also provides some handy methods to make awaiting in your tests a little easier.

You can use `await` with any of the following methods to pause execution for a duration or until something occurs.  You can find more information about each method below, and in the `GutTest` documentation.
 * <a href="class_ref/class_guttest.html#class-guttest-method-wait-seconds">wait_seconds</a>:  Waits x seconds.
 * <a href="class_ref/class_guttest.html#class-guttest-method-wait-frames">wait_frames</a>:  Waits x frames (physics frames).
 * <a href="class_ref/class_guttest.html#class-guttest-method-wait-for-signal">wait_for_signal</a>:  Waits until a signal is emitted, or a maximum amount of time.
 * <a href="class_ref/class_guttest.html#class-guttest-method-wait-until">wait_until</a>:   Waits until a `Callable` returns `true` or a maximum amount of time.
 * `pause_before_teardown`:  can be called in a test to pause execution at the end of a test, before moving on to the next test or ending the run.

Calling `await` without using one of GUT's "wait" methods is discouraged.  When you use these methods, GUT provides output to indicate that execution is paused.  If you don't use them it can look like your tests have stopped running.


## <a href="class_ref/class_guttest.html#class-guttest-method-wait-seconds">wait_seconds</a>
``` gdscript
wait_seconds(time, msg=''):
```
Sometimes you just want to pause for some amount of time.  Use `wait_seconds` instead of making timers.

The optional `msg` parameter is logged so you know why test execution is paused.
``` gdscript
# wait 2.8 seconds then continue running the test
await wait_seconds(2.8)

# wait .25 seconds, text included in log message
await wait_secondes(.25, "waiting for a short period")
```

## <a href="class_ref/class_guttest.html#class-guttest-method-wait-frames">wait_frames</a>
``` gdscript
wait_frames(frames, msg=''):
```

This is just like `wait_seconds` but instead of counting seconds it counts frames.  Due to order of operations, this may wait +/- 1 frames, but sholdn't ever be 0.  This can be very useful if you use `call_deferred` in any of the objects under test, or need to wait a frame or two for `_process` to run.

The internal frame counter is incremented in `_process_physics`.

The optional `msg` parameter is logged so you know why test execution is paused.
``` gdscript
# wait 2 frames before continue test execution
await wait_frames(2)

# wait's some frames and includes optional message
await wait_frames(20) # waiting some frames.
```

## <a href="class_ref/class_guttest.html#class-guttest-method-wait-for-signal">wait_for_signal</a>
``` gdscript
wait_for_signal(sig, max_wait, msg=''):
```
This method will pause execution until a signal is emitted or until `max_wait` seconds have passed, whichever comes first.  Using `wait_for_signal` is better than just using `await my_obj.my_signal` since tests will continue to run if the signal is never emitted.

`wait_for_signal` internally calls `watch_signals` for the object, so you can skip that step when asserting signals have been emitted.

This method returns `true` if the signal was emitted before timing out, `false` if not.

The optional `msg` parameter is logged so you know why test execution is paused.
``` gdscript
# wait for my_object to emit the signal 'my_signal'
# or 5 seconds, whichever comes first.
await wait_for_signal(my_object.my_signal, 5)
assert_signal_emitted(my_object, 'my_signal', \
                     'Maybe it did, maybe it didnt, but we still got here.')

# You can also use the return value directly in an assert
assert_true(await wait_for_signal(my_object.my_signal, 2),
	"The signal should have been emitted before timeout")
```


## <a href="class_ref/class_guttest.html#class-guttest-method-wait-until">wait_until</a>
``` gdscript
wait_until(callable, max_wait, p3='', p4=''):
```
This method takes a `Callable` predicate method that will be called every frame.  The wait will end when the `Callable` returns `true` or when `max_wait` seconds has expired.  This requires the method to explicity return `true` and not a truthy value.

This will return `true` if the method returned `true` before the timeout, `false` if otherwise.  You can optionally specify an amount of time to wait between calling the `Callable`.

* `p3` can be the optional message or an amount of time to wait between tests.
* `p4` is the optional message if you have specified an amount of time to wait between tests.

``` gdscript
var everything_is_ok = func():
	return true

# Call everything_is_ok every frame until it returns true or 5 seconds elapses
await wait_until(everything_is_ok, 5)

# Same as above but we get the result to use later and provide a message to
# display when the await starts.
var result = await wait_until(everything_is_ok, 5, 'Show this message')

# Calls everything_is_ok every second until it returns true and asserts
# on the returned value
assert_true(await wait_until(everything_is_ok, 10, 1),
	"Everything should be ok in 10 seconds").
```

## pause_before_teardown
Sometimes, as you are developing your tests you may want to verify something before the any of the teardown methods are called or just look at things a bit.  If you call `pause_before_teardown()` anywhere in your test then GUT will pause execution until you press the "Continue" button in the GUT GUI.  You can also specify an option to ignore all calls to `pause_before_teardown` through the GUT Panel, command line, or `.gutconfig` in case you get lazy and don't want to remove them.  You should always remove them, but I know you won't because I didn't, so I made that an option.