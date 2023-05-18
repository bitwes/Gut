# Release notes
All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).


# 9.1.0
* Fix #482:  Doubling now disables the Native Method Override warning/error when creating doubles.  The warning/error is turned off and then restored to previous value after a Double or Partial Double has been loaded.  The doubling strategy INCLUDE_SUPER has been renamed to INCLUDE_NATIVE.  INCLUDE_NATIVE is the default (still).  Due to how the Godot Engine calls native methods, the overrides may not be called by the engine so spying and stubbing may not work in some scenarios.  See Double-Strategy in the wiki for more information.



# 9.0.1
* Fix #475, you can now double scripts that use the new accessors.

# 9.0.0
9.0.0 is the first version of GUT released for Godot 4.  Any version below 9.0.0 is for 3.x.  See the [GODOT_4_README.md](https://github.com/bitwes/Gut/blob/godot_4/GODOT_4_README.md) in the `godot_4` branch for changes to GUT from 3.x.

The wiki has not been updated yet for GUT 9.0.0, but it has been moved to the `godot_4` branch so it can be edited via this repo.  Changes to the wiki will be pushed to https://bitwes.github.io/GutWiki/Godot4/.
