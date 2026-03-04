# TODO

Need to update the url to point to main branch before merging.


# Check for Update

## When are checks performed
Checks using the files on the filesystem are performed:
* When the Editor is launched to see if the current version is valid for the version of Godot being used.
* When the About box is shown.  This will display if an update is available as well.
* At the end of a run, a check is performed to display if an update is available.

## Downloading Remote File
The remote file will be downloaded when:
* Godot is launched and the local copy of the remote file is some number of days old (2 as of the writing of this).  This is done after the invalid check is performed on startup.
* The about box will display a link to "check for update" if the local copy of the remote file is more than some number of hours old (currently 1 hr as defined by `update_detector.min_fetch_wait`).  This link will download the remote file, parse it, and display the results.
* From the command line, the `-gcheck_update` will download the remote file and parse the results.

## Functionanlity

### `res://addons/gut/update_detector.gd`
Responsible for downloading files, parsing version data, as well as helper methods for detecting/displaying update and invalid version information.

### `res://addons/gut/gui/check_for_update.tscn/.gd`
This control uses the `update_detector.gd` to present info to the end user through the GUI.  This is used in the About box and `update_required`.

### `res://addons/gut/gui/update_required.tscn/.gd`
Used on startup to display invalid GUT version information.




## Data files

### `res://addons/gut/versions.json`
This file is shipped with GUT and serves as a backup if the remote file cannot be downloaded.  When there is no remote file, this mostly serves to detect when GUT is being run on an earlier version of Godot that may not be supported.

### `user://gut_temp_directory/versions.json`
This is downloaded from the main branch's `addons/gut/versions.json`.  This allows the file to be updated externally.




## Sample Data
```json
{
    # The version in the Asset Library
    "asset_library": "9.6.0",
    # Branches that are available to be used.  Used to provide info for
    # experimental/new versions of GUT that have not been released yet.
    "branches": {
        "main": {
            "godot_max": "9999",
            "godot_min": "4.6"
        }
    },
    # This is added when the file is downloaded so we know when it was last
    # updated.  Getting the timestamp for the file looked non-trival in Godot.
    # This does not exist in the local file.
    "fetch_timestamp": 1772560259.54128,
    # The GUT releases and the min/max versions of Godot they support.
    "releases": {
        "9.3.0": {
            "godot_max": "4.2.999",
            "godot_min": "4.2"
        },
        "9.4.0": {
            "godot_max": "4.4.999",
            "godot_min": "4.3"
        },
        "9.5.0": {
            "godot_max": "4.5.999",
            "godot_min": "4.5"
        },
        "9.6.0": {
            "godot_max": "999",
            "godot_min": "4.6"
        }
    }
}
```