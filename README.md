# [See the Wiki for Details](https://github.com/bitwes/Gut/wiki)

# 6.6.0 has a potentially bad bug, please install 6.6.2
6.1.0 has a bug that can, if everything goes wrong just right, delete files in the root of the project.  I only saw it happen when running the test suite for Gut and only the `test_doubler.gd` test script.  I don't recall ever seeing it happen in my own game, but just to be safe you should upgrade.

### Godot 3.1
I've started a [3.1 branch](https://github.com/bitwes/Gut/tree/godot_3_1) that I will be keeping inline with master.  Check open issues (they will have the 3.1 tag) and the [3.1 wiki page](https://github.com/bitwes/Gut/wiki/Godot-3.1-Alpha) for any known issues.

# Gut 6.6.2
GUT (Godot Unit Test) is a utility for writing tests for your Godot Engine game.  It allows you to write tests for your gdscript in gdscript.

More info can be found in the [wiki](https://github.com/bitwes/Gut/wiki).

### Godot 3.0 Compatible.
Version 6.0.0 is Godot 3.0 compatible.  These changes are not compatible with any of the 2.x versions of Godot.  The godot_2x branch has been created to hold the old version of Gut that works with Godot 2.x.  Barring any severe issues, there will not be any more development for Godot 2.x.

# License
Gut is provided under the MIT license.  License is in `addons/gut/LICENSE.md`

# Getting Started
Here's a short setup tutorial provided by Rainware https://www.youtube.com/watch?v=vBbqlfmcAlc

Here's a couple more [wiki](https://github.com/bitwes/Gut/wiki) links to get you started.
* [Install](https://github.com/bitwes/Gut/wiki/Install)
* [Creating Tests](https://github.com/bitwes/Gut/wiki/Creating-Tests)
* [Methods](https://github.com/bitwes/Gut/wiki/Methods)

# [See the Wiki for Details](https://github.com/bitwes/Gut/wiki)
