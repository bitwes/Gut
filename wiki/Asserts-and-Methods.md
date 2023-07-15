<div class="warning">This page has not been <b>completely</b> updated for GUT 9.0.0 or Godot 4.  There could be incorrect information here.</div>
These are all the methods, bells, whistles and blinky lights you get when you extend the Gut Test Class (`extends GutTest`).

All sample code listed for the methods can be found here in [test_readme_examples.gd](https://github.com/bitwes/Gut/blob/master/test/samples/test_readme_examples.gd)

# Utilities
|
[add_child_autofree](#add_child_autofree)|
[add_child_autoqfree](#add_child_autoqfree)|
[autofree](#autofree)|
[autoqfree](#autoqfree)|
[compare_deep](#compare_deep) |
[compare_shallow](#compare_shallow) |
[double](#double) |
[get_call_count](#get_call_count) |
[get_call_parameters](#get_call_parameters) |
[get_non_matching_array_indexes](#get_non_matching_array_indexes) |
[get_signal_emit_count](#get_signal_emit_count) |
[get_signal_parameters](#get_signal_parameters) |
[ignore_method_when_doubling](#ignore_method_when_doubling) |
[is_failing](#is_failing) |
[is_passing](#is_passing) |
[pause_before_teardown](#pause_before_teardown) |
[pending](#pending) |
[replace_node](#replace_node) |
[simulate](#simulate) |
[stub](#stub) |
[wait_for_signal](#wait_for_signal) |
[wait_frames](#wait_frames) |
[wait_seconds](#wait_seconds) |
[watch_signals](#watch_signals) |


# Gut Utilities
These methods exist on the GUT instance, and not in `test.gd`.  They must all be prefixed with `gut`.

|
[gut.directory_delete_files]()|
[gut.file_delete]()|
[gut.file_touch]()|
[gut.is_file_empty]()|
[gut.p](#gut_p) |

# Assertions
<!-- Almost alphabetical list, "not" asserts are listed after their counterparts -->
<!-- 1 assert per line unless there is a "not" version for easy sorting -->
|
[assert_accessors](#assert_accessors) |
[assert_almost_eq](#assert_almost_eq) | [assert_almost_ne](#assert_almost_ne) |
[assert_between](#assert_between) | [assert_not_between](#assert_not_between) |
[assert_call_count](#assert_call_count) |
[assert_called](#assert_called) | [assert_not_called](#assert_not_called) |
[assert_connected](#assert_connected) |
[assert_eq (equal)](#assert_eq) | [assert_ne (not equal)](#assert_ne) |
[assert_eq_deep](#assert_eq_deep) | [assert_ne_deep](#assert_ne_deep) |
[assert_eq_shallow](#assert_eq_shallow) | [assert_ne_shallow](#assert_ne_shallow) |
[assert_exports](#assert_exports) |
[assert_false](#assert_false) |
[assert_file_does_not_exist](#assert_file_does_not_exist) |
[assert_file_empty](#assert_file_empty) |
[assert_file_exists](#assert_file_exists) |
[assert_file_not_empty](#assert_file_not_empty) |
[assert_freed](#assert_freed) | [assert_not_freed](#assert_not_freed) |
[assert_gt (greater than)](#assert_gt) |
[assert_has_method](#assert_has_method) |
[assert_has_signal](#assert_has_signal) |
[assert_has](#assert_has) | [assert_does_not_have](#assert_does_not_have) |
[assert_is](#assert_is) |
[assert_lt (less than)](#assert_lt) |
[assert_no_new_orpahns](#assert_no_new_orphans)|
[assert_not_connected](#assert_not_connected) |
[assert_null](#assert_null) | [assert_not_null](#assert_not_null) |
[assert_property](#assert_property) |
[assert_setget_called](#assert_setget_called) |
[assert_setget](#assert_setget) |
[assert_signal_emit_count](#assert_signal_emit_count) |
[assert_signal_emitted_with_parameters](#assert_signal_emitted_with_parameters) |
[assert_signal_emitted](#assert_signal_emitted) |
[assert_signal_not_emitted](#assert_signal_not_emitted) |
[assert_string_contains](#assert_string_contains) |
[assert_string_ends_with](#assert_string_ends_with) |
[assert_string_starts_with](#assert_string_starts_with) |
[assert_true](#assert_true) |
[assert_typeof](#assert_typeof) | [assert_not_typeof](#assert_not_typeof)|
[fail_test](#fail_test) |
[pass_test](#pass_test) |




#### <a name="pass_test">pass_test(text) </a>
Useful when you don't have anything meaningful to assert.  Any failing asserts within the test will override this.
```gdscript
func test_nothing():
  pass_test('nothing tested, passing')
```

#### <a name="fail_test">fail_test(text) </a>
Useful when you need to fail a test but don't have a meaningful way to assert the condition you are testing.
```gdscript
func test_this_test_just_fails():
  fail_test('total unbridled failure')
```

#### <a name="pending"> pending(text="") </a>
flag a test as pending, the optional message is printed in the GUI
``` gdscript
pending('This test is not implemented yet')
pending()
```
#### <a name="assert_eq"> assert_eq(got, expected, text="") </a>
assert got == expected and prints optional text.  There are some caveats due to how  Godot compares things.  Arrays are compared by value (with some additional caveats) and dictionaries are compared by reference.  See also [assert_eq_deep](#assert_eq_deep) and [Comparing Things](Comparing-Things)
``` gdscript
func test_equals():
	var one = 1
	var node1 = Node.new()
	var node2 = node1

	assert_eq(one, 1, 'one should equal one') # PASS
	assert_eq('racecar', 'racecar') # PASS
	assert_eq(node2, node1) # PASS
	assert_eq([1, 2, 3], [1, 2, 3]) # PASS
	var d1_pass = {'a':1}
	var d2_pass = d1_pass
	assert_eq(d1_pass, d2_pass) # PASS

	gut.p('-- failing --')
	assert_eq(1, 2) # FAIL
	assert_eq('hello', 'world') # FAIL
	assert_eq(self, node1) # FAIL
	assert_eq([1, 'two', 3], [1, 2, 3, 4]) # FAIL
	assert_eq({'a':1}, {'a':1}) # FAIL
```

#### <a name="assert_ne"> assert_ne(got, not_expected, text="") </a>
asserts got != expected and prints optional text.  Read [Comparing Things](Comparing-Things) for array and dictionary caveats.
``` gdscript
var two = 2
var node1 = Node.new()

gut.p('-- passing --')
assert_ne(two, 1, 'Two should not equal one.')  # PASS
assert_ne('hello', 'world') # PASS
assert_ne(self, node1) # PASS

gut.p('-- failing --')
assert_ne(two, 2) # FAIL
assert_ne('one', 'one') # FAIL
assert_ne('2', 2) # FAIL
```

#### <a name="assert_gt"> assert_gt(got, expected, text="") </a>
assserts got > expected
``` gdscript
var bigger = 5
var smaller = 0

gut.p('-- passing --')
assert_gt(bigger, smaller, 'Bigger should be greater than smaller') # PASS
assert_gt('b', 'a') # PASS
assert_gt('a', 'A') # PASS
assert_gt(1.1, 1) # PASS

gut.p('-- failing --')
assert_gt('a', 'a') # FAIL
assert_gt(1.0, 1) # FAIL
assert_gt(smaller, bigger) # FAIL
```

#### <a name="assert_lt"> assert_lt(got, expected, text="") </a>
asserts got < expected
``` gdscript
var bigger = 5
var smaller = 0
gut.p('-- passing --')
assert_lt(smaller, bigger, 'Smaller should be less than bigger') # PASS
assert_lt('a', 'b') # PASS

gut.p('-- failing --')
assert_lt('z', 'x') # FAIL
assert_lt(-5, -5) # FAIL
```

#### <a name="assert_true"> assert_true(got, text="") </a>
asserts got == true.
``` gdscript
func test_true():
	gut.p('-- passing --')
	assert_true(true, 'True should be true') # PASS
	assert_true(5 == 5, 'That expressions should be true') # PASS

	gut.p('-- failing --')
	assert_true(false) # FAIL
	assert_true('a' == 'b') # FAIL
	assert_true('b') # FAIL
	assert_true(1)
```
#### <a name="assert_false"> assert_false(got, text="") </a>
asserts got == false
``` gdscript
func test_false():
	gut.p('-- passing --')
	assert_false(false, 'False is false') # PASS
	assert_false(1 == 2) # PASS
	assert_false('a' == 'z') # PASS
	assert_false(self.has_user_signal('nope')) # PASS

	gut.p('-- failing --')
	assert_false(true) # FAIL
	assert_false('ABC' == 'ABC') # FAIL
	assert_false(null) # FAIL
	assert_false(0)
```

#### <a name="assert_null"> assert_null(got) </a>
asserts the passed in value is null
```gdscript
gut.p('-- passing --')
assert_null(null)

gut.p('-- failing --')
assert_null('a')
assert_null(1)
```

#### <a name="assert_not_null"> assert_not_null(got) </a>
asserts the passed in value is not null
```gdscript
gut.p('-- passing --')
assert_not_null('a')
assert_not_null(1)

gut.p('-- failing --')
assert_not_null(null)
```

#### <a name="assert_between"> assert_between(got, expect_low, expect_high, text="") </a>
asserts got > expect_low and <= expect_high
``` gdscript
gut.p('-- passing --')
assert_between(5, 0, 10, 'Five should be between 0 and 10') # PASS
assert_between(10, 0, 10) # PASS
assert_between(0, 0, 10) # PASS
assert_between(2.25, 2, 4.0) # PASS

gut.p('-- failing --')
assert_between('a', 'b', 'c') # FAIL
assert_between(1, 5, 10) # FAIL
```

#### <a name="assert_not_between"> assert_not_between(got, expect_low, expect_high, text="") </a>
asserts that got <= expect_low or got >=  expect_high.
``` gdscript
gut.p('-- passing --')
assert_not_between(1, 5, 10) # PASS
assert_not_between('a', 'b', 'd') # PASS
assert_not_between('d', 'b', 'd') # PASS
assert_not_between(10, 0, 10) # PASS
assert_not_between(-2, -2, 10) # PASS

gut.p('-- failing --')
assert_not_between(5, 0, 10, 'Five shouldnt be between 0 and 10') # FAIL
assert_not_between(0.25, -2.0, 4.0) # FAIL

```
#### <a name="assert_almost_eq"> assert_almost_eq(got, expected, error_interval, text='') </a>
Asserts that `got` is within the range of `expected` +/- `error_interval`.  The upper and lower bounds are included in the check.  Verified to work with integers, floats, and Vector2.  Should work with anything that can be added/subtracted.

``` gdscript
gut.p('-- passing --')
assert_almost_eq(0, 1, 1, '0 within range of 1 +/- 1') # PASS
assert_almost_eq(2, 1, 1, '2 within range of 1 +/- 1') # PASS

assert_almost_eq(1.2, 1.0, .5, '1.2 within range of 1 +/- .5') # PASS
assert_almost_eq(.5, 1.0, .5, '.5 within range of 1 +/- .5') # PASS

assert_almost_eq(Vector2(.5, 1.5), Vector2(1.0, 1.0), Vector2(.5, .5))  # PASS

gut.p('-- failing --')
assert_almost_eq(1, 3, 1, '1 outside range of 3 +/- 1') # FAIL
assert_almost_eq(2.6, 3.0, .2, '2.6 outside range of 3 +/- .2') # FAIL

assert_almost_eq(Vector2(.5, 1.5), Vector2(1.0, 1.0), Vector2(.25, .25))  # PASS
```
#### <a name="assert_almost_ne"> assert_almost_ne(got, expected, error_interval, text='') </a>
This is the inverse of `assert_almost_eq`.  This will pass if `got` is outside the range of `expected` +/- `error_interval`.
``` gdscript
gut.p('-- passing --')
assert_almost_ne(1, 3, 1, '1 outside range of 3 +/- 1') # PASS
assert_almost_ne(2.6, 3.0, .2, '2.6 outside range of 3 +/- .2') # PASS

assert_almost_ne(Vector2(.5, 1.5), Vector2(1.0, 1.0), Vector2(.25, .25))  # PASS

gut.p('-- failing --')
assert_almost_ne(0, 1, 1, '0 within range of 1 +/- 1') # FAIL
assert_almost_ne(2, 1, 1, '2 within range of 1 +/- 1') # FAIL

assert_almost_ne(1.2, 1.0, .5, '1.2 within range of 1 +/- .5') # FAIL
assert_almost_ne(.5, 1.0, .5, '.5 within range of 1 +/- .5') # FAIL

assert_almost_ne(Vector2(.5, 1.5), Vector2(1.0, 1.0), Vector2(.5, .5))  # FAIL
```
#### <a name="assert_has"> assert_has(obj, element, text='') </a>
Asserts that the object passed in "has" the element.  This works with any object that has a `has` method.
``` gdscript
var an_array = [1, 2, 3, 'four', 'five']
var a_hash = { 'one':1, 'two':2, '3':'three'}

gut.p('-- passing --')
assert_has(an_array, 'four') # PASS
assert_has(an_array, 2) # PASS
# the hash's has method checks indexes not values
assert_has(a_hash, 'one') # PASS
assert_has(a_hash, '3') # PASS

gut.p('-- failing --')
assert_has(an_array, 5) # FAIL
assert_has(an_array, self) # FAIL
assert_has(a_hash, 3) # FAIL
assert_has(a_hash, 'three') # FAIL
```
#### <a name="assert_does_not_have"> assert_does_not_have(obj, element, text='') </a>
The inverse of `assert_has`
``` gdscript
var an_array = [1, 2, 3, 'four', 'five']
var a_hash = { 'one':1, 'two':2, '3':'three'}

gut.p('-- passing --')
assert_does_not_have(an_array, 5) # PASS
assert_does_not_have(an_array, self) # PASS
assert_does_not_have(a_hash, 3) # PASS
assert_does_not_have(a_hash, 'three') # PASS

gut.p('-- failing --')
assert_does_not_have(an_array, 'four') # FAIL
assert_does_not_have(an_array, 2) # FAIL
# the hash's has method checks indexes not values
assert_does_not_have(a_hash, 'one') # FAIL
assert_does_not_have(a_hash, '3') # FAIL
```

#### <a name="assert_string_contains"> assert_string_contains(text, search, match_case=true) </a>
Assert that `text` contains `search`.  Can perform case insensitive search by passing false for `match_case`.
```gdscript
func test_string_contains():
	gut.p('-- passing --')
	assert_string_contains('abc 123', 'a')
	assert_string_contains('abc 123', 'BC', false)
	assert_string_contains('abc 123', '3')

	gut.p('-- failing --')
	assert_string_contains('abc 123', 'A')
	assert_string_contains('abc 123', 'BC')
	assert_string_contains('abc 123', '012')
```

#### <a name="assert_string_starts_with"> assert_string_starts_with(text, search, match_case=true) </a>
Assert that `text` starts with `search`.  Can perform case insensitive check by passing false for `match_case`
```gdscript
func test_string_starts_with():
	gut.p('-- passing --')
	assert_string_starts_with('abc 123', 'a')
	assert_string_starts_with('abc 123', 'ABC', false)
	assert_string_starts_with('abc 123', 'abc 123')

	gut.p('-- failing --')
	assert_string_starts_with('abc 123', 'z')
	assert_string_starts_with('abc 123', 'ABC')
	assert_string_starts_with('abc 123', 'abc 1234')
```

#### <a name="assert_string_ends_with"> assert_string_ends_with(text, search, match_case=true) </a>
Assert that `text` ends with `search`.  Can perform case insensitive check by passing false for `match_case`
```gdscript
func test_string_ends_with():
	gut.p('-- passing --')
	assert_string_ends_with('abc 123', '123')
	assert_string_ends_with('abc 123', 'C 123', false)
	assert_string_ends_with('abc 123', 'abc 123')

	gut.p('-- failing --')
	assert_string_ends_with('abc 123', '1234')
	assert_string_ends_with('abc 123', 'C 123')
	assert_string_ends_with('abc 123', 'nope')
```

#### <a name="assert_has_signal"> assert_has_signal(object, signal_name) </a>
Asserts the passed in object has a signal with the specified name.  It should be noted that all the asserts that verify a signal was/wasn't emitted will first check that the object has the signal being asserted against.  If it does not, a specific failure message will be given.  This means you can usually skip the step of specifically verifying that the object has a signal and move on to making sure it emits the signal correctly.
``` gdscript
class SignalObject:
	func _init():
		add_user_signal('some_signal')
		add_user_signal('other_signal')

func test_assert_has_signal():
	var obj = SignalObject.new()

	gut.p('-- passing --')
	assert_has_signal(obj, 'some_signal')
	assert_has_signal(obj, 'other_signal')

	gut.p('-- failing --')
	assert_has_signal(obj, 'not_a real SIGNAL')
	assert_has_signal(obj, 'yea, this one doesnt exist either')
	# Fails because the signal is not a user signal.  Node2D does have the
	# specified signal but it can't be checked this way.  It could be watched
	# and asserted that it fired though.
	assert_has_signal(Node2D.new(), 'exit_tree')

```
#### <a name="assert_connected"> assert_connected(signaler_obj, connect_to_obj, signal_name, method_name="") </a>
Asserts that `signaler_obj` is connected to `connect_to_obj` on signal `signal_name`.  The method that is connected is optional.  If `method_name` is supplied then this will pass only if the signal is connected to the  method.  If it is not provided then any connection to the signal will cause a pass.
``` gdscript
class Signaler:
	signal the_signal

class Connector:
	func connect_this():
		pass
	func  other_method():
		pass

func test_assert_connected():
	var signaler = Signaler.new()
	var connector  = Connector.new()
	signaler.connect('the_signal', connector, 'connect_this')

	# Passing
	assert_connected(signaler, connector, 'the_signal')
	assert_connected(signaler, connector, 'the_signal', 'connect_this')

	# Failing
	var foo = Connector.new()
	assert_connected(signaler,  connector, 'the_signal', 'other_method')
	assert_connected(signaler, connector, 'other_signal')
	assert_connected(signaler, foo, 'the_signal')
```
#### <a name="assert_not_connected"> assert_not_connected(signaler_obj, connect_to_obj, signal_name, method_name="") </a>
The inverse of `assert_connected`.

#### <a name="watch_signals"> watch_signals(object) </a>
This must be called in order to make assertions based on signals being emitted.  __Right now, this only supports signals that are emitted with 9 or less parameters.__  This can be extended but nine seemed like enough for now.  The Godot documentation suggests that the limit is four but in my testing I found you can pass more.

This must be called in each test in which you want to make signal based assertions in.  You can call it multiple times with different objects.   You should not call it multiple times with the same object in the same test.  The objects that are watched are cleared after each test (specifically right before `teardown` is called).  Under the covers, Gut will connect to all the signals an object has and it will track each time they fire.  You can then use the following asserts and methods to verify things are acting correct.

#### <a name=assert_signal_emitted> assert_signal_emitted(object, signal_name) </a>
Assert that the specified object emitted the named signal.  You must call `watch_signals` and pass it the object that you are making assertions about.  This will fail if the object is not being watched or if the object does not have the specified signal.  Since this will fail if the signal does not exist, you can often skip using `assert_has_signal`.
``` gdscript
class SignalObject:
	func _init():
		add_user_signal('some_signal')
		add_user_signal('other_signal')

func test_assert_signal_emitted():
	var obj = SignalObject.new()

	watch_signals(obj)
	obj.emit_signal('some_signal')

	gut.p('-- passing --')
	assert_signal_emitted(obj, 'some_signal')

	gut.p('-- failing --')
	# Fails with specific message that the object does not have the signal
	assert_signal_emitted(obj, 'signal_does_not_exist')
	# Fails because the object passed is not being watched
	assert_signal_emitted(SignalObject.new(), 'some_signal')
	# Fails because the signal was not emitted
	assert_signal_emitted(obj, 'other_signal')
```
#### <a name="assert_signal_not_emitted"> assert_signal_not_emitted(object, signal_name) </a>
This works opposite of `assert_signal_emitted`.  This will fail if the object is not being watched or if the object does not have the signal.
``` gdscript
class SignalObject:
	func _init():
		add_user_signal('some_signal')
		add_user_signal('other_signal')

func test_assert_signal_not_emitted():
	var obj = SignalObject.new()

	watch_signals(obj)
	obj.emit_signal('some_signal')

	gut.p('-- passing --')
	assert_signal_not_emitted(obj, 'other_signal')

	gut.p('-- failing --')
	# Fails with specific message that the object does not have the signal
	assert_signal_not_emitted(obj, 'signal_does_not_exist')
	# Fails because the object passed is not being watched
	assert_signal_not_emitted(SignalObject.new(), 'some_signal')
	# Fails because the signal was emitted
	assert_signal_not_emitted(obj, 'some_signal')
```
#### <a name="assert_signal_emitted_with_parameters"> assert_signal_emitted_with_parameters(object, signal_name, parameters, index=-1) </a>
Asserts that a signal was fired with the specified parameters.  The expected parameters should be passed in as an array.  An optional index can be passed when a signal has fired more than once.  The default is to retrieve the most recent emission of the signal.

This will fail with specific messages if the object is not being watched or the object does not have the specified signal
``` gdscript
class SignalObject:
	func _init():
		add_user_signal('some_signal')
		add_user_signal('other_signal')

func test_assert_signal_emitted_with_parameters():
	var obj = SignalObject.new()

	watch_signals(obj)
	# emit the signal 3 times to illustrate how the index works in
	# assert_signal_emitted_with_parameters
	obj.emit_signal('some_signal', 1, 2, 3)
	obj.emit_signal('some_signal', 'a', 'b', 'c')
	obj.emit_signal('some_signal', 'one', 'two', 'three')

	gut.p('-- passing --')
	# Passes b/c the default parameters to check are the last emission of
	# the signal
	assert_signal_emitted_with_parameters(obj, 'some_signal', ['one', 'two', 'three'])
	# Passes because the parameters match the specified emission based on index.
	assert_signal_emitted_with_parameters(obj, 'some_signal', [1, 2, 3], 0)

	gut.p('-- failing --')
	# Fails with specific message that the object does not have the signal
	assert_signal_emitted_with_parameters(obj, 'signal_does_not_exist', [])
	# Fails because the object passed is not being watched
	assert_signal_emitted_with_parameters(SignalObject.new(), 'some_signal', [])
	# Fails because parameters do not match latest emission
	assert_signal_emitted_with_parameters(obj, 'some_signal', [1, 2, 3])
	# Fails because the parameters for the specified index do not match
	assert_signal_emitted_with_parameters(obj, 'some_signal', [1, 2, 3], 1)
```
#### <a name="assert_signal_emit_count"> assert_signal_emit_count(object, signal_name) </a>
Asserts that a signal fired a specific number of times.

``` gdscript
class SignalObject:
	func _init():
		add_user_signal('some_signal')
		add_user_signal('other_signal')

func test_assert_signal_emit_count():
	var obj_a = SignalObject.new()
	var obj_b = SignalObject.new()

	watch_signals(obj_a)
	watch_signals(obj_b)
	obj_a.emit_signal('some_signal')
	obj_a.emit_signal('some_signal')

	obj_b.emit_signal('some_signal')
	obj_b.emit_signal('other_signal')

	gut.p('-- passing --')
	assert_signal_emit_count(obj_a, 'some_signal', 2)
	assert_signal_emit_count(obj_a, 'other_signal', 0)

	assert_signal_emit_count(obj_b, 'other_signal', 1)

	gut.p('-- failing --')
	# Fails with specific message that the object does not have the signal
	assert_signal_emit_count(obj_a, 'signal_does_not_exist', 99)
	# Fails because the object passed is not being watched
	assert_signal_emit_count(SignalObject.new(), 'some_signal', 99)
	# The following fail for obvious reasons
	assert_signal_emit_count(obj_a, 'some_signal', 0)
	assert_signal_emit_count(obj_b, 'other_signal', 283)
```
#### <a name="get_signal_emit_count"> get_signal_emit_count(object, signal_name) </a>
This will return the number of times a signal was fired.  This gives you the freedom to make more complicated assertions if the spirit moves you.  This will return -1 if the signal was not fired or the object was not being watched, or if the object does not have the signal.

#### <a name="get_signal_parameters"> get_signal_parameters(object, signal_name, index=-1) </a>
If you need to inspect the parameters in order to make more complicate assertions, then this will give you access to the parameters of any watched signal.  This works the same way that `assert_signal_emitted_with_parameters` does.  It takes an object, signal name, and an optional index.  If the index is not specified then the parameters from the most recent emission will be returned.  If the object is not being watched, the signal was not fired, or the object does not have the signal then `null` will be returned.
``` gdscript
class SignalObject:
	func _init():
		add_user_signal('some_signal')
		add_user_signal('other_signal')

func test_get_signal_parameters():
	var obj = SignalObject.new()
	watch_signals(obj)
	obj.emit_signal('some_signal', 1, 2, 3)
	obj.emit_signal('some_signal', 'a', 'b', 'c')

	gut.p('-- passing --')
	# passes because get_signal_parameters returns the most recent emission
	# by default
	assert_eq(get_signal_parameters(obj, 'some_signal'), ['a', 'b', 'c'])
	assert_eq(get_signal_parameters(obj, 'some_signal', 0), [1, 2, 3])
	# if the signal was not fired null is returned
	assert_eq(get_signal_parameters(obj, 'other_signal'), null)
	# if the signal does not exist or isn't being watched null is returned
	assert_eq(get_signal_parameters(obj, 'signal_dne'), null)

	gut.p('-- failing --')
	assert_eq(get_signal_parameters(obj, 'some_signal'), [1, 2, 3])
	assert_eq(get_signal_parameters(obj, 'some_signal', 0), ['a', 'b', 'c'])
```
#### <a name="assert_file_exists"> assert_file_exists(file_path) </a>
asserts a file exists at the specified path
``` gdscript
func before_each():
	gut.file_touch('user://some_test_file')

func after_each():
	gut.file_delete('user://some_test_file')

func test_assert_file_exists():
	gut.p('-- passing --')
	assert_file_exists('res://addons/gut/gut.gd') # PASS
	assert_file_exists('user://some_test_file') # PASS

	gut.p('-- failing --')
	assert_file_exists('user://file_does_not.exist') # FAIL
	assert_file_exists('res://some_dir/another_dir/file_does_not.exist') # FAIL
```
#### <a name="assert_file_does_not_exist"> assert_file_does_not_exist(file_path) </a>
asserts a file does not exist at the specified path
``` gdscript
func before_each():
	gut.file_touch('user://some_test_file')

func after_each():
	gut.file_delete('user://some_test_file')

func test_assert_file_does_not_exist():
	gut.p('-- passing --')
	assert_file_does_not_exist('user://file_does_not.exist') # PASS
	assert_file_does_not_exist('res://some_dir/another_dir/file_does_not.exist') # PASS

	gut.p('-- failing --')
	assert_file_does_not_exist('res://addons/gut/gut.gd') # FAIL
```
#### <a name="assert_file_empty"> assert_file_empty(file_path) </a>
asserts the specified file is empty
``` gdscript
func before_each():
	gut.file_touch('user://some_test_file')

func after_each():
	gut.file_delete('user://some_test_file')

func test_assert_file_empty():
	gut.p('-- passing --')
	assert_file_empty('user://some_test_file') # PASS

	gut.p('-- failing --')
	assert_file_empty('res://addons/gut/gut.gd') # FAIL
```
#### <a name="assert_file_not_empty"> assert_file_not_empty(file_path) </a>
asserts the specified file is not empty
``` gdscript
func before_each():
	gut.file_touch('user://some_test_file')

func after_each():
	gut.file_delete('user://some_test_file')

func test_assert_file_not_empty():
	gut.p('-- passing --')
	assert_file_not_empty('res://addons/gut/gut.gd') # PASS

	gut.p('-- failing --')
	assert_file_not_empty('user://some_test_file') # FAIL
```
#### <a name="assert_is"> assert_is(object, a_class, text) </a>
Asserts that "object" extends "a_class".  object must be an instance of an object.  It cannot be any of the built in classes like Array or Int or Float.  a_class must be a class, it can be loaded via load, a GDNative class such as Node or Label or anything else.

``` gdscript
func test_assert_is():
	gut.p('-- passing --')
	assert_is(Node2D.new(), Node2D)
	assert_is(Label.new(), CanvasItem)
	assert_is(SubClass.new(), BaseClass)
	# Since this is a test script that inherits from test.gd, so
	# this passes.  It's not obvious w/o seeing the whole script
	# so I'm telling you.  You'll just have to trust me.
	assert_is(self, load('res://addons/gut/test.gd'))

	var Gut = load('res://addons/gut/gut.gd')
	var a_gut = Gut.new()
	assert_is(a_gut, Gut)

	gut.p('-- failing --')
	assert_is(Node2D.new(), Node2D.new())
	assert_is(BaseClass.new(), SubClass)
	assert_is('a', 'b')
	assert_is([], Node)
```

#### <a name="assert_typeof">assert_typeof(object, type, text='') </a>
Asserts that `object` is the the `type` specified.  `type` should be one of the Godot `TYPE_` constants.
``` gdscript
func test_assert_typeof():
	gut.p('-- passing --')
	var c = Color(1, 1, 1, 1)
	gr.test.assert_typeof(c, TYPE_COLOR)
	assert_pass(gr.test)

	gut.p('-- failing --')
	gr.test.assert_typeof('some string', TYPE_INT)
	assert_fail(gr.test)
```

#### <a name="assert_not_typeof">assert_not_typeof(object, type, text='') </a>
The inverse of `assert_typeof`

#### <a name="assert_freed">assert_freed(obj, text) </a>
Asserts that the passed in object has been freed.  This assertion requires that  you pass in some text in the form of a title since, if the object is freed, we won't have anything to convert to a string to put in the output statement.

Note that this currently does not detect if a node has been queued free.
``` gdscript
func test_object_is_freed_should_pass():
	var obj = Node.new()
	obj.free()
	test.assert_freed(obj, "New Node")
```

#### <a name="assert_not_freed">assert_not_freed(obj, text) </a>
The inverse of `assert_freed`

``` gdscript
func test_object_is_not_freed_should_pass():
	var obj = Node.new()
	assert_not_freed(obj, "New Node")

func test_queued_free_is_not_freed():
	var obj = Node.new()
	add_child(obj)
	obj.queue_free()
	assert_not_freed(obj, "New Node")
```

#### <a name="assert_exports">assert_exports(obj, property_name, type) </a>
Asserts that `obj` exports a property with the name `property_name` and a type of `type`.  The `type` must be one of the various Godot built-in `TYPE_` constants.

``` gdscript
class ExportClass:
	export var some_number = 5
	export(PackedScene) var some_scene
	var some_variable = 1

func test_assert_exports():
	var obj = ExportClass.new()

	gut.p('-- passing --')
	assert_exports(obj, "some_number", TYPE_INT)
	assert_exports(obj, "some_scene", TYPE_OBJECT)

	gut.p('-- failing --')
	assert_exports(obj, 'some_number', TYPE_VECTOR2)
	assert_exports(obj, 'some_scene', TYPE_AABB)
	assert_exports(obj, 'some_variable', TYPE_INT)
```

#### <a name="assert_called">assert_called(inst, method_name, parameters=null) </a>
This assertion is is one of the ways Gut implements Spies.  It requires that you pass it an instance of a "doubled" object.  An instance created with `double` will record when a method it has is called.  You can then make assertions based on this.

This assert will check the object to see if a call to the specified method (optionally with parameters) was called over the course of the test.  If it finds a match this test will `pass`, if not it will `fail`.

The `parameters` parameter is an array of values that you expect to have been passed to `method_name`.  If you do not specify any parameters then any call to `method_name` will match and the assert will `pass`.  If you specify parameters then all the parameter values must match.  You must specify all parameters the method takes, even if they have defaults.  Gut is not able (yet?) to fill in default values.

__Methods that are inherited from built-in parent classes are not yet recorded.  For example, you cannot make "called" assertions on methods like `set_position` unless your sub-class specifically implements it.  But since those methods retain their built-in functionality, you can just make normal assertions on them.__

``` gdscript
# Given the following class located at 'res://test/doubler_test_objects/double_extends_node2d.gd'
# --------------------
	extends Node2D
	var _value = 0

	func get_value():
	    return _value
	func set_value(val):
	    _value = val
	func has_one_param(one):
	    pass
	func has_two_params_one_default(one, two=null):
	    pass
	func get_position():
	    return .get_position()
# --------------------

# This is how assert_called behaves
func test_assert_called():
	var DOUBLE_ME_PATH = 'res://test/doubler_test_objects/double_extends_node2d.gd'

	var doubled = double(DOUBLE_ME_PATH).new()
	doubled.set_value(4)
	doubled.set_value(5)
	doubled.has_two_params_one_default('a')
	doubled.has_two_params_one_default('a', 'b')

	gut.p('-- passing --')
	assert_called(doubled, 'set_value')
	assert_called(doubled, 'set_value', [5])
	# note the passing of `null` here.  Default parameters must be supplied.
	assert_called(doubled, 'has_two_params_one_default', ['a', null])
	assert_called(doubled, 'has_two_params_one_default', ['a', 'b'])

	gut.p('-- failing --')
	assert_called(doubled, 'get_value')
	assert_called(doubled, 'set_value', ['nope'])
	# This fails b/c Gut isn't smart enough to fill in default values for you...
	# ast least not yet.
	assert_called(doubled, 'has_two_params_one_default', ['a'])
	# This fails with a specific message indicating that you have to pass an
	# instance of a doubled class.
	assert_called(GDScript.new(), 'some_method')
```
#### <a name="asssert_not_called">assert_not_called(inst, method_name, parameters=null) </a>
This is the inverse of `assert_called` and works the same way except, you know, inversely.  Matches are found based on parameters in the same fashion.  If a matching call is found then this assert will `fail`, if not it will `pass`.

#### <a name="assert_call_count">assert_call_count(inst, method_name, expected_count, parameters=null) </a>
This assertion is is one of the ways Gut implements Spies.  It requires that you pass it an instance of a "doubled" object.  An instance created with `double` will record when a method it has is called.  You can then make assertions based on this.

This asserts that a method on a doubled instance has been called a number of times.  If you do not specify any parameters then all calls to the method will be counted.  If you specify parameters, then only those calls that were passed matching values will be counted.

The `parameters` parameter is an array of values that you expect to have been passed to `method_name`.  If you do not specify any parameters then any call to `method_name` will match and the assert will `pass`.  If you specify parameters then all the parameter values must match.  You must specify all parameters the method takes, even if they have defaults.  Gut is not able (yet?) to fill in default values.

__Methods that are inherited from built-in parent classes are not yet recorded.  For example, you cannot make "call" assertions on methods like `set_position` unless your sub-class specifically implements it (you can, they will just always return 0).  Since those methods retain their built-in functionality, you can just make normal assertions on them.__


``` gdscript
# Given the following class located at 'res://test/doubler_test_objects/double_extends_node2d.gd'
# --------------------
	extends Node2D
	var _value = 0

	func get_value():
	    return _value
	func set_value(val):
	    _value = val
	func has_one_param(one):
	    pass
	func has_two_params_one_default(one, two=null):
	    pass
	func get_position():
	    return .get_position()
# --------------------

# This is how assert_call_count behaves
func test_assert_call_count():
	var DOUBLE_ME_PATH = 'res://test/doubler_test_objects/double_extends_node2d.gd'

	var doubled = double(DOUBLE_ME_PATH).new()
	doubled.set_value(4)
	doubled.set_value(5)
	doubled.has_two_params_one_default('a')
	doubled.has_two_params_one_default('a', 'b')
	doubled.set_position(Vector2(100, 100))

	gut.p('-- passing --')
	assert_call_count(doubled, 'set_value', 2)
	assert_call_count(doubled, 'set_value', 1, [4])
	# note the passing of `null` here.  Default parameters must be supplied.
	assert_call_count(doubled, 'has_two_params_one_default', 1, ['a', null])
	assert_call_count(doubled, 'get_value', 0)

	gut.p('-- failing --')
	assert_call_count(doubled, 'set_value', 5)
	assert_call_count(doubled, 'set_value', 2, [4])
	assert_call_count(doubled, 'get_value', 1)
	# This fails with a specific message indicating that you have to pass an
	# instance of a doubled class even though technically the method was called.
	assert_call_count(GDScript.new(), 'some_method', 0)
	# This fails b/c double_extends_node2d does not have it's own implementation
	# of set_position.  The function is supplied by the parent class and these
	# methods are not yet being recorded.
	assert_call_count(doubled, 'set_position', 1)

```

#### <a name="get_call_parameters">get_call_parameters(obj, method_name, index=-1) </a>
This method allows you to get the parameters that were sent to a call to a doubled object's method.  You must pass it an object created with/from `double`.  It will return and array containing the parameters from the most recent call by default.  You can optionally specify an index to get where the first call to the method is at position `0`.  If no calls were made to the method or you pass in a object this is not a double then `null` is returned.

```gdscript
func test_get_call_parameters():
	var DOUBLE_ME_PATH = 'res://test/resources/doubler_test_objects/double_extends_node2d.gd'

	var doubled = double(DOUBLE_ME_PATH).new()
	doubled.set_value(5)
	doubled.has_two_params_one_default('a')
	doubled.has_two_params_one_default('x', 'y')

	# prints [5]
	print(get_call_parameters(doubled, 'set_value'))
	# prints [x, y]
	print(get_call_parameters(doubled, 'has_two_params_one_default'))
	# prints [a, Null]
	print(get_call_parameters(doubled, 'has_two_params_one_default', 0))

```

#### <a name="get_call_count">get_call_count(obj, method_name, parameters=null) </a>
Get the number of times a method was called on a double.  Include the optional parameters array to only get the count for calls with matching parameters.  This is essentially `assert_call_count` without the assert, in case you need to do something else with the count.
```
	func test_called_10_times():
		var doubled = partial_double(DOUBLE_ME_PATH).new()
		for i in range(10):
			doubled.set_value(5)
		var count = get_call_count(doubled, 'set_value') # 10

	func test_it_works_with_parameters():
		var doubled = double(DOUBLE_ME_PATH).new()
		for i in range(3):
			doubled.set_value(3)

		for i in range(5):
			doubled.set_value(5)
		var count = get_call_count(doubled, 'set_value', [3]) # 3
```

#### <a name="assert_has_method">assert_has_method(obj, method) </a>
Asserts that the passed in object has a method named `method`.
```gdscript
class SomeClass:
	var _count = 0

	func get_count():
		return _count
	func set_count(number):
		_count = number

	func get_nothing():
		pass
	func set_nothing(val):
		pass

func test_assert_has_method():
	var some_class = SomeClass.new()
	gut.p('-- passing --')
	assert_has_method(some_class, 'get_nothing')
	assert_has_method(some_class, 'set_count')

	gut.p('-- failing --')
	assert_has_method(some_class, 'method_does_not_exist')
```
#### <a name="assert_accessors"> assert_accessors(obj, property, default, set_to) </a>
I found that making tests for most getters and setters was repetitious and annoying.  Enter `assert_accessors`.  This assertion handles 80% of your getter and setter testing needs.  Given an object and a property name it will verify:
 * The object has a method called `get_<PROPERTY_NAME>`
 * The object has a method called `set_<PROPERTY_NAME>`
 * The method `get_<PROPERTY_NAME>` returns the expected default value when first called.
 * Once you set the property, the `get_<PROPERTY_NAME>`will return the value passed in.

On the inside Gut actually performs up to 4 assertions.  So if everything goes right you will have four passing asserts each time you call `assert_accessors`.  I say "up to 4 assertions" because there are 2 assertions to make sure the object has the methods and then 2 to verify they act correctly.  If the object does not have the methods, it does not bother running the tests for the methods.
``` gdscript
class SomeClass:
	var _count = 0

	func get_count():
		return _count
	func set_count(number):
		_count = number

	func get_nothing():
		pass
	func set_nothing(val):
		pass

func test_assert_accessors():
  var some_class = SomeClass.new()
  gut.p('-- passing --')
  assert_accessors(some_class, 'count', 0, 20) # 4 PASSING

  gut.p('-- failing --')
  # 1 FAILING, 3 PASSING
  assert_accessors(some_class, 'count', 'not_default', 20)
  # 2 FAILING, 2 PASSING
  assert_accessors(some_class, 'nothing', 'hello', 22)
  # 2 FAILING
  assert_accessors(some_class, 'does_not_exist', 'does_not', 'matter')
```

#### <a name="is_passing">is_passing() </a>
Returns true if the test is passing as of the time of calling it.  This will return false if there haven't been any asserts or if any of the asserts are failing.  Usable in `after_each` but not `after_all`.

#### <a name="is_failing">is_failing() </a>
Returns true if any failing asserts have occurred as of the time of calling it.  Usable in `after_each` but not `after_all`.

#### <a name="add_child_autofree"> add_child_autofree(object) </a>
Calls `add_child` and `autofree` with the passed in object and returns it.  See [Memory Management](Memory-Management) page for more details.

#### <a name="add_child_autoqfree">add_child_autoqfree(object) </a>
Calls `add_child` and `autoqfree` with the passed in object and returns it.  See [Memory Management](Memory-Management) page for more details.

#### <a name="autofree">autofree(object) </a>
Marks an object so that `free` will be called on it after the test finishes.  Returns the object passed in.  See [Memory Management](Memory-Management) page for more details.

#### <a name="autoqfree">autoqfree(object) </a>
Marks an object so that `queue_free` will be called on it after the test finishes.  Returns the object passed in.  See [Memory Management](Memory-Management) page for more details.

#### <a name="assert_no_new_orphans">assert_no_new_orphans(text='') </a>
This method will assert that no orphaned nodes have been introduced by the test when the assert is executed.  See the [Memory Management](Memory-Management#testing_for_leaks) page for more information.

#### <a name="gut_p"> gut.p(text, level=0) </a>
Print info to the GUI and console (if enabled).  You can see examples if this in the sample code above.  In order to be able to spot check the sample code, I print out a divider between the passing and failing tests.

#### <a name="pause_before_teardown"> pause_before_teardown() </a>
This method will cause Gut to pause before it moves on to the next test.  This is useful for debugging, for instance if you want to investigate the screen or anything else after a test has finished executing.  See also `set_ignore_pause_before_teardown`

#### <a name="wait_seconds"> wait_seconds(time, msg='') </a>
See [Awaiting](Awaiting)


#### <a name="wait_seconds"> wait_frames(frames, msg='') </a>
See [Awaiting](Awaiting)


#### <a name="wait_for_signal"> wait_for_signal(sig, max_wait, msg='') </a>
See [Awaiting](Awaiting)


#### <a name="double"> double(path_or_class, inner_class_path=null) </a>
This will return a double of a class.  See [Doubles](Doubles) for more information.


#### <a name="simulate"> simulate(obj, times, delta) </a>
This will call `_process` or `_physics_process` on the passed in object and all children of the object.  It will call them `times` times and pass in `delta` to each call.  See [Simulate](Simulate) for more information.

#### <a name="stub"> stub(...) </a>
Allows you to stub a [doubled](Doubles) instance of a script or scene to return a value.  See [Stubbing](Stubbing) for a list of parameters and instructions on Stubbing.

#### <a name="ignore_method_when_doubling"> ignore_method_when_doubling(path_or_class, method_name) </a>
This was implemented to allow the doubling of classes with static methods.  There might be other valid use cases for this method, but you should always try stubbing before using this method.  Using `stub(my_double, 'method').to_call_super()` or  creating a `partial_double` works for any other known scenario.  You cannot stub or spy on methods passed to `ignore_method_when_doubling`.

This method will add a method for a script to an ignore list.  This means the method will not be included in the double.  This is required if you are attempting to double a class that has static methods.  Each of the static methods must be added to the ignore list or you will get a parser error similar to:
```
Parser Error: Function signature doesn't match the parent. Parent signature is: 'Variant foo()'.
```

`ignore_method_when_doubling` takes two parameters.  The first parameter can be a path to a script, a path to a scene, a loaded script, or a loaded scene.  The second is the name of the method to ignore.

``` gdscript
# -----------------------------------------------
# Given this as res://scripts/has_statics.gd
# -----------------------------------------------
static func this_is_static():
  pass

func not_static():
  return 'foo'

# -----------------------------------------------
# You can double this script like this:
# -----------------------------------------------
func test_can_double_classes_with_statics_if_ignored():
  ignore_method_when_doubling('res://scripts/has_statics.gd', 'this_is_static')
  var d_has_statics = double('res://scripts/has_statics.gd').new()
  assert_not_null(d_has_statics)

func test_can_use_loaded_scripts_to_ignore_statics():
  var HasStatics = load('res://scripts/has_statics.gd')
  ignore_method_when_doubling(HasStatics, 'this_is_static')
  var d_has_statics = double(HasStatics).new()
  assert_not_null(d_has_statics)

func test_cannot_spy_or_stub_ignored_methods():
  var HasStatics = load('res://scripts/has_statics.gd')
  ignore_method_when_doubling(HasStatics, 'this_is_static')
  ignore_method_when_doubling(HasStatics, 'not_static')

  var d_has_statics = double(HasStatics).new()
  # This stub will not be used since the method was ignored
  stub(d_has_statics, 'not_static').to_return('bar')
  var result = d_has_statics.not_static()

  assert_eq(result, 'foo', 'not stubbed so "foo" will be returned')
  # this will pass, even though the method was called,
  # because you cannot spy on ignored methods.
  assert_not_called(d_has_statics, 'not_static')
```

#### <a name="replace_node"> replace_node(base_node, path_or_node, with_this) </a>
Replaces the child node of base_node with `with_this`.  You can pass a path to a node or a child node of base_node.  `with_this` will get all groups that the replaced node had.  `with_this` also gets the same "name" that the replaced node had so that any references to it via `$` will work.  The replaced node is freed via `queue_free`.

This is useful when you want to double a node in another node.  Your code might be referencing the node via a call to `get_node` or might be using the `$` syntax to get to the object.  `replace_node` allows you to replace a node in another node and retain all of your `get_node` and `$` references.

This will only work for references to the node are made __after__ `replace_node` has been called.  If your object has a local variable that points to the node that gets replaced and:
* it was set on `_init`
* or it was set in `_ready` or via an `onready` variable, and the base object has already been added to the tree

then these variables will point to the old object (which gets freed after the call to `replace_node`).

```gdscript
func test_replace_node():
	# This scene has:
	# Node2D
	#   - Label
	#   - MyPanel
	#     - MyButton
	#
	# And code:
	#
	# double_me_scene.gd:
	# extends Node2D
	#
	# onready var label = get_node('Label')
	#
	# func return_hello():
	# 	return 'hello'
	#
	# func set_label_text(text):
	# 	$Label.set_text(text)
	#
	# func get_button():
	# 	return $MyPanel/MyButton
	var DOUBLE_ME_SCENE = 'res://test/resources/doubler_test_objects/double_me_scene.tscn'

	var scene = load(DOUBLE_ME_SCENE).instance()
	add_child_autofree(scene)
	var replace_label = Label.new()
	replace_node(scene, 'Label', replace_label)

	# Passing
	scene.set_label_text('asdf')
	assert_eq(replace_label.get_text(), 'asdf',
	  "Since set_label_text references the label using $ this will point to the new one.")

	var replace_button = Button.new()
	replace_node(scene, 'MyPanel/MyButton', replace_button)
	assert_eq(scene.get_button(), replace_button,
	  'Get button uses $ so this will work.')

	# Failing
	assert_eq(scene.label, replace_label,
	  'The variable "label" was set as onready so it will not be updated')
```

[Comparing Things](Comparing-Things)
#### <a name="compare_shallow"> compare_shallow(v1, v2, max_differences=30) </a>
Performs a shallow comparison between two arrays or dictionaries.  A `CompareResult` object is returned.   See [Comparing Things](Comparing-Things) for more information and examples.

#### <a name="compare_deep"> compare_deep(v1, v2, max_differences=30) </a>
Performs a deep comparison between two arrays or dictionaries.  A `CompareResult` object is returned.   See [Comparing Things](Comparing-Things) for more information and examples.

#### <a name="assert_eq_deep"> assert_eq_deep(v1, v2) </a>
Performs a deep comparison between two arrays or dictionaries and asserts they are equal.  If they are not equal then a formatted list of differences are displayed.  See [Comparing Things](Comparing-Things) for more information.
```gdscript
func test_assert_eq_deep():
	var complex_example = [
		'a', 'b', 'c',
		[1, 2, 3, 4],
		{'a':1, 'b':2, 'c':3},
		[{'a':1}, {'b':2}]
	]

	# Passing
	assert_eq_deep([1, 2, {'a':1}], [1, 2, {'a':1}])
	assert_eq_deep({'a':1, 'b':{'c':1}}, {'b':{'c':1}, 'a':1})

	var shallow_copy  = complex_example.duplicate(false)
	var deep_copy = complex_example.duplicate(true)
	assert_eq_deep(complex_example, shallow_copy)
	assert_eq_deep(complex_example, deep_copy)
	assert_eq_deep(shallow_copy, deep_copy)

	# Failing
	assert_eq_shallow([1, 2], [1, 2 ,3]) # missing index
	assert_eq_shallow({'a':1}, {'a':1, 'b':2}) # missing key
	assert_eq_deep([1, 2, {'a':1}], [1, 2, {'a':1.0}]) # floats != ints
```

#### <a name="assert_ne_deep"> assert_ne_deep(v1, v2) </a>
Performs a deep comparison of two arrays or dictionaries and asserts they are not equal.  See [Comparing Things](Comparing-Things) for more information.

#### <a name="assert_eq_shallow"> assert_eq_shallow(v1, v2) </a>
Performs a shallow comparison between two arrays or dictionaries and asserts they are equal.  If they are not equal then a formatted list of differences are displayed.  See [Comparing Things](Comparing-Things) for more information.
```gdscript
func test_assert_eq_shallow():
	var complex_example = [
		'a', 'b', 'c',
		[1, 2, 3, 4],
		{'a':1, 'b':2, 'c':3},
		[{'a':1}, {'b':2}]
	]

	# Passing
	assert_eq_shallow([1, 2, 3], [1, 2, 3])
	assert_eq_shallow([1, [2, 3], 4], [1, [2, 3], 4])
	var d1 = {'foo':'bar'}
	assert_eq_shallow([1, 2, d1], [1, 2, d1])
	assert_eq_shallow({'a':1}, {'a':1})
	assert_eq_shallow({'a':[1, 2, 3, d1]}, {'a':[1, 2, 3, d1]})

	var shallow_copy = complex_example.duplicate(false)
	assert_eq_shallow(complex_example, shallow_copy)

	# Failing
	assert_eq_shallow([1, 2], [1, 2 ,3]) # missing index
	assert_eq_shallow({'a':1}, {'a':1, 'b':2}) # missing key
	assert_eq_shallow([1, 2], [1.0, 2.0]) # floats != ints
	assert_eq_shallow([1, 2, {'a':1}], [1, 2, {'a':1}]) # compare [2] by ref
	assert_eq_shallow({'a':1}, {'a':1.0}) # floats != ints
	assert_eq_shallow({'a':1, 'b':{'c':1}}, {'a':1, 'b':{'c':1}}) # compare 'b' by ref

	var deep_copy = complex_example.duplicate(true)
	assert_eq_shallow(complex_example, deep_copy)
```

#### <a name="assert_ne_shallow"> assert_ne_shallow(v1, v2) </a>
Performs a shallow comparison of two arrays or dictionaries and asserts they are not equal.  See [Comparing Things](Comparing-Things) for more information.


#### <a name="assert_property"> assert_property(obj, name_property, default_value, set_to_value) </a>
This method does a couple of common tests for properties.
It checks if:
* the named setter and getter functions exist
* the given default value is set_to_value
* the value is set correctly to the given `set_to_value`
* the named setter and getter functions are called when the property is accessed directly

It fails if at least one of the mentioned sub-checks fails.

The parameter `obj` can be any `Object`. Depending on what you put in the function will try retrieve the underlying class or to instantiate from `obj`. It is tested for classes extending `Script` or `PackedScene` in case you want to put in a class / scene. It is tested for objects extending the `Node` class. The method may fail if you try to put in something else.

Under the cover it runs `assert_accessors` and `assert_setget_called`. Look into [assert_accessors](#assert_accessors) or [assert_setget_called](#assert_setget_called) to get further information on how they work.

In the following script you can see some examples how to use this assert function. The class under test is a "Health" component. It has a `max_hap` field with no setter or getter assigned. It also has a `current_hp` property with assigned setter and getter functions.

```gdscript
gut.p('-- class under test --')
class Health:
  extends Node


  export(int) var max_hp = 0
  export(int) var current_hp = 0 setget set_current_hp, get_current_hp


  func set_max_hp(value: int) -> void:
  	if value < 0:
  		value = 0
  	max_hp = value


  func get_max_hp() -> int:
  	return max_hp


  func set_current_hp(value: int) -> void:
  	current_hp = clamp(value, 0, max_hp)


  func get_current_hp() -> int:
  	return current_hp


gut.p('-- passing --')
assert_property(Health, 'current_hp', 0, 0) # PASS
var health = Health.new()
health.max_hp = 10
assert_property(health, 'current_hp', 0, 5) # PASS

gut.p('-- failing --')
assert_property(Health, 'max_hp', 0, 5) # FAIL => no setget keyword
assert_property(Health, 'current_hp', 0, 5) # FAIL => method will clamp current_hp to max_hp which is 0 by default
var directory = Directory.new()
assert_property(directory, 'current_dir', '', 'new_dir') # FAIL => directory is not a Resource nor a Node

```

#### <a name="assert_setget_called"> assert_setget_called(type, name_property, name_setter="", name_getter="") </a>
This method checks if the named setter and getter functions are called when the given property is accessed.

In GDScript this is realized by using the `setget` keyword. The keyword requires you to specify a setter or getter function, you can also specify both:

```gdscript
class SomeClass:
  var property_both = null setget set_property_both, get_property_both
  var property_setter = null setget set_property_setter
  var property_getter = null setget , get_property_getter
  var normal_class_attribute = null
  var another_property = null setget some_completely_different_name, another_different_name
```

With this assert you can test for scenarios equivalent to `property_both`, `property_setter` and `property_getter`. As shown in the example GDScript allows any names for the setter and getter functions. With this assert you can test for this scenario as well. With this assert you cannot test for normal class attributes.

The parameter `type` has to be a `Resource`. Therefore you can put in a `Script` or a `PackedScene` but no instances of your class / scene under test.

The parameters `name_setter` and `name_getter` are optional.

In the following script you can see some examples how to use this assert function. The class under test is a "Health" component. It has a `max_hap` field with no setter or getter assigned. It also has a `current_hp` property with assigned setter and getter functions. For slightly more convenient ways to test properties with setget keyword also look into [assert_setget](#assert_setget) or [assert_property](#assert_property). They wrap around this assert function and set some common defaults to safe you some time.

```gdscript
gut.p('-- class under test --')
class Health:
  extends Node


  export(int) var max_hp = 0
  export(int) var current_hp = 0 setget set_current_hp, get_current_hp


  func set_max_hp(value: int) -> void:
  	if value < 0:
  		value = 0
  	max_hp = value


  func get_max_hp() -> int:
  	return max_hp


  func set_current_hp(value: int) -> void:
  	current_hp = clamp(value, 0, max_hp)


  func get_current_hp() -> int:
  	return current_hp


gut.p('-- passing --')
assert_setget_called(Health, 'current_hp', 'set_current_hp', 'get_current_hp') # PASS
assert_setget_called(Health, 'current_hp', 'set_current_hp') # PASS
assert_setget_called(Health, 'current_hp', '', 'get_current_hp') # PASS


gut.p('-- failing --')
assert_setget_called(Health, 'max_hp', 'set_max_hp') # FAIL
assert_setget_called(Health, 'max_hp') # FAIL => out of scope
assert_setget_called(Health, 'current_hp') # FAIL => setter or getter name must be specified
assert_setget_called(Health, 'current_hp', 'set_current_hp', 'get_current_hp') # FAIL => typo...
var health = Health.new()
assert_setget_called(health, 'current_hp', 'set_current_hp') # FAIL => type has to be a Resource
assert_setget_called(Health, max_hp, null, null) # FAIL => methods do not exist
assert_setget_called(Health, max_hp, 1, 1)  # FAIL => methods do not exist
assert_setget_called(5, 'current_hp', 'set_current_hp')  # FAIL => type has to be a Resource
assert_setget_called(double(Health), 'current_hp', 'set_current_hp') # FAIL => type has to be a Resource that can be doubled
```

Please note the last example. So far an already doubled type cannot be doubled again. Since the class under test will be doubled within the assert procession it is important to only feed in types that can be doubled. For more information about doubling its restrictions see the wiki page about [Doubles](Doubles).


#### <a name="assert_setget"> assert_property(obj, name_property, has_setter=false, has_getter=false) </a>
This method checks if the named setter and getter functions are called when the given property is accessed.

In GDScript this is realized by using the `setget` keyword. The keyword requires you to specify a setter or getter function, you can also specify both:

```gdscript
class SomeClass:
  var property_both = null setget set_property_both, get_property_both
  var property_setter = null setget set_property_setter
  var property_getter = null setget , get_property_getter
```

The parameter `obj` can be any `Object`. Depending on what you put in the function will try retrieve the underlying class or to instantiate from `obj`. It is tested for classes extending `Script` or `PackedScene` in case you want to put in a class / scene. It is tested for objects extending the `Node` class. The method may fail if you try to put in something else.

The parameters `name_setter` and `name_getter` are optional.

Under the cover it runs `assert_setget_called`. Look into [assert_setget_called](#assert_setget_called) to get further information on how it works.

In the following script you can see some examples how to use this assert function. The class under test is a "Health bar" component. It has a `health` field with a setter but no getter assigned.

```gdscript
gut.p('-- class under test --')
class HealthBar:
  extends Control

const Health = preload("res://some_path/health.gd")
var health: Health = null setget set_health

onready var progress_bar = $ProgressBar
onready var label = $Label


func set_health(node: Health) -> void:
	health = node


func _on_Health_updated() -> void:
	if health != null:
		label.text = "%s / %s" %[health.current_hp, health.max_hp]
		progress_bar.max_value = health.max_hp
		progress_bar.value = health.current_hp


gut.p('-- passing --')
assert_setget(HealthBar, 'health', true) # PASS
var health_bar = load("res://some_path/HealthBar.tscn").instance()
assert_setget(health_bar, 'health', true) # PASS

gut.p('-- failing --')
assert_setget(HealthBar, 'label') # FAIL => setter or getter has to be specified
assert_setget(HealthBar, 'label', true) # FAIL => setter does not exist
```
