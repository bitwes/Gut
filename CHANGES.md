# Release notes
All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

# 4.1.0
- Added the ability to assert that signals did or did not fire.  By calling `watch_signals` Gut will monitor any signals emitted by the object.  You can then later make assertions about whether or not a signal was emitted or whether it emitted a desired number of times, and even if it was emitted and passed specific parameters.  You can also verify that the signal was emitted with the right parameters.  The following methods were added for this feature, see the README for more information about them.
	- `watch_signals`
	- `assert_signal_emitted`
	- `assert_signal_not_emitted`
	- `assert_signal_emitted_with_parameters`
	- `assert_signal_emit_count`
	- `assert_has_signal`
	- `get_signal_emit_count`
	- `get_signal_parameters`
- Some minor fixes to `gut.p`
	- It now performs a `str` on the input.  So if you pass it an object or something that isn't a string it won't blow up.
	- It now indents multi-line input correctly.
# 4.0.0
### Breaking Changes from 3.0.x and earlier

Before upgrading, remove gut.gd and gut_cmdln.gd from your your current project.  That will help ensure that you got everything setup right with the new install location.

0.  The install location has changed to `res://addons/gut`.  So you'll want to clean out wherever you had it previously installed.
0.  You'll want to update your existing scene to use the new plugin object.  Follow the new install instructions. <br>
__Note:__  just about everything you had to code to get your main testing scene running can now be configured in the Editor.  Select the Gut node and the options will appear in the Inspector.  Your existing code will work with the new custom node but using the Editor greatly simplifies things.
0.  The object that all test scripts must extend has changed to `res://addons/gut/test.gd`.
0.  All examples and tests for Gut itself have been moved to the new repo https://github.com/bitwes/GutTests/

### Other Changes
- I think there were other changes that went into this but I started keeping a change log with 4.0.1.  If it is really important to you then you could probably figure it out through the history.

# Earlier versions
- I didn't track changes for earlier versions.  I know I should have.  Trust me, you can't make me feel any worse about it so just get off my back already.
