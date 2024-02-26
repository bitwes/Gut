# ------------------------------------------------------------------------------
# Description
# -----------
# Command line interface for the GUT unit testing tool.  Allows you to run tests
# from the command line instead of running a scene.  Place this script along with
# gut.gd into your scripts directory at the root of your project.  Once there you
# can run this script (from the root of your project) using the following command:
# 	godot -s -d test/gut/gut_cmdln.gd
#
# See the readme for a list of options and examples.  You can also use the -gh
# option to get more information about how to use the command line interface.
# ------------------------------------------------------------------------------
extends SceneTree

var Optparse = load('res://addons/gut/optparse.gd')
var Gut = load('res://addons/gut/gut.gd')
var GutRunner = load('res://addons/gut/gui/GutRunner.tscn')

var json = JSON.new()

# ------------------------------------------------------------------------------
# Helper class to resolve the various different places where an option can
# be set.  Using the get_value method will enforce the order of precedence of:
# 	1.  command line value
#	2.  config file value
#	3.  default value
#
# The idea is that you set the base_opts.  That will get you a copies of the
# hash with null values for the other types of values.  Lower precedented hashes
# will punch through null values of higher precedented hashes.
# ------------------------------------------------------------------------------
class OptionResolver:
	var base_opts = {}
	var cmd_opts = {}
	var config_opts = {}


	func get_value(key):
		return _nvl(cmd_opts[key], _nvl(config_opts[key], base_opts[key]))

	func set_base_opts(opts):
		base_opts = opts
		cmd_opts = _null_copy(opts)
		config_opts = _null_copy(opts)

	# creates a copy of a hash with all values null.
	func _null_copy(h):
		var new_hash = {}
		for key in h:
			new_hash[key] = null
		return new_hash

	func _nvl(a, b):
		if(a == null):
			return b
		else:
			return a
	func _string_it(h):
		var to_return = ''
		for key in h:
			to_return += str('(',key, ':', _nvl(h[key], 'NULL'), ')')
		return to_return

	func to_s():
		return str("base:\n", _string_it(base_opts), "\n", \
				"config:\n", _string_it(config_opts), "\n", \
				"cmd:\n", _string_it(cmd_opts), "\n", \
				"resolved:\n", _string_it(get_resolved_values()))

	func get_resolved_values():
		var to_return = {}
		for key in base_opts:
			to_return[key] = get_value(key)
		return to_return

	func to_s_verbose():
		var to_return = ''
		var resolved = get_resolved_values()
		for key in base_opts:
			to_return += str(key, "\n")
			to_return += str('  default: ', _nvl(base_opts[key], 'NULL'), "\n")
			to_return += str('  config:  ', _nvl(config_opts[key], ' --'), "\n")
			to_return += str('  cmd:     ', _nvl(cmd_opts[key], ' --'), "\n")
			to_return += str('  final:   ', _nvl(resolved[key], 'NULL'), "\n")

		return to_return

# ------------------------------------------------------------------------------
# Here starts the actual script that uses the Options class to kick off Gut
# and run your tests.
# ------------------------------------------------------------------------------
var _utils = null
var _gut_config = load('res://addons/gut/gut_config.gd').new()
# instance of gut
var _tester = null
# array of command line options specified
var _final_opts = []


func setup_options(options, font_names):
	var opts = Optparse.new()
	opts.set_banner(
"""
The GUT CLI
-----------
The default behavior for GUT is to load options from a res://.gutconfig.json if
it exists.  Any options specified on the command line will take precedence over
options specified in the gutconfig file.  You can specify a different gutconfig
file with the -gconfig option.

To generate a .gutconfig.json file you can use -gprint_gutconfig_sample
To see the effective values of a CLI command and a gutconfig use -gpo

Any option that requires a value will take the form of \"-g<name>=<value>\".
There cannot be any spaces between the option, the \"=\", or ' + 'inside a
specified value or godot will think you are trying to run a scene.
""")
	# Run specific things
	opts.add('-gselect', '', ('All scripts that contain the specified string in their filename will be ran'))
	opts.add('-ginner_class', '', 'Only run inner classes that contain the specified string int their name.')
	opts.add('-gunit_test_name', '', ('Any test that contains the specified text will be run, all others will be skipped.'))

	# Run Config
	opts.add('-ginclude_subdirs', false, 'Include subdirectories of -gdir.')
	opts.add('-gdir', options.dirs, 'Comma delimited list of directories to add tests from.')
	opts.add('-gtest', [], 'Comma delimited list of full paths to test scripts to run.')
	opts.add('-gprefix', options.prefix, 'Prefix used to find tests when specifying -gdir.  Default "[default]".')
	opts.add('-gsuffix', options.suffix, 'Test script suffix, including .gd extension.  Default "[default]".')
	opts.add('-gconfig', 'res://.gutconfig.json', 'A config file that contains configuration information.  Default is res://.gutconfig.json')
	opts.add('-gpre_run_script', '', 'pre-run hook script path')
	opts.add('-gpost_run_script', '', 'post-run hook script path')
	opts.add('-gerrors_do_not_cause_failure', false, 'When an internal GUT error occurs tests will fail.  With this option set, that does not happen.')
	opts.add('-gdouble_strategy', 'SCRIPT_ONLY', 'Default strategy to use when doubling.  Valid values are [INCLUDE_NATIVE, SCRIPT_ONLY].  Default "[default]"')

	# Misc
	opts.add('-gpaint_after', options.paint_after, 'Delay before GUT will add a 1 frame pause to paint the screen/GUI.  default [default]')

	# Display options
	opts.add('-glog', options.log_level, 'Log level.  Default [default]')
	opts.add('-ghide_orphans', false, 'Display orphan counts for tests and scripts.  Default "[default]".')
	opts.add('-gmaximize', false, 'Maximizes test runner window to fit the viewport.')
	opts.add('-gcompact_mode', false, 'The runner will be in compact mode.  This overrides -gmaximize.')
	opts.add('-gopacity', options.opacity, 'Set opacity of test runner window. Use range 0 - 100. 0 = transparent, 100 = opaque.')
	opts.add('-gdisable_colors', false, 'Disable command line colors.')
	opts.add('-gfont_name', options.font_name, str('Valid values are:  ', font_names, '.  Default "[default]"'))
	opts.add('-gfont_size', options.font_size, 'Font size, default "[default]"')
	opts.add('-gbackground_color', options.background_color, 'Background color as an html color, default "[default]"')
	opts.add('-gfont_color',options.font_color, 'Font color as an html color, default "[default]"')

	# End Behavior
	opts.add('-gexit', false, 'Exit after running tests.  If not specified you have to manually close the window.')
	opts.add('-gexit_on_success', false, 'Only exit if all tests pass.')
	opts.add('-gignore_pause', false, 'Ignores any calls to gut.pause_before_teardown.')

	# Helpish options
	opts.add('-gh', false, 'Print this help.  You did this to see this, so you probably understand.')
	opts.add('-gpo', false, 'Print option values from all sources and the value used.')
	opts.add('-gprint_gutconfig_sample', false, 'Print out json that can be used to make a gutconfig file.')

	# Output options
	opts.add('-gjunit_xml_file', options.junit_xml_file, 'Export results of run to this file in the Junit XML format.')
	opts.add('-gjunit_xml_timestamp', options.junit_xml_timestamp, 'Include a timestamp in the -gjunit_xml_file, default [default]')

	return opts


# Parses options, applying them to the _tester or setting values
# in the options struct.
func extract_command_line_options(from, to):
	to.config_file = from.get_value('-gconfig')
	to.dirs = from.get_value('-gdir')
	to.disable_colors =  from.get_value('-gdisable_colors')
	to.double_strategy = from.get_value('-gdouble_strategy')
	to.ignore_pause = from.get_value('-gignore_pause')
	to.include_subdirs = from.get_value('-ginclude_subdirs')
	to.inner_class = from.get_value('-ginner_class')
	to.log_level = from.get_value('-glog')
	to.opacity = from.get_value('-gopacity')
	to.post_run_script = from.get_value('-gpost_run_script')
	to.pre_run_script = from.get_value('-gpre_run_script')
	to.prefix = from.get_value('-gprefix')
	to.selected = from.get_value('-gselect')
	to.should_exit = from.get_value('-gexit')
	to.should_exit_on_success = from.get_value('-gexit_on_success')
	to.should_maximize = from.get_value('-gmaximize')
	to.compact_mode = from.get_value('-gcompact_mode')
	to.hide_orphans = from.get_value('-ghide_orphans')
	to.suffix = from.get_value('-gsuffix')
	to.errors_do_not_cause_failure = from.get_value('-gerrors_do_not_cause_failure')
	to.tests = from.get_value('-gtest')
	to.unit_test_name = from.get_value('-gunit_test_name')

	to.font_size = from.get_value('-gfont_size')
	to.font_name = from.get_value('-gfont_name')
	to.background_color = from.get_value('-gbackground_color')
	to.font_color = from.get_value('-gfont_color')
	to.paint_after = from.get_value('-gpaint_after')

	to.junit_xml_file = from.get_value('-gjunit_xml_file')
	to.junit_xml_timestamp = from.get_value('-gjunit_xml_timestamp')



func _print_gutconfigs(values):
	var header = """Here is a sample of a full .gutconfig.json file.
You do not need to specify all values in your own file.  The values supplied in
this sample are what would be used if you ran gut w/o the -gprint_gutconfig_sample
option (option priority:  command-line, .gutconfig, default)."""
	print("\n", header.replace("\n", ' '), "\n\n")
	var resolved = values

	# remove_at some options that don't make sense to be in config
	resolved.erase("config_file")
	resolved.erase("show_help")

	print("Here's a config with all the properties set based off of your current command and config.")
	print(json.stringify(resolved, '  '))

	for key in resolved:
		resolved[key] = null

	print("\n\nAnd here's an empty config for you fill in what you want.")
	print(json.stringify(resolved, ' '))


# parse options and run Gut
func _run_gut():
	var opt_resolver = OptionResolver.new()
	opt_resolver.set_base_opts(_gut_config.default_options)

	print("\n\n", ' ---  Gut  ---')
	var o = setup_options(_gut_config.default_options, _gut_config.valid_fonts)

	var all_options_valid = o.parse()
	extract_command_line_options(o, opt_resolver.cmd_opts)

	var load_result = _gut_config.load_options_no_defaults(
		opt_resolver.get_value('config_file'))

	# SHORTCIRCUIT
	if(!all_options_valid or load_result == -1):
		_end_run(1)
	else:
		opt_resolver.config_opts = _gut_config.options

		if(o.get_value('-gh')):
			print(_utils.get_version_text())
			o.print_help()
			_end_run(0)
		elif(o.get_value('-gpo')):
			print('All command line options and where they are specified.  ' +
				'The "final" value shows which value will actually be used ' +
				'based on order of precedence (default < .gutconfig < cmd line).' + "\n")
			print(opt_resolver.to_s_verbose())
			_end_run(0)
		elif(o.get_value('-gprint_gutconfig_sample')):
			_print_gutconfigs(opt_resolver.get_resolved_values())
			_end_run(0)
		else:
			_final_opts = opt_resolver.get_resolved_values();
			_gut_config.options = _final_opts

			var runner = GutRunner.instantiate()

			runner.ran_from_editor = false
			runner.set_gut_config(_gut_config)

			get_root().add_child(runner)
			_tester = runner.get_gut()
			_tester.connect('end_run', Callable(self,'_on_tests_finished').bind(_final_opts.should_exit, _final_opts.should_exit_on_success))

			run_tests(runner)


func run_tests(runner):
	runner.run_tests()


func _end_run(exit_code=-9999):
	if(is_instance_valid(_utils)):
		_utils.free()

	if(exit_code != -9999):
		quit(exit_code)

# exit if option is set.
func _on_tests_finished(should_exit, should_exit_on_success):
	if(_final_opts.dirs.size() == 0):
		if(_tester.get_summary().get_totals().scripts == 0):
			var lgr = _tester.logger
			lgr.error('No directories configured.  Add directories with options or a .gutconfig.json file.  Use the -gh option for more information.')

	var exit_code = 0
	if(_tester.get_fail_count()):
		exit_code = 1

	# Overwrite the exit code with the post_script
	var post_inst = _tester.get_post_run_script_instance()
	if(post_inst != null and post_inst.get_exit_code() != null):
		exit_code = post_inst.get_exit_code()

	if(should_exit or (should_exit_on_success and _tester.get_fail_count() == 0)):
		_end_run(exit_code)
	else:
		_end_run()
		print("Tests finished, exit manually")


# ------------------------------------------------------------------------------
# MAIN
# ------------------------------------------------------------------------------
func _init():
	var max_iter = 20
	var iter = 0

	# Not seen this wait more than 1.
	while(Engine.get_main_loop() == null and iter < max_iter):
		await create_timer(.01).timeout
		iter += 1

	if(Engine.get_main_loop() == null):
		push_error('Main loop did not start in time.')
		quit(0)
		return

	_utils = GutUtils.get_instance()
	if(!_utils.is_version_ok()):
		print("\n\n", _utils.get_version_text())
		push_error(_utils.get_bad_version_text())
		_end_run(1)
	else:
		_run_gut()


# ##############################################################################
#(G)odot (U)nit (T)est class
#
# ##############################################################################
# The MIT License (MIT)
# =====================
#
# Copyright (c) 2023 Tom "Butch" Wesley
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#
# ##############################################################################
