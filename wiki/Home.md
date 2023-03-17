# Gut 7.4.0
GUT (Godot Unit Test) is a utility for writing tests for your Godot Engine game.  It allows you to write tests for your gdscripts in gdscript.

### Godot 3.2
* As of version 7.0.0 GUT requires Godot 3.2.  Version 6.8.x is 3.1 compatible.


# Getting Started
* [Quick Start](Quick-Start)
* [Install](Install)
* [Asserts and Methods](Asserts-and-Methods)
* [Creating Tests](Creating-Tests)
* [Gut Settings and Methods](Gut-Settings-And-Methods)
* [Using Gut at the command line](Command-Line)


# Advanced Testing
* [Inner Test Classes](Inner-Test-Classes)
* [Doubling](Doubles)
* [Spies](Spies)
* [Stubbing](Stubbing)
* [Parameterized Tests](Parameterized-Tests)
* [Simulate](Simulate)
* [Yielding during tests](Yielding)
* [Pre/Post Run Hooks](Hooks)
* [Exporting Results](Export-Test-Results)


# Editor GUI
[[https://raw.githubusercontent.com/wiki/bitwes/Gut/images/gut_panel.png|alt=gut_panel]]

# GUT GUI
[[https://raw.githubusercontent.com/wiki/bitwes/Gut/images/GutGui.png|alt=gutgui]]

1.  Output Box.
1.  List of Test Scripts.  Inner Classes are indented under scripts.
1.  Progress bars for all scripts and the current script.
1.  Log Level slider.
1.  Previous Script (in list of scripts)
1.  Run the currently selected script and all scripts after it.  This can be especially useful when running on another device and some script in the middle of the list causes a crash.  To run the tests after the crash, just select that test in the list and click this button.  It will run that one and all the ones after.
1.  Next Script (in list of scripts)
1.  Run the currently selected script.  If an Inner Class is selected then just that class will be run.  If a Script is selected then the script and all of its Inner Classes will be run.
1.  Toggle display of List of Test Scripts
1.  The Hamburger button.  It shows some additional options.
1.  Continue button will be enabled if a call to `yield_before_teardown` occurs.  Click it to continue running tests.
1.  The title bar.  It has a maximize button, shows the current script, has a running tally on the left of the pass/fail count, shows the elapsed time.  Also you can drag it all about.

Also, in the bottom right corner, you can drag to resize the dialog.


# Engine Warnings
There are a fair number of warnings that Godot will show related to GUT.  Some of the warnings are valid and are being cleaned up overtime.  Most of the warnings are not valid and sometimes relate to generated code.  As of 3.2 you can disable warnings for addons, and it recommended you do so.
[[https://raw.githubusercontent.com/wiki/bitwes/Gut/images/exclude_addons.png|alt=exclude_addons]]


# License
Gut is provided under the MIT license.  [The license is distributed with Gut so it is in the `addons/gut` folder](https://github.com/bitwes/Gut/blob/master/addons/gut/LICENSE.md).


# Contributing
[Contributing](Contributing)


# Who do I talk to?
You can talk to me, Butch Wesley

* Github:  bitwes
* Godot forums:  bitwes
* Godot Discord:  bitwes
