# Porting GUT to Godot 4.0



## Overview
Ported to Godot 4 Beta 1

GUT is currently somewhat usable in 4.0.  Some features work, but many do not.  The CLI works, but the in-editor panel does not.

This file tracks the changes that have occurred in porting GUT to Godot 4.0.  All issues related to the conversion have the [Godot 4.0](https://github.com/bitwes/Gut/issues?q=is%3Aissue+is%3Aopen+label%3A%22Godot+4.0%22) tag.

<ins>Current results of all GUT tests</ins>
```
Totals
Scripts:          160
Passing tests     934
Failing tests     37
Risky tests       16
Pending:          64
Asserts:          1431 of 1477 passed

Warnings/Errors:
* 15 Errors.
* 6 Warnings.


934 passed 37 failed.  Tests finished in 120.166s
```



## Contributing
Pull requests are welcome.  You can look at the [Godot 4.0](https://github.com/bitwes/Gut/issues?q=is%3Aissue+is%3Aopen+label%3A%22Godot+4.0%22) issues for items that need to be addressed.  If you find something that is not mentioned, please make an issue.  There are also a lot of pending and failing tests that need to be addressed.

Running tests for GUT requires using the CLI or VSCode plugin currently.

Read the "Working" and "Broken" features section before starting.  There are some major features that are not working.  These features might be required before other features can be fixed.  `yield`/`await` and doubling inner classes are big ones.

* Tests that are mostly working in 4.0 have been moved to `res://tests/ported_to_4/`.  Anything you fix/implement should have tests in the `unit` or `integration` directory.
* Move any existing tests related to your work from the various directories below.
* Tests in `res://test/unit` or `res://test/integration` have not been ported yet.
* You can use the `skip_script` variable (details below) to skip inner classes in a test script.
* Use the following format for skipping individual tests in a script:
```gdscript
pending('<put reason here> 4.0')
return

<rest of test code here>
```



## Godot 4 Changes
These are changes to Godot that affect how GUT is used/implemented.

* `setget` has been replaced with a completely new syntax.  More info at [#380](/../../issues/380).  Examples of the new way and the new `assert_property` method below.
* `connect` has been significantly altered.  The signal related asserts will likely change to use `Callable` parameters instead of strings.  It is possible to use strings, so this may remain in some form.  More info in [#383](/../../issues/383).
* `yield` has been replaced with `await`.  `yield_to`, `yield_for`, and `yield_frames` have been deprecated, the new methods are `wait_seconds`, `wait_frams` and `wait_for_signal`.  There are exampels below and more info at [#382](/../../issues/382).
* Arrays are pass by reference now.

## Working Features
* The command line seems to be working fine.
* Basic asserts (assert_eq, ne, between etc) with anything except arrays and dictionaries.
* `assert_is` seems is working now.
* Signal asserts
* Signal connection asserts
* Orphan monitoring
* Doubling, Spying, Stubbing (mostly).  Cannot double inner classes.
* Using `await` (the new `yield`) in tests, and all the GUT supplied `yield_` methods.  See notes in Changes section.
* Input mocking.

## Broken Features
* Gut Panel.  The in-editor panel is not working, you must use the CLI for now.
* Cannot double inner classes due to Godot bug #65666.
* Dictionary/array asserts are broke in some cases.
* Probably much much more.



## Changes
### Usage
* Any methods that were deprecated in GUT 7.x have been removed.
* `assert_setget` no longer works (it now just fails with a message).  `assert_property` has been altered to work with the new setter/getter syntax.  `assert_set_property`, `assert_readonly_property`, and `assert_property_with_backing_variable` have been added.
* To aid refactoring, `assert_property` and `assert_property_with_backing_variable` will warn if any "public accessors" are found for the property ('get_' and 'set_' methods).
* `assert_property` now requires an instance instead of also working with a loaded objects.
* Doubling strategy flags have been renamed to `INCLUDE_SUPER` (was `FULL`) and `SCRIPT_ONLY` (was `PARTIAL`).  The default is `SCRIPT_ONLY`.  These names may change again before release.  I wanted something more descriptive and less likely to be confused with partial doubles.
* Added support for a `skip_script` test-script variable.  This can be added to any test-script or inner-class causing GUT to skip running tests in that script.  The script will be included in the "risky" count and appear in the summary as skipped.  This was done to help porting tests to 4.0 but might stick around as a permanent feature.
```
var skip_script = 'The reason for skipping.  This will be printed in the output.'
```
* When using `yield_to`, `yield_for`, or `yield_frames` (deprecated) the new syntax is:
```
await yield_to(signaler, 'the_signal_name', 5, 'optional message')
await yield_for(1.5, 'optional message')
await yield_frames(30, 'optional message')
```
* The new `yield_` methods are `wait_seconds`, `wait_frames`, and `wait_for_signal`.
```
await wait_for_signal(signaler.the_signal, 5, 'optional message')
await wait_seconds(1.5, 'optional message')
await wait_frames(30, 'optional message')
```


### Implementation Changes
* The `Gut` control has been removed.  Adding a `Gut` node to a scene to run tests will no longer work.  This control dates back to Godot 2.x days.  With GUT 7.4.1 I believe the in-editor Gut Panel has enough features to discontinue using a Scene/`Gut` control to run tests.  Another approach for running tests in a deployed project will be added at some point.
* The GUI for GUT has been simplified to reflect that it is no longer used to run tests, just display progress and output.  It has also been decoupled from `gut.gd`.  `gut.gd` is now a `Node` instead of a `Control` and all GUI logic has been removed.  New signals have been added so that a GUI can be made without `gut.gd` having to know anything about it.  As a result, GUT can now be run without a GUI if that ever becomes something we want to do.
* Replaced the old `yield_between_tests` flag with `paint_after`.  This property (initially set to .1s) tells GUT how long to wait before it pauses for 1 frame to allow for painting the screen.  This value is checked after each test, so longer tests can still cause a delay in the painting of the screen.  This has made the painting a little choppier but has cut down the time it takes to run tests (200 simple tests in 20 scripts dropped from 2+ seconds to .5 seconds to run).  This feature is settable from the command line, .gutconfig.json, and GutPanel.
* The doubling implementation has changed significantly but usage has remained the same.



## setget vs set: and get:
In godot 4.0 `setget` has been replaced with `set(val):` and `get():` psuedo methods which make properties more concrete.  This is a welcome change, but comes with a few caveats.

Here's an example of usage:
```
var foo = 10:
    get():
        return foo
    set(val):
        foo = val
```
This means you no longer need to define methods for your accessors.  Though you may still want to for organizational purposes.

One downside to this approach is that there is no way to set the `foo` without going through the accessor.  Many times, internally, you will want to set a value for a property without going through the setter.  This is still possible, but you have to make a backing variable.
```
var _foo = 10
var foo = 10:
    get():
        return _foo
    set(val):
        _foo = val
        foo_changed.emit()
```
With this approach you can set `_foo` internally in your class without triggering the `foo_changed` signal.  When you see `foo =` anywhere in your code, it will be going through the accessor.  When you see `_foo =` you are only setting the backing variable.

To test this new paradigm `assert_setget` has been removed.  `assert_property` has changed to work with the new syntax.  Added `assert_property_with_backing_variable` to validate the backing variable wiring....etc.

`assert_property` will generate a warning when it finds "public" accessors for these properties (`get_foo`, `set_foo`).
