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

var Gut = load("res://scripts/gut.gd")
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
	suffix = '.gd'
}

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
func parse_options():
	for i in range(OS.get_cmdline_args().size()):
		_opts.append(OS.get_cmdline_args().get(i))

	# add directories of tests
	parse_option_dirs()
	
	# add tests
	parse_option_tests()
	
	options.should_exit = was_specified('-gexit')
	options.log_level = get_value('-glog', options.log_level)
	options.ignore_pause_before_teardown = was_specified('-gignore_pause')
	options.selected = get_value('-gselect', options.selected)
	options.prefix = get_value('-gprefix', options.prefix)
	options.suffix = get_value('-gsuffix', options.suffix)
	
	
	print(options)

# apply all the options specified to _tester
func apply_options():
	_tester.set_log_level(float(options.log_level))
	_tester.set_ignore_pause_before_teardown(options.ignore_pause_before_teardown)
	
	for i in range(options.dirs.size()):
		_tester.add_directory(options.dirs[i], options.prefix, options.suffix)
	
	for i in range(options.tests.size()):
		_tester.add_script(options.tests[i])

	if(options.selected != ''):
		_tester.select_script(options.selected)

# parse option and run Gut
func _init():
	_tester = Gut.new()
	get_root().add_child(_tester)
	_tester.connect('tests_finished', self, '_on_tests_finished')
	_tester.set_yield_between_tests(true)
	_tester.show()
	
	parse_options()
	apply_options()
	
	_tester.test_scripts()
	
# exit if option is set.
func _on_tests_finished():
	if(options.should_exit):
		quit()