# Release notes
All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).


# 9.1.0 (requires Godot 4.1)
* GUT generated errors now cause tests to fail (not engine errors, just things GUT thinks are bad).  You can disable this through the CLI, .gutconfig, or the panel.
* Changes to Double Strategy and Double/Partial Double creation to fix #482.
    * See [Double-Strategy](https://bitwes.github.io/GutWiki/Godot4/Double-Strategy.html) in the wiki for more information.
    * The default strategy has been changed back to `SCRIPT_ONLY` (a bug caused it to change).  Due to how the Godot Engine calls native methods, the overrides may not be called by the engine so spying and stubbing may not work in some scenarios.
    * Doubling now disables the Native Method Override warning/error when creating Doubles and Partial Doubles.  The warning/error is turned off and then restored to previous value after a Double or Partial Double has been loaded.
    * The doubling strategy `INCLUDE_SUPER` has been renamed to `INCLUDE_NATIVE`.
    * If you have an invalid Double Strategy set via command line or gutconfig, the default will be used.  So if you are explicity setting it to the old `INCLUDE_SUPER`, it will use `SCRIPT_ONLY`.
    * You can now set the default double strategy in the GutPanel in the Editor.
* Added `GutControl` to aid in running tests in a deployed game.  Instructions and sample code can be found [in the wiki](https://bitwes.github.io/GutWiki/Godot4/Running-On-Devices.html).
* __Issue 485__ GUT prints a warning and ignores scripts that do not extend `GutTest`.
* A lot of internal reworkings to simplify logging and info about test statuses.  The summary changed and the final line printed by GUT is now the highest severity status of the run (i.e. failed > pending/risky > passed).
* __Issue 503__ Fixed issue where GUT would not find script object when doubling PackedScenes.


# 9.0.1
* Fix #475, you can now double scripts that use the new accessors.


# 9.0.0
9.0.0 is the first version of GUT released for Godot 4.  Any version below 9.0.0 is for 3.x.  See the [GODOT_4_README.md](https://github.com/bitwes/Gut/blob/godot_4/GODOT_4_README.md) in the `godot_4` branch for changes to GUT from 3.x.

The wiki has not been updated yet for GUT 9.0.0, but it has been moved to the `godot_4` branch so it can be edited via this repo.  Changes to the wiki will be pushed to https://bitwes.github.io/GutWiki/Godot4/.
