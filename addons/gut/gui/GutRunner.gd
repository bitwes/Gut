# ##############################################################################
# This class joins together GUT, GUT Gui, GutConfig and is the main way to
# run a test suite.
#
# This creates its own instance of gut.gd that it manages.
# Use set_gut_config to set the gut_config.gd that should be used to configure
# gut.
# This will create a GUI and wire it up and apply gut_config.gd options.
#
# Running tests:
# By default, this will run tests once this control has been added to the tree.
# You can override this by setting auto_run_tests to false prior to adding
# this to the tree.  To run tests manually, call run_tests.
#
# ##############################################################################
extends Node2D

var Gut = load('res://addons/gut/gut.gd')
var ResultExporter = load('res://addons/gut/result_exporter.gd')
var GutConfig = load('res://addons/gut/gut_config.gd')

const RUNNER_JSON_PATH = 'res://.gut_editor_config.json'
const RESULT_FILE = 'user://.gut_editor.bbcode'
const RESULT_JSON = 'user://.gut_editor.json'

var _gut_config = null
var _gut = null;
var _wrote_results = false
# Flag for when this is being used at the command line.  Otherwise it is
# assumed this is being used by the panel and being launched with
# play_custom_scene
var _cmdln_mode = false

@onready var _gut_layer = $GutLayer
@onready var _gui = $GutLayer/GutScene

# When true, tests will be kicked off in _ready.
var auto_run_tests = true

func _ready():
	if(_gut_config == null):
		_gut_config = GutConfig.new()
		_gut_config.load_panel_options(RUNNER_JSON_PATH)

	# The command line will call run_tests on its own.  When used from the panel
	# we have to kick off the tests ourselves b/c there's no way I know of to
	# interact with the scene that was run via play_custom_scene.
	if(!_cmdln_mode and auto_run_tests):
		call_deferred('run_tests')


func _lazy_make_gut():
	if(_gut == null):
		_gut = Gut.new()


func _setup_gui(show_gui):
	if(show_gui):
		_gui.gut = _gut
		var printer = _gut.logger.get_printer('gui')
		printer.set_textbox(_gui.get_textbox())
	else:
		_gut.logger.disable_printer('gui', true)
		_gui.visible = false

	var opts = _gut_config.options
	_gui.set_font_size(opts.font_size)
	_gui.set_font(opts.font_name)
	if(opts.font_color != null and opts.font_color.is_valid_html_color()):
		_gui.set_default_font_color(Color(opts.font_color))
	if(opts.background_color != null and opts.background_color.is_valid_html_color()):
		_gui.set_background_color(Color(opts.background_color))

	_gui.set_opacity(min(1.0, float(opts.opacity) / 100))
	# if(opts.should_maximize):
	# 	_tester.maximize()
	_gui.use_compact_mode(opts.compact_mode)



func _write_results():
	var content = _gui.get_textbox().get_parsed_text() #_gut.logger.get_gui_bbcode()
	var f = FileAccess.open(RESULT_FILE, FileAccess.WRITE)
	if(f != null):
		f.store_string(content)
		f = null # closes file
	else:
		push_error('Could not save bbcode, result = ', FileAccess.get_open_error())

	var exporter = ResultExporter.new()
	var f_result = exporter.write_json_file(_gut, RESULT_JSON)
	_wrote_results = true


func _exit_tree():
	if(!_wrote_results and !_cmdln_mode):
		_write_results()


func _on_tests_finished(should_exit, should_exit_on_success):
	_write_results()

	if(should_exit):
		get_tree().quit()
	elif(should_exit_on_success and _gut.get_fail_count() == 0):
		get_tree().quit()


func run_tests(show_gui=true):
	_lazy_make_gut()

	_setup_gui(show_gui)

	_gut.add_children_to = self
	if(_gut.get_parent() == null):
		if(_gut_config.options.gut_on_top):
			_gut_layer.add_child(_gut)
		else:
			add_child(_gut)

	if(!_cmdln_mode):
		_gut.end_run.connect(_on_tests_finished.bind(_gut_config.options.should_exit, _gut_config.options.should_exit_on_success))

	_gut_config.apply_options(_gut)
	var run_rest_of_scripts = _gut_config.options.unit_test_name == ''

	_gut.test_scripts(run_rest_of_scripts)


func get_gut():
	_lazy_make_gut()
	return _gut


func set_gut_config(which):
	_gut_config = which


func set_cmdln_mode(is_it):
	_cmdln_mode = is_it




# ##############################################################################
# The MIT License (MIT)
# =====================
#
# Copyright (c) 2023 Tom "Butch" Wesley
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#
# ##############################################################################
