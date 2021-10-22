tool
extends Control

const RUNNER_JSON_PATH = 'res://.gut_editor_config.json'
const RESULT_FILE = 'user://.gut_editor.bbcode'
const RESULT_JSON = 'user://.gut_editor.json'
const SHORTCUTS_PATH = 'res://.gut_editor_shortcuts.cfg'

var TestScript = load('res://addons/gut/test.gd')
var GutConfigGui = load('res://addons/gut/gui/gut_config_gui.gd')

var _interface = null;
var _is_running = false;
var _gut_config = load('res://addons/gut/gut_config.gd').new()
var _gut_config_gui = null
var _gut_plugin = null
var _light_color = Color(0, 0, 0, .5)


onready var _ctrls = {
	output = $layout/RSplit/CResults/Output,
	run_button = $layout/ControlBar/RunAll,
	settings = $layout/RSplit/sc/Settings,
	shortcut_dialog = $BottomPanelShortcuts,
	light = $layout/RSplit/CResults/ControlBar/Light,
	run_like = {
		button = $layout/ControlBar/RunLike,
		txt_script = $layout/ControlBar/CScript/txtScript,
		txt_inner = $layout/ControlBar/CInner/txtInner,
		txt_test = $layout/ControlBar/CTest/txtTest,
	},
	run_current = {
		button = $layout/ControlBar/RunCurrent,
	},
	rerun = {
		button = $layout/ControlBar/Rerun,
	},
	results = {
		passing = $layout/RSplit/CResults/ControlBar/lblPassingValue,
		failing = $layout/RSplit/CResults/ControlBar/lblFailingValue,
		pending = $layout/RSplit/CResults/ControlBar/lblPendingValue
	}

}


func _init():
	_gut_config.load_options(RUNNER_JSON_PATH)


func _ready():
	_gut_config_gui = GutConfigGui.new(_ctrls.settings)
	_gut_config_gui.set_options(_gut_config.options)
	_set_all_fonts_in_ftl(_ctrls.output, _gut_config.options.font_name)
	_set_font_size_for_rtl(_ctrls.output, _gut_config.options.font_size)
	_ctrls.shortcut_dialog.load_shortcuts(SHORTCUTS_PATH)
	_apply_shortcuts()

func _process(delta):
	if(_is_running):
		if(!_interface.is_playing_scene()):
			_is_running = false
			_ctrls.output.add_text("\ndone")
			load_result_output()
			_gut_plugin.make_bottom_panel_item_visible(self)

# ---------------
# Private
# ---------------

# -----------------------------------
func _set_font(rtl, font_name, custom_name):
	if(font_name == null):
		rtl.set('custom_fonts/' + custom_name, null)
	else:
		var dyn_font = DynamicFont.new()
		var font_data = DynamicFontData.new()
		font_data.font_path = 'res://addons/gut/fonts/' + font_name + '.ttf'
		font_data.antialiased = true
		dyn_font.font_data = font_data
		rtl.set('custom_fonts/' + custom_name, dyn_font)


func _set_all_fonts_in_ftl(ftl, base_name):
	if(base_name == 'Default'):
		_set_font(ftl, null, 'normal_font')
		_set_font(ftl, null, 'bold_font')
		_set_font(ftl, null, 'italics_font')
		_set_font(ftl, null, 'bold_italics_font')
	else:
		_set_font(ftl, base_name + '-Regular', 'normal_font')
		_set_font(ftl, base_name + '-Bold', 'bold_font')
		_set_font(ftl, base_name + '-Italic', 'italics_font')
		_set_font(ftl, base_name + '-BoldItalic', 'bold_italics_font')


func _set_font_size_for_rtl(rtl, new_size):
	if(rtl.get('custom_fonts/normal_font') != null):
		rtl.get('custom_fonts/bold_italics_font').size = new_size
		rtl.get('custom_fonts/bold_font').size = new_size
		rtl.get('custom_fonts/italics_font').size = new_size
		rtl.get('custom_fonts/normal_font').size = new_size
# -----------------------------------


func _is_test_script(script):
	var from = script.get_base_script()
	while(from and from.resource_path != 'res://addons/gut/test.gd'):
		from = from.get_base_script()

	return from != null

func _update_last_run_label():
	var text = ''

	if(	_gut_config.options.selected == null and
		_gut_config.options.inner_class == null and
		_gut_config.options.unit_test_name == null):
		text = 'All'
	else:
		text = nvl(_gut_config.options.selected, '') + ' '
		text += nvl(_gut_config.options.inner_class, '') + ' '
		text += nvl(_gut_config.options.unit_test_name, '')

	_ctrls.rerun.button.text = str('Rerun(', text.strip_edges(), ')')


func _run_tests():
	_ctrls.rerun.button.disabled = false
	write_file(RESULT_FILE, 'Run in progress')
	_gut_config.options = _gut_config_gui.get_options(_gut_config.options)
	_set_all_fonts_in_ftl(_ctrls.output, _gut_config.options.font_name)
	_set_font_size_for_rtl(_ctrls.output, _gut_config.options.font_size)

	var w_result = _gut_config.write_options(RUNNER_JSON_PATH)
	if(w_result != OK):
		push_error(str('Could not write options to ', RUNNER_JSON_PATH, ': ', w_result))
		return;

	_ctrls.output.clear()

	_update_last_run_label()
	_interface.play_custom_scene('res://addons/gut/gui/GutRunner.tscn')

	_is_running = true
	_ctrls.output.add_text('running...')

func _apply_shortcuts():
	_ctrls.run_button.shortcut = _ctrls.shortcut_dialog.get_run_all()
	_ctrls.rerun.button.shortcut = _ctrls.shortcut_dialog.get_rerun()
	_ctrls.run_current.button.shortcut = _ctrls.shortcut_dialog.get_run_current()
	_ctrls.run_like.button.shortcut = _ctrls.shortcut_dialog.get_run_like()


func _save_shortcuts():
	pass


func _load_shortcuts():
	pass

# ---------------
# Events
# ---------------
func _on_editor_script_changed(script):
	if(script):
		set_current_script(script)

func _on_RunAll_pressed():
	_on_RunTests_pressed()


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
		_gut_config.options.selected = script.resource_path.get_file()
	_run_tests()


func _on_Rerun_pressed():
	_run_tests()


func _on_RunLike_pressed():
	_on_RunLikeButton_pressed()


func _on_RunLikeButton_pressed():
	_gut_config.options.selected = _ctrls.run_like.txt_script.text
	_gut_config.options.inner_class = _ctrls.run_like.txt_inner.text
	_gut_config.options.unit_test_name = _ctrls.run_like.txt_test.text

	_run_tests()

func _on_CopyButton_pressed():
	OS.clipboard = _ctrls.output.text


func _on_ClearButton_pressed():
	_ctrls.output.clear()


func _on_Shortcuts_pressed():
	_ctrls.shortcut_dialog.popup_centered()


func _on_BottomPanelShortcuts_popup_hide():
	_apply_shortcuts()
	_ctrls.shortcut_dialog.save_shortcuts(SHORTCUTS_PATH)


func _on_Light_draw():
	var l = _ctrls.light
	l.draw_circle(Vector2(l.rect_size.x / 2, l.rect_size.y / 2), l.rect_size.x / 2, _light_color)

# ---------------
# Public
# ---------------

func load_result_output():
	_ctrls.output.bbcode_text = get_file_as_text(RESULT_FILE)
	_ctrls.output.grab_focus()
	_ctrls.output.scroll_to_line(_ctrls.output.get_line_count() -1)

	var summary = get_file_as_text(RESULT_JSON)
	var results = JSON.parse(summary)
	if(results.error != OK):
		return
	var summary_json = results.result['test_scripts']['props']
	_ctrls.results.passing.text = str(summary_json.passing)
	_ctrls.results.failing.text = str(summary_json.failures)
	_ctrls.results.pending.text = str(summary_json.pending)
	
	if(summary_json.failures != 0):
		_light_color = Color(1, 0, 0, .75)
	elif(summary_json.pending != 0):
		_light_color = Color(1, 1, 0, .75)
	else:
		_light_color = Color(0, 1, 0, .75)
	_ctrls.light.update()
	


func set_current_script(script):
	if(script):
		var file = script.resource_path.get_file()
		_ctrls.run_current.button.text = str(file)
		if(_is_test_script(script)):
			_ctrls.run_current.button.text = str(file)
			_ctrls.run_current.button.disabled = false
			# _ctrls.run_current.button.modulate = Color(.5, 1, .5)
		else:
			_ctrls.run_current.button.disabled = true
			# _ctrls.run_current.button.modulate = Color(1, .5, .5)
	else:
		_ctrls.run_current.button.disabled = true
		_ctrls.run_current.button.text = 'None Selected'


func set_interface(value):
	_interface = value
	_interface.get_script_editor().connect("editor_script_changed", self, '_on_editor_script_changed')
	set_current_script(_interface.get_script_editor().get_current_script())


func set_plugin(value):
	_gut_plugin = value


# ------------------------------------------------------------------------------
# Write a file.
# ------------------------------------------------------------------------------
func write_file(path, content):
	var f = File.new()
	var result = f.open(path, f.WRITE)
	if(result == OK):
		f.store_string(content)
		f.close()
	return result


# ------------------------------------------------------------------------------
# Returns the text of a file or an empty string if the file could not be opened.
# ------------------------------------------------------------------------------
func get_file_as_text(path):
	var to_return = ''
	var f = File.new()
	var result = f.open(path, f.READ)
	if(result == OK):
		to_return = f.get_as_text()
		f.close()
	return to_return


# ------------------------------------------------------------------------------
# return if_null if value is null otherwise return value
# ------------------------------------------------------------------------------
func nvl(value, if_null):
	if(value == null):
		return if_null
	else:
		return value
