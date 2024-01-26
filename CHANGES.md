# Release notes
All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).


# 9.2.0
## Features
* The Settings Subpanel now has on/off switches for directories, so you can turn them off if you want to run a subset of tests.

## Bug Fixes
* Documentation and branch changes.
* __Issue__ #536 Theme refernces font instead of embedding it.
* __Issue__ #523 "got" values are printed with extra precision for float, Vector2, and Vector3 when using `assert_almost_eq`, `assert_almost_ne`, `assert_between` and `assert_not_between`.
* __Issue__ #436 Doubled Scenes now retain export variable values that were set in the editor.
* __Issue__ #547 The output_font_name and output_font_size for the GutPanel are now saved.
* __PR__ #544 (@xorblo-doitus) InputSender will now emit the `gui_input` signal on receivers.
* __Issue__ #473 Moved gut panel settings and gut options out of res:// so that multiple devs won't fight over files that are really user preferences.
    * Created some Editor Preferences for Gut to handle user only settings.
    * When running GUT from the editor, the config used by the runner is saved to `user://` now.
    * You can load and save configs through the editor, so you can have a base set of settings that are not overwritten when running Gut.
    * Moved all files that Gut creates in `user://` to `user://gut_temp_directory`.
    * Output Subanel related settings have moved to the Output Subpanel.  Use the "..." button.
* __Issue__ #557 Tests are now found in exported projects.
* Fixed issue where the panel was not setting the double strategy correctly.



# 9.1.1
* Fixed numerous issues with doubling that were caused by the port from 3.x.  Most of these involved using the INCLUDE_NATIVE doubling strategy.
* Added errors and better failure messages when trying to stub or spy on an invalid method.  For example, if your script does not implement `_ready` and you try to spy on it, your test will now fail since `_ready` is virtual and you didn't overload it.
* Doubled methods that have a vararg argument are now auto detected and extra parameters (up to 10) are added to the method signature to handle most use cases (i.e. `rpc_id`, `emit_signal`).  If you call a doubled method that has a vararg argument and you have not stubbed `param_count` on the object's script then a warning is generated.
* Fixed an issue where command line would not launch in 4.2rc1.
* __Issue #510__ Added all types to strutils to address #510.
* __Issue #525__ Signals are now disconnected when waiting on signals that do not fire in the expected amount of time.

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
* __Port PR 409__ GUT's simulate function can now check `is_processing` and `is_physics_processing` when running thier respective methods.


# 9.0.1
* Fix #475, you can now double scripts that use the new accessors.


# 9.0.0
9.0.0 is the first version of GUT released for Godot 4.  Any version below 9.0.0 is for 3.x.  See the [GODOT_4_README.md](https://github.com/bitwes/Gut/blob/godot_4/GODOT_4_README.md) in the `godot_4` branch for changes to GUT from 3.x.

The wiki has not been updated yet for GUT 9.0.0, but it has been moved to the `godot_4` branch so it can be edited via this repo.  Changes to the wiki will be pushed to https://bitwes.github.io/GutWiki/Godot4/.
