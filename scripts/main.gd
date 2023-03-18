extends Node2D
# ##############################################################################
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
# ##############################################################################

# ##############################################################################
#
# Description:
# ------------
# This file is used to illustrate how you would Run tests on a deployed project
# and some of the ways to interact with GUT, the runner, and a config.
# 
# ##############################################################################
var GutConfig = load('res://addons/gut/gut_config.gd')
var GutRunnerScene = load('res://addons/gut/gui/GutRunner.tscn')

var _config = GutConfig.new()
var _gut_runner = GutRunnerScene.instantiate()


func _ready():
	# Setup all the GUT options from a file.
	_config.load_options('res://.gutconfig.json')
	
	# Override soecific values for the purposes of this 
	# scene.  You can see all the options available in 
	# the default_options dictionary in gut_config.gd
	_config.options.selected = 'test_test.gd'
	_config.options.should_exit = false
	_config.options.compact_mode = false

	# Connect to some of the GUT signals
	var gut = _gut_runner.get_gut()
	gut.start_run.connect(_on_gut_run_started)
	gut.start_script.connect(_on_gut_start_script)
	gut.start_test.connect(_on_gut_test_started)
	gut.end_run.connect(_on_gut_run_ended)

	# Stop tests from kicking off when the runner is "ready"
	_gut_runner.auto_run_tests = false
	# apply the config
	_gut_runner.set_gut_config(_config)
	add_child(_gut_runner)
	

func _on_RunGutTestsButton_pressed():
	_gut_runner.run_tests()


func _on_gut_run_started():
	print('Gut Run Started')

	
func _on_gut_run_ended():
	print('Gut Run Ended')


# This signal passes a TestCollector.gd/TestScript instance
func _on_gut_start_script(script_obj):
	print(script_obj.get_full_name(), ' has ', script_obj.tests.size(), ' tests')


func _on_gut_test_started(test_name):
	print('  ', test_name)
