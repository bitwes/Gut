################################################################################
#(G)odot (U)nit (T)est class
#
################################################################################
#The MIT License (MIT)
#=====================
#
#Copyright (c) 2017 Tom "Butch" Wesley
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
# Version 6.6.0
################################################################################
extends SceneTree

#-------------------------------------------------------------------------------
# Parses the command line arguments supplied into an array that can then be
# examined and parsed based on how the gut options work.
#-------------------------------------------------------------------------------
class CmdLineParser:
	var _opts = []

	func _init():
		for i in range(OS.get_cmdline_args().size()):
			_opts.append(OS.get_cmdline_args()[i])

	# Search _opts for an element that starts with the option name
	# specified.
	func find_option(name):
		var found = false
		var idx = 0

		while(idx < _opts.size() and !found):
			if(_opts[idx].find(name) == 0):
				found = true
			else:
				idx += 1

		if(found):
			return idx
		else:
			return -1

	# Parse out the value of an option.  Values are seperated from
	# the option name with "="
	func get_option_value(full_option):
		var split = full_option.split('=')

		if(split.size() > 1):
			return split[1]
		else:
			return null

	# Parse out multiple comma delimited values from a command line
	# option.  Values are separated from option name with "=" and
	# additional values are comma separated.
	func get_option_array_value(full_option):
		var value = get_option_value(full_option)
		var split = value.split(',')
		return split

	func get_array_value(option):
		var to_return = []
		var opt_loc = find_option(option)
		if(opt_loc != -1):
			to_return = get_option_array_value(_opts[opt_loc])
			_opts.remove(opt_loc)

		return to_return

	# returns the value of an option if it was specfied, null otherwise.  This
	# used to return the default but that became problemnatic when trying to
	# punch layer the different places where values could be specified.
	func get_value(option):
		var to_return = null
		var opt_loc = find_option(option)
		if(opt_loc != -1):
			to_return = get_option_value(_opts[opt_loc])
			_opts.remove(opt_loc)

		return to_return

	# returns true if it finds the option, false if not.
	func was_specified(option):
		return find_option(option) != -1

#-------------------------------------------------------------------------------
# Simple class to hold a command line option
#-------------------------------------------------------------------------------
class Option:
	var value = null
	var option_name = ''
	var default = null
	var description = ''

	func _init(name, default_value, desc=''):
		option_name = name
		default = default_value
		description = desc
		value = null#default_value

	func pad(value, size, pad_with=' '):
		var to_return = value
		for i in range(value.length(), size):
			to_return += pad_with

		return to_return

	func to_s(min_space=0):
		var subbed_desc = description
		if(subbed_desc.find('[default]') != -1):
			subbed_desc = subbed_desc.replace('[default]', str(default))
		return pad(option_name, min_space) + subbed_desc

#-------------------------------------------------------------------------------
# The high level interface between this script and the command line options
# supplied.  Uses Option class and CmdLineParser to extract information from
# the command line and make it easily accessible.
#-------------------------------------------------------------------------------
class Options:
	var options = []
	var _opts = []
	var _banner = ''

	func add(name, default, desc):
		options.append(Option.new(name, default, desc))

	func get_value(name):
		var found = false
		var idx = 0

		while(idx < options.size() and !found):
			if(options[idx].option_name == name):
				found = true
			else:
				idx += 1

		if(found):
			return options[idx].value
		else:
			print("COULD NOT FIND OPTION " + name)
			return null

	func set_banner(banner):
		_banner = banner

	func print_help():
		var longest = 0
		for i in range(options.size()):
			if(options[i].option_name.length() > longest):
				longest = options[i].option_name.length()

		print('---------------------------------------------------------')
		print(_banner)

		print("\nOptions\n-------")
		for i in range(options.size()):
			print('  ' + options[i].to_s(longest + 2))
		print('---------------------------------------------------------')

	func print_options():
		for i in range(options.size()):
			print(options[i].option_name + '=' + str(options[i].value))

	func parse():
		var parser = CmdLineParser.new()

		for i in range(options.size()):
			var t = typeof(options[i].default)
			# only set values that were specified at the command line so that
			# we can punch through default and config values correctly later.
			# Without this check, you can't tell the difference between the
			# defaults and what was specified, so you can't punch through
			# higher level options.
			if(parser.was_specified(options[i].option_name)):
				if(t == TYPE_INT):
					options[i].value = int(parser.get_value(options[i].option_name))
				elif(t == TYPE_STRING):
					options[i].value = parser.get_value(options[i].option_name)
				elif(t == TYPE_ARRAY):
					options[i].value = parser.get_array_value(options[i].option_name)
				elif(t == TYPE_BOOL):
					options[i].value = parser.was_specified(options[i].option_name)
				elif(t == TYPE_NIL):
					print(options[i].option_name + ' cannot be processed, it has a nil datatype')
				else:
					print(options[i].option_name + ' cannot be processsed, it has unknown datatype:' + str(t))

#-------------------------------------------------------------------------------
# Helper class to resolve the various different places where an option can
# be set.  Using the get_value method will enforce the order of precedence of:
# 	1.  command line value
#	2.  config file value
#	3.  default value
#
# The idea is that you set the base_opts.  That will get you a copies of the
# hash with null values for the other types of values.  Lower precendeted hashes
# will punch through null values of higher precedednted hashes.
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
			to_return += str('  config:  ', _nvl(config_opts[key], 'NULL'), "\n")
			to_return += str('  cmd:     ', _nvl(cmd_opts[key], 'NULL'), "\n")
			to_return += str('  final:   ', _nvl(resolved[key], 'NULL'), "\n")

		return to_return

#-------------------------------------------------------------------------------
# Here starts the actual script that uses the Options class to kick off Gut
# and run your tests.
#-------------------------------------------------------------------------------
# instance of gut
var _tester = null
# array of command line options specified
var _opts = []
# Hash for easier access to the options in the code.  Options will be
# extracted into this hash and then the hash will be used afterwards so
# that I don't make any dumb typos and get the neat code-sense when I
# type a dot.
var options = {
	should_maximize = false,
	should_exit = false,
	log_level = 1,
	ignore_pause_before_teardown = false,
	tests = [],
	dirs = [],
	selected = '',
	prefix = 'test_',
	suffix = '.gd',
	gut_location = 'res://addons/gut/gut.gd',
	unit_test_name = '',
	show_help = false,
	config_file = 'res://.gutconfig.json',
	inner_class = '',
	opacity = 100,
	include_subdirs = false
}

# flag to say if we should run the scripts or not.  It is only
# set to false if you specify a script to run with the -gselect
# option and it cannot find the script.
var _auto_run = true
# flag to indicate if only a single script should be run.
var _run_single = false

func setup_options():
	var opts = Options.new()
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
	opts.add('-gselect', '', ('Select a sccript to run initially.  The first script that ' +
	                          'was loaded using -gtest or -gdir that contains the specified ' +
	                          'string will be executed.  You may run others by interacting ' +
                              'with the GUI.'))
	opts.add('-gunit_test_name', '', ('Name of a test to run.  Any test that contains the specified ' +
                                 'text will be run, all others will be skipped.'))
	opts.add('-gutloc', 'res://addons/gut/gut.gd', 'Full path (including name) of the gut script.  Default [default]')
	opts.add('-gh', false, 'Print this help')
	opts.add('-gconfig', 'res://.gutconfig.json', 'A config file that contains configuration information.  Default is res://.gutconfig.json')
	opts.add('-ginner_class', '', 'Only run inner classes that contain this string')
	opts.add('-gopacity', 100, 'Set opacity of test runner window. Use range 0 - 100. 0 = transparent, 100 = opaque.')
	opts.add('-gpo', false, 'Print option values from all sources and the value used, then quit.')
	opts.add('-ginclude_subdirs', false, 'Include subdirectories of -gdir.')
	return opts


# Parses options, applying them to the _tester or setting values
# in the options struct.

func extract_command_line_options(from, to):
	to.tests = from.get_value('-gtest')
	to.dirs = from.get_value('-gdir')
	to.should_exit = from.get_value('-gexit')
	to.should_maximize = from.get_value('-gmaximize')
	to.log_level = from.get_value('-glog')
	to.ignore_pause_before_teardown = from.get_value('-gignore_pause')
	to.selected = from.get_value('-gselect')
	to.prefix = from.get_value('-gprefix')
	to.suffix = from.get_value('-gsuffix')
	to.gut_location = from.get_value('-gutloc')
	to.unit_test_name = from.get_value('-gunit_test_name')
	to.config_file = from.get_value('-gconfig')
	to.inner_class = from.get_value('-ginner_class')
	to.opacity = from.get_value('-gopacity')
	to.include_subdirs = from.get_value('-ginclude_subdirs')

func get_value(dict, index, default):
	if(dict.has(index)):
		return dict[index]
	else:
		return default

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

	into.dirs = get_value(results.result, 'dirs', [])
	into.should_maximize = get_value(results.result, 'should_maximize', false)
	into.should_exit = get_value(results.result, 'should_exit', false)
	into.ignore_pause_before_teardown = get_value(results.result, 'ignore_pause', false)
	into.log_level = get_value(results.result, 'log', 1)
	into.inner_class = get_value(results.result, 'inner_class', '')
	into.opacity = get_value(results.result, 'opacity', 100)

	return 1

# apply all the options specified to _tester
func apply_options(opts):
	_tester = load(opts.gut_location).new()
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
	_tester.set_ignore_pause_before_teardown(opts.ignore_pause_before_teardown)

	for i in range(opts.dirs.size()):
		_tester.add_directory(opts.dirs[i], opts.prefix, opts.suffix)

	for i in range(opts.tests.size()):
		_tester.add_script(opts.tests[i])

	if(opts.selected != ''):
		_auto_run = _tester.select_script(opts.selected)
		_run_single = true
		if(!_auto_run):
			_tester.p("Could not find a script that matched:  " + opts.selected)

	_tester.set_unit_test_name(opts.unit_test_name)


# Loads any scripts that have been configured to be loaded through the project
# settings->autoload.
func load_auto_load_scripts():
	var f = ConfigFile.new()
	f.load('res://project.godot')

	for key in f.get_section_keys('autoload'):
		# There's an * in my autoload path, at the start, idk why.  It breaks
		# things so I'm removing all * from the value.
		var obj = load(f.get_value('autoload', key).replace('*', '')).new()
		obj.set_name(key)
		get_root().add_child(obj)

# parse options and run Gut
func _init():
	var opt_resolver = OptionResolver.new()
	opt_resolver.set_base_opts(options)

	print("\n\n", ' ---  Gut  ---')
	var o = setup_options()
	o.parse()
	extract_command_line_options(o, opt_resolver.cmd_opts)
	var load_result = \
		load_options_from_config_file(options.config_file, opt_resolver.config_opts)

	if(load_result == -1): # -1 indicates json parse error
		quit()
	else:
		if(o.get_value('-gh')):
			o.print_help()
			quit()
		elif(o.get_value('-gpo')):
			print('All command line options and where they are specified.  ' +
			      'The "final" value shows which value will actually be used ' +
				  'based on order of precedence (default < .gutconfig < cmd line).' + "\n")
			print(opt_resolver.to_s_verbose())
			quit()
		else:
			load_auto_load_scripts()
			apply_options(opt_resolver.get_resolved_values())

			if(_auto_run):
				_tester.test_scripts(!_run_single)

# exit if option is set.
func _on_tests_finished(should_exit):
	if(_tester.get_fail_count()):
		OS.exit_code = 1
	if(should_exit):
		quit()
