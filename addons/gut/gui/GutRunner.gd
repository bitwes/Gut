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
# You can override this by setting ran_from_editor to false before adding
# this to the tree.  To run tests manually, call run_tests.
#
# ##############################################################################
extends Node2D

var Gut = load('res://addons/gut/gut.gd')
var ResultExporter = load('res://addons/gut/result_exporter.gd')
var GutConfig = load('res://addons/gut/gut_config.gd')

var runner_json_path = null
var result_bbcode_path = null
var result_json_path = null

var _gut_config = null
var _hid_gut = null;
var gut = _hid_gut :
	get:
		if(_hid_gut == null):
			_hid_gut = Gut.new()
		return _hid_gut
var _wrote_results = false

# The editor runs this scene using play_custom_scene, which means we cannot
# pass any info directly to the scene.  Whenever this is being used from
# somewhere else, you probably want to set this to false before adding this
# to the tree.
var ran_from_editor = true

@onready var _gut_layer = $GutLayer
@onready var _gui = $GutLayer/GutScene


func _ready():
	print('---  GUT  ---')
	GutUtils.WarningsManager.apply_warnings_dictionary(
		GutUtils.warnings_at_start)
	GutUtils.LazyLoader.load_all()

	# When used from the panel we have to kick off the tests ourselves b/c
	# there's no way I know of to interact with the scene that was run via
	# play_custom_scene.
	if(ran_from_editor):
		var GutEditorGlobals = load('res://addons/gut/gui/editor_globals.gd')
		runner_json_path = GutUtils.nvl(runner_json_path, GutEditorGlobals.editor_run_gut_config_path)
		result_bbcode_path = GutUtils.nvl(result_bbcode_path, GutEditorGlobals.editor_run_bbcode_results_path)
		result_json_path = GutUtils.nvl(result_json_path, GutEditorGlobals.editor_run_json_results_path)

		if(_gut_config == null):
			_gut_config = GutConfig.new()
			_gut_config.load_options(runner_json_path)

		call_deferred('run_tests')


func _exit_tree():
	if(!_wrote_results and ran_from_editor):
		_write_results()


func _setup_gui(show_gui):
	if(show_gui):
		_gui.gut = gut
		var printer = gut.logger.get_printer('gui')
		printer.set_textbox(_gui.get_textbox())
	else:
		gut.logger.disable_printer('gui', true)
		_gui.visible = false

	var opts = _gut_config.options
	_gui.set_font_size(opts.font_size)
	_gui.set_font(opts.font_name)
	if(opts.font_color != null and opts.font_color.is_valid_html_color()):
		_gui.set_default_font_color(Color(opts.font_color))
	if(opts.background_color != null and opts.background_color.is_valid_html_color()):
		_gui.set_background_color(Color(opts.background_color))

	_gui.set_opacity(min(1.0, float(opts.opacity) / 100))
	_gui.use_compact_mode(opts.compact_mode)


func _write_results():
	var content = _gui.get_textbox().get_parsed_text() #_gut.logger.get_gui_bbcode()
	var f = FileAccess.open(result_bbcode_path, FileAccess.WRITE)
	if(f != null):
		f.store_string(content)
		f = null # closes file
	else:
		push_error('Could not save bbcode, result = ', FileAccess.get_open_error())

	var exporter = ResultExporter.new()
	# TODO this should be checked and _wrote_results should maybe not be set, or
	# maybe we do not care.  Whichever, it should be clear.
	var _f_result = exporter.write_json_file(gut, result_json_path)
	_wrote_results = true



# -------------
# Events
# -------------
func _on_tests_finished(should_exit, should_exit_on_success):
	_write_results()

	if(should_exit):
		get_tree().quit()
	elif(should_exit_on_success and gut.get_fail_count() == 0):
		get_tree().quit()



# -------------
# Public
# -------------
func run_tests(show_gui=true):
	var install_check_text = GutUtils.make_install_check_text()
	if(install_check_text != GutUtils.INSTALL_OK_TEXT):
		print("\n\n", GutUtils.version_numbers.get_version_text())
		push_error(install_check_text)
		return

	_setup_gui(show_gui)

	gut.add_children_to = self
	if(gut.get_parent() == null):
		if(_gut_config.options.gut_on_top):
			_gut_layer.add_child(gut)
		else:
			add_child(gut)

	if(ran_from_editor):
		gut.end_run.connect(_on_tests_finished.bind(
			_gut_config.options.should_exit,
			_gut_config.options.should_exit_on_success))

	_gut_config.apply_options(gut)
	var run_rest_of_scripts = _gut_config.options.unit_test_name == ''

	gut.test_scripts(run_rest_of_scripts)


func set_gut_config(which):
	_gut_config = which


# for backwards compatibility
func get_gut():
	return gut

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
