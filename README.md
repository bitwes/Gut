### What is this repository for? ###
Utility for adding test cases to a Godot project.  The premise is that the gut.gd script will run other scripts that contain tests.  You must manually invoke the tests by telling it to run a specific script.  Also, that script must inherit from the subclass in gut.gd.  Other than it being a kind of manual process it isn't that bad.  This project illustrates using it and includes the one required script gut.gd which is located in /scripts/gut.gd and does all the magic.

Sometimes the best tutorial is to dive right in, so to that end you should read through the main.gd script for illustrations on running scripts and setting the various options available.  There are various test scripts that illustrate performing assertions and printing messages.  There's even the tests that were created to test the tester.  They can be found in gut_tests.gd.

### How do I get set up? ###

* To setup GUT in your own project, simply copy the gut.gd script into your project somewhere.  Probably to /scripts, that's what will be used for the rest of this documentation, but it doesn't have to be there for any specific reason.
* You're done, go write some tests.

### Creating Tests ###

### Running Tests ###
* Deployment instructions

### Who do I talk to? ###

* Repo owner or admin
* Other community or team contact