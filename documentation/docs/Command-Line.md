# Command Line
Also supplied in this repo is the `gut_cmdln.gd` script that can be run from the command line.  This is also used by the VSCode Plugin [gut-extension](https://marketplace.visualstudio.com/items?itemName=bitwes.gut-extension).

__Note:__ All the examples here come from my Mac/Bash.

In the examples below I will be using `godot` as a command.  This is an alias I have created as:
```bash
alias godot='/Applications/Godot.app/Contents/MacOS/Godot'
```

From the command line, at the root of your project, use the following command to run the script.  Use the options below to run tests.

```bash
godot -d -s --path "$PWD" addons/gut/gut_cmdln.gd
```

The `-d` option tells Godot to run in debug mode which is helpful.  The `-s` option tells Godot to run a script. `--path "$PWD"` tells Godot to treat the current directory as the root of a project.

When running from command line, `0` will be returned if all tests pass and `1` will be returned if any fail (`pending` doesn't affect the return value).

## Options
_Output from the command line help via `-gh` option_
```text
The GUT CLI
-----------
The default behavior for GUT is to load options from a res://.gutconfig.json if
it exists.  Any options specified on the command line will take precedence over
options specified in the gutconfig file.  You can specify a different gutconfig
file with the -gconfig option.

To generate a .gutconfig.json file you can use -gprint_gutconfig_sample
To see the effective values of a CLI command and a gutconfig use -gpo

Values for options can be supplied using:
    option=value    # no space around "="
    option value    # a space between option and value w/o =

Options whose values are lists/arrays can be specified multiple times:
	-gdir=a,b
	-gdir c,d
	-gdir e
	# results in -gdir equaling [a, b, c, d, e]

To not use an empty value instead of a default value, specifiy the option with
an immediate "=":
	-gconfig=


Usage
-----------
  <path to godot> -s addons/gut/gut_cmdln.gd [opts]


Options
-----------

Test Config:
  -gdir                           List of directories to search for test scripts in.
  -ginclude_subdirs               Flag to include all subdirectories specified with -gdir.
  -gtest                          List of full paths to test scripts to run.
  -gprefix                        Prefix used to find tests when specifying -gdir.  Default "test_".
  -gsuffix                        Test script suffix, including .gd extension.  Default ".gd".
  -gconfig                        The config file to load options from.  The default is res://.gutconfig.json.
                                  Use "-gconfig=" to not use a config file.
  -gpre_run_script                pre-run hook script path
  -gpost_run_script               post-run hook script path
  -gerrors_do_not_cause_failure   When an internal GUT error occurs tests will fail.  With this option
                                  set, that does not happen.
  -gdouble_strategy               Default strategy to use when doubling.  Valid values are [INCLUDE_NATIVE,
                                  SCRIPT_ONLY].  Default "SCRIPT_ONLY"

Run Options:
  -gselect                        All scripts that contain the specified string in their filename will be ran
  -ginner_class                   Only run inner classes that contain the specified string in their name.
  -gunit_test_name                Any test that contains the specified text will be run, all others will be skipped.
  -gexit                          Exit after running tests.  If not specified you have to manually close the window.
  -gexit_on_success               Only exit if zero tests fail.
  -gignore_pause                  Ignores any calls to pause_before_teardown.
  -gno_error_tracking             Disable error tracking.
  -gfailure_error_types           Error types that will cause tests to fail if the are encountered during
                                  the execution of a test.  Default "["engine", "gut", "push_error"]"

Display Settings:
  -glog                           Log level [0-3].  Default 1
  -ghide_orphans                  Display orphan counts for tests and scripts.  Default false.
  -gmaximize                      Maximizes test runner window to fit the viewport.
  -gcompact_mode                  The runner will be in compact mode.  This overrides -gmaximize.
  -gopacity                       Set opacity of test runner window. Use range 0 - 100. 0 = transparent,
                                  100 = opaque.
  -gdisable_colors                Disable command line colors.
  -gfont_name                     Valid values are:  ["AnonymousPro", "CourierPrime", "LobsterTwo", "Default"].
                                  Default "CourierPrime"
  -gfont_size                     Font size, default "16"
  -gbackground_color              Background color as an html color, default "262626ff"
  -gfont_color                    Font color as an html color, default "ccccccff"
  -gpaint_after                   Delay before GUT will add a 1 frame pause to paint the screen/GUI.  default 0.1
  -gwait_log_delay                Delay before GUT will print a message to indicate a test is awaiting
                                  one of the wait_* methods.  Default 0.5

Result Export:
  -gjunit_xml_file                Export results of run to this file in the Junit XML format.
  -gjunit_xml_timestamp           Include a timestamp in the -gjunit_xml_file, default false

Help:
  -gh                             Print this help.  You did this to see this, so you probably understand.
  -gpo                            Print option values from all sources and the value used.
  -gprint_gutconfig_sample        Print out json that can be used to make a gutconfig file.
```

## Examples

Run godot in debug mode (-d), run a test script (-gtest), set log level to lowest (-glog), exit when done (-gexit)

```bash
godot -s addons/gut/gut_cmdln.gd -d --path "$PWD" -gtest=res://test/unit/sample_tests.gd -glog=1 -gexit
```

Load all test scripts that begin with 'me_' and end in '.res' and run me_only_only_me.res (given that the directory contains the following scripts:  me_and_only_me.res, me_only.res, me_one.res, me_two.res).  I don't specify the -gexit on this one since I might want to run all the scripts using the GUI after I run this one script.

```bash
godot -s addons/gut/gut_cmdln.gd -d --path "$PWD" -gdir=res://test/unit -gprefix=me_ -gsuffix=.res -gselect=only_me
```

## Config file
To cut down on the amount of arguments you have to pass to gut and to make it easier to change them, you can optionally use a json file to specify some of the values.  By default `gut_cmdln` looks for a config file at `res://.gutconfig.json`.  You can specify a different file using the `-gconfig` option.

Here is a sample file.  You can print out the text for a gutconfig file using the `-gprint_gutconfig_sample` option.
### Example
``` json
{
  "dirs":["res://test/unit/","res://test/integration/"],
  "double_strategy":"partial",
  "ignore_pause":false,
  "include_subdirs":true,
  "inner_class":"",
  "log_level":3,
  "opacity":100,
  "prefix":"test_",
  "selected":"",
  "should_exit":true,
  "should_maximize":true,
  "suffix":".gd",
  "tests":[],
  "unit_test_name":"",
}
```


## Common Errors
I really only know of one so far, but if you get a space in your command somewhere, you might see something like this:
```
ERROR:  No loader found for resource: res://samples3
At:  core\io\resource_loader.cpp:209
ERROR:  Failed loading scene: res://samples3
At:  main\main.cpp:1260
```
I got this one when I accidentally put a space instead of an "=" after `-gselect`.
