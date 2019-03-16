################################################################################
#(G)odot (U)nit (T)est class
#
################################################################################
#The MIT License (MIT)
#=====================
#
#Copyright (c) 2019 Tom "Butch" Wesley
#
#Permission is hereby granted, free of charge, to any person obtaining a copy
#of this software and associated documentation files (the "Software"), to deal
#in the Software without restriction, including without limitation the rights
#to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#copies of the Software, and to permit persons to whom the Software is
#furnished to do so, subject to the following conditions:
#
#The above copyright notice and this permission notice shall be included in
#all copies or substantial portions of the Software.
#
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
#THE SOFTWARE.
#
################################################################################
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
#
# Version 6.7.0
################################################################################
extends SceneTree


var Optparse = load('res://addons/gut/optparse.gd')
#-------------------------------------------------------------------------------
# Helper class to resolve the various different places where an option can
# be set.  Using the get_value method will enforce the order of precedence of:
# 	1.  command line value
#	2.  config file value
#	3.  default value
#
# The idea is that you set the base_opts.  That will get you a copies of the
# hash with null values for the other types of values.  Lower precedented hashes
# will punch through null values of higher precedented hashes.
#-------------------------------------------------------------------------------
class OptionResolver:
	var base_opts = null
	var cmd_opts = null
	var config_opts = null


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

#-------------------------------------------------------------------------------
# Here starts the actual script that uses the Options class to kick off Gut
# and run your tests.
#-------------------------------------------------------------------------------
var _utils = load('res://addons/gut/utils.gd').new()
# instance of gut
var _tester = null
# array of command line options specified
var _opts = []
# Hash for easier access to the options in the code.  Options will be
# extracted into this hash and then the hash will be used afterwards so
# that I don't make any dumb typos and get the neat code-sense when I
# type a dot.
var options = {
	config_file = 'res://.gutconfig.json',
	dirs = [],
	double_strategy = 'partial',
	ignore_pause = false,
	include_subdirs = false,
	inner_class = '',
	log_level = 1,
	opacity = 100,
	prefix = 'test_',
	selected = '',
	should_exit = false,
	should_maximize = false,
	show_help = false,
	suffix = '.gd',
	tests = [],
	unit_test_name = '',
}

# flag to indicate if only a single script should be run.
var _run_single = false

func setup_options():
	var opts = Optparse.new()
	opts.set_banner(('This is the command line interface for the unit testing tool Gut.  With this ' +
	                'interface you can run one or more test scripts from the command line.  In order ' +
	                'for the Gut options to not clash with any other godot options, each option starts ' +
	                'with a "g".  Also, any option that requires a value will take the form of ' +
	                '"-g<name>=<value>".  There cannot be any spaces between the option, the "=", or ' +
	                'inside a specified value or godot will think you are trying to run a scene.'))
	opts.add('-gtest', [], 'Comma delimited list of full paths to test scripts to run.')
	opts.add('-gdir', [], 'Comma delimited list of directories to add tests from.')
	opts.add('-gprefix', 'test_', 'Prefix used to find tests when specifying -gdir.  Default "[default]"')
	opts.add('-gsuffix', '.gd', 'Suffix used to find tests when specifying -gdir.  Default "[default]"')
	opts.add('-gmaximize', false, 'Maximizes test runner window to fit the viewport.')
	opts.add('-gexit', false, 'Exit after running tests.  If not specified you have to manually close the window.')
	opts.add('-glog', 1, 'Log level.  Default [default]')
	opts.add('-gignore_pause', false, 'Ignores any calls to gut.pause_before_teardown.')
	opts.add('-gselect', '', ('Select a script to run initially.  The first script that ' +
	                          'was loaded using -gtest or -gdir that contains the specified ' +
	                          'string will be executed.  You may run others by interacting ' +
                              'with the GUI.'))
	opts.add('-gunit_test_name', '', ('Name of a test to run.  Any test that contains the specified ' +
                                 'text will be run, all others will be skipped.'))
	opts.add('-gh', false, 'Print this help, then quit')
	opts.add('-gconfig', 'res://.gutconfig.json', 'A config file that contains configuration information.  Default is res://.gutconfig.json')
	opts.add('-ginner_class', '', 'Only run inner classes that contain this string')
	opts.add('-gopacity', 100, 'Set opacity of test runner window. Use range 0 - 100. 0 = transparent, 100 = opaque.')
	opts.add('-gpo', false, 'Print option values from all sources and the value used, then quit.')
	opts.add('-ginclude_subdirs', false, 'Include subdirectories of -gdir.')
	opts.add('-gdouble_strategy', 'partial', 'Default strategy to use when doubling.  Valid values are [partial, full].  Default "[default]"')
	opts.add('-gprint_gutconfig_sample', false, 'Print out json that can be used to make a gutconfig file then quit.')
	return opts


# Parses options, applying them to the _tester or setting values
# in the options struct.
func extract_command_line_options(from, to):
	to.tests = from.get_value('-gtest')
	to.dirs = from.get_value('-gdir')
	to.should_exit = from.get_value('-gexit')
	to.should_maximize = from.get_value('-gmaximize')
	to.log_level = from.get_value('-glog')
	to.ignore_pause = from.get_value('-gignore_pause')
	to.selected = from.get_value('-gselect')
	to.prefix = from.get_value('-gprefix')
	to.suffix = from.get_value('-gsuffix')
	to.unit_test_name = from.get_value('-gunit_test_name')
	to.config_file = from.get_value('-gconfig')
	to.inner_class = from.get_value('-ginner_class')
	to.opacity = from.get_value('-gopacity')
	to.include_subdirs = from.get_value('-ginclude_subdirs')
	to.double_strategy = from.get_value('-gdouble_strategy')


func load_options_from_config_file(file_path, into):
	# SHORTCIRCUIT
	var f = File.new()
	if(!f.file_exists(file_path)):
		if(file_path != 'res://.gutconfig.json'):
			print('ERROR:  Config File "', file_path, '" does not exist.')
			return -1
		else:
			return 1

	f.open(file_path, f.READ)
	var json = f.get_as_text()
	f.close()

	var results = JSON.parse(json)
	# SHORTCIRCUIT
	if(results.error != OK):
		print("\n\n",'!! ERROR parsing file:  ', file_path)
		print('    at line ', results.error_line, ':')
		print('    ', results.error_string)
		return -1

	# Get all the options out of the config file using the option name.  The
	# options hash is now the default source of truth for the name of an option.
	for key in into:
		if(results.result.has(key)):
			into[key] = results.result[key]

	return 1

# Apply all the options specified to _tester.  This is where the rubber meets
# the road.
func apply_options(opts):
	_tester = load('res://addons/gut/gut.gd').new()
	get_root().add_child(_tester)
	_tester.connect('tests_finished', self, '_on_tests_finished', [opts.should_exit])
	_tester.set_yield_between_tests(true)
	_tester.set_modulate(Color(1.0, 1.0, 1.0, min(1.0, float(opts.opacity) / 100)))
	_tester.show()

	_tester.set_include_subdirectories(opts.include_subdirs)

	if(opts.should_maximize):
		_tester.maximize()

	if(opts.inner_class != ''):
		_tester.set_inner_class_name(opts.inner_class)
	_tester.set_log_level(opts.log_level)
	_tester.set_ignore_pause_before_teardown(opts.ignore_pause)

	for i in range(opts.dirs.size()):
		_tester.add_directory(opts.dirs[i], opts.prefix, opts.suffix)

	for i in range(opts.tests.size()):
		_tester.add_script(opts.tests[i])

	if(opts.selected != ''):
		_tester.select_script(opts.selected)
		_run_single = true

	if(opts.double_strategy == 'full'):
		_tester.set_double_strategy(_utils.DOUBLE_STRATEGY.FULL)
	elif(opts.double_strategy == 'partial'):
		_tester.set_double_strategy(_utils.DOUBLE_STRATEGY.PARTIAL)

	_tester.set_unit_test_name(opts.unit_test_name)

func _print_gutconfigs(values):
	var header = """Here is a sample of a full .gutconfig.json file.
You do not need to specify all values in your own file.  The values supplied in
this sample are what would be used if you ran gut w/o the -gprint_gutconfig_sample
option (the resolved values where default < .gutconfig < command line)."""
	print("\n", header.replace("\n", ' '), "\n\n")
	var resolved = values

	# remove some options that don't make sense to be in config
	resolved.erase("config_file")
	resolved.erase("show_help")

	print("Here's a config with all the properties set based off of your current command and config.")
	var text = JSON.print(resolved)
	print(text.replace(',', ",\n"))

	for key in resolved:
		resolved[key] = null

	print("\n\nAnd here's an empty config for you fill in what you want.")
	text = JSON.print(resolved)
	print(text.replace(',', ",\n"))


# parse options and run Gut
func _init():
	var opt_resolver = OptionResolver.new()
	opt_resolver.set_base_opts(options)

	print("\n\n", ' ---  Gut  ---')
	var o = setup_options()

	var all_options_valid = o.parse()
	extract_command_line_options(o, opt_resolver.cmd_opts)
	var load_result = \
			load_options_from_config_file(opt_resolver.get_value('config_file'), opt_resolver.config_opts)

	if(load_result == -1): # -1 indicates json parse error
		quit()
	else:
		if(!all_options_valid):
			quit()
		elif(o.get_value('-gh')):
			o.print_help()
			quit()
		elif(o.get_value('-gpo')):
			print('All command line options and where they are specified.  ' +
			      'The "final" value shows which value will actually be used ' +
				  'based on order of precedence (default < .gutconfig < cmd line).' + "\n")
			print(opt_resolver.to_s_verbose())
			quit()
		elif(o.get_value('-gprint_gutconfig_sample')):
			_print_gutconfigs(opt_resolver.get_resolved_values())
			quit()
		else:
			apply_options(opt_resolver.get_resolved_values())
			_tester.test_scripts(!_run_single)

# exit if option is set.
func _on_tests_finished(should_exit):
	if(_tester.get_fail_count()):
		OS.exit_code = 1

	if(should_exit):
		quit()
