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
# 	godot -s scirpts/gut_cmdln.gd
#
#
# Options
# -------
# 	-gexit:  
#		Exit when done running tests.  If not specified you have to manually
#       close the window or ctrl+c at command line.
# 	-glog=<X>:   
#		Specify the log level after the = (-glog=0).  See Gut readme for description
#		of levels.
#   -gscript=<comma seperated list of scripts>:
#		Add a script or scripts to be tested.  Multiple scripts must be separated
#		by a comma.
#
#
# Examples
# --------
# Run godot in debug mode (-d), run a test script (-gtest), set log level 
# to lowest (-glog), exit when done (-gexit)
# 	godot -s scripts/gut_cmdln.gd -d -gtest=res://scripts/sample_tests.gd -glog=1 -gexit
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
	log_level = 1
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
		if(scripts.size() != 0):
			for i in range(scripts.size()):
				print('adding script:  ' + scripts[i])
				_tester.add_script(scripts[i])
		_opts.remove(opt_loc)
		
		opt_loc = find_option('-gtest')
		
# Parses options, applying them to the _tester or setting values
# in the options struct.
func apply_options():
	for i in range(OS.get_cmdline_args().size()):
		_opts.append(OS.get_cmdline_args().get(i))
	print(_opts)
	
	# add tests
	parse_option_tests()
	
	# exit option
	var e_loc = _opts.find('-gexit')
	if(e_loc != -1):
		options.should_exit = true
		_opts.remove(e_loc)

	# log level
	var log_loc = find_option('-glog')
	if(log_loc != -1):
		options.log_level = get_option_value(_opts[log_loc])
		_opts.remove(log_loc)

# parse option and run Gut
func _init():
	_tester = Gut.new()
	get_root().add_child(_tester)
	_tester.connect('tests_finished', self, '_on_tests_finished')
	_tester.set_yield_between_tests(true)
	_tester.show()
	
	apply_options()
	
	_tester.set_log_level(float(options.log_level))
	
	_tester.test_scripts()
	
# exit if option is set.
func _on_tests_finished():
	if(options.should_exit):
		quit()