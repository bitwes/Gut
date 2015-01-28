### What is this repository for? ###

GUT (Godot Unit Test) is a utility for writing unit tests in Godot's scripting language.  The premise is that the gut.gd script will run other scripts that contain tests and asserts and then reports the status of said tests and asserts.  You must manually invoke the tests by telling it to run a specific script.  Also, that script must inherit from the subclass Test found in gut.gd.  Other than it being a kind of manual process it isn't that bad.  This project illustrates using it and includes the one required script, gut.gd, which is located in /scripts/.

Sometimes the best tutorial is to dive right in, so to that end you should read through the main.gd script for illustrations on running scripts and setting the various options available.  There are various test scripts that illustrate performing assertions and printing messages.  There's even the tests that were created to test GUT itself.  They can be found in gut_tests.gd.

GUT has the following asserts, each of which take 3 parameters (except assert_true and assert_false which only take in a value and text).  These asserts should work with just about anything, but it the datatypes must match.  If you pass in a string and a number it will error out.  They have been tested with booleans, numbers and strings.

* func assert_eq(expected, got, text="") #Asserts that the expected value equals the value got.
* func assert_ne(not_expected, got, text=""): #Asserts that the value got does not equal the "not expected" value.  
* func assert_gt(expected, got, text=""): #Asserts got is greater than expected
* func assert_lt(expected, got, text=""): #Asserts got is less than expected
* func assert_true(got, text=""): #Asserts that got is true
* func assert_false(got, text=""): #Asserts that got is false

These are called from within the test script by prefixing them with "gut.".  For example:

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

### Running Tests ###



### Who do I talk to? ###

* Repo owner or admin
* Other community or team contact