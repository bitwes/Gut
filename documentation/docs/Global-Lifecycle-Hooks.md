# Global Lifecycle Hooks

## Disclaimer

This page describes workarounds for missing features in GUT
that are not planned to be long term solutions.
Eventually this same functionality will be available
through a more formally supported system.

## Overview

GUT does not expose "global" function hooks that can be run before each test script or method
-- while GutTest exposes [hooks](Creating-Tests.md#details)
to run code before/after each test method/class,
these must be set on every GutTest instance you want the behavior for.

However, GutMain _does_ expose <a href="class_ref/class_gutmain.html#signals">signals</a>
that have the same effect on a global level,
being emitted at the beginning/end of all test scripts/methods.
By connecting custom functions to these signals during the [Pre-Run Hook](Hooks.md#pre-run-hook),
you can call custom code in hooks across every GutTest instance while defining it only once.
Following is an example of how you would write a pre-run hook script to set up a global setup function.

```gdscript
extends GutHookScript

func run():
    gut.start_test.connect(_on_test_started)

func _on_test_started(test_name):
    # setup logic run before every test in every test script goes here
```

## Signal Order

It may be important to note the order in which the normal GutTest hooks are run
and the GutMain signals are emitted.
The order of the signals and hooks is as follows:

1. signal `start_script` (once per test script)
1. hook `before_all` (once per test script)
1. hook `before_each` (once per test method)
1. signal `start_test` (once per test method)
1. hook `after_each` (once per test method)
1. signal `end_test` (once per test method)
1. hook `after_all` (once per test script)
1. signal `end_script` (once per test script)

## Example

In this example pre-hook script,
functions are connected to each of the lifecycle hooks
to use the names of test methods and files as a test is run.

```gdscript
extends GutHookScript

const NO_TEST := "__NO_TEST__"
var _current_test_script_object = null
var _current_collected_script = null
var _current_test_name := NO_TEST

func run():
    gut.start_run.connect(_on_run_started)
    gut.start_script.connect(_on_script_started)
    gut.start_test.connect(_on_test_started)
    gut.end_test.connect(_on_test_ended)
    gut.end_script.connect(_on_script_ended)
    gut.end_run.connect(_on_run_ended)

    # Do pre-run stuff here

# This might be redundant, and it might have already been emitted by the time
# this hook is called.  I wanted it in here for illustration purposes.
func _on_run_started():
    pass

# This is passed an instance of res://addons/gut/collected_script.gd.  It is not
# the instance of the script that will be run.  You can get to the script object
# using `load_script`, but you can't get to the actual instance that will be
# run.
func _on_script_started(collected_script):
    _current_collected_script = collected_script
    # The GutTest script, not the instance.
    _current_test_script_object = collected_script.load_script()
    # _current_collected_script.get_full_name() returns the path of the file
    # that contains the test


# This is just the name of the test method being ran.
func _on_test_started(test_name):
    _current_test_name = test_name


func _on_test_ended():
    # example of inspecing the test that ended if you wanted to.
    var failed = _current_collected_script.get_test_named(_current_test_name).is_failing()
    if (failed):
        print(_current_test_name + " failed")
    else:
        print(_current_test_name + " passed")

    _current_test_name = NO_TEST


func _on_script_ended():
    #example of inspecing the script that ended if you wanted to
    if(!_current_collected_script.was_skipped):
        if(_current_collected_script.get_fail_count() > 0):
            print("The script ", _current_collected_script.get_full_name(), " failed")
        else:
            print("The script ", _current_collected_script.get_full_name(), " passed")

    _current_collected_script = null
    _current_test_script_object = null


# I'm not sure if this is called before or after the post-run hook.  This can't
# do everything a post-run hook can do, but it might be enough for this.
func _on_run_ended():
    pass
    # Do "after_every" things here.
```

## Related Material

The `start_script` signal contains an object `test_script_obj` which is an instance of
the [collected_script.gd](https://github.com/bitwes/Gut/blob/main/addons/gut/collected_script.gd) class,
which may be found at `addons/gut/collected_script.gd`.
This class is not intended for public consumption,
so use this value at your own risk.

## Improvements

The GutMain signals were not originally intended to be used for this purpose
(the astute may observe that the ordering of signals and hooks is not particularly orderly).
Plans for a new system of hooks created for this purpose
were considered [here](https://github.com/bitwes/Gut/pull/804#issuecomment-3929695342),
but further input and consideration of the matter would be appreciated
-- if you've got an idea, open an issue about it!
