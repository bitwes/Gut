### What is this repository for? ###
GUT (Godot Unit Test) is a utility for writing unit tests in Godot's scripting language.  The premise is that the gut.gd script will run other scripts that contain tests and asserts and then reports the status of said tests and asserts.  You must manually invoke the tests by telling it to run a specific script.  Also, that script must inherit from the subclass Test found in gut.gd.  Other than it being a kind of manual process it isn't that bad.  This project illustrates using it and includes the one required script, gut.gd, which is located in /scripts/.

Sometimes the best tutorial is to dive right in, so to that end you should read through the main.gd script for illustrations on running scripts and setting the various options available.  There are various test scripts that illustrate performing assertions and printing messages.  There's even the tests that were created to test GUT itself.  They can be found in gut_tests.gd.

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
* * Tests should perform at least one assert.  There are many to choose from and come on the form of gut.assert_x and take three parameters
* * * (1) expected:  This is the value expect to get
* * *  (2) got:  This is the value you did get
* * *  (3) text:  Optional text to display.
### Running Tests ###
* Deployment instructions

### Who do I talk to? ###

* Repo owner or admin
* Other community or team contact