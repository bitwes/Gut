### What is this repository for? ###
GUT (Godot Unit Test) is a utility for writing unit tests in Godot's scripting language.  The premise is that the gut.gd script will run other scripts that contain tests and asserts and then reports the status of said tests and asserts.  This is all done through godot using a scene you create to run the tests.  Once your scene is in place and you've coded up a GUT instance to run your test scripts, you simply run the scene.  This project illustrates using GUT to run tests, some sample tests, and the one required script, gut.gd, which is located in /scripts/.

Sometimes the best tutorial is to dive right in, so to that end you should read through the main.gd script for illustrations on running scripts and setting the various options available.  There are various test scripts that illustrate performing assertions and printing messages.  There's even the tests that were created to test GUT itself.  They can be found in gut_tests.gd.

GUT has the following asserts, each of which take the value you recieved and sometimes expected values.  These asserts should work with just about anything, but it the datatypes must match.  If you pass in a string and a number it will error out.  They have been tested with booleans, numbers and strings.

###Godot Version 1.0 and 1.1 ###
As development continues I will try to support the last two releases of Godot.  I have been developing with the 1.1 beta relase.  To use the project in this repo in 1.1 you may have to load the main_1_0.scn instead of the default.  You'll know if you have to load it if you get the "ugh" error.  Remember, this is only for the project, using the gut.gd script doesn't require anything special.
###Gut Methods###

__Setting up the tester__

* __add_script(script, select_this_one=false)__ add a script to be tetsted with test_scripts
* __add_directory(path, prefix='test_', suffix='.gd')__ add a directory of test scripts that start with prefix and end with suffix.  Subdirectories not included.
* __test_scripts()__ run all scripts added with add_script or add_directory
* __test_script(script)__ runs a single script immediately.
* __select_script(script_name)__ sets a script added with add_script or add_directory to be initially selected.  This allows you to run one script instead of all the scripts.  This will select the first script it finds that contains the specified string.
* __get_test_count()__ return the number of tests run
* __get_assert_count()__ return the number of assertions that were made
* __get_pass_count()__ return the number of tests that passed
* __get_fail_count()__ return the number of tests that failed
* __get_pending_count()__ return the number of tests that were pending
* __get/set_should_print_to_console(should)__ accessors for printing to console
* __get_result_text()__ returns all the text contained in the gui
* __clear_text()__ clears the text in the gui
* __set_ignore_pause_before_teardown(should_ignore)__ causes gui to disregard and calls to pause_before_teardown
* __set_yield_between_tests(should)__ will pause briefly between each test so that you can see progress in the gui.  Should not be used in versions earlier than 1.1
* __get/set_log_level(level)__ see section on log level for list of values.

__Asserting things__

* __p(text, level=0, indent=0)__ print info to the gui and console
* __assert_eq(got, expected, text="")__ assert got == expected and prints optional text
* __assert_ne(got, not_expected, text="")__ asserts got != expected and prints optional text
* __assert_gt(got, expected, text="")__ assserts got > expected
* __assert_lt(got, expected, text="")__ asserts got < expected
* __assert_true(got, text="")__ asserts got == true
* __assert_false(got, text="")__ asserts got == false
* __assert_between(got, expect_low, expect_high, text="")__ asserts got > expect_low and <= expect_high
* __assert_file_exists(file_path)__ asserts a file exists at the specified path
* __assert_file_does_not_exist(file_path)__ asserts a file does not exist at the specified path
* __assert_file_empty(file_path)__ asserts the specified file is empty
* __assert_file_not_empty(file_path)__ asserts the specified file is not empty
* __assert_get_set_methods(obj, property, default, set_to)__ assert that object has get_<property> and set_<property> methods.  Also asserts that the intial call to get_<property> returns the value in default and that calling set_<property> sets the value to set_to and that set_to is returned by a subsequent call to get_<property>.  For example, calling  `gut.assert_get_set_methods(some_obj, 'description', 'default', 'new description')` will verify `some_obj` has a `get_description` and `set_description` method and that the first call to `get_description()` returns 'default' and that a call to `set_description('new description')` then a call to `get_description()` will return 'new_description'.
* __pending(text="")__ flag a test as pending

__Yielding during a test__

_See the section on yielding for more information._

* __pause_before_teardown()__ causes the gui to pause before it runs the teardown method.  You must press the "continue" button on the gui to continue testing.  Can be by-passed using the set_ignore_pause_before_teardown method.
* __set_yield_time(time)__ Sets the amount of time to wait when yielding to gut.  See section on yielding.
* __end_yielded_test()__ Signifies a test that yielded has ended.  Must be called after yielding during a test or the gui will sit there and do nothing and you will be confused and angry.
* __simulate(obj, times, delta)__ Runs the \_process and/or \_fixed_process method on the passed in object, along with any of it's children and their children and so on and so forth.  This will call the methods x times and pass them a value of delta each time they are called.

__File manipulation convenience methods__

* __file_touch(path)__ create an empty file if it doesn't exist.
* __file_delete(path)__ delete a file
* __is_file_empty(path)__ checks if a file is empty
* __directory_delete_files__ deletes all files in a directory.  does not delete subdirectories or any files in them.

####Watching tests as they execute####
Note, this feature is not supported in 1.0.  For that reason it is disabled by default as to not break anything.  When running longer tests it can appear as though the program has hung.  To address this and see the tests as they execute a yield was added between tests.  To enable this feature call set_yield_between_tests(true).

####Output Detail####
The level of detail that is printed to the screen can be changed using the slider on the dialog or by calling set_log_level with one of the following constants defined in Gut

* LOG_LEVEL_FAIL_ONLY (0)
* LOG_LEVEL_TEST_AND_FAILURES (1)
* LOG_LEVEL_ALL_ASSERTS (2)

####Printing info####
The "p" method allows you to print information out indented under the test output.  It has an optional 2nd parameter that sets which log level to display it at.  Use one of the constants in the section above to set it.  The default is LOG_LEVEL_FAIL_ONLY which means the output will always be visible.  


####Working with Files####
GUT contains a few utility methods to ease the testing of file creation/deletion.  

* __file_touch(path)__ Creates a file at the designated path.
* __file_delete(path)__ Deletes a file at the disgnated path.
* __is_file_empty(path)__ Returns true if the file at the path is empty, false if not.
* __directory_delete_files(path)__ Deletes all files at a given path.  Does not delete sub directories or any files in any sub directories.


####Simulate####
The simulate method will call the \_process or \_fixed_process on a tree of objects.  It takes in the base object, the number of times to call the methods and the delta value to be passed to \_process or \_fixed_process (if the object has one).  This will only cause code directly related to the \_process and \_fixed_process methods to run.  Timers will not fire since the main loop of the game is not actually running.  Creating a test that yields is a better solution for testing such things.

GUT also supports yielding to a test, but this does not work very well in 1.0.  See the section on yielding for more information.
Example

```
#!python

# Given that SomeCoolObj has a _process method that incrments a_number by 1
# each time _process is called, and that the number starts at 0, this test
# should pass
func test_does_something_each_loop():
	var my_obj = SomeCoolObj.new()
	gut.simulate(my_obj, 20, .1)
	gut.assert_eq(my_obj.a_number, 20, 'Since a_number is incremented in _process, it should be 20 now')

# Let us also assume that AnotherObj acts exactly the same way as
# but has SomeCoolObj but has a _fixed_process method instead of
# _process.  In that case, this test will pass too since all child objects
# have the _process or _fixed_process method called.
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
# All the magic happens with the extends.  This gets you access to all the gut
# asserts and the overridable setup and teardown methods.
#
# The path to this script is passed to an instance of the gut script when calling
# test_script
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
This method is a little more involved but when something breaks you have easy access to the editor.  To get started faster, skip down to the "From command line" section.

You should create a scene that you can run that will execute all your test scripts for your project.  You can run the scripts one by one and have the output sent to the console or you can add in the scripts, run them together and then use the GUI to rerun or examine the results with handy dandy coloring and buttons.

There are 3 ways to add scripts to be run, feel free to use any combination of these:

* __test_script__ runs a single test that has been passed to it.  No frills, prints to the console.
* __add_script__ adds a script to the list of scripts to be run.  use `test_scripts` method to run them all in a row.
* __add_directory__ Similar to add_script but adds all the test scripts in the specified directory.  This will not add tests found in subdirectories but can be called multiple times.  By default it searches for files that start with 'test_' and end with '.gd'.  This can be changed by specify the option prefix and suffix parameters `add_directory('res://unit_tests', 'some_prefix', '.res')`

To cut down on clicks, the `add_script` method takes an optional true/false flag that allows you flag a test to be run initially.  You can also use `select_script` method to select a script that was added with add_script or add_directory.  `select_script` will find the first script that contains the string you specify and mark it as the script to be run initially.

__One script at a time__

The test script method will run a single script that you pass it and send the output to the console.  

Example of one line of code to run one test script and send the output to console:
```
#!python
extends Node2d
func_ready():
    load('res://scripts/gut.gd').new().test_script('res://scripts/sample_tests.gd')
```


__Multiple Scripts__

Example where we add the scripts to be tested then call test_scripts().  This will run all the scripts.  Since the tester has been added as a child of the scene, you will see the GUI when you run the scene.

```
#!python
extends Node2D

func _ready():
	# get an instance of gut
	var tester = load('res://scripts/gut.gd').new()
	# Move it down some so you can see the dialog box bar at top
	tester.set_pos(0, 50)
	add_child(tester)

	# stop it from printing to console, just because
	tester.set_should_print_to_console(false)

	# Add all the scripts in a directory
	tester.add_directory('res://unit_tests')

	#Add additional scripts one at a time.
	tester.add_script('res://unit_tests/gut_tests.gd')
	tester.add_script('res://unit_tests/sample_tests.gd')
	# by passing true to the optional 2nd parameter, only this script
	# will be run when test_scripts() is called and it will be selected
	# in the GUI dropdown.  All other scripts will still be in the drop
	# down as well.  Makes it a little easier when trying to run just
	# one script.
	tester.add_script('res://scripts/another_sample.gd', true)
	tester.add_script('res://scripts/all_passed.gd')
	tester.test_scripts()
```
...and the GUI looks like:
![gut.png](https://bitbucket.org/repo/oeKM6G/images/3049099836-gut.png)

#### From command line
Also supplied in this repo is the gut_cmdln.gd script that can be run from the command line so that you don't have to create a scene to run your tests.  One of the main reasons to use this approach instead of going through the editor is that you get to see error messages generated by Godot in the context of your running tests.  You also see any `print` statements you put in  your code in the context of all the Gut generated output.  It's a bit quicker to get started and is a bit cooler if I do say so.  The biggest downside is that debugging your code/tests is a little more difficult since you won't be able to interact with the editor when something blows up.

To run the command line tool, place gut.gd and gut_cmdln.gd in the scripts directory at the root of your project (if that doesn't work for you, you can put it anywhere else but you have to use the -gutloc option to tell it where it is).  From the command line, at the root of your project, use the following command to run the script.  Use the options below to run tests.
	`godot -d -s scirpts/gut_cmdln.gd`
The -d option tells godot to run in debug mode which is helpful.  The -s option tells godot to run a script.

__Options__
_Output from the command line help (-gh)_
```
---------------------------------------------------------                                                             
This is the command line interface for the unit testing tool Gut.  With this interface you can run one or more test scipts from the command line.  In order for the Gut options to not clash with any other godot options, each option start with a "g".  Also, any option that requires a value will take the form of "-g<name>=<value>".  There cannot be any spces between the option, the "=", or inside a specified value or godot will think you are trying to run a scene.       

Options                                                                                                               
-------                                                                                                               
  -gtest          Comma delimited list of tests to run                                                                
  -gdir           Comma delimited list of directories to add tests from.                                              
  -gprefix        Prefix used to find tests when specifying -gdir.  Default "test_"                                   
  -gsuffix        Suffix used to find tests when specifying -gdir.  Default ".gd"                                     
  -gexit          Exit after running tests.  If not specified you have to manually close the window.                  
  -glog           Log level.  Default 1                                                                               
  -gignore_pause  Ignores any calls to gut.pause_before_teardown.                                                     
  -gselect        Select a script to run initially.  The first script that was loaded using -gtest or -gdir that contains the specified string will be executed.  You may run others by interacting with the GUI.                           
  -gutloc         Full path (including name) of the gut script.  Default res://scripts/gut.gd                         
  -gh             Print this help                                                                                     
---------------------------------------------------------                                                             
```

__Examples__

Run godot in debug mode (-d), run a test script (-gtest), set log level to lowest (-glog), exit when done (-gexit)

`godot -s scripts/gut_cmdln.gd -d -gtest=res://unit_tests/sample_tests.gd -glog=1 -gexit`

Load all test scripts that begin with 'me_' and end in '.res' and run me_only_only_me.res (given that the directory contains the following scripts:  me_and_only_me.res, me_only.res, me_one.res, me_two.res).  I don't specify the -gexit on this one since I might want to run all the scripts using the GUI after I run this one script.

`godot -s scripts/gut_cmdln.gd -d -gdir=res://unit_tests -gprefix=me_ -gsuffix=.res -gselect=only_me`

__Alias__
Make your life easier by creating an alias that includes your most frequent options.  Here's the one I use in bash:

`alias gut='godot -d -s scirpts/gut_cmdln.gd -gdir=res://unit_tests,res://other_tests -gexit -gignore_pause'`

This alias loads up all the scripts I want from my testing directories and sets some other flags.  With this, if I want to run 'test_one.gd', I just enter `gut -gselect=test_one`.

__Common Errors__
I really only know of one so far, but if you get a space in your command somewhere, you might see something like this:
```
ERROR:  No loader found for resource: res://samples3
At:  core\io\resource_loader.cpp:209
ERROR:  Failed loading scene: res://samples3
At:  main\main.cpp:1260
```
I got this one when I accidentally put a space instead of an "=" after -gselect.


### Who do I talk to? ###
You can talk to me, Butch Wesley

* Bitbucket:  bitwes
* Godot forums:  bitwes
