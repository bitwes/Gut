# <div class="warning">This page has not been updated for GUT 9.0.0 or Godot 4.  There could be incorrect information here.</div>
# Install
GUT is a Godot Plugin.  You can download it directly or install it from the Asset Lib in the Godot Editor.

## Installing from in-editor Godot Asset Lib
1.  Click the AssetLib button at the top of the editor
1.  Search for "Gut"
1.  Click it.
1.  Click "Install".  This will kick off the download.
1.  Click the 2nd "Install" button that appears when the download finishes.  It will be in a little dialog at the bottom of the AssetLib window.
1.  Click the 3rd "Install" button.
1.  You did it!

Finish the install by following the instructions in [Setup](#setup) below.

## Download and install
Download the zip from the [releases](https://github.com/bitwes/gut/releases) or from the [Godot Asset Library](https://godotengine.org/asset-library/asset/54).

Extract the zip and place the `gut` directory into your `addons` directory in your project.  If you don't have an `addons` folder at the root of your project, then make one and THEN put the `gut` directory in there.

Finish the install by following the instructions in Setup below.

# <a name="setup">Setup
#### Activate
1.  From the menu choose Project->Project Settings, click the Plugins tab and activate Gut.

#### Setup directories for tests
The next few steps cover the suggested configuration.  Feel free to deviate where you see fit.

1.  Create directories to store your tests and test related code (suggested config)
	* `res://test`
	* `res://test/unit`
	* `res://test/integration`

# Running Tests
## Run tests from the GUT Panel
As of 7.2.0 GUT supports running through the Editor.

Set the test directories in the settings panel (below) and click "Run All".  That's all there is to it.

[[https://raw.githubusercontent.com/wiki/bitwes/Gut/images/gut_panel.png|alt=gut_panel]]


## Run tests from the command line
GUT comes with a command line interface, more info can be found on the [Command Line](Command-Line) page.


## Run tests through VSCode
There is also a VSCode plugin that you can use to run tests directly from VSCode.  You can find the plugin and related documentation [here](https://github.com/bitwes/gut-extension).


## Run tests using a scene.
You can also create a scene to run your test scripts.  This can be useful for running tests in your deployed game, making it possible to run tests on the different devices you install your game on.  The configuration for the scene is separate from the GUT Panel and must be done in the Property Inspector for the GUT control.

1.  Create a scene that will use Gut to run your tests at `res://test/tests.tscn` (for example)
	* Add a Gut object the same way you would any other object.
	* Click "Add/Create Node"
	* type "Gut"
	* press enter.
1.  Configure Gut to find your tests.  Select it in the Scene Tree and set the following settings in the Inspector:
	* In the `Directory1` setting enter `res://test/unit`
	* In the `Directory2` setting enter `res://test/integration`

A full description of all GUT settings can be found [here](Gut-Settings-And-Methods).


## Where to next?
* [Creating Tests](Creating-Tests)<br/>
* [Command Line](Command-Line)
* [Gut Settings and Methods](Gut-Settings-And-Methods)
* [Quick Start](Quick-Start)

