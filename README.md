### What is this repository for? ###
__IMPORTANT NOTE __

__The ordering of the parameters in the asserts has changed with this version.  After using GUT for awhile I realized that "got" should come first for things to read better.  This change won't break any of your tests but the message will be misleading until you reorder the parameters when you call the various asserts.__

GUT (Godot Unit Test) is a utility for writing unit tests in Godot's scripting language.  The premise is that the gut.gd script will run other scripts that contain tests and asserts and then reports the status of said tests and asserts.  This is all done through godot using a scene you create to run the tests.  Once your scene is in place and you've coded up a GUT instance to run your test scripts, you simply run the scene.  This project illustrates using GUT to run tests, some sample tests, and the one required script, gut.gd, which is located in /scripts/.

Sometimes the best tutorial is to dive right in, so to that end you should read through the main.gd script for illustrations on running scripts and setting the various options available.  There are various test scripts that illustrate performing assertions and printing messages.  There's even the tests that were created to test GUT itself.  They can be found in gut_tests.gd.

GUT has the following asserts, each of which take the value you recieved and sometimes expected values.  These asserts should work with just about anything, but it the datatypes must match.  If you pass in a string and a number it will error out.  They have been tested with booleans, numbers and strings.

###Godot Version 1.0 and 1.1 Beta###
As development continues I will try to support the last two releases of Godot.  I have been developing with the 1.1 beta relase.  To use the project in this repo in 1.1 you may have to load the main_1_0.scn instead of the default.  You'll know if you have to load it if you get the "ugh" error.  Remember, this is only for the project, using the gut.gd script doesn't require anything special.
###Gut Methods###

####Asserts####
__AS STATED BEFORE...the parameters have been reordered in this version, "got" is now always the first parameter.__

* __assert_eq(got, expected, text="")__:  #Asserts that the expected value equals the value got.
* __assert_ne(got, not_expected, text="")__:  #Asserts that the value got does not equal the "not expected" value.  
* __assert_gt(got, expected, text="")__:  #Asserts got is greater than expected
* __assert_lt(got, expected, text="")__:  #Asserts got is less than expected
* __assert_true(got, text="")__:  #Asserts that got is true
* __assert_false(got, text="")__:  #Asserts that got is false
* __assert_between(got, expected_low, expected_high, text="")__:  #Asserts got is between the two expected values (inclusive)

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
* LOG_LEVEL_ALL_ASSERTS (20

####Printing info####
The "p" method allows you to print information out indented under the test output.  It has an optional 2nd parameter that sets which log level to display it at.  Use one of the constants in the section above to set it.  The default is LOG_LEVEL_FAIL_ONLY which means the output will always be visible.  
```
#!python

func p(text, level=0)
```
####Simulate####
The simulate method will call the _process or _fixed_process on a tree of objects.  It takes in the base object, the number of times to call the methods and the delta value to be passed to _process or _fixed_process (if the object has one).  
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

### Who do I talk to? ###
You can talk to me, Butch Wesley

* Bitbucket:  bitwes
* Godot forums:  bitwes