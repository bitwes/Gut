# <div class="warning">This page has not been updated for GUT 9.0.0 or Godot 4.  There could be incorrect information here.</div>
##  <a name="yielding"> Yielding during a test

I'm not going to try and explain yielding here.  It can be a bit confusing and [Godot does a pretty good job of it already](https://docs.godotengine.org/en/latest/getting_started/scripting/gdscript/gdscript_basics.html#coroutines-with-yield).  Gut has support for yielding though, so you can yield at anytime in your test.

When might you want to yield?  Yielding is very handy when you want to wait for a signal to occur instead of running for a finite amount of time.  For example, you could have your test yield until your character gets hit by something (`yield(my_char, 'hit')`).  An added bonus of this approach is that you can watch everything happen.  In your test you create your character, the object to hit it, and then watch the interaction play out.

Here's an example of yielding to a custom signal.
``` gdscript
func test_yield_to_custom_signal():
	my_object = ObjectToTest.new()
	add_child_autofree(my_object)
	yield(my_object, 'custom_signal')
	assert_true(some_condition, 'After signal fired, this should be true')
```
### yield_to
Sometimes you need to wait for a signal to be emitted, but you can never really be sure it will, we are making tests after all.  You could `yield` to that signal in your test and hope it gets emitted.  If it doesn't though, your test will just hang forever.  The `yield_to` method addresses this by allowing you to `yield` to a signal or a maximum amount of time, whichever occurs first.  You must make sure the 2nd parameter to `yield` is the `YIELD` constant.  This constant is available to all test scripts.  As an extra bonus, Gut will watch the signals on the object you passed in, so you can save yourself a call to `watch_signals` if you want, but you don't have to.  How all this magic works is covered a couple of sections down.

``` gdscript
# wait for my_object to emit the signal 'my_signal'
# or 5 seconds, whichever comes first.
yield(yield_to(my_object, 'my_signal', 5), YIELD)
assert_signal_emitted(my_object, 'my_signal', \
                     'Maybe it did, maybe it didnt, but we still got here.')
```

### yield_for
Another use case I have come across is when creating integration tests and you want to verify that a complex interaction ends with an expected result.  In this case you might have an idea of how long the interaction will take to play out but you don't have a signal that you can attach to.  Instead you want to pause your test execution until that time has elapsed.  For this, Gut has the `yield_for` method.  For example `yield(yield_for(5), YIELD)` will pause your test execution for 5 seconds while the rest of your code executes as expected.  You must make sure the 2nd parameter to `yield` is the `YIELD` constant.  This constant is available to all test scripts.  How all this magic works is covered a couple of sections down.

Here's an example of yielding for 5 seconds.
``` gdscript
func test_wait_for_a_bit():
	my_object = ObjectToTest.new()
	my_object.do_something()
	#wait 5 seconds
	yield(yield_for(5), YIELD)
	gut.assert_eq(my_object.some_property, 'some value', 'After waiting 5 seconds, this property should be set')
```

### pause_before_teardown
Sometimes it's also helpful to just watch things play out.  Yield is great for that, you just create a couple objects, set them to interact and then yield.  You can leave the yields in or take them out if your test passes without them.  You can also use the `pause_before_teardown` method that will pause test execution before it runs `teardown` and moves onto the next test.  This keeps the game loop running after the test has finished and you can see what everything looks like.

### How Yielding and Gut Works
For those that are interested, Gut is able to detect when a test has called yield because the method returns a special class back (`GDScriptFunctionState`).  Gut itself will then `yield` to the `completed` signal provided by the `GDScriptFunctionState` that is returned when your test yielded.  It also kicks off a timer that will print out messages so you know it hasn't locked up.

The `yield_for()` method and `YIELD` constant are some syntax sugar built into the `Test` object.  `yield` takes in an object and a signal.  The `yield_for` method kicks off a timer inside Gut that will run for however many seconds you passed in.  It also returns the Gut object so that `yield` has an object to yield to.  The `YIELD` constant contains the name of the signal that Gut emits when the timer finishes.

`yield_to` works similarly to `yield_for` except it takes the extra step that Gut will watch the signal you pass in.  It will emit the same signal (`YIELD`) when it detects the signal you specified or it will emit the signal when the timer times out.
