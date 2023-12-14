# Contributing
Here at the GUT Mega, we don't have to time to do everything

## Checklist for PRs
* Open PRs against `main` for Godot 4 issues, or the `godot_3x` branc for Godot 3 issues.
* PRs __must have unit tests__.  See sections below.
* Include any wiki text in the PR.
  * Info about documentation changes can be found in `documentation/README.md`.
* CHANGES.md
  * I will take care of making any changes to CHANGES.md.
  * I will credit you in the CHANGES.md.  If you have a handle you would like me to use (other than your GitHub username) then let me know in the PR

## Creating Tests for GUT

### All GUT tests are found in
* `res://test/unit`
* `res://test/integration`

Edit existing scripts or add new ones there.

### Any resources needed by tests should be placed in:
* `res://test/resources`

If you don't see an existing directory that matches your needs then you can create a new directory or place them directly in `res://test/resources`.


## Running GUT Tests
Due to the nature of using the tool to test the tool, there are some tests that are expected to fail.  The message for failing tests will indicate that they are expected to fail.

I've found that using VSCode and the VSCode plugin "gut-extension" is the easiest way to run tests as you develop your feature.  Mostly because you can have more than one file on the screen at a time.  If you do not care for VSCode then I'd suggest using the command line to avoid having to switch scenes.  A `.gutconfig.json` is already included in the project so you should be able to run tests with no config changes.


### The GUT Panel doesn't do anything.
Sometimes when you edit GUT files, the plugin doesn't like it.  Reload the plugin.

### If you see this in the IDE Output
```
res://addons/gut/gui/GutBottomPanel.gd:### - Invalid get index '<whatever>' (on base: 'Nil').
```
Then reload the plugin.
