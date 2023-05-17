__NOTE__ Do not use the in-editor __GUT toolbar__ to run tests for GUT.  I recommend using the command line or `main.tscn` instead.  There are notes below if you really want to try, but it crashes a lot and the plugin needs to be reloaded often.


# Checklist for PRs
* Open PRs against `master` unless there's a reason not to.
* PRs __must have unit tests__.  See sections below.
* Include any wiki text in the PR.  You cannot make PRs against the wiki so this is probably the best approach.  You can also NOT include wiki text and I'll add it, no problem.  Any typing you can save me is wonderful.
* CHANGES.md
  * I will take care of making any changes to CHANGES.md.
  * I will credit you in the CHANGES.md.  If you have a handle you would like me to use (other than your GitHub username) then let me know in the PR

# Creating Tests for GUT
#### All GUT tests are found in
* `res://test/unit`
* `res://test/integration`

Edit existing scripts or add new ones there.

#### Any resources needed by tests should be placed in:
* `res://test/resources`

If you don't see an existing directory that matches your needs then you can create a new directory or place them directly in `res://test/resources`.


# Running GUT Tests
__Do not__ use the GUT Panel to run tests (at least in 3.3.2).  Godot doesn't seem to like using GUT inside GUT.  You can try, but you'll probably not like it.

I've found that using VSCode and the VSCode plugin "gut-extension" is the easiest way to run tests as you develop your feature.  Mostly because you can have more than one file on the screen at a time.  If you do not care for VSCode then I'd suggest using the command line to avoid having to switch scenes.  A `.gutconfig.json` is already included in the project so you should be able to run tests with no config changes.

If you are more of a Godot IDE fan then use `main.tscn` to run your tests. This scene includes a handy "Run Gut Unit Tests" button that will kick off all the essential test scripts.  This button might be hiding behind the GUT Node when you run the scene.  You may have to change the options for the GUT node in `main.tscn` to run specific tests if you don't use "Run Gut Unit Tests" button.


# GUT Panel issues
When developing the GUT Panel (against version Godot 3.3.2) I had bunch of problems.  These only occurred when attempting to use the GUT Panel within the GUT project.  I have not seen these issues when using the panel in other projects.

__reload the plugin__  = Go to Project Settings->Plugins Tab.  Uncheck then check "enabled" for Gut.

##### Godot crashes upon running tests.
Sometimes Godot will crash and burn hard when using the various "run" buttons on the GUT panel.

I found that closing `main` scene upon entering Godot (and before running tests) helps here.  You may have to reload the plugin after doing so.

##### The GUT Panel doesn't do anything.
Sometimes when you edit GUT files, the plugin doesn't like it.  Reload the plugin.

##### If you see this in the IDE Output
```
res://addons/gut/gui/GutBottomPanel.gd:### - Invalid get index '<whatever>' (on base: 'Nil').
```
Then reload the plugin.
