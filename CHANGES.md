# Release notes
All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

# 5.0.0
This version mostly contains some long overdue house cleaning.  When I first created Gut I tried to keep it all to a single file so that deployment was easier.  With the advent of the Addons system, I have a lot more freedom in structuring the files.  I had also based the structure of the classes on another unit test tool I had cobbled together for a procedural language.  This refactoring of the files will make changes easier in the future and separates out the various responsibilities into their own files and classes better.

So that this wasn't JUST a reorganization release I also added an method for asserting instance type and inheritance.

### Breaking Changes from 4.1.0
Due to the restructuring I've completely moved the various `asserts` out of the core gut object and put them in the test object that all unit tests inherit from.  This means that any asserts or pending calls that are prefixed with `gut.` need to have the `gut.` prefix removed.  To cut down on the annoyance level of this change, I've added the methods back into gut but they fail with a message indicating that the method has been moved.

- New Methdos
  - `assert_extends` Asserts that an instance of an object inherits from the class passed.
- Some changes to the log output.  
  - Quick summary about each test script is included at the end of the run.
  - Scripts that had a failing assert are listed together in the quick summary.
- Changed the GUI to have a fixed width font.  It makes formatting the output easier and I like it more.  Future changes should make customizing the GUI possible, so if you aren't fond of it you'll be able to change it sometime soon.
- All asserts were moved from the `gut` class to the `test` class so you don't need to prefix them.  Placeholder methods were put back into `gut` so your tests will run but fail with a message indicating the assert has been moved.




# 4.1.0
- Added the ability to assert that signals did or did not fire.  By calling `watch_signals` Gut will monitor any signals emitted by the object.  You can then later make assertions about whether or not a signal was emitted or whether it emitted a desired number of times, and even if it was emitted and passed specific parameters.  You can also verify that the signal was emitted with the right parameters.  The following methods were added for this feature, see the README for more information about them.
	- `watch_signals`
	- `assert_signal_emitted`
	- `assert_signal_not_emitted`
	- `assert_signal_emitted_with_parameters`
	- `assert_signal_emit_count`
	- `assert_has_signal`
	- `get_signal_emit_count`
	- `get_signal_parameters`
- Some minor fixes to `gut.p`
	- It now performs a `str` on the input.  So if you pass it an object or something that isn't a string it won't blow up.
	- It now indents multi-line input correctly.
# 4.0.0
### Breaking Changes from 3.0.x and earlier

Before upgrading, remove gut.gd and gut_cmdln.gd from your your current project.  That will help ensure that you got everything setup right with the new install location.

0.  The install location has changed to `res://addons/gut`.  So you'll want to clean out wherever you had it previously installed.
0.  You'll want to update your existing scene to use the new plugin object.  Follow the new install instructions. <br>
__Note:__  just about everything you had to code to get your main testing scene running can now be configured in the Editor.  Select the Gut node and the options will appear in the Inspector.  Your existing code will work with the new custom node but using the Editor greatly simplifies things.
0.  The object that all test scripts must extend has changed to `res://addons/gut/test.gd`.
0.  All examples and tests for Gut itself have been moved to the new repo https://github.com/bitwes/GutTests/

### Earlier Versions:
- There were earlier versions, they had changes but I can't remember what they were.
