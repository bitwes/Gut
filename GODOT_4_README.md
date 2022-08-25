# Porting GUT to Godot 4.0



## Overview
GUT is currently not yet usable in 4.0.  Some features work, but many do not.

This file tracks the changes that have occurred in porting GUT to Godot 4.0.  All issues related to the conversion have the [Godot 4.0](https://github.com/bitwes/Gut/issues?q=is%3Aissue+is%3Aopen+label%3A%22Godot+4.0%22) tag.

## Godot 4 Changes
These are changes to Godot that affect how GUT is used/implemented.

* `setget` has been replaced with a completely new syntax.  More info at [#380](/../../issues/380).
* `connect` has been significantly altered.  The signal related asserts will likely change to use `Callable` parameters instead of strings.  It is possible to use strings, so this may remain in some form.  More info in [#383](/../../issues/383).
* `yield` has been replaced with `await`.  `yield_to`, `yield_for`, and `yield_frames` will be replaced with similar `await` methods.  The `yield_*` methods will be deprecated.  More info at [#382](/../../issues/382).


## Changes
* Any methods that were deprecated in GUT 7.x have been removed.
* The `Gut` control has been removed.  Adding a `Gut` node to a scene to run tests will no longer work.  This control dates back to Godot 2.x days.  With GUT 7.4.1 I believe the in-editor Gut Panel has enough features to discontinue using a Scene/`Gut` control to run tests.  Another approach for running tests in a deployed project will be added at some point.
* Added support for a `skip_script` test-script variable.  This can be added to any test-script or inner-class causing GUT to skip running tests in that script.  The script will be included in the "risky" count and appear in the summary as skipped.  This was done to help porting tests to 4.0 but might stick around as a permanent feature.
```
var skip_script = 'The reason for skipping.  This will be printed in the output.'
```
* The GUI for GUT has been simplified to reflect that it is no longer used to run tests, just display progress and output.  It has also been decoupled from `gut.gd`.  `gut.gd` is now a `Node` instead of a `Control` and all GUI logic has been removed.  New signals have been added so that a GUI can be made without `gut.gd` having to know anything about it.  As a result, GUT can now be run without a GUI if that ever becomes something we want to do.
* Replaced the old `yield_between_tests` flag with `paint_after`.  This property (initially set to .1s) tells GUT how long to wait before it pauses for 1 frame to allow for painting the screen.  This value is checked after each test, so longer tests can still cause a delay in the painting of the screen.  This has made the painting a little choppier but has cut down the time it takes to run tests (200 simple tests in 20 scripts dropped from 2+ seconds to .5 seconds to run).  This feature is settable from the command line, .gutconfig.json, and GutPanel.
* assert_setget has been removed (all uses will cause the test to fail).  `assert_property` has been altered to work with the new setter/getter syntax.  `assert_set_property`, `assert_readonly_property`, and `assert_property_with_backing_variable` have been added.
