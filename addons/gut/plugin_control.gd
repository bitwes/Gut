tool
extends Control

export(String) var _select_script = ''
export(String) var _tests_like = ''
export(String) var _inner_class_name = ''

export var _run_on_load = false
export var _should_maximize = false setget set_should_maximize, get_should_maximize

export var _should_print_to_console = true setget set_should_print_to_console, get_should_print_to_console
export(int, 'Failures only', 'Tests and failures', 'Everything') var _log_level = 1 setget set_log_level, get_log_level
# This var is JUST used to expose this setting in the editor
# the var that is used is in the _yield_between hash.
export var _yield_between_tests = true setget set_yield_between_tests, get_yield_between_tests
export var _disable_strict_datatype_checks = false setget disable_strict_datatype_checks, is_strict_datatype_checks_disabled
# The prefix used to get tests.
export var _test_prefix = 'test_'
export var _file_prefix = 'test_'
export var _file_extension = '.gd'
export var _inner_class_prefix = 'Test'

export(String) var _temp_directory = 'user://gut_temp_directory'
export(String) var _export_path = '' setget set_export_path, get_export_path

export var _include_subdirectories = false setget set_include_subdirectories, get_include_subdirectories
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
export(int, 'FULL', 'PARTIAL') var _double_strategy = 1 setget set_double_strategy, get_double_strategy
export(String, FILE) var _pre_run_script = '' setget set_pre_run_script, get_pre_run_script
export(String, FILE) var _post_run_script = '' setget set_post_run_script, get_post_run_script
export(bool) var _color_output = false setget set_color_output, get_color_output

var _gut = null
func _ready():
	call_deferred('_deferred_ready')

func _deferred_ready():
	_gut = load('res://addons/gut/gut.gd').new()

	_gut._directory1 = _directory1
	_gut._directory2 = _directory2
	_gut._directory3 = _directory3
	_gut._directory4 = _directory4
	_gut._directory5 = _directory5
	_gut._directory6 = _directory6

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

# ---------------------------------------------
# Accessors
# ---------------------------------------------
func get_color_output():
	return _color_output

func set_color_output(color_output):
	_color_output = color_output

func get_post_run_script():
	return _post_run_script

func set_post_run_script(post_run_script):
	_post_run_script = post_run_script

func get_pre_run_script():
	return _pre_run_script

func set_pre_run_script(pre_run_script):
	_pre_run_script = pre_run_script

func get_double_strategy():
	return _double_strategy

func set_double_strategy(double_strategy):
	_double_strategy = double_strategy

func get_include_subdirectories():
	return _include_subdirectories

func set_include_subdirectories(include_subdirectories):
	_include_subdirectories = include_subdirectories

func get_export_path():
	return _export_path

func set_export_path(export_path):
	_export_path = export_path

func is_strict_datatype_checks_disabled():
	return _disable_strict_datatype_checks

func disable_strict_datatype_checks(disable_strict_datatype_checks):
	_disable_strict_datatype_checks = disable_strict_datatype_checks

func get_yield_between_tests():
	return _yield_between_tests

func set_yield_between_tests(yield_between_tests):
	_yield_between_tests = yield_between_tests

func get_log_level():
	return _log_level

func set_log_level(log_level):
	_log_level = log_level

func get_should_maximize():
	return _should_maximize

func set_should_maximize(should_maximize):
	_should_maximize = should_maximize

func get_should_print_to_console():
	return _should_print_to_console

func set_should_print_to_console(should_print_to_console):
	_should_print_to_console = should_print_to_console
