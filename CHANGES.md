# Release notes
All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).
# 6.6.0

## Fixes
* __Issue 79__:  Scaling wasn't being accounted for by the `maximize` method.
* __Issue 80__:  Inner classes are no longer included in the count of scripts that were ran.

## Features
* __Issue 83__: Added option to include subdirectories.  Thanks to ChemicalInk for doing the initial work to implement the traversals.  The option is off by default so that it doesn't break anything.  This will probably change in later releases.  
  * gutconfig:  include_subdirs
  * command line:  -ginclude_subdirs
  * editor: Include Subdirectories
  * Gut instance:  set/get_include_subdirectories()
* __Issue 69__:  Renamed some methods.  The old names will remain but the documentation has been updated to reflect the new names.  If I ever end up removing the old names they will become deprecated for awhile and then removed in some later release.
  * `assert_get_set_methods` renamed to `assert_accessors` b/c it is easier to say
  * `assert_extends` renamed to `assert_is` b/c the keyword changed in gut 3.0
  * The setup/teardown methods got a rename so they are a little easier to understand.  You should use the new names going forward, but refactoring existing tests can be messy (see note below).
    * `prerun_setup` renamed to `before_all`
    * `setup` renamed to `before_each`
    * `postrun_teardown` renamed to `after_all`
    * `teardown` renamed to `after_each`
    * __Special note about these:__
      * The new methods could not be actual aliases due to how they are used internally.  They exist side by side with the old names and are called after the old methods.  __DO NOT USE BOTH in the same script.__
      * If you refactor your tests to use the new names, be careful wherever you have a test class that extends another test class and it calls `super`'s setup/teardown methods.  For example, if you rename `super`'s `setup` to `before_each` but all the test classes that inherit from it are still calling `.setup` then you'll have problem on your hands.  

# 6.5.0

## Fixes
* Bug fix by __Xrayez__ to ensure that the command line tool always sets the return code properly.  Before it was only setting it if Gut was configured to exit when done.
* Fixed an issue where the command line tool wasn't setting options correctly when the .gutconfig.json file was present.  All options are now applied correctly based on order of precedence (default < gutconfig < cmd line).  I also added the `-gpo` command line option to print out all option values from all sources and what value would be used when running Gut.  This will make debugging theses issues easier later.

## Features
* We have two new asserts thanks to __hbergren__.  These asserts make it easier to assert if a value is within or outside of a +/- range of a value.  These are especially useful when comparing floats that the engine insists aren't equal due to rounding errors.
  * `assert_almost_eq(got, expected, error_interval, text='')` - Asserts that `got` is within the range of `expected` +/- `error_interval`.  The upper and lower bounds are included in the check.  Verified to work with integers, floats, and Vector2.  Should work with anything that can be added/subtracted.  <a href="https://github.com/bitwes/Gut/wiki/Methods#assert_almost_eq">  Examples</a>
  * `assert_almost_ne(got, expected, error_interval, text='')` - This is the inverse of `assert_almost_eq`.  This will pass if `got` is outside the range of `expected` +/- `error_interval`.<a href="https://github.com/bitwes/Gut/wiki/Methods#assert_almost_ne">  Examples</a>
* __Xrayez__ contributed a new option to maximize the Gut window upon launch.  The option can be set in the editor, .gutconfig, or at the command line.
* Added the `-gpo` command line option to print out all option values from all sources and what value would be used when running Gut.  This will make debugging option issues much easier.


## Other
Some housekeeping.  Removed some commented out and unreachable code.  Renamed a lot of tests in `test_test.gd` since it now uses Inner Test Classes which allows for better names.  They were setting a bad example for PRs.

# 6.4.0
I've "dog food"ed the doubles, stubs, and spies more in my own game and I think they are pretty stable.  This release contains some tweaks to doubles and stubs and the introduction of spies as well as some other testing goodness.  

## Features
* `inner_class_name` option for editor node, command line, and .gutconfig.json.
* `assert_exports`:  Assert that script exports a variable with a specific type.  __Thanks Myrkrheim__
* Command line now returns `0` when all tests pass and `1` if there are any failures.  __Thanks cmfcmf.__
* You can now set the opacity for the GUI through a command line option or the `.gutconfig.json` file.  __That one is also thanks to Myrkheim__.
* Spies (experimental)
  * You can make assertions now about method calls on doubled objects.
  * `assert_called`
  * `assert_not_called`
  * `assert_call_count`

## Fixes
* Fixed issue with duplicate methods in doubled classes.

# 6.3.0

### Wiki
First, the [Readme has been broken up into a Github wiki](https://github.com/bitwes/Gut/wiki).  I think this will make consuming the help easier.  There is probably some room for improvement in the documentation and organization.  Create issues for anything that could be done better.

### Inner Test Classes
You can now create "Inner Classes" that run tests.  This allows you to breakup your tests and create multiple setup/teardown scopes in a single script.

Example:
``` python
extends "res://addons/gut/test.gd"

class TestInnerClass:
  extends "res://addons/gut/test.gd"

  func setup():
    pass

class TestInnerClass2:
  extends "res://addons/gut/test.gd"

  func setup():
    pass
```

### Command line config file
There is now support for a config file for the command line tool.  It only supports some options right now, but that will be expanded in the future.
``` json
{
  "dirs":["res://test/unit/", "res://test/integration/"],
  "should_exit":true,
  "ignore_pause":true,
  "log": 3
}
```

### Experimental Doubles and Stubs
There are also two new experimental features in this release.  Doubling and Stubbing.  These are experimental because their implementation could change a lot.  I hope not, but they might.  I fought with how these should work a lot, and honestly, I might have gotten it wrong.  So I'm going to put it out there and see how they get used in the wild.  I'm dedicated to keeping these features and improving on them, but they might be a little rough around the edges.

[You can find out more about Stubbing and Doubling in the Wiki.](https://github.com/bitwes/Gut/wiki)

### Yet another repo reorg
Big thanks to [cmfcmf](https://github.com/cmfcmf) for introducing me to `.gitattributes` and creating a PR to put the old repo structure back.  Now that I can easily exclude files from the exported zip file, this should be the last reorg or the repo.

# 6.2.0
* Some new asserts courtesy of Myrkrheim
``` python
assert_string_contains
assert_string_starts_with
assert_string_ends_with
assert_has_method
```
* Added .gitattributes which might make for less un-checkboxing when installing from Asset Library and less extra files when downloading the addon.  If this works out, then the next release will undo moving everything into `gut_tests_and_examples` and everything will be right in the world.  Thanks cmfcmf.

# 6.1.0
* Moved as many files as I could to `gut_tests_and_examples` so that there was less stuff to uncheck when installing via the in-engine Asset Library.  I'm still not 100% happy with the setup.
* Moved the License to `addons/gut/` so that it is distributed with the addon and doesn't accidently get copied into the root of some other project when installed via the Asset Library.
* Some README tweaks.
* Fixed resize window handle bug.  It was connecting to wrong signals and didn't work.
* Missed changing `simulate` to call `_physics_process` instead of `_fixed_process` in the 3.0 conversion.  Fixed that.
* Improved summary.  It now lists all failures and pendings instead of just listing the scripts that have failures or pending tests.
* Fixed issue where the `signal_watcher` could try to disconnect from a freed object.
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
