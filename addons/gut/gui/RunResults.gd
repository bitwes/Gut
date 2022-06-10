extends Control
tool

var _interface = null
var _utils = load('res://addons/gut/utils.gd').new()

var ScriptResult = load('res://addons/gut/gui/ScriptResult.tscn')
var TestResult = load('res://addons/gut/gui/TestResult.tscn')

var _hide_passing = true
var _font = null
var _font_size = null

var _root = null
var _icons = {
	red = load('res://addons/gut/images/red.png'),
	green = load('res://addons/gut/images/green.png'),
	yellow = load('res://addons/gut/images/yellow.png'),
}

signal search_for_text(text)

onready var _ctrls = {
#	vbox = $Panel/Scroll/VBox,
	tree = $Panel/Scroll/Tree,
	lbl_overlay = $Panel/OverlayMessage
}


func _ready():
	_root = _ctrls.tree.create_item()
	_ctrls.tree.set_hide_root(true)
	_ctrls.tree.columns = 2
#	_ctrls.tree.set_column_title(0, 'Thing')
#	_ctrls.tree.set_column_title(1, 'Status')
#	_ctrls.tree.set_column_titles_visible(true)
	_ctrls.tree.set_column_expand(0, true)
	_ctrls.tree.set_column_expand(1, false)
	_ctrls.tree.set_column_min_width(1, 150)
	
	if(get_parent() == get_tree().root):
		_hide_passing = false
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


func _load_result_tree(j):
	var scripts = j['test_scripts']['scripts']
	var script_keys = scripts.keys()
	for key in script_keys:
		var tests = scripts[key]['tests']
		var test_keys = tests.keys()
		var s_item = _add_script_tree_item(key, scripts[key])
		var bad_count = 0
		for test_key in test_keys:
			var t_item = _add_test_tree_item(test_key, tests[test_key], s_item)
			if(tests[test_key].status != 'pass'):
				bad_count += 1
		
		# get_children returns the first child or null.  its a dumb name.
		if(s_item.get_children() == null):
			s_item.free()
		else:
			if(bad_count == 0):
				s_item.collapsed = true
			s_item.set_text(1, str(bad_count, '/', test_keys.size()))
			
	_show_all_passed()



func _add_script_tree_item(script_path, script_json):
	var item = _ctrls.tree.create_item(_root)
	item.set_text(0, script_path)
	var meta = {"type":"script", "json":script_json}
	item.set_metadata(0, meta)
	
	return item
	
func _add_test_tree_item(test_name, test_json, script_item):
	if(_hide_passing and test_json['status'] == 'pass'):
		return
	
	var item = _ctrls.tree.create_item(script_item)
	var status = test_json['status']
	item.set_text(0, test_name)
	item.set_text(1, status)
	var meta = {"type":"test", "json":test_json}
	item.set_metadata(0, meta)
	item.set_icon_max_width(0, 10)
	
	if(status == 'pass'):
		item.set_icon(0, _icons.green)
	elif(status == 'fail'):
		item.set_icon(0, _icons.red)
	else:
		item.set_icon(0, _icons.yellow)
	
	for failure in test_json.failing:
		var assert_item = _ctrls.tree.create_item(item)
		assert_item.set_icon_max_width(0, 10)
		assert_item.set_text(0, "fail:  " + failure.replace("\n", ''))
		assert_item.set_metadata(0, {"type":"assert"})
		assert_item.set_icon(0, _icons.red)

	for pending in test_json.pending:
		var assert_item = _ctrls.tree.create_item(item)
		assert_item.set_icon_max_width(0, 10)
		assert_item.set_text(0, "pending:  " + pending.replace("\n", ''))
		assert_item.set_metadata(0, {"type":"assert"})
		assert_item.set_icon(0, _icons.yellow)

		
	return item

func _on_Tree_item_selected():
	var item = _ctrls.tree.get_selected()
	var item_type = item.get_metadata(0).type
	
	var path = '';
	var line = -1;
	var search = ''
	
	if(item_type == 'test'):
		path = item.get_parent().get_text(0)
		search = item.get_text(0)
	elif(item_type == 'assert'):
		path = item.get_parent().get_parent().get_text(0)
		if(item.get_text(0).find('at line') > 0):
			line = int(item.get_text(0).split("at line")[-1].split(" ")[-1])
		search = item.get_parent().get_text(0)
		
	if !path.ends_with('.gd'):
		var loc = path.find('.gd')
		path = path.substr(0, loc + 3)

	_on_test_result_goto(path, line, search)


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
		print('going to ', path, '@', line, ' ', method_name)


func load_json_file(path):
	var text = _utils.get_file_as_text(path)
	var j = JSON.parse(text).result
	load_json_results(j)
	

func _load_result_controls(j):
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
	


func load_json_results(j):
	clear()
	_load_result_tree(j)



func add_centered_text(t):
	_ctrls.lbl_overlay.text = t
	
#	var row = HBoxContainer.new()
#	row.alignment = row.ALIGN_CENTER
#	row.size_flags_vertical = row.SIZE_EXPAND_FILL
#
#	var lbl = Label.new()
#	row.add_child(lbl)
#	lbl.text = t
#	_ctrls.vbox.add_child(row)
	

func _show_all_passed():
	if(_root.get_children() == null):
		add_centered_text('Everything passed!')

#	var kids = _ctrls.vbox.get_children()
#	var i = 0
#	while(i < kids.size() and !kids[i].visible):
#		i += 1
#
#	print(i, '=', kids.size())
#	if(i == kids.size()):
#		add_centered_text('Everything passed!')


func clear():
	_ctrls.tree.clear()
	_root = _ctrls.tree.create_item()
	_ctrls.lbl_overlay.text = ''
#	var kids = _ctrls.vbox.get_children()
#	for kid in kids:
#		kid.free()
	
	
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
