# ##############################################################################
#The MIT License (MIT)
#=====================
#
#Copyright (c) 2023 Tom "Butch" Wesley
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
extends Control

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
var _has_connected = false

@onready var _ctrls = {
	run_tests_button = $RunTests
}

func _ready():
	# Stop tests from kicking off when the runner is "ready" and
	# prevents it from writing results file that is used by
	# the panel.
	_gut_runner.set_cmdln_mode(true)
	add_child(_gut_runner)
	
	# Becuase of the janky _utils psuedo-global script, we cannot
	# do all this in _ready.  If we do this in _ready, it generates
	# a bunch of errors.  The errors don't matter, but it looks bad.
	call_deferred('_wire_up_gut')


func _wire_up_gut():
	var gut = _gut_runner.get_gut()
	gut.start_run.connect(_on_gut_run_started)
	gut.end_run.connect(_on_gut_run_ended)
		
	
func _on_gut_run_started():
	_ctrls.run_tests_button.disabled = true
	_ctrls.run_tests_button.text = 'Running'
#
#
func _on_gut_run_ended():
	_ctrls.run_tests_button.disabled = false
	_ctrls.run_tests_button.text = 'Run Tests'


func _on_run_tests_pressed():
	run_tests()


func get_gut():
	return _gut_runner.get_gut()

	
func get_config():
	return _config

	
func run_tests():
	# apply the config
	_gut_runner.set_gut_config(_config)
	_gut_runner.run_tests()
