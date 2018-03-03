# Release notes
All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

# 6.1.0
* Fixed resize window handle bug.  It was connecting to wrong signals and didn't work.
* Missed changing `simulate` to call `_physics_process` instead of `_fixed_process` in the 3.0 conversion.  Fixed that.
* Improved summary.  It now lists all failures and pendings instead of just listing the scripts that have failures or pending tests.
* Added `yield_to` which allows you to `yield` to a signal or a maximum amount of time.  This keeps your tests moving along if you yield to a signal that never gets emitted.  Now the test will fail after an amount of time instead of sitting in limbo forever.  This will also watch the signals on the object so you can make asserts about signals after the `yield` and you can save a line of code.  
Example:
``` python
# wait for my_object to emit the signal 'my_signal'
# or 5 seconds, whichever comes first.
yield(yield_to(my_object, 'my_signal', 5), YIELD)  
assert_signal_emitted(my_object, 'my_signal', \
                     'Maybe it did, maybe it didnt, but we still got here.')
```

# 6.0.0
* Godot 3.0 compatibility
* Combined GutTests repo so everything is now in one place.
* Fixed bug where prev/next were disabled incorrectly on startup.
* Some house keeping.

### Breaking Changes
No longer works with Godot 2.x, other than that everything remained the same.

# 5.0.1
* Fixed issue where `watch_signals` was not working with "Script Signals".  These are signals defined using the syntax `signal SomeSignal` instead of using `add_user_signal` to create them.
* Fixed a link in the README

# 5.0.0
This version mostly contains some long overdue house cleaning.  So that this wasn't JUST a reorganization release I also added an method for asserting instance type and inheritance and some minor tweaks.

### Breaking Changes (kinda) from 4.1.0
This change should only affect really old tests.  If you started using Gut later than 4.0 then you will most likely be ok.  The best approach to adjusting your tests is just to run them and see if it tells you that you are calling any methods that have been moved and then fixing them by removing the _`gut.`_ prefix.

Due to the restructuring I've completely moved the various `asserts` out of the core `gut` object and put them in the `test` object that all unit tests inherit from.  This means that any asserts or pending calls that are prefixed with _`gut.`_ need to have the _`gut.`_ prefix removed.  To cut down on the annoyance level of this change I've added stubs for the removed methods that fail with a message indicating that the method has been moved.


- New Methdos
  - `assert_extends` Asserts that an instance of an object inherits from the class passed.
- Some changes to the log output.  
  - Quick summary about each test script is included at the end of the run.
  - Scripts that had a failing assert are listed together in the quick summary.
- Changed the GUI to have a fixed width font.  It makes formatting the output easier and I like it more.  Future changes should make customizing the GUI possible, so if you aren't fond of it you'll be able to change it sometime soon.
- All asserts were moved from the `gut` class to the `test` class so you don't need to prefix them.  Placeholder methods were put back into `gut` so your tests will run but fail with a message indicating the assert has been moved.

#### But Why?
When I first created Gut I tried to keep it all to a single file so that deployment was easier.  With the advent of the Addons system, I have a lot more freedom in structuring the files.  I had also based the structure of the classes on another unit test tool I had cobbled together for a procedural language.  This refactoring of the files will make changes easier in the future and separates out the various responsibilities into their own files and classes better.

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
