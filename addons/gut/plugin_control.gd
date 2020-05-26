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
# This is the control that is added via the editor.  It exposes GUT settings
# through the editor and delays the creation of the GUT instance until
# Engine.get_main_loop() works as expected.
################################################################################
tool
extends Control

export(String) var _select_script = ''
export(String) var _tests_like = ''
export(String) var _inner_class_name = ''

export var _run_on_load = false
export var _should_maximize = false

export var _should_print_to_console = true
export(int, 'Failures only', 'Tests and failures', 'Everything') var _log_level = 1
export var _yield_between_tests = true
export var _disable_strict_datatype_checks = false
export var _test_prefix = 'test_'
export var _file_prefix = 'test_'
export var _file_extension = '.gd'
export var _inner_class_prefix = 'Test'

export(String) var _temp_directory = 'user://gut_temp_directory'
export(String) var _export_path = ''

export var _include_subdirectories = false
# Allow user to add test directories via editor.  This is done with strings
# instead of an array because the interface for editing arrays is really
# cumbersome and complicates testing because arrays set through the editor
# apply to ALL instances.  This also allows the user to use the built in
# dialog to pick a directory.
export(String, DIR) var _directory1 = ''
export(String, DIR) var _directory2 = ''
export(String, DIR) var _directory3 = ''
export(String, DIR) var _directory4 = ''
export(String, DIR) var _directory5 = ''
export(String, DIR) var _directory6 = ''
# Must match the types in _utils for double strategy
export(int, 'FULL', 'PARTIAL') var _double_strategy = 1
export(String, FILE) var _pre_run_script = ''
export(String, FILE) var _post_run_script = ''
export(bool) var _color_output = false

var _gut = null
func _ready():
	# Must call this deferred so that there is enough time for
	# Engine.get_main_loop() is populated and the psuedo singleton utils.gd
	# can be setup correctly.
	call_deferred('_deferred_ready')

func _deferred_ready():
	_gut = load('res://addons/gut/gut.gd').new()

	_gut.add_directory(_directory1)
	_gut.add_directory(_directory2)
	_gut.add_directory(_directory3)
	_gut.add_directory(_directory4)
	_gut.add_directory(_directory5)
	_gut.add_directory(_directory6)

	_gut._select_script = _select_script
	_gut._tests_like = _tests_like
	_gut._inner_class_name = _inner_class_name
	_gut._run_on_load = _run_on_load

	_gut._test_prefix = _test_prefix
	_gut._file_prefix = _file_prefix
	_gut._file_extension = _file_extension
	_gut._inner_class_prefix = _inner_class_prefix
	_gut._temp_directory = _temp_directory

	_gut.set_should_maximize(_should_maximize)

	_gut.set_should_print_to_console(_should_print_to_console)

	_gut.set_yield_between_tests(_yield_between_tests)
	_gut.disable_strict_datatype_checks(_disable_strict_datatype_checks)
	_gut.set_export_path(_export_path)
	_gut.set_include_subdirectories(_include_subdirectories)
	_gut.set_double_strategy(_double_strategy)
	_gut.set_pre_run_script(_pre_run_script)
	_gut.set_post_run_script(_post_run_script)
	_gut.set_color_output(_color_output)

	#get_tree().root.add_child(_gut)
	get_parent().add_child(_gut)

	_gut.set_log_level(_log_level)