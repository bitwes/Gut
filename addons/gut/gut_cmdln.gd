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
# Version 5.0.0
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

	# returns the value of an option if it was specfied, otherwise
	# it returns the default.
	func get_value(option, default):
		var to_return = default
		var opt_loc = find_option(option)
		if(opt_loc != -1):
			to_return = get_option_value(_opts[opt_loc])
			_opts.remove(opt_loc)

		return to_return

	# returns true if it finds the option, false if not.
	func was_specified(option):
		var opt_loc = find_option(option)
		if(opt_loc != -1):
			_opts.remove(opt_loc)

		return opt_loc != -1

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
		value = default_value

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
			if(t == TYPE_INT):
				options[i].value = int(parser.get_value(options[i].option_name, options[i].default))
			elif(t == TYPE_STRING):
				options[i].value = parser.get_value(options[i].option_name, options[i].default)
			elif(t == TYPE_ARRAY):
				options[i].value = parser.get_array_value(options[i].option_name)
			elif(t == TYPE_BOOL):
				options[i].value = parser.was_specified(options[i].option_name)
			elif(t == TYPE_NIL):
				print(options[i].option_name + ' cannot be processed, it has a nil datatype')
			else:
				print(options[i].option_name + ' cannot be processsed, it has unknown datatype:' + str(t))


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
	should_exit = false,
	log_level = 1,
	ignore_pause_before_teardown = false,
	tests = [],
	dirs = [],
	selected = '',
	prefix = '',
	suffix = '',
	gut_location = '',
	unit_test_name = '',
	show_help = false
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
	opts.add('-gtest', [], 'Comma delimited list of test scripts to run')
	opts.add('-gdir', [], 'Comma delimited list of directories to add tests from.')
	opts.add('-gprefix', 'test_', 'Prefix used to find tests when specifying -gdir.  Default "[default]"')
	opts.add('-gsuffix', '.gd', 'Suffix used to find tests when specifying -gdir.  Default "[default]"')
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
	return opts


# Parses options, applying them to the _tester or setting values
# in the options struct.
func extract_options(opt):
	options.tests = opt.get_value('-gtest')
	options.dirs = opt.get_value('-gdir')
	options.should_exit = opt.get_value('-gexit')
	options.log_level = opt.get_value('-glog')
	options.ignore_pause_before_teardown = opt.get_value('-gignore_pause')
	options.selected = opt.get_value('-gselect')
	options.prefix = opt.get_value('-gprefix')
	options.suffix = opt.get_value('-gsuffix')
	options.gut_location = opt.get_value('-gutloc')
	options.unit_test_name = opt.get_value('-gunit_test_name')

# apply all the options specified to _tester
func apply_options():
	# setup the tester
	_tester = load(options.gut_location).new()
	get_root().add_child(_tester)
	_tester.connect('tests_finished', self, '_on_tests_finished')
	_tester.set_yield_between_tests(true)
	_tester.show()

	_tester.set_log_level(options.log_level)
	_tester.set_ignore_pause_before_teardown(options.ignore_pause_before_teardown)

	for i in range(options.dirs.size()):
		_tester.add_directory(options.dirs[i], options.prefix, options.suffix)

	for i in range(options.tests.size()):
		_tester.add_script(options.tests[i])

	if(options.selected != ''):
		_auto_run = _tester.select_script(options.selected)
		_run_single = true
		if(!_auto_run):
			_tester.p("Could not find a script that matched:  " + options.selected)

	_tester.set_unit_test_name(options.unit_test_name)

# Loads any scripts that have been configured to be loaded through the project
# settings->autoload.
func load_auto_load_scripts():
	var f = ConfigFile.new()
	f.load('res://engine.cfg')

	for key in f.get_section_keys('autoload'):
		var obj = load(f.get_value('autoload', key)).new()
		obj.set_name(key)
		get_root().add_child(obj)

# parse option and run Gut
func _init():
	var o = setup_options()
	o.parse()
	extract_options(o)

	if(o.get_value('-gh')):
		o.print_help()
		quit()
	else:
		load_auto_load_scripts()
		apply_options()

		if(_auto_run):
			_tester.test_scripts(!_run_single)

# exit if option is set.
func _on_tests_finished():
	if(options.should_exit):
		quit()
