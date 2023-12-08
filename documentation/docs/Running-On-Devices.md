# Running on Devices
You may find yourself wanting to run your tests on an Android or iOS device or you may want your testers to run the tests on their device.  To do this you will have to give the users access to the GUT instance through your GUI and you'll have to export your tests.  You can also enable file logging so that if running the tests causes a crash you can still get to the output from the run.

## Godot 3.1+ Export As Text
In Godot 3.1 an old 2.x feature was reintroduced that allows you to export your scripts as text.  Normally Godot will compile your tests and GUT cannot parse compiled tests.  If you change the setting below then GUT will be able to find and parse all your tests when the project is exported.

Just change the following setting in your exports settings form `compiled` to `text`
[[https://raw.githubusercontent.com/wiki/bitwes/Gut/images/export_as_text.png|alt=export_as_text]]

If you don't want to pass out your code in plain text or you are using Godot 3.0, then you can use the next section to export your tests.

## Exporting Compiled/Encrypted/Godot 3.0 Tests
When you export your project, all the scripts get compiled and Gut cannot parse them anymore.  To address this Gut has some methods and settings that make it possible to run your tests on any device.

Exporting is only supported through a scene since there is no built-in way to run the tests in your exported game via the command line.  To that end, you will have to have a scene in your game that has a Gut node (See the Setup section on the Install page).  I'm going to assume the node name is `$Gut`.

## Configuring Gut to Export
Select the Gut node and set the and set the `Export Path` setting in the Inspector.  This must be a file in the `res://` directory.  I've been using `res://test/exported_tests.cfg`.  This way the file won't be included when you create a production export which, of course, excludes the `test` directory from the build.

You must also be sure that your project is configured to export files with the extension you give in the setting.
* Click Project->Export
* Select the Preset to configure.
* Under the Resources tab make sure that `*.cfg` is in the list (or whatever extension you used when setting `Export Path`).
```
*.txt, *.cfg
```

## Auto Export/Import
__When interacting with the GUT scene you must wait until it has completed initialization.  GUT will emit the `gut_ready` signal.  Do not interact with GUT until this signal has been emitted.__

Gut has a couple of methods that should allow you to automatically export and import your settings in most cases.  They are:
* `export_if_tests_found()`
* `import_tests_if_none_found()`

When you add these methods to the `_ready()` of your scene then Gut should take the proper action based on whether you are running from the editor or on some other device.
```
func _on_gut_ready():
  # always put them in this order
  $Gut.export_if_tests_found()
  $Gut.import_tests_if_none_found()
```
Both methods will either print an error if something went wrong or a complete list of everything they exported/imported and the name of the file it used.

Both of these methods __require__ that the `Export Path` property has been set.  The `gut_ready` signal will be emitted after Gut has loaded up all the directories you have configured in the editor.  If Gut has found tests it was able to parse then `export_if_tests_found` will write them to the `Export Path`.  If it cannot find any tests then the `import_tests_if_none_found` line will load the file at `Export Path` and all your tests will be ready to go.

__NOTE__:  It is recommended that you do not configure your scene to `Run On Load` when you are exporting your tests.  If a test causes a crash on a device, then you won't be able to use the GUI to run other tests, it will just run until it crashes.

## Manually Exporting/Importing
Gut also has methods that you can use to have full control over when and where you export/import tests.
* `set/get_export_path(...)`
* `export_tests(path=export_path)`
* `import_tests(path=export_path)`

`export_tests` and `import_tests` will use any path you give them or the value set by `set_export_path` if no path is passed.

## Logging and Viewing Logs
If you enable file logging in ProjectSettings->Logging->FileLogging then output will be put into the `user://logs` directory by default.  GUT has a built-in file viewer in the extra options button on the right of the dialog.  This allows you to view logs or any other user file from GUT.

[[https://raw.githubusercontent.com/wiki/bitwes/Gut/images/view_user_files.png|alt=view_user_files]]
