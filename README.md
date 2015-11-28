### What is this repository for? ###
GUT (Godot Unit Test) is a utility for writing unit tests in Godot's scripting language.  The premise is that the gut.gd script will run other scripts that contain tests and asserts and then reports the status of said tests and asserts.  This is all done through godot using a scene you create to run the tests.  Once your scene is in place and you've coded up a GUT instance to run your test scripts, you simply run the scene.  This project illustrates using GUT to run tests, some sample tests, and the one required script, gut.gd, which is located in /scripts/.

Sometimes the best tutorial is to dive right in, so to that end you should read through the main.gd script for illustrations on running scripts and setting the various options available.  There are various test scripts that illustrate performing assertions and printing messages.  There's even the tests that were created to test GUT itself.  They can be found in gut_tests.gd.

GUT has the following asserts, each of which take the value you recieved and sometimes expected values.  These asserts should work with just about anything, but it the datatypes must match.  If you pass in a string and a number it will error out.  They have been tested with booleans, numbers and strings.

###Godot Version 1.0 and 1.1 Beta###
As development continues I will try to support the last two releases of Godot.  I have been developing with the 1.1 beta relase.  To use the project in this repo in 1.1 you may have to load the main_1_0.scn instead of the default.  You'll know if you have to load it if you get the "ugh" error.  Remember, this is only for the project, using the gut.gd script doesn't require anything special.
###Gut Methods###

####Asserts####
* __assert_eq(got, expected, text="")__:  Asserts that the expected value equals the value got.
* __assert_ne(got, not_expected, text="")__:  Asserts that the value got does not equal the "not expected" value.  
* __assert_gt(got, expected, text="")__:  Asserts got is greater than expected
* __assert_lt(got, expected, text="")__:  Asserts got is less than expected
* __assert_true(got, text="")__:  Asserts that got is true
* __assert_false(got, text="")__:  Asserts that got is false
* __assert_between(got, expected_low, expected_high, text="")__:  Asserts got is between the two expected values (inclusive)
* __assert_get_set_methods(obj, property, default, set_to)__:  Verifies some basic get/set accessor behavior.  For example, calling  `gut.assert_get_set_methods(some_obj, 'description', 'default', 'new description')` will verify `some_obj` has a `get_description` and `set_description` method and that the first call to `get_description()` returns 'default' and that a call to `set_description('new description')` then a call to `get_description()` will return 'new_description'.

File related asserts

* __assert_file_exists(file_path)__: #Asserts that a file exists at the given path
* __assert_file_does_not_exist(file_path)__: #Asserts a file does not exist at the given path
* __assert_file_empty(file_path)__: #Asserts the file at the path is empty.  Also fails if the file does not exist.
* __assert_file_not_empty(file_path)__: #Asserts the file at the path is not empty.  Also fails if the file does not exist.

These are called from within test scripts (scripts that extend "res://scripts/gut.gd".Test) by prefixing them with "gut.".  For example:

* gut.assert_eq(1, my_number_var, "The number should be 1.")
* gut.assert_lt("b", my_string_var, "The value should be less than 'b'.")
* gut.assert_true(my_bool_var, "If this ain't true, then it's false, and that means this test fails")

####Watching tests as they execute####
Note, this feature is not supported in 1.0.  For that reason it is disabled by default as to not break anything.  When running longer tests it can appear as though the program has hung.  To address this and see the tests as they execute a yield was added between tests.  To enable this feature call set_yield_between_tests(true).

####Output Detail####
The level of detail that is printed to the screen can be changed using the slider on the dialog or by calling set_log_level with one of the following constants defined in Gut

* LOG_LEVEL_FAIL_ONLY (0)
* LOG_LEVEL_TEST_AND_FAILURES (1)
* LOG_LEVEL_ALL_ASSERTS (2)

####Printing info####
The "p" method allows you to print information out indented under the test output.  It has an optional 2nd parameter that sets which log level to display it at.  Use one of the constants in the section above to set it.  The default is LOG_LEVEL_FAIL_ONLY which means the output will always be visible.  
```
#!python

func p(text, level=0)
```

####Working with Files####
GUT contains a few utility methods to ease the testing of file creation/deletion.  

* __file_touch(path)__ Creates a file at the designated path.
* __file_delete(path)__ Deletes a file at the disgnated path.
* __is_file_empty(path)__ Returns true if the file at the path is empty, false if not.
* __directory_delete_files(path)__ Deletes all files at a given path.  Does not delete sub directories or any files in any sub directories.

There are also asserts for examining files.  See the assert list above.

####Simulate####
The simulate method will call the \_process or \_fixed_process on a tree of objects.  It takes in the base object, the number of times to call the methods and the delta value to be passed to \_process or \_fixed_process (if the object has one).  This will only cause code directly related to the \_process and \_fixed_process methods to run.  Timers will not fire since the main loop of the game is not actually running.  Creating a test that yields is a better solution for testing such things.

GUT also supports yielding to a test, but this does not work very well in 1.0.  See the section on yielding for more information.
Example

```
#!python

#Given that SomeCoolObj has a _process method that incrments a_number by 1
#each time _process is called, and that the number starts at 0, this test
#should pass
func test_does_something_each_loop():
	var my_obj = SomeCoolObj.new()
	gut.simulate(my_obj, 20, .1)
	gut.assert_eq(my_obj.a_number, 20, 'Since a_number is incremented in _process, it should be 20 now')

#Let us also assume that AnotherObj acts exactly the same way as
#but has SomeCoolObj but has a _fixed_process method instead of
#_process.  In that case, this test will pass too since all child objects
#have the _process or _fixed_process method called.
func test_does_something_each_loop():
	var my_obj = SomeCoolObj.new()
	var other_obj = AnotherObj.new()
	myObj.add_child(other_obj)
	gut.simulate(my_obj, 20, .1)
	#We check other_obj, to make sure it was called 20 times too.
	gut.assert_eq(other_obj.a_number, 20, 'Since a_number is incremented in _process, it should be 20 now')

```

####Yielding during a test####
__Note that this fucntionality will not work in Godot 1.0.__

You can yield during a test to allow your objects to run their course as they would during an actual run of the game.  This allows you to test functionality in real time as it would occur during game play.  This does however slow your tests down since you have to wait for the game do what you expect in real time and there is no way of speeding things up.  

Yielding works by calling the Godot built-in __yield__ method which takes in an object to yield to, and a signal which that object will emit.  Execution of the test will pause until that signal is emitted.  For example you could yield to a button's 'pressed' event or a timer's 'timeout' event.

``` python
func test_yield_to_button_click():
	my_object = ObjectToTest.new()
	add_child(my_object)
	yield(my_object.some_button, 'pressed')
	gut.assert_true(some_condition, 'After button pressed, this should be true')
	gut.end_yielded_test()
```
Due to the nature of yielding, GUT cannot know when the actual test has finished.  You must notify GUT that a test that contains a yield has completed by calling __gut.end_yielded_test()__.  For this reason, GUT will print out to the screen that it is currently waiting for a the __end_yielded_test__ signal to let you know that it's not just sitting there doing nothing.  If this prints to the screen longer than you expect, then you've either yielded to a signal that may not fire or you forgot to call __gut.end_yielded_test()__ at then end of your test.

In some cases you may not have a signal to wait on, but you do have an idea of how long it will take for a specific test to play out.  To make things easier in this situation GUT provides a timer that you can kick off and yield to.  You tell it how long to wait then yield to the GUT object like so:

``` python
func test_wait_for_a_bit():
	my_object = ObjectToTest.new()
	my_object.do_something()
	gut.set_yield_time(5) #wait 5 seconds
	yield(gut, 'timeout')
	gut.assert_eq(my_object.some_property, 'some value', 'After waiting 5 seconds, this property should be set')
	gut.end_yielded_test()
```

### Setup ###

* To setup GUT in your own project, simply copy the gut.gd script into your project somewhere.  Probably to /scripts, that's what will be used for the rest of this documentation, but it doesn't have to be there for any specific reason.
* You're done, go write some tests.

### Creating Tests ###

To create a test script

* Create a new GDScript
* Extend the Test class in gut.gd (extends "res://scripts/gut.gd".Test).
* Implement the setup/teardown methods that you may need, there are four, none of which are required.
* * setup:  Ran before each test
* * teardown:  Ran after each test
* * prerun_setup:  Ran before any test is run
* * postrun_teardown:  Ran after all tests have run
* Start making test functions
* * Test functions must start with "test_" [func test_some_small_aspect_of_this_cool_thing_i_made():]
* * Tests cannot have a parameter
* * Tests should perform at least one assert.  See the summary for a list of asserts.

Here's a sample test script:

```
#!python
################################################################################
#All the magic happens with the extends.  This gets you access to all the gut
#asserts and the overridable setup and teardown methods.
#
#The path to this script is passed to an instance of the gut script when calling
#test_script
#
#WARNING
#	DO NOT assign anything to the gut variable.  This is set at runtime by the gut
#	script.  Setting it to something will cause everything to go crazy go nuts.
################################################################################
extends "res://scripts/gut.gd".Test
func setup():
	gut.p("ran setup", 2)

func teardown():
	gut.p("ran teardown", 2)

func prerun_setup():
	gut.p("ran run setup", 2)

func postrun_teardown():
	gut.p("ran run teardown", 2)

func test_assert_eq_number_not_equal():
	gut.assert_eq(1, 2, "Should fail.  1 != 2")

func test_assert_eq_number_equal():
	gut.assert_eq('asdf', 'asdf', "Should pass")

func test_assert_true_with_true():
	gut.assert_true(true, "Should pass, true is true")

func test_assert_true_with_false():
	gut.assert_true(false, "Should fail")

func test_something_else():
	gut.assert_true(false, "didn't work")

```

### Running Tests ###

#### From Godot
You should create a scene that you can run that will execute all your test scripts for your project.  You can run the scripts one by one and have the output sent to the console or you can add in the scripts, run them together and then use the GUI to rerun or examine the results with handy dandy coloring and buttons.

Example of one line of code to run one test script and send the output to console:
```
#!python
extends Node2d
func_ready():
    load('res://scripts/gut.gd').new().test_script('res://scripts/sample_tests.gd')
```

Example where we add the scripts to be tested then call test_scripts().  This will run all the scripts.  Since the tester has been added as a child of the scene, you will see the GUI when you run the scene.

```
#!python
extends Node2D

func _ready():
	#get an instance of gut
	var tester = load('res://scripts/gut.gd').new()
	#Move it down some so you can see the dialog box bar at top
	tester.set_pos(0, 50)
	add_child(tester)

	#stop it from printing to console, just because
	tester.set_should_print_to_console(false)

	#Add a bunch of test scripts to run.  These will appear in the drop
	#down and can be rerun.
	tester.add_script('res://scripts/gut_tests.gd')
	tester.add_script('res://scripts/sample_tests.gd')
	#by passing true to the optional 2nd parameter, only this script
	#will be run when test_scripts() is called and it will be selected
	#in the GUI dropdown.  All other scripts will still be in the drop
	#down as well.  Makes it a little easier when trying to run just
	#one script.
	tester.add_script('res://scripts/another_sample.gd', true)
	tester.add_script('res://scripts/all_passed.gd')
	tester.test_scripts()
```
...and the GUI looks like:
![gut.png](https://bitbucket.org/repo/oeKM6G/images/3049099836-gut.png)

#### From command line
Also supplied in this repo is the gut_cmdln.gd script that can be run from the command line so that you don't have to create a scene to run your tests.  The upside is that the command line is a lot more fun, and requires less code.  The biggest downside is that debugging your code/tests is more difficult since you won't be able to interact with the editor.  

To run the command line tool, place gut.gd and gut_cmdln.gd in the scripts directory at the root of your project (it has to go there, it assumes that location).  From the command line, at the root of your project, use the following command to run the script.  Use the options below to run tests.
	`godot -d -s scirpts/gut_cmdln.gd`
The -d option tells godot to run in debug mode which is helpful.  The -s option points to the script to be run.

__Options__

* gexit  
* * Exit when done running tests.  If not specified you have to manually close the window or ctrl+c at command line.
* glog=<X\>   
* * Specify the log level after the = (-glog=0).  See above for description of levels.
* gscript=<comma separated list of scripts\>
* * Add a script or scripts to be tested.  Multiple scripts must be separated by a comma.
* gignore_pause
* * Ignore any calls to gut.pause_before_teardown that might exist in your test scripts.  Useful when batch processing and you don't want to worry about babysitting the run.


__Examples__

Run godot in debug mode (-d), run a test script (-gtest), set log level to lowest (-glog), exit when done (-gexit)

* `godot -s scripts/gut_cmdln.gd -d -gtest=res://unit_tests/sample_tests.gd -glog=1 -gexit`

### Who do I talk to? ###
You can talk to me, Butch Wesley

* Bitbucket:  bitwes
* Godot forums:  bitwes
