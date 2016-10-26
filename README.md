# What is this repository for?
GUT (Godot Unit Test) is a utility for writing tests for your Godot Engine game.  It allows you to write tests for your gdscript in gdscript.

# Table of Contents
  0.  [Install](#install)
  0.  [Creating Tests](#creating_tests)
  0.  [Method List](#method_list)
    0.  [Test Methods](#test_methods)
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

# <a name="install"> Install
For the purposes of this documentation it is assumed all the Gut pieces will go in `res://test/gut` and that all unit tests will be in `res://test/unit`.  This keeps the test code all in one place and avoids any name clashes.  Who knows, someone probably has a game that has a character that is actually a gut.  It runs around digesting things and...well, that's probably it.  With this structure the testing script gut.gd and their character class gut.gd won't clash.

This also makes it easy to exclude all the test related code from a release if you so choose.

0.  Create your `res://test`, `res://test/gut`, and `res://test/unit` directories.
0.  Copy the following into your `res://test/gut` directory
  * `gut.gd`
  * `gut_cmdln.gd`
  * `gut_main.gd` *skip on upgrade*
  * `gut_main.scn` *skip on upgrade*
0.  Copy `test_.gd` from the templates directory into `res://test/unit`.
0.  Open the `gut_main.scn` scene in Godot and run it!  Would you look at that, you have one pending test.  Well done good sir and/or madam.

When you are done with the install it should look like this:
```
├───scenes                 
├───scripts                
└───test                   
    ├───gut                
    │       gut.gd         
    │       gut_cmdln.gd   
    │       gut_main.gd    
    │       gut_main.scn   
    │                      
    └───unit               
            test_.gd       
```

<!-- It should look like this -->
<!-- TODO insert screenshot here. -->

# <a name="creating_tests"> Creating Tests

All test scripts must extend the Test class in gut.gd
* `extends "res://test/gut/gut.gd".Test`

Each test script has optional setup and teardown methods that are called at various stages of execution.  They take no parameters.
 * `setup()`:  Ran before each test
 * `teardown()`:  Ran after each test
 * `prerun_setup()`:  Ran before any test is run
 * `postrun_teardown()`:  Ran after all tests have run

All tests in the test script must start with the prefix `test_` in order for them to be run.  The methods must not have any parameters.
* `func test_this_is_only_a_test():`

Each test should perform at least one assert or call `pending` to indicate the test hasn't been implemented yet.

Here's a sample test script:

``` python
extends "res://test/gut/gut.gd".Test
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
# <a name="method_list"> Method List

### <a name="test_methods"> Methods for Use in Tests
These methods should be used in tests to make assertions about the things being tested.  These methods are available to anything that inherits from the Test class (`extends "res://test/gut/gut.gd".Test`)
* `pending(text="")` flag a test as pending, the optional message is printed in the GUI
* `assert_eq(got, expected, text="")` assert got == expected and prints optional text
* `assert_ne(got, not_expected, text="")` asserts got != expected and prints optional text
* `assert_gt(got, expected, text="")` assserts got > expected
* `assert_lt(got, expected, text="")` asserts got < expected
* `assert_true(got, text="")` asserts got == true
* `assert_false(got, text="")` asserts got == false
* `assert_between(got, expect_low, expect_high, text="")` asserts got > expect_low and <= expect_high
* `assert_file_exists(file_path)` asserts a file exists at the specified path
* `assert_file_does_not_exist(file_path)` asserts a file does not exist at the specified path
* `assert_file_empty(file_path)` asserts the specified file is empty
* `assert_file_not_empty(file_path)` asserts the specified file is not empty
* `assert_get_set_methods(obj, property, default, set_to)`
This guy warrants his own section.  I found that making tests for most getters and setters was repetitious and annoying.  Enter `assert_get_set_methods`.  This assertion handles 80% of your getter and setter testing needs.  Given an object and a property name it will verify:
 * The object has a method called `get_<PROPERTY_NAME>`
 * The object has a method called `set_<PROPERTY_NAME>`
 * The method `get_<PROPERTY_NAME>` returns the expected default value when first called.
 * Once you set the property, the `get_<PROPERTY_NAME>`will return the value passed in.
* `gut.p(text, level=0, indent=0)` print info to the GUI and console (if enabled.)

* `gut.pause_before_teardown()` This method will cause Gut to pause before it moves on to the next test.  This is useful for debugging, for instance if you want to investigate the screen or anything else after a test has finished executing.  See also `set_ignore_pause_before_teardown`
* `yield_for(time_in_seconds)` Basically this simplifies the code needed to pause the test execution for a number of seconds.  This is useful if your test requires things to play out in real time before making an assertion.  There are more details in the Yielding section.  It is designed to be used with the `yield` built in.  The following example will pause your test execution (and only the test execution) for 5 seconds before continuing.  You must call `end_test()` in any test that has a yield in it or execution will not continue.
  * `yield(yield_for(5), YIELD)`
* `end_test()` This must be called in any test that has a `yield` in it (regardless of what is yielded to) so that Gut knows when the test has completed.

### <a name="gut_methods"> Methods for Configuring the Execution of Tests
These methods would be used inside the Scene's script (`templates/gut_main.gd`) to load and execute scripts as well as inspect the results of a run and change how Gut behaves.  These methods must all be called on the Gut object that was instantiated.  In the case of the provided template, this would be `tester`.

* `add_script(script, select_this_one=false)` add a script to be tetsted with test_scripts
* `add_directory(path, prefix='test_', suffix='.gd')` add a directory of test scripts that start with prefix and end with suffix.  Subdirectories not included.
* `test_scripts()` run all scripts added with add_script or add_directory.  If you leave this out of your script then you can select which script will run, but you must press the "run" button to start the tests.
* `test_script(script)` runs a single script immediately.
* `select_script(script_name)` sets a script added with `add_script` or `add_directory` to be initially selected.  This allows you to run one script instead of all the scripts.  This will select the first script it finds that contains the specified string.
* `get_test_count()` return the number of tests run
* `get_assert_count()` return the number of assertions that were made
* `get_pass_count()` return the number of tests that passed
* `get_fail_count()` return the number of tests that failed
* `get_pending_count()` return the number of tests that were pending
* `get/set_should_print_to_console(should)` accessors for printing to console
* `get_result_text()` returns all the text contained in the GUI
* `clear_text()` clears the text in the GUI
* `set_ignore_pause_before_teardown(should_ignore)` causes GUI to disregard any calls to pause_before_teardown.  This is useful when you want to run in a batch mode.
* `set_yield_between_tests(should)` will pause briefly between every 5 tests so that you can see progress in the GUI.  If this is left out, it  can seem like the program has hung when running longer test sets.
* `get/set_log_level(level)` see section on log level for list of values.
* `disable_strict_datatype_checks(true)` disables strict datatype checks.  See section on "Strict type checking" before disabling.

# <a name="extras"> Extras

##  <a name="strict"> Strict type checking
Gut performs type checks in the asserts where it applies.  This is done for a few reasons.  The first is that invalid comparisons can cause runtime errors which will stop your tests from running.  With the type checking enabled your test will fail instead of crashing.  The other reason is that you can get false positives/negatives when comparing things like a Real/Float and an Integer.  With strict type checking enabled these become a lot more obvious.  It's also a sanity check to make sure your classes are using the expected types of values which can save time in the long run.

You can disable this behavior if you like by calling `tester.disable_strict_datatype_checks(true)` inside `gut_main.gd`.

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

I'm not going to try and explain yielding here.  It's can be a bit confusing and [Godot does a pretty good job of it already](http://docs.godotengine.org/en/latest/reference/gdscript.html#coroutines).  Gut has support for yielding though, so you can yield at anytime in your test.  The one caveat is that you must tell Gut when your test has completed so it can continue running tests.  You do this by calling `end_test()`.  

When might you want to yield?  Yielding is very handy when you want to wait for a signal to occur instead of running for a finite amount of time.  For example, you could have your test yield until your character gets hit by something (`yield(my_char, 'hit')`).  An added bonus of this approach is that you can watch everything happen.  In your test you create your character, the object to hit it, and then watch the interaction play out.

Here's an example of yielding to a custom signal.
``` python
func test_yield_to_custom_signal():
	my_object = ObjectToTest.new()
	add_child(my_object)
	yield(my_object, 'custom_signal')
	assert_true(some_condition, 'After signal fired, this should be true')
	end_test()
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
	end_test()
```
Sometimes it's also helpful to just watch things play out.  Yield is great for that, you just create a couple objects, set them to interact and then yield.  You can leave the yields in or take them out if your test passes without them.  You can also use the `pause_before_teardown` method that will pause test execution before it runs `teardown` and moves onto the next test.  This keeps the game loop running after the test has finished and you can see what everything looks like.

### How Yielding and Gut Works
For those that are interested, Gut is able to detect when a test has called yield because the method returns a special class back.  Gut itself will then `yield` to an internal timer and check to see if `end_test` has been called every second, if not it waits again.  It continues to do this until `end_test` has been called.  

If you only yielded using `yield_for` then Gut would always know when to resume the test and could handle it itself.  You can yield to anything though and Gut cannot tell the difference.  Also, when you yield to something else Gut has no way of knowing when the method has continued so you have to tell it when you are done so it will stop waiting.  One side effect of this is that if you `yield` multiple times in the same test, Gut can't tell.  It continues to wait from the first yield and you won't see any additional "yield detected" outputs in the GUI or console.

The `yield_for()` method and `YIELD` constant are some syntax sugar built into the `Test` object.  `yield` takes in an object and a signal.  The `yield_for` method kicks off a timer inside Gut that will run for however many seconds you passed in.  It also returns the Gut object so that `yield` has an object to yield to.  The `YIELD` constant contains the name of the signal that Gut emits when the timer finishes.

#  <a name="command_line"> Running Gut from the Command Line
Also supplied in this repo is the gut_cmdln.gd script that can be run from the command line so that you don't have to create a scene to run your tests.  One of the main reasons to use this approach instead of going through the editor is that you get to see error messages generated by Godot in the context of your running tests.  You also see any `print` statements you put in  your code in the context of all the Gut generated output.  It's a bit quicker to get started and is a bit cooler if I do say so.  The biggest downside is that debugging your code/tests is a little more difficult since you won't be able to interact with the editor when something blows up.

From the command line, at the root of your project, use the following command to run the script.  Use the options below to run tests.
	`godot -d -s test/gut/gut_cmdln.gd`

The -d option tells Godot to run in debug mode which is helpful.  The -s option tells Godot to run a script.

### Options
_Output from the command line help (-gh)_
```
---------------------------------------------------------                               
This is the command line interface for the unit testing tool Gut.  With this
interface you can run one or more test scipts from the command line.  In order
for the Gut options to not clash with any other Godot options, each option
starts with a "g".  Also, any option that requires a value will take the form of
"-g<name>=<value>".  There cannot be any spaces between the option, the "=", or
inside a specified value or godot will think you are trying to run a scene.       

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

`godot -s test/gut/gut_cmdln.gd -d -gtest=res://test/unit/sample_tests.gd -glog=1 -gexit`

Load all test scripts that begin with 'me_' and end in '.res' and run me_only_only_me.res (given that the directory contains the following scripts:  me_and_only_me.res, me_only.res, me_one.res, me_two.res).  I don't specify the -gexit on this one since I might want to run all the scripts using the GUI after I run this one script.

`godot -s test/gut/gut_cmdln.gd -d -gdir=res://test/unit -gprefix=me_ -gsuffix=.res -gselect=only_me`

### Alias
Make your life easier by creating an alias that includes your most frequent options.  Here's the one I use in bash:

`alias gut='godot -d -s test/gut/gut_cmdln.gd -gdir=res://test/unit,res://test/integration -gexit -gignore_pause'`

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


# Who do I talk to?
You can talk to me, Butch Wesley

* Bitbucket:  bitwes
* Godot forums:  bitwes
