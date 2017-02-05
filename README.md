# Gut
GUT (Godot Unit Test) is a utility for writing tests for your Godot Engine game.  It allows you to write tests for your gdscript in gdscript.

# !! 4.0.0 Breaking changes from 3.0.x !!
It is a plugin now!  Unfortunately that means some things and paths have changed.

Before upgrading, remove gut.gd and gut_cmdln.gd from your your current project.  That will help ensure that you got everything setup right with the new install location.

0.  The install location has changed to `res://addons/gut`.  So you'll want to clean out wherever you had it previously installed.
0.  You'll want to update your existing scene to use the new plugin object.  Follow the new install instructions. <br>
__Note:__  just about everything you had to code to get your main testing scene running can now be configured in the Editor.  Select the Gut node and the options will appear in the Inspector.  Your existing code will work with the new custom node but using the Editor greatly simplifies things.
0.  The object that all test scripts must extend has changed to `res://addons/gut/test.gd`.
0.  All examples and tests for Gut itself have been moved to the new rep https://github.com/bitwes/GutTests/

# Table of Contents
  0.  [Install](#install)
  0.  [Gut Settings](#gut_settings)
  0.  [Creating Tests](#creating_tests)
  0.  [Method List](#method_list)
    0.  [Asserting Things](#test_methods)
    0.  [Methods for Configuring Test Execution](#gut_methods)
  0.  [Extras](#extras)
    0.  [Strict Type Checking](#strict)
    0.  [File Manipulation](#files)
    0.  [Watching Tests](#watch)
    0.  [Output Detail](#output_detail)
    0.  [Printing](#printing)
  0. [Advanced](#advanced)
    0.  [Simulate](#simulate)
    0.  [Yielding](#yielding)
  0. [Command Line Interface](#command_line)
  0. [Contributing](#contributing)

# <a name="install"> Install
Download and extract the zip from the releases or from the Godot Asset Library https://godotengine.org/asset-library/asset.  

Place the `gut` directory into your `addons` folder in your project.  If you don't have an `addons` folder at the root of your project, then make one and THEN put the `gut` directory in there.

From the menu choose Scene->Project Settings, click the plugins tab and activate Gut.

The next few steps cover the suggested configuration.  Feel free to deviate where you see fit.

0.  Create directories to store your tests and test related code
  * `res://test`
  * `res://test/unit`
  * `res://test/integration`
0.  Create a scene that will use Gut to run your tests at `res://test/tests.tscn`
  * Add a Gut object the same way you would any other object.
  * Click "Add/Create Node"
  * type "Gut"
  * press enter.
0.  Configure Gut to find your tests.  Select it in the Scene Tree and set the following settings in the Inspector:
  * In the `Directory1` setting enter `res://test/unit`
  * In the `Directory2` setting enter `res://test/integration`

That's it.  The next step is to make some tests.

# <a name="gut_settings"> Gut Settings
The following settings are accessible in the Editor under "Script Variables"

* <b>Run On Load</b>:  Flag to indicate if Gut should start running tests when loaded.
* <b>Select Script</b>:  Select the named script in the drop down.  When this is set and "Run On Load" is true, only this script will be run.
* <b>Tests Like</b>:  Only tests that contain the set text will be run initially.
* <b>Should Print To Console</b>:  Print output to the console as well as to Gut.
* <b>Log Level</b>:  Set the level of output.
* <b>Yield Between Tests</b>:  A short yield is performed by Gut so that the Gut control has a chance to redraw.  This increases execution time by a tiny bit, but stops Gut from appearing to be hung up while it runs tests.
* <b>Disable Strict Datatype Checks</b>:  Disables the verifying of datatypes before comparisons are done.  You can disable this if you want.  See the section on datatype checks for more details.
* <b>Test Prefix</b>:  The prefix used on all test functions.  This prefixed will be used by Gut to find tests inside your test scripts.
* <b>File Prefix</b>:  The prefix used on all test files.  This is used in conjunction with the Directory settings to find tests.
* <b>File Extension</b>:  This is the suffix it will use to find test files.  
* <b>Directory(1-6)</b>:  The path to the directories where your test scripts are located.  Subdirectories are not included.  If you need more than six directories you can use the `add_directory` method to add more.

# <a name="creating_tests"> Making Tests

## Sample for Setup
Here's a sample test script.  Copy the contents into the file `res://test/unit/test_example.gd` then run your scene.  If everything is setup correctly then you'll see some passing and failing tests.  If you don't have "Run on Load" checked in the editor, you'll have to hit the "Run" button on the dialog window.

``` python
extends "res://addons/gut/test.gd"
func setup():
	gut.p("ran setup", 2)

func teardown():
	gut.p("ran teardown", 2)

func prerun_setup():
	gut.p("ran run setup", 2)

func postrun_teardown():
	gut.p("ran run teardown", 2)

func test_assert_eq_number_not_equal():
	assert_eq(1, 2, "Should fail.  1 != 2")

func test_assert_eq_number_equal():
	assert_eq('asdf', 'asdf', "Should pass")

func test_assert_true_with_true():
	assert_true(true, "Should pass, true is true")

func test_assert_true_with_false():
	assert_true(false, "Should fail")

func test_something_else():
	assert_true(false, "didn't work")

```

## Creating tests
All test scripts must extend the test class.
* `extends "res://addons/gut/test.gd"`

Each test script has optional setup and teardown methods that are called at various stages of execution.  They take no parameters.
 * `setup()`:  Ran before each test
 * `teardown()`:  Ran after each test
 * `prerun_setup()`:  Ran before any test is run
 * `postrun_teardown()`:  Ran after all tests have run

All tests in the test script must start with the prefix `test_` in order for them to be run.  The methods must not have any parameters.
* `func test_this_is_only_a_test():`

Each test should perform at least one assert or call `pending` to indicate the test hasn't been implemented yet.


# <a name="method_list"> Method List

### <a name="test_methods"> Asserting things
These methods should be used in tests to make assertions.  These methods are available to anything that inherits from the Test class (`extends "res://addons/gut/test.gd"`).  All sample code listed for the methods can be found here:  https://github.com/bitwes/GutTests/blob/master/test/unit/test_readme_examples.gd.
#### pending(text="")
flag a test as pending, the optional message is printed in the GUI
``` python
pending('This test is not implemented yet')
pending()
```
#### assert_eq(got, expected, text="")
assert got == expected and prints optional text
``` python
var one = 1
var node1 = Node.new()
var node2 = node1

assert_eq(one, 1, 'one should equal one') # PASS
assert_eq('racecar', 'racecar') # PASS
assert_eq(node2, node1) # PASS

gut.p('-- failing --')
assert_eq(1, 2) # FAIL
assert_eq('hello', 'world') # FAIL
assert_eq(self, node1) # FAIL
```
#### assert_ne(got, not_expected, text="")
asserts got != expected and prints optional text
``` python
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
#### assert_gt(got, expected, text="")
assserts got > expected
``` python
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
#### assert_lt(got, expected, text="")
asserts got < expected
``` python
var bigger = 5
var smaller = 0
gut.p('-- passing --')
assert_lt(smaller, bigger, 'Smaller should be less than bigger') # PASS
assert_lt('a', 'b') # PASS

gut.p('-- failing --')
assert_lt('z', 'x') # FAIL
assert_lt(-5, -5) # FAIL
```
#### assert_true(got, text="")
asserts got == true
``` python
gut.p('-- passing --')
assert_true(true, 'True should be true') # PASS
assert_true(5 == 5, 'That expressions should be true') # PASS

gut.p('-- failing --')
assert_true(false) # FAIL
assert_true('a' == 'b') # FAIL
```
#### assert_false(got, text="")
asserts got == false
``` python
gut.p('-- passing --')
assert_false(false, 'False is false') # PASS
assert_false(1 == 2) # PASS
assert_false('a' == 'z') # PASS
assert_false(self.has_user_signal('nope')) # PASS

gut.p('-- failing --')
assert_false(true) # FAIL
assert_false('ABC' == 'ABC') # FAIL
```
#### assert_between(got, expect_low, expect_high, text="")
asserts got > expect_low and <= expect_high
``` python
gut.p('-- passing --')
assert_between(5, 0, 10, 'Five should be between 0 and 10') # PASS
assert_between(10, 0, 10) # PASS
assert_between(0, 0, 10) # PASS
assert_between(2.25, 2, 4.0) # PASS

gut.p('-- failing --')
assert_between('a', 'b', 'c') # FAIL
assert_between(1, 5, 10) # FAIL
```
#### assert_has(obj, element, text='')
Asserts that the object passed in "has" the element.  This works with any object that has a `has` method.
``` python
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
#### assert_does_not_have(obj, element, text='')
The inverse of `assert_has`
``` python
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
# the hash's has method checkes indexes not values
assert_does_not_have(a_hash, 'one') # FAIL
assert_does_not_have(a_hash, '3') # FAIL
```
#### assert_file_exists(file_path)
asserts a file exists at the specified path
``` python
func setup():
	gut.file_touch('user://some_test_file')

func teardown():
	gut.file_delete('user://some_test_file')

func test_assert_file_exists():
	gut.p('-- passing --')
	assert_file_exists('res://addons/gut/gut.gd') # PASS
	assert_file_exists('user://some_test_file') # PASS

	gut.p('-- failing --')
	assert_file_exists('user://file_does_not.exist') # FAIL
	assert_file_exists('res://some_dir/another_dir/file_does_not.exist') # FAIL  
```
#### assert_file_does_not_exist(file_path)
asserts a file does not exist at the specified path
``` python
func setup():
	gut.file_touch('user://some_test_file')

func teardown():
	gut.file_delete('user://some_test_file')

func test_assert_file_does_not_exist():
	gut.p('-- passing --')
	assert_file_does_not_exist('user://file_does_not.exist') # PASS
	assert_file_does_not_exist('res://some_dir/another_dir/file_does_not.exist') # PASS

	gut.p('-- failing --')
	assert_file_does_not_exist('res://addons/gut/gut.gd') # FAIL
```
#### assert_file_empty(file_path)
asserts the specified file is empty
``` python
func setup():
	gut.file_touch('user://some_test_file')

func teardown():
	gut.file_delete('user://some_test_file')

func test_assert_file_empty():
	gut.p('-- passing --')
	assert_file_empty('user://some_test_file') # PASS

	gut.p('-- failing --')
	assert_file_empty('res://addons/gut/gut.gd') # FAIL
```
#### assert_file_not_empty(file_path)
asserts the specified file is not empty
``` python
func setup():
	gut.file_touch('user://some_test_file')

func teardown():
	gut.file_delete('user://some_test_file')

func test_assert_file_not_empty():
	gut.p('-- passing --')
	assert_file_not_empty('res://addons/gut/gut.gd') # PASS

	gut.p('-- failing --')
	assert_file_not_empty('user://some_test_file') # FAIL
```
#### assert_get_set_methods(obj, property, default, set_to)
I found that making tests for most getters and setters was repetitious and annoying.  Enter `assert_get_set_methods`.  This assertion handles 80% of your getter and setter testing needs.  Given an object and a property name it will verify:
 * The object has a method called `get_<PROPERTY_NAME>`
 * The object has a method called `set_<PROPERTY_NAME>`
 * The method `get_<PROPERTY_NAME>` returns the expected default value when first called.
 * Once you set the property, the `get_<PROPERTY_NAME>`will return the value passed in.

On the inside Gut actually performs up to 4 assertions.  So if everything goes right you will have four passing asserts each time you call `assert_get_set_methods`.  I say "up to 4 assertions" because there are 2 assertions to make sure the object has the methods and then 2 to verify that act correctly.  If the object does not have the methods, it does not bother running the tests for the methods.
```
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

func test_assert_get_set_methods():
  var some_class = SomeClass.new()
  gut.p('-- passing --')
  assert_get_set_methods(some_class, 'count', 0, 20) # 4 PASSING

  gut.p('-- failing --')
  # 1 FAILING, 3 PASSING
  assert_get_set_methods(some_class, 'count', 'not_default', 20)  
  # 2 FAILING, 2 PASSING
  assert_get_set_methods(some_class, 'nothing', 'hello', 22)
  # 2 FAILING
  assert_get_set_methods(some_class, 'does_not_exist', 'does_not', 'matter')
```
#### gut.p(text, level=0, indent=0)
Print info to the GUI and console (if enabled).  You can see examples if this in the sample code above.  In order to be able to spot check the sample code, I print out a divider between the passing and failing tests.

#### gut.pause_before_teardown()
This method will cause Gut to pause before it moves on to the next test.  This is useful for debugging, for instance if you want to investigate the screen or anything else after a test has finished executing.  See also `set_ignore_pause_before_teardown`
#### yield_for(time_in_seconds)
This simplifies the code needed to pause the test execution for a number of seconds, while the thing that you are testing can run its course in real time.  There are more details in the Yielding section.  It is designed to be used with the `yield` built in.  The following example will pause your test execution (and only the test execution) for 5 seconds before continuing.  You must call an assert or `pending` or `end_test()` after a yield or the test will never stop running.
```
class MovingNode:
	extends Node2D
	var _speed = 2

	func _ready():
		set_process(true)

	func _process(delta):
		set_pos(get_pos() + Vector2(_speed * delta, 0))

func test_illustrate_yield():
	var moving_node = MovingNode.new()
	add_child(moving_node)
	moving_node.set_pos(Vector2(0, 0))

	# While the yield happens, the node should move
	yield(yield_for(2), YIELD)
	assert_gt(moving_node.get_pos().x, 0)
	assert_between(moving_node.get_pos().x, 3.9, 4, 'it should move almost 4 whatevers at speed 2')
```
#### end_test()
This can be called instead of an assert or `pending` to end a test that has yielded.
```
func test_illustrate_end_test():
	yield(yield_for(1), YIELD)
	# we don't have anything to test yet, or at all.  So we
	# call end_test so that Gut knows all the yielding has
	# finished.
	end_test()
```
### <a name="gut_methods"> Methods for Configuring the Execution of Tests
These methods would be used inside the scene you created at `res://test/tests.tcn`.  These methods can be called against the Gut node you created.  Most of these are not necessary anymore since you can configure Gut in the editor but they are here if you want to use them.  Simply put `get_node('Gut').` in front of any of them.  

<i>__**__ indicates the option can be set via the editor</i>
* `add_script(script, select_this_one=false)` add a script to be tetsted with test_scripts
* __**__`add_directory(path, prefix='test_', suffix='.gd')` add a directory of test scripts that start with prefix and end with suffix.  Subdirectories not included.  This method is useful if you have more than the 6 directories the editor allows you to configure.  You can use this to add others.
* __**__`test_scripts()` run all scripts added with add_script or add_directory.  If you leave this out of your script then you can select which script will run, but you must press the "run" button to start the tests.
* `test_script(script)` runs a single script immediately.
* __**__`select_script(script_name)` sets a script added with `add_script` or `add_directory` to be initially selected.  This allows you to run one script instead of all the scripts.  This will select the first script it finds that contains the specified string.
* `get_test_count()` return the number of tests run
* `get_assert_count()` return the number of assertions that were made
* `get_pass_count()` return the number of tests that passed
* `get_fail_count()` return the number of tests that failed
* `get_pending_count()` return the number of tests that were pending
* __**__`get/set_should_print_to_console(should)` accessors for printing to console
* `get_result_text()` returns all the text contained in the GUI
* `clear_text()` clears the text in the GUI
* `set_ignore_pause_before_teardown(should_ignore)` causes GUI to disregard any calls to pause_before_teardown.  This is useful when you want to run in a batch mode.
* __**__`set_yield_between_tests(should)` will pause briefly between every 5 tests so that you can see progress in the GUI.  If this is left out, it  can seem like the program has hung when running longer test sets.
* __**__`get/set_log_level(level)` see section on log level for list of values.
* __**__`disable_strict_datatype_checks(true)` disables strict datatype checks.  See section on "Strict type checking" before disabling.

# <a name="extras"> Extras

##  <a name="strict"> Strict type checking
Gut performs type checks in the asserts when comparing two differnt types would normally cause a runtime error.  With the type checking enabled (on be default) your test will fail instead of crashing.  Some types are ok to be compared such as Floats and Integers but if you attempt to compare a String with a Float your test will fail instead of blowing up.

You can disable this behavior if you like by calling `disable_strict_datatype_checks(true)` on your Gut node or by clicking the checkbox to "Disable Strict Datatype Checks" in the editor.

##  <a name="files"> File Manipulation Methods for Tests
Use these methods in a test or setup/teardown method to make file related testing easier.  These all exist on the Gut object so they must be prefixed with `gut`
* `gut.file_touch(path)` create an empty file if it doesn't exist.
* `gut.file_delete(path)` delete a file
* `gut.is_file_empty(path)` checks if a file is empty
* `gut.directory_delete_files` deletes all files in a directory.  does not delete subdirectories or any files in them.

##  <a name="watch"> Watching tests as they execute
When running longer tests it can appear as though the program has hung.  To address this and see the tests as they execute a yield was added between tests.  To enable this feature call `set_yield_between_tests(true)` before running your tests.  This feature is disabled by default since it does add a small amount of time to running your tests (about .01 seconds per 5 tests)

##  <a name="output_detail"> Output Detail
The level of detail that is printed to the screen can be changed using the slider on the dialog or by calling `set_log_level` with one of the following constants defined in Gut

* LOG_LEVEL_FAIL_ONLY (0)
* LOG_LEVEL_TEST_AND_FAILURES (1)
* LOG_LEVEL_ALL_ASSERTS (2)

##  <a name="printing"> Printing info
The `gut.p` method allows you to print information out indented under the test output.  It has an optional 2nd parameter that sets which log level to display it at.  Use one of the constants in the section above to set it.  The default is `LOG_LEVEL_FAIL_ONLY` which means the output will always be visible.  


#  <a name="advanced"> Advanced Testing

## <a name="simulate"> Simulate
The simulate method will call the `_process` or `_fixed_process` on a tree of objects.  It takes in the base object, the number of times to call the methods and the delta value to be passed to `_process` or `_fixed_process` (if the object has one).  This will only cause code directly related to the `_process` and `_fixed_process` methods to run.  Signals will be sent, methods will be called but timers, for example, will not fire since the main loop of the game is not actually running.  Creating a test that yields is a better solution for testing such things.

Example
``` python

# --------------------------------
# res://scripts/my_object.gd
# --------------------------------
extends Node2D
  var a_number = 1

  func _ready():
    set_process(true)

  func _process(delta):
    a_number += 1

# --------------------------------
# res://scripts/another_object.gd
# --------------------------------
extends Node2D
  var another_number = 1

  func _ready():
    set_fixed_process(true)

  func _fixed_process(delta):
    another_number += 1

# --------------------------------
# res://test/unit/test_my_object.gd
# --------------------------------

# ...

var MyObject = load('res://scripts/my_object.gd')
var AnotherObject = load('res://scripts/another_object')

# ...

# Given that SomeCoolObj has a _process method that incrments a_number by 1
# each time _process is called, and that the number starts at 0, this test
# should pass
func test_does_something_each_loop():
  var my_obj = MyObject.new()
  add_child(my_obj)
  gut.simulate(my_obj, 20, .1)
  assert_eq(my_obj.a_number, 20, 'Since a_number is incremented in _process, it should be 20 now')

# Let us also assume that AnotherObj acts exactly the same way as
# but has SomeCoolObj but has a _fixed_process method instead of
# _process.  In that case, this test will pass too since all child objects
# have the _process or _fixed_process method called.
func test_does_something_each_loop():
  var my_obj = MyObject.new()
  var other_obj = AnotherObj.new()

  add_child(my_obj)
  my_obj.add_child(other_obj)

  gut.simulate(my_obj, 20, .1)

  assert_eq(my_obj.a_number, 20, 'Since a_number is incremented in _process, \
                                  it should be 20 now')
  assert_eq(other_obj.another_number, 20, 'Since other_obj is a child of my_obj \
                                           and another_number is incremened in \
                                           _fixed_process then it should be 20 now')

```
##  <a name="yielding"> Yielding during a test

I'm not going to try and explain yielding here.  It can be a bit confusing and [Godot does a pretty good job of it already](http://docs.godotengine.org/en/latest/reference/gdscript.html#coroutines).  Gut has support for yielding though, so you can yield at anytime in your test.  The one caveat is that you must use one of the various asserts or `pending()` after the yield.  Otherwise Gut won't know that the yield has finished.  You can optionally use `end_test()` if an assert or `pending` doesn't make sense for some reason.

When might you want to yield?  Yielding is very handy when you want to wait for a signal to occur instead of running for a finite amount of time.  For example, you could have your test yield until your character gets hit by something (`yield(my_char, 'hit')`).  An added bonus of this approach is that you can watch everything happen.  In your test you create your character, the object to hit it, and then watch the interaction play out.

Here's an example of yielding to a custom signal.
``` python
func test_yield_to_custom_signal():
	my_object = ObjectToTest.new()
	add_child(my_object)
	yield(my_object, 'custom_signal')
	assert_true(some_condition, 'After signal fired, this should be true')
```

Another use case I have come across is when creating integration tests and you want to verify that a complex interaction ends with an expected result.  In this case you might have an idea of how long the interaction will take to play out but you don't have a signal that you can attach to.  Instead you want to pause your test execution until that time has elapsed.  For this, Gut has the `yield_for` method.  This method has a little magic in it, but all you really need to know is that the following line will pause your test execution for 5 seconds while the rest of your code executes as expected:  `yield(yield_for(5), YIELD)`.

Here's an example of yielding for 5 seconds.
``` python
func test_wait_for_a_bit():
	my_object = ObjectToTest.new()
	my_object.do_something()
	#wait 5 seconds
	yield(yield_for(5), YIELD)
	gut.assert_eq(my_object.some_property, 'some value', 'After waiting 5 seconds, this property should be set')
```
Sometimes it's also helpful to just watch things play out.  Yield is great for that, you just create a couple objects, set them to interact and then yield.  You can leave the yields in or take them out if your test passes without them.  You can also use the `pause_before_teardown` method that will pause test execution before it runs `teardown` and moves onto the next test.  This keeps the game loop running after the test has finished and you can see what everything looks like.

### How Yielding and Gut Works
For those that are interested, Gut is able to detect when a test has called yield because the method returns a special class back.  Gut itself will then `yield` to an internal timer and check to see if an assertion or `pending()` or `end_test()` has been called every second, if not it waits again.

If you only yielded using `yield_for` then Gut would always know when to resume the test and could handle it itself.  You can yield to anything though and Gut cannot tell the difference.  Also, when you yield to something else Gut has no way of knowing when the method has continued so you have to tell it when you are done so it will stop waiting.  One side effect of this is that if you `yield` multiple times in the same test, Gut can't tell.  It continues to wait from the first yield and you won't see any additional "yield detected" outputs in the GUI or console.

The `yield_for()` method and `YIELD` constant are some syntax sugar built into the `Test` object.  `yield` takes in an object and a signal.  The `yield_for` method kicks off a timer inside Gut that will run for however many seconds you passed in.  It also returns the Gut object so that `yield` has an object to yield to.  The `YIELD` constant contains the name of the signal that Gut emits when the timer finishes.

#  <a name="command_line"> Running Gut from the Command Line
Also supplied in this repo is the gut_cmdln.gd script that can be run from the command line so that you don't have to create a scene to run your tests.  One of the main reasons to use this approach instead of going through the editor is that you get to see error messages generated by Godot in the context of your running tests.  You also see any `print` statements you put in  your code in the context of all the Gut generated output.  It's a bit quicker to get started and is a bit cooler if I do say so.  The biggest downside is that debugging your code/tests is a little more difficult since you won't be able to interact with the editor when something blows up.

From the command line, at the root of your project, use the following command to run the script.  Use the options below to run tests.
	`godot -d -s addons/gut/gut_cmdln.gd`

The -d option tells Godot to run in debug mode which is helpful.  The -s option tells Godot to run a script.

### Options
_Output from the command line help (-gh)_
```
---------------------------------------------------------                               
This is the command line interface for the unit testing tool Gut.  With this
interface you can run one or more test scripts from the command line.  In order
for the Gut options to not clash with any other Godot options, each option
starts with a "g".  Also, any option that requires a value will take the form of
"-g<name>=<value>".  There cannot be any spaces between the option, the "=", or
inside a specified value or Godot will think you are trying to run a scene.       

Options                                                                                                               
-------                                                                                                               
  -gtest          Comma delimited list of tests to run
  -gdir           Comma delimited list of directories to add tests from.
  -gprefix        Prefix used to find tests when specifying -gdir.  Default
                  "test_"
  -gsuffix        Suffix used to find tests when specifying -gdir.  Default
                  ".gd"
  -gexit          Exit after running tests.  If not specified you have to
                  manually close the window.
  -glog           Log level.  Default 1
  -gignore_pause  Ignores any calls to gut.pause_before_teardown.
  -gselect        Select a script to run initially.  The first script that was
                  loaded using -gtest or -gdir that contains the specified
                  string will be executed.  You may run others by interacting
                  with the GUI.
  -gutloc         Full path (including name) of the gut script.  Default
                  res://test/gut/gut.gd
  -gh             Print this help
---------------------------------------------------------   
```

### Examples

Run godot in debug mode (-d), run a test script (-gtest), set log level to lowest (-glog), exit when done (-gexit)

`godot -s addons/gut/gut_cmdln.gd -d -gtest=res://test/unit/sample_tests.gd -glog=1 -gexit`

Load all test scripts that begin with 'me_' and end in '.res' and run me_only_only_me.res (given that the directory contains the following scripts:  me_and_only_me.res, me_only.res, me_one.res, me_two.res).  I don't specify the -gexit on this one since I might want to run all the scripts using the GUI after I run this one script.

`godot -s addons/gut/gut_cmdln.gd -d -gdir=res://test/unit -gprefix=me_ -gsuffix=.res -gselect=only_me`

### Alias
Make your life easier by creating an alias that includes your most frequent options.  Here's the one I use in bash:

`alias gut='godot -d -s addons/gut/gut_cmdln.gd -gdir=res://test/unit,res://test/integration -gexit -gignore_pause'`

This alias loads up all the scripts I want from my testing directories and sets some other flags.  With this, if I want to run 'test_one.gd', I just enter `gut -gselect=test_one.gd`.

### Common Errors
I really only know of one so far, but if you get a space in your command somewhere, you might see something like this:
```
ERROR:  No loader found for resource: res://samples3
At:  core\io\resource_loader.cpp:209
ERROR:  Failed loading scene: res://samples3
At:  main\main.cpp:1260
```
I got this one when I accidentally put a space instead of an "=" after -gselect.


#  <a name="contributing"> Contributing
Pull requests are welcome but first read the directions in the testing and example repo https://github.com/bitwes/GutTests/.  The core Gut code is separated out into this repo and the linked repo contains all the test and example code.  Any enhancements or bug fixes should have a corresponding pull request with new tests.


# Who do I talk to?
You can talk to me, Butch Wesley

* Github:  bitwes
* Godot forums:  bitwes
