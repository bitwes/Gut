extends Control
tool

var _interface = null
var _utils = load('res://addons/gut/utils.gd').new()

var ScriptResult = load('res://addons/gut/gui/ScriptResult.tscn')
var TestResult = load('res://addons/gut/gui/TestResult.tscn')

var _hide_passing = true
var _font = null
var _font_size = null

signal search_for_text(text)

onready var _ctrls = {
	vbox = $Panel/Scroll/VBox
}


func _ready():
	if(get_parent() == get_tree().root):
		var _gut_config = load('res://addons/gut/gut_config.gd').new()
		_gut_config.load_panel_options('res://.gut_editor_config.json')
		set_font(
			_gut_config.options.panel_options.font_name, 
			_gut_config.options.panel_options.font_size)
		load_json_file('user://.gut_editor.json')


func _open_file(path, line_number):
	if(_interface == null):
		print('Too soon, wait a bit and try again.')
		return

	var r = load(path)
	if(line_number != -1):
		_interface.edit_script(r, line_number)
	else:
		_interface.edit_script(r)


func _add_script_ctrl(script_path, script_json):
	var obj = ScriptResult.instance()
	_ctrls.vbox.add_child(obj)
	obj.set_font(_font, _font_size * 1.15)
	obj.set_name(script_path)
	var status_text = str(script_json.props.failures , '/',
		script_json.props.tests)
	obj.set_status(status_text)
	obj.visible = !_hide_passing

	return obj


func _add_test_ctrl_to_script_ctrl(test_name, test_json, script_ctrl):
	var obj = TestResult.instance()
	obj.visible = false
	var test_row = script_ctrl.add_test_result(obj)
	obj.set_font(_font)
	obj.set_name(test_name)
	obj.set_goto(script_ctrl.get_path(), -1)
	obj.set_data(test_name, test_json)
	
	obj.visible = !_hide_passing or(_hide_passing and  test_json.status != 'pass')
	test_row.visible = obj.visible
	if(_hide_passing and obj.visible):
		script_ctrl.visible = true
		
	script_ctrl.update_name_display()
	return obj


func _on_test_result_goto(path, line, method_name=''):
	if(_interface):
		_open_file(path, line)
		if(line == -1 and method_name != ''):
			emit_signal('search_for_text', method_name)
	else:
		print('going to ', path, '@', line)


func load_json_file(path):
	var text = _utils.get_file_as_text('user://.gut_editor.json')
	var j = JSON.parse(text).result
	load_json_results(j)
	

func load_json_results(j):
	clear()

	var scripts = j['test_scripts']['scripts']
	var script_keys = scripts.keys()
	for key in script_keys:
		var tests = scripts[key]['tests']
		var test_keys = tests.keys()
		var script_obj = _add_script_ctrl(key, scripts[key])
		
		for test_key in test_keys:			
			var test_obj = _add_test_ctrl_to_script_ctrl(test_key, tests[test_key], script_obj)
			test_obj.connect('goto', self, '_on_test_result_goto')

	_show_all_passed()


func add_centered_text(t):
	var row = HBoxContainer.new()
	row.alignment = row.ALIGN_CENTER
	row.size_flags_vertical = row.SIZE_EXPAND_FILL
	
	var lbl = Label.new()
	row.add_child(lbl)
	lbl.text = t
	_ctrls.vbox.add_child(row)
	

func _show_all_passed():
	var kids = _ctrls.vbox.get_children()
	var i = 0
	while(i < kids.size() and !kids[i].visible):
		i += 1
		
	print(i, '=', kids.size())
	if(i == kids.size()):
		add_centered_text('Everything passed!')


func clear():
	var kids = _ctrls.vbox.get_children()
	for kid in kids:
		kid.free()
	
	
func set_interface(which):
	_interface = which


func set_font(font_name, size):
	var dyn_font = DynamicFont.new()
	var font_data = DynamicFontData.new()
	font_data.font_path = 'res://addons/gut/fonts/' + font_name + '-Regular.ttf'
	font_data.antialiased = true
	dyn_font.font_data = font_data

	_font = dyn_font
	_font.size = size
	_font_size = size
