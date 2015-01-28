### What is this repository for? ###

GUT (Godot Unit Test) is a utility for writing unit tests in Godot's scripting language.  The premise is that the gut.gd script will run other scripts that contain tests and asserts and then reports the status of said tests and asserts.  This is all done through godot using a scene you create to run the tests.  Once your scene is in place and you've coded up a GUT instance to run your test scripts, you simply run the scene.  This project illustrates using GUT to run tests, some sample tests, and the one required script, gut.gd, which is located in /scripts/.

Sometimes the best tutorial is to dive right in, so to that end you should read through the main.gd script for illustrations on running scripts and setting the various options available.  There are various test scripts that illustrate performing assertions and printing messages.  There's even the tests that were created to test GUT itself.  They can be found in gut_tests.gd.

GUT has the following asserts, each of which take 3 parameters (except assert_true and assert_false which only take in a value and text).  These asserts should work with just about anything, but it the datatypes must match.  If you pass in a string and a number it will error out.  They have been tested with booleans, numbers and strings.

* func assert_eq(expected, got, text="") #Asserts that the expected value equals the value got.
* func assert_ne(not_expected, got, text=""): #Asserts that the value got does not equal the "not expected" value.  
* func assert_gt(expected, got, text=""): #Asserts got is greater than expected
* func assert_lt(expected, got, text=""): #Asserts got is less than expected
* func assert_true(got, text=""): #Asserts that got is true
* func assert_false(got, text=""): #Asserts that got is false

These are called from within test scripts (scripts that extend "res://scripts/gut.gd".Test) by prefixing them with "gut.".  For example:

* gut.assert_eq(1, my_number_var, "The number should be 1.")
* gut.assert_lt("b", my_string_var, "The value should be less than 'b'.")
* gut.assert_true(my_bool_var, "If this ain't true, then it's false, and that means this test fails")

### How do I get set up? ###

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
	add_child(tester)
	
	#stop it from printing to console, just because
	tester.set_should_print_to_console(false)
	
	#Add a bunch of test scripts to run.  These will appear in the drop
	#down and can be rerun.  As long as you don't introduce a runtime
	#error, you can leave it running, code some more, then rerun the
	#tests for any or all of the scripts that have been added using
	#add_script.
	tester.add_script('res://scripts/gut_tests.gd')
	tester.add_script('res://scripts/sample_tests.gd')
	tester.add_script('res://scripts/another_sample.gd')
	tester.add_script('res://scripts/all_passed.gd')
	tester.test_scripts()
```
...and the GUI looks like:
![gut_screenshot.png](https://bitbucket.org/repo/oeKM6G/images/3406082255-gut_screenshot.png)

### Who do I talk to? ###
You can talk to me, Butch Wesley

* * Bitbucket:  bitwes
* * Godot forums:  bitwes