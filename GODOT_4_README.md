# Porting GUT to Godot 4.0



## Overview
Ported to Godot 4 RC 2

GUT is currently somewhat usable in 4.0.  Some features work, but many do not.  The CLI works, but the in-editor panel does not.

This file tracks the changes that have occurred in porting GUT to Godot 4.0.  All issues related to the conversion have the [Godot 4.0](https://github.com/bitwes/Gut/issues?q=is%3Aissue+is%3Aopen+label%3A%22Godot+4.0%22) tag.

<ins>Current results of all GUT tests</ins>

```
Totals
Scripts:          48
Passing tests     1062
Failing tests     8
Risky tests       16
Pending:          29
Asserts:          1671 of 1686 passed

Warnings/Errors:
* 15 Errors.
* 35 Warnings.
* 4 Deprecated calls.

1057 passed 12 failed.  Tests finished in 149.371s
```



## Contributing
Pull requests are welcome.  You can look at the [Godot 4.0](https://github.com/bitwes/Gut/issues?q=is%3Aissue+is%3Aopen+label%3A%22Godot+4.0%22) issues for items that need to be addressed.  If you find something that is not mentioned, please make an issue.  There are also a lot of pending and failing tests that need to be addressed.

Running tests for GUT requires using the CLI or VSCode plugin currently.

Read the "Working" and "Broken" features section before starting.  There are some major features that are not working.  These features might be required before other features can be fixed.  `yield`/`await` and doubling inner classes are big ones.

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
* `File` and `Directory` have been replaced with `FileAccess` and `DirAccess`.





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
* Doubling Inner Classes has been fixed and all the tests have been restored.

## Broken Features
* Gut Panel.  The in-editor panel is not working, you must use the CLI or the VSCode plugin (which uses the cli) for now.
* Dictionary/array asserts are broke in some cases.  Godot 4 passes all arrays and dictionaries by reference now (arrays were by value, dictionaries were by reference).  This has broken a lot of the logic for comparing dictionaris, arrays, arrays in dictionaries, dictionaries in arrays.
* Probably somewhat more.



## Changes
### Usage
* Any methods that were deprecated in GUT 7.x have been removed.
* `assert_setget` no longer works (it now just fails with a message).  `assert_property` has been altered to work with the new setter/getter syntax.  `assert_set_property`, `assert_readonly_property`, and `assert_property_with_backing_variable` have been added.
* To aid refactoring, `assert_property` and `assert_property_with_backing_variable` will warn if any "public accessors" are found for the property ('get_' and 'set_' methods).
* `assert_property` now requires an instance instead of also working with a loaded objects.
* Doubling strategy flags have been renamed to `INCLUDE_SUPER` (was `FULL`) and `SCRIPT_ONLY` (was `PARTIAL`).  The default is `SCRIPT_ONLY`.  These names may change again before release.  I wanted something more descriptive and less likely to be confused with partial doubles.
* Added support for a `skip_script` test-script variable.  This can be added to any test-script or inner-class causing GUT to skip running tests in that script.  The script will be included in the "risky" count and appear in the summary as skipped.  This was done to help porting tests to 4.0 but might stick around as a permanent feature.
```gdscript
var skip_script = 'The reason for skipping.  This will be printed in the output.'
```
* The various `yield_` methods have been deprecated but are still supported to make conversions easier.  The new syntax for `yield_to`, `yield_for`, or `yield_frames` is:
```gdscript
await yield_to(signaler, 'the_signal_name', 5, 'optional message')
await yield_for(1.5, 'optional message')
await yield_frames(30, 'optional message')
```
* The replacement methods for the various `yield_` methods are `wait_seconds`, `wait_frames`, and `wait_for_signal`.
```gdscript
await wait_for_signal(signaler.the_signal, 5, 'optional message') # wait for signal or 5 seconds
await wait_seconds(1.5, 'optional message')
await wait_frames(30, 'optional message')
```
* Doubling no longer supports paths to a script or scene.  Load the script or scene first and pass that to `double`.  See the "Doubling Changes" section for more details.
* Doubling Inner Classes now requires you to call `register_inner_classes` first.  See the "Doubling Changes" sedtion for more details.

### Comparing Dictionaries and Arrays
In Godot 3.x dictionaries were compared by reference and arrays were compared by value.  In 4.0 both are compared by value.  In Godot 4.0 you can compare dictionaries and arrays by reference using `is_same`.

GUT honored the default comparing logic in 3.x, so it does the same in 4.0.  This means that `assert_eq` will use Godot's `==` logic for dictionaries and arrays (comparing by value).  If you want to compare by reference you can use the new `assert_same` or `assert_not_same`.

The shallow compare functionanlity has been removed since it no longer applies.  Shallow compares would compare the elements of an array or dictionary by value.  In Godot 3.x this meant that dictionaries inside of arrays or dictionaries would be compared by reference.  Since everything is compared by value now, shallow compares do not apply.  The following methods have been removed.  Calling these methods will generate a failure and a warning.
* `compare_shallow`
* `assert_eq_shallow`
* `assert_ne_shallow`



### Doubling Changes
#### Doubling scripts and scenes
The `double` method no longer supports paths to scripts or scenes.  You should `load` the script or scene first, and then pass that to `double` instead.
```
var MyScript = load('res://my_script.gd')
var dbl = double(MyScript).new()
```
If you pass a string then an error message will be printed and `double` will return `null`.  This will most likely result in a runtime error when you attempt to instantiate your double.
```
'Invalid call. Nonexistent function 'new' in base 'Nil'.'
```

#### Doubling Inner Classes
The `double` method no longer supports strings for the path of the base script or a string of the name of the Inner Class.  You must call `register_inner_classes` then pass the Inner Class to `double`.  You only have to do this once, so it is best to call it in `before_all` or a pre-hook script.  Registering multiple times does nothing.  Failing to call `register_inner_classes` will result in a GUT error and a runtime error.
```gdscript
# Given that SomeScript contains the class InnerClass that you wish to to double:
var SomeScript = load('res://some_script.gd')

func before_all():
    register_inner_classes(SomeScript)

func test_foo():
    var dbl = double(SomeScript.InnerClass).new()
```
This approach was used to make tests cleaner and less susceptible to typos.  If Godot adds meta data to inner classes that point back to the source script, then `register_inner_classes` can be removed later and no other changes will need to be made.


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


## Implementation Changes
* The `Gut` control has been removed.  Adding a `Gut` node to a scene to run tests will no longer work.  This control dates back to Godot 2.x days.  With GUT 7.4.1 I believe the in-editor Gut Panel has enough features to discontinue using a Scene/`Gut` control to run tests.  Another approach for running tests in a deployed project will be added at some point.
* The GUI for GUT has been simplified to reflect that it is no longer used to run tests, just display progress and output.  It has also been decoupled from `gut.gd`.  `gut.gd` is now a `Node` instead of a `Control` and all GUI logic has been removed.  New signals have been added so that a GUI can be made without `gut.gd` having to know anything about it.  As a result, GUT can now be run without a GUI if that ever becomes something we want to do.
* Replaced the old `yield_between_tests` flag with `paint_after`.  This property (initially set to .1s) tells GUT how long to wait before it pauses for 1 frame to allow for painting the screen.  This value is checked after each test, so longer tests can still cause a delay in the painting of the screen.  This has made the painting a little choppier but has cut down the time it takes to run tests (200 simple tests in 20 scripts dropped from 2+ seconds to .5 seconds to run).  This feature is settable from the command line, .gutconfig.json, and GutPanel.
* Doubling has changed significantly.
