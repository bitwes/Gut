tool
extends Control

const RUNNER_JSON_PATH = 'res://addons/gut/gui/runner.json'
const RESULT_FILE = 'user://_gut_runner_.bbcode'

var TestScript = load('res://addons/gut/test.gd')
var GutConfigGui = load('res://addons/gut/gui/gut_config_gui.gd')

var _utils = null
var _interface = null;
var _pid = null;
var _is_running = false;
var _gut_config = load('res://addons/gut/gut_config.gd').new()
var _gut_config_gui = null
var _gut_plugin = null

onready var _ctrls = {
	output = $layout/RSplit/Output,
	run_button = $layout/cp/sc/vbox/HRunAll/RunTests,
	last_run_label = $layout/cp/sc/vbox/HRerun/LastRunLabel,
	run_like = {
		hbox = $layout/cp/sc/vbox/HRunLike,
		button = $layout/cp/sc/vbox/HRunLike/VRunButton/RunLikeButton,
		txt_script = $layout/cp/sc/vbox/HRunLike/VInputs/txtScriptName,
		txt_inner = $layout/cp/sc/vbox/HRunLike/VInputs/txtInnerName,
		txt_test = $layout/cp/sc/vbox/HRunLike/VInputs/txtTestName
	},
	run_current = {
		hbox = $layout/cp/sc/vbox/HRunCurrent,
		label = $layout/cp/sc/vbox/HRunCurrent/ScriptName,
		button = $layout/cp/sc/vbox/HRunCurrent/RunCurrent
	},
	settings = $layout/RSplit/Settings
}

func _init():
	_gut_config.load_options(RUNNER_JSON_PATH)

func _ready():
	# _utils = load('res://addons/gut/utils.gd').get_instance()
	_ctrls.run_like.hbox.connect("draw", self, '_draw_bg_box', [_ctrls.run_like.hbox])
	if(_interface):
		_interface.get_script_editor().connect("editor_script_changed", self, '_on_editor_script_changed')

	# _gut_config_gui = GutConfigGui.new(_ctrls.settings)
	# _gut_config_gui.set_options(_gut_config.options)


func _is_test_script(script):
	var from = script.get_base_script()
	while(from and from.resource_path != 'res://addons/gut/test.gd'):
		from = from.get_base_script()

	return from != null


func _on_editor_script_changed(script):
	if(script):
		var file = script.resource_path.get_file()
		_ctrls.run_current.label.text = file
		if(_is_test_script(script)):
			_ctrls.run_current.button.disabled = false
			_ctrls.run_current.label.modulate = Color(.5, 1, .5)
		else:
			_ctrls.run_current.button.disabled = true
			_ctrls.run_current.label.modulate = Color(1, .5, .5)


func _draw_bg_box(which):
	which.draw_rect(Rect2(Vector2(0, 0), which.rect_size), Color(0, 0, 0, .15))


func ___process(delta):
	if(_is_running):
		if(!_interface.is_playing_scene()):
			_is_running = false
			_ctrls.output.add_text("\ndone")
			load_result_output()
			_gut_plugin.make_bottom_panel_item_visible(self)


func load_result_output():
	_ctrls.output.bbcode_text = _utils.get_file_as_text(RESULT_FILE)
	_ctrls.output.grab_focus()
	_ctrls.output.scroll_to_line(_ctrls.output.get_line_count() -1)


func _update_last_run_label():
	var text = ''

	if(	_gut_config.options.selected == null and
		_gut_config.options.inner_class == null and
		_gut_config.options.unit_test_name == null):
		text = 'All'
	else:
		text = _utils.nvl(_gut_config.options.selected, '') + ' '
		text += _utils.nvl(_gut_config.options.inner_class, '') + ' '
		text += _utils.nvl(_gut_config.options.unit_test_name, '')

	_ctrls.last_run_label.text = text


func _run_tests():
	# _utils.write_file(RESULT_FILE, 'Run in progress')
	# _gut_config.options = _gut_config_gui.get_options(_gut_config.options)
	# print(JSON.print(_gut_config.options, ' '))
	# var w_result = _gut_config.write_options(RUNNER_JSON_PATH)
	# if(w_result != OK):
	# 	push_error(str('Could not write options to ', RUNNER_JSON_PATH, ': ', w_result))
	# 	return;

	_ctrls.output.clear()

	# _update_last_run_label()
	_interface.play_custom_scene('res://addons/gut/gui/GutRunner.tscn')

	_is_running = true
	# _ctrls.output.add_text('running...')


func _on_RunTests_pressed():
	_gut_config.options.selected = null
	_gut_config.options.inner_class = null
	_gut_config.options.unit_test_name = null

	_run_tests()


func _on_RunCurrent_pressed():
	var script = _interface.get_script_editor().get_current_script()
	_gut_config.options.inner_class = null
	_gut_config.options.unit_test_name = null

	if(script != null):
		print(script.resource_path)
		_gut_config.options.selected = script.resource_path.get_file()
	_run_tests()


func _on_Rerun_pressed():
	_run_tests()


func _on_RunLikeButton_pressed():
	_gut_config.options.selected = _ctrls.run_like.txt_script.text
	_gut_config.options.inner_class = _ctrls.run_like.txt_inner.text
	_gut_config.options.unit_test_name = _ctrls.run_like.txt_test.text

	_run_tests()
