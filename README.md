# 6.6.0 has a potentially bad bug
__Please upgrade to the latest version.__

6.6.0 has a bug that can, if everything goes wrong just right, delete files in the root of the project.  I only saw it happen when running the test suite for Gut and only the `test_doubler.gd` test script.  I don't recall ever seeing it happen in my own game, but just to be safe you should upgrade.

# Gut 6.7.0
GUT (Godot Unit Test) is a utility for writing tests for your Godot Engine game.  It allows you to write tests for your gdscript in gdscript.

More info can be found in the [wiki](https://github.com/bitwes/Gut/wiki).

## Features
* Write unit/integration tests for your `gdscript` in `gdscript`.
* Godot 3.0 and 3.1 compatible (There are some minor issues with 3.1 though, [check them out here](https://github.com/bitwes/Gut/wiki/Godot-3.1-Issues).)
* [Simple install via the Asset Library.](https://github.com/bitwes/Gut/wiki/Install)
* [Doubling](https://github.com/bitwes/Gut/wiki/Doubles)
* [Stubbing](https://github.com/bitwes/Gut/wiki/Stubbing)
* [Spying](https://github.com/bitwes/Gut/wiki/Spies)
* [A plethora of asserts and utility methods to help make your tests simple and concise.](https://github.com/bitwes/Gut/wiki/Methods)
* [Export tests with your project and run them on any platform Godot supports.](https://github.com/bitwes/Gut/wiki/Exporting-Tests)
* [Command Line Interface (CLI)](https://github.com/bitwes/Gut/wiki/Command-Line)
* [Support for Inner Test Classes to give your tests some extra context and maintainability.](https://github.com/bitwes/Gut/wiki/Inner-Test-Classes)
* [Integration testing made easier with `yield`s](https://github.com/bitwes/Gut/wiki/Yielding)

## Upgrading to 6.7.0 from any 6.x version
* It is not required, but you should remove the existing Gut node for any scenes you have that use it and then re-add it and re-configure it.  Re-adding will get rid of the caution symbol next to the control (this is due to changes in inheritance, Gut changed from a `WindowDialog` to a `Control`)
* For the command line, note that the `log` option in the `.gutconfig.json` file has changed to `log_level` for consistency.

# License
Gut is provided under the MIT license.  License is in `addons/gut/LICENSE.md`

# Getting Started
Here's a short setup tutorial provided by Rainware https://www.youtube.com/watch?v=vBbqlfmcAlc

Here's a couple more [wiki](https://github.com/bitwes/Gut/wiki) links to get you started.
* [Install](https://github.com/bitwes/Gut/wiki/Install)
* [Creating Tests](https://github.com/bitwes/Gut/wiki/Creating-Tests)
* [Methods](https://github.com/bitwes/Gut/wiki/Methods)
