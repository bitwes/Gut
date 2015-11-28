################################################################################
#(G)odot (U)nit (T)est class
#
################################################################################
#The MIT License (MIT)
#=====================
#
#Copyright (c) 2015 Tom "Butch" Wesley
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
# 	alias gut='godot -s -d scirpts/gut_cmdln.gd'
#
#See the readme for a list of options and examples.
#
################################################################################
extends SceneTree

class CmdLineParser:
	var _opts = []
	
	func _init():
		for i in range(OS.get_cmdline_args().size()):
			_opts.append(OS.get_cmdline_args().get(i))
			
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
	
	func to_s():
		var subbed_desc = description
		if(subbed_desc.find('[default]') != -1):
			subbed_desc = subbed_desc.replace('[default]', default)
		return option_name + "\t" + "\t" + subbed_desc
		
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
		print(_banner)
		
		for i in range(options.size()):
			print(options[i].to_s())
		
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
				
# instance of gut
var _tester = null
# array of command line options specified
var _opts = []
# options that can be set and their defaults
var options = {
	should_exit = false,
	log_level = 1,
	ignore_pause_before_teardown = false,
	tests = [],
	dirs = [],
	selected = '',
	prefix = 'test_',
	suffix = '.gd',
	gut_location = 'res://scripts/gut.gd',
	show_help = false
}

func fill_options():
	var opts = Options.new()
	opts.add('-gtest', [], 'Comma delimited list of tests to run')
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
	opts.add('-gutloc', 'res://scripts/gut.gd', 'Full path (including name) of the gut script.  Default [default]')
	return opts
	
# flag to say if we should run the scripts or not.  Is only
# set to false if you specify a script to run with the -gselect
# option and it cannot find the script.
var _auto_run = true

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

# Add tests based on the options in _opts
func parse_option_tests():
	var opt_loc = find_option('-gtest')
	while(opt_loc != -1):
		var scripts = get_option_array_value(_opts[opt_loc])
		for i in range(scripts.size()):
			print('adding script:  ' + scripts[i])
			options.tests.append(scripts[i])
		_opts.remove(opt_loc)
		
		opt_loc = find_option('-gtest')

# fills the list of directories
func parse_option_dirs():
	var opt_loc = find_option('-gdir')
	while(opt_loc != -1):
		var dirs = get_option_array_value(_opts[opt_loc])
		for i in range(dirs.size()):
			print('adding directory:  ' + dirs[i])
			options.dirs.append(dirs[i])
		_opts.remove(opt_loc)
		
		opt_loc = find_option('-gdir')

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
	
# Parses options, applying them to the _tester or setting values
# in the options struct.
func parse_options(opt):
	options.tests = opt.get_value('-gtest')
	options.dirs = opt.get_value('-gdir')
	options.should_exit = opt.get_value('-gexit')
	options.log_level = opt.get_value('-glog')
	options.ignore_pause_before_teardown = opt.get_value('-gignore_pause')
	options.selected = opt.get_value('-gselect')
	options.prefix = opt.get_value('-gprefix')
	options.suffix = opt.get_value('-gsuffix')
	options.gut_location = opt.get_value('-gutloc')
	
	print(options)

# apply all the options specified to _tester
func apply_options():
	# setup the tester
	_tester = load(options.gut_location).new()
	get_root().add_child(_tester)
	_tester.connect('tests_finished', self, '_on_tests_finished')
	_tester.set_yield_between_tests(true)
	_tester.show()
	
	_tester.set_log_level(float(options.log_level))
	_tester.set_ignore_pause_before_teardown(options.ignore_pause_before_teardown)
	
	for i in range(options.dirs.size()):
		_tester.add_directory(options.dirs[i], options.prefix, options.suffix)
	
	for i in range(options.tests.size()):
		_tester.add_script(options.tests[i])

	if(options.selected != ''):
		_auto_run = _tester.select_script(options.selected)
		if(!_auto_run):
			_tester.p("Could not find a script that matched:  " + options.selected)

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
	var o = fill_options()
	o.parse()
	o.print_options()
	parse_options(o)
	
	load_auto_load_scripts()
	#parse_options()
	apply_options()
	
	if(_auto_run):
		_tester.test_scripts()
	
# exit if option is set.
func _on_tests_finished():
	if(options.should_exit):
		quit()