# !! Not Updated for GUT 9.0.0 Yet !!
# <a name="gut_settings"> Gut Settings
These settings are for the GUT node that can be added to a scene.  The most common scenario for using a scene (now that we have the GutPanel) is to run tests in a depoloyed build.  These are not the settings for the in-editor GutPanel.  Mouse over settings in the GutPanel for description.

When using a GUT node in a scene, the following settings can be found in the Inspector.
| Setting | Description|
| --- | --- |
| Run On Load|  Flag to indicate if Gut should start running tests when loaded.|
|Should Maximize|Flag to maximize the Gut window upon launch.|
|Select Script|Select the named script in the drop down.  When this is set and "Run On Load" is true, only this script will be run.|
|Tests Like|Only tests that contain the set text will be run initially.|
|Should Print To Console|Print output to the console as well as to Gut.|
|Log Level|Set the level of output.|
|Yield Between Tests|A short yield is performed by Gut so that the Gut control has a chance to redraw.  This increases execution time by a tiny bit, but stops Gut from appearing to be hung up while it runs tests.|
|Disable Strict Datatype Checks|All asserts check datatypes before making comparisions to avoid runtime errors.  Disabling this was added for backwards compatability.|
|Test Prefix|The prefix used on all test functions.  This prefixed will be used by Gut to find tests inside your test scripts.|
|File Prefix|The prefix used on all test files.  This is used in conjunction with the Directory settings to find tests.|
|File Suffix|This is the suffix it will use to find test files (must include the ".gd" extension).|
|Inner Class Prefix|This is the prefix that Gut will use to find Inner Classes that are test scripts.|
|Inner Class Name|Only run Inner Classes that have names that contain the specified string.|
|Include Subdirectories|Include subdirectories when looking for tests.  This applies to the 6 "Directory" settings.|
|Directory(1-6)|The path to the directories where your test scripts are located.  If you need more than six directories you can use the `add_directory` method to add more.|
|Color Output| Unix style escape codes can be used for some color formatting of the ouput to the console.  This doesn't work with the Godot console so it is disabled by default in the editor but is enabled by default when using the command line tool.|
|Pre-run script| Path to a script that will run before all tests are ran.  See [Hooks](Hooks)|
|Post-run script| Path to a script that will run after all tests are ran.  See [Hooks](Hooks)|
|Junit Xml File | Gut will export test results in the JUnit XML format to this file when set.|
|Junit Xml Timestamp| If checked, Gut will insert an epoch timestamp into the "Junit Xml File" filename.|


## <a name="gut_methods"> Methods for Configuring the Execution of Tests
__When interacting with the GUT scene you must wait until it has completed initialization.  GUT will emit the `gut_ready` signal.  Do not interact with GUT until this signal has been emitted.__

These methods would be used inside the scene you created at `res://test/tests.tcn`.  These methods can be called against the Gut node you created.  Most of these are not necessary anymore since you can configure Gut in the editor but they are here if you want to use them.


<i>__**__ indicates the option can be set via the editor</i>
* `add_script(script, select_this_one=false)` add a script to be tetsted with test_scripts
* __**__`add_directory(path, prefix='test_', suffix='.gd')` add a directory of test scripts that start with prefix and end with suffix.  Subdirectories not included.  This method is useful if you have more than the 6 directories the editor allows you to configure.  You can use this to add others.
* __**__`test_scripts()` run all scripts added with add_script or add_directory.  If you leave this out of your script then you can select which script will run, but you must press the "run" button to start the tests.
* `test_script(script)` runs a single script immediately.
* __**__`select_script(script_name)` sets a script added with `add_script` or `add_directory` to be initially selected.  This allows you to run one script instead of all the scripts.  This will select the first script it finds that contains the specified string.
* `get_test_count()` return the number of tests run
* `get_assert_count()` return the number of assertions that were made
* `get_pass_count()` return the number of tests that passed
* `get_fail_count()` return the number of tests that failed
* `get_pending_count()` return the number of tests that were pending
* __**__`get/set_should_print_to_console(should)` accessors for printing to console
* `get_result_text()` returns all the text contained in the GUI
* `clear_text()` clears the text in the GUI
* `set_ignore_pause_before_teardown(should_ignore)` causes GUI to disregard any calls to pause_before_teardown.  This is useful when you want to run in a batch mode.
* __**__`set_yield_between_tests(should)` will pause briefly between every 5 tests so that you can see progress in the GUI.  If this is left out, it  can seem like the program has hung when running longer test sets.
* __**__`get/set_log_level(level)` see section on log level for list of values.
* __**__`disable_strict_datatype_checks(true)` disables strict datatype checks.  See section on "Strict type checking" before disabling.
* __**__ `maximize()` maximizes the gut window.
* __**__ `get/set_include_subdirectories(should)` flag to include subdirectories when `add_directory` is called.  This is `false` by default.

# <a name="extras"> Extras

##  <a name="strict"> Strict type checking
Gut performs type checks in the asserts when comparing two different types that would normally cause a runtime error.  With the type checking enabled (on be default) your test will fail instead of crashing.  Some types are ok to be compared such as Floats and Integers but if you attempt to compare a String with a Float your test will fail instead of blowing up.

You can disable this behavior if you like by calling `disable_strict_datatype_checks(true)` on your Gut node or by clicking the checkbox to "Disable Strict Datatype Checks" in the editor.

##  <a name="output_detail"> Output Detail
The level of detail that is printed to the screen can be changed using the slider on the dialog or by calling `set_log_level` with one of the following constants defined in Gut

* LOG_LEVEL_FAIL_ONLY (0)
* LOG_LEVEL_TEST_AND_FAILURES (1)
* LOG_LEVEL_ALL_ASSERTS (2)

##  <a name="printing"> Printing info
The `gut.p` method allows you to print information that is indented under the test output.  This output appears wherever GUT sends output (gui, terminal, console).  It has an optional 2nd parameter that sets which log level to display it at.  Use one of the constants in the section above to set it.  The default is `LOG_LEVEL_FAIL_ONLY` which means the output will always be visible.
```
# From within your tests
gut.p('hello')
gut.p('world', gut.LOG_LEVEL_ALL_ASSERTS)
```
