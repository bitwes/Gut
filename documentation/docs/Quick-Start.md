This page contains brief descriptions of many of GUT's features.  Most sections have a "More information" link where more in depth documentation can be found.

* [Setup](#setup)
* [Creating Tests](#creating_tests)
* [Doubles/Stubbing/Spies](#doubles)
* [Partial Doubles](#partial_doubles)
* [Parameterized Tests](#parameterized_tests)
* [Await](#await)
* [Memory Leak Testing and Memory Management](#memory_management)


# <a name = "setup"> Setup
Setup doesn't get any simpler than what is already on the [install page.](Install)


# <a name = "run"> Run Tests
* Configure the directories where your tests are in the Gut Panel settings.
* Open a test script.
* use the various buttons to run a script, inner class, or test.
![Gut Panel](images/gut_panel.png)

Mouse-over labels and buttons in the GUT panel for more information.  You can even set keyboard shortcuts for all of the GUT panel actions.

You can also run tests via the [command line](Command-Line) and through [VSCode](https://marketplace.visualstudio.com/items?itemName=bitwes.gut-extension)

# <a name = "creating_tests">Creating Tests
[More Information](Creating-Tests)

All test scripts must extend the `test.gd` script supplied by GUT.
```
extends GutTest
```
There are various asserts and helpers that are listed [here](Asserts-and-Methods)

Setup and teardown methods:
* `before_all`
* `before_each`
* `after_each`
* `after_all`

Any method that starts with "test" will be run as a test.
``` gdscript
extends GutTest

func before_all():
	gut.p("Runs once before all tests")

func before_each():
	gut.p("Runs before each test.")

func after_each():
	gut.p("Runs after each test.")

func after_all():
	gut.p("Runs once after all tests")

func test_assert_eq_number_not_equal():
	assert_eq(1, 2, "Should fail.  1 != 2")

func test_assert_eq_number_equal():
	assert_eq('asdf', 'asdf', "Should pass")
```

You can use inner classes to group tests together.  The class name must start with "Test" and it also must extend `test.gd`.
``` gdscript
extends GutTest

class TestSomeAspects:
	extends GutTest

	func test_assert_eq_number_not_equal():
		assert_eq(1, 2, "Should fail.  1 != 2")

	func test_assert_eq_number_equal():
		assert_eq('asdf', 'asdf', "Should pass")

class TestOtherAspects:
	extends GutTest

	func test_assert_true_with_true():
		assert_true(true, "Should pass, true is true")
```

# <a name="doubles">Doubles/Spies/Stubs
More Information:  [Doubles](Doubles), [Spies](Spies), [Stubs](Stubbing)

You can make a double of just about anything.  `double` returns a loaded class, not an instance.  Doubles extend the object to be doubled and have empty implementations for all methods defined in the script or parent scripts, but not parent Godot methods that are not overloaded.

```gdscript
var Foo = load('res://foo.gd')
var MyScene = load('res://my_scene.tscn')

var double_foo = double(Foo).new()
var double_scene = double(MyScene).instantiate()
```

You can stub your double to do different things.  Any unstubbed method that is called will generate a warning.
```gdscript
var double_foo = double(Foo).new()
stub(double_foo, 'bar').to_return(42)
stub(double_foo, 'something').to_call_super() # do what method would normally do
stub(double_foo, 'other_thing').to_return(null).when_passed(1, 2, 'c')
stub(double_foo, 'method').to_do_nothing()
```

You can spy on your doubles with various asserts and helpers.
```gdscript
var double_foo = double(Foo).new()

...

assert_called(double_foo, 'bar')
assert_not_called(double_foo, 'something')
assert_call_count(double_foo, 'call_me', 10)

# assert other_thing called with parameters in array.
assert_called(double_foo, 'other_thing', [1, 2, 'c'])

# Get an array of the parameters sent to the last
# call to call_me
var called_with_last = get_call_parameters(double_foo, 'call_me')

# get the parameters passed to the 4th call of `call_me`
var called_with_4 = get_call_parameters(double_foo, 'call_me', 4))
```

# <a name="partial_doubles">Partial Doubles
[More Information](Partial-Doubles)

Partial doubles have all the same properties of a double except they retain the source functionality by default.  You can stub and spy on them just like a double, but anything not stubbed will behave as if it wasn't a double.
```gdscript
var double_bar = partial_double(Bar).instance()

# the foo method will do nothing always now
stub(double_bar, 'foo').to_do_nothing()

# the something method will return 27 when passed 32,
# but act normally when passed anything else.
stub(double_bar, 'something').to_return(27).when_passed(32)

# example of spying
assert_called(double_bar, 'other_thing')
```

# <a name="parameterized_tests">Parameterized Tests
[More Information](Parameterized-Tests)

You can create tests that will be run multiple times and be passed multiple values.
* The test must have one and only one parameter.
* That parameter must be defaulted to call `use_parameters`.
* The value passed to use_parameters must be an array.
	* Each element in the array will result in one execution of the test with that element passed in.

```gdscript
var test_params = [[1, 2, 3], [4, 5, 6]]
func test_with_parameters(p=use_parameters(test_params)):
	assert_eq(p[0], p[2] - p[1])

# The first array contains the name of the parameters, the 2nd array contains the values.
var named_params = ParameterFactory.named_parameters(['a', 'b'], [[1, 2], ['one', 'two']])
func test_with_named_params(p=use_parameters(better_params)):
	assert_ne(p.a, p.b)
```
There are helpers to make your parameters more readable.


# <a name="await">Await
[More Information](Await)

You can use `await` in your tests to allow time to pass before making assertions.  This can be useful if you need to wait for some interaction to play out, a signal to be emitted, or wait for things to happen in the next frames, such as physics process or draw.

If you want to wait for a certain amount of time you can use `wait_seconds`.
```gdscript
await wait_seconds(10)
```
You can `await` to a signal or an amount of time, whichever comes first with `wait_for_signal`.  This ensures that your tests do not hang when a signal is not emitted.
```gdscript
var my_obj = load('res://my_obj.gd').new()
await wait_for_signal(my_obj.some_signal, 3)
```
You can also `await` for a number of frames using `wait_frames`.  It's best to wait at least 2 frames as waiting one frame can be flaky.
```
await wait_frames(5)
```

# <a name="memory_management">Leak Testing and Memory Management
[More Information](Memory-Management)

Call `autofree` or `autoqfree` on anything you want to be automatically freed up after your test.  These return whatever you pass it so you can save a line of code!
```gdscript
var my_node = autofree(Node.new())
```
`autofree` calls `free` on the object and `autoqfree` calls `queue_free`.

If you plan to add your object to the tree you can use the `add_child_autofree` and `add_child_autoqfree` methods to add them as a child of the test script and free them at the end of the test.
``` gdscript
var my_node = add_child_autofree(Node2D.new())
```

Orphan counts are displayed after each test/script that generates orphans and at the end of the run.  If you don't see output, then you don't have any orphans!  You can disable this feature if you want.

All objects created with `double` or `partial_double` are freed automatically.

You can assert you didn't make any new orphans with `assert_no_new_orphans`.  `assert_no_new_orphans` doesn't know about objects passed to `autofree` so they will be counted if they are not in the tree.
```gdscript
func test_freeing():
	var node = Node.new()
	assert_no_new_orphans('this one fails')
	node.free()
	assert_no_new_orphans('this one passes')

# If you queue_free then you have to wait for it to be freed.
func test_queue_freeing():
	var node = Node.new()
	node.queue_free()
	assert_no_new_orphans('this one fails')
	yield(yield_for(.1), YIELD)
	assert_no_new_orphans('this one passes')

```
