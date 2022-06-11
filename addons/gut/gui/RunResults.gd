extends Control
tool

var _interface = null
var _utils = load('res://addons/gut/utils.gd').new()
var _hide_passing = true
var _font = null
var _font_size = null
var _root = null
var _max_icon_width = 10
var _editors = null # script_text_editor_controls.gd

var _icons = {
	red = load('res://addons/gut/images/red.png'),
	green = load('res://addons/gut/images/green.png'),
	yellow = load('res://addons/gut/images/yellow.png'),
}

signal search_for_text(text)

onready var _ctrls = {
	tree = $Panel/Scroll/Tree,
	lbl_overlay = $Panel/OverlayMessage
}

func _test_running_setup():
	_hide_passing = false
	var _gut_config = load('res://addons/gut/gut_config.gd').new()
	_gut_config.load_panel_options('res://.gut_editor_config.json')
	set_font(
		_gut_config.options.panel_options.font_name,
		_gut_config.options.panel_options.font_size)
	load_json_file('user://.gut_editor.json')


func _ready():
	_root = _ctrls.tree.create_item()
	_ctrls.tree.set_hide_root(true)
	_ctrls.tree.columns = 2
	_ctrls.tree.set_column_expand(0, true)
	_ctrls.tree.set_column_expand(1, false)
	_ctrls.tree.set_column_min_width(1, 150)

	if(get_parent() == get_tree().root):
		_test_running_setup()

func _open_file(path, line_number):
	if(_interface == null):
		print('Too soon, wait a bit and try again.')
		return

	var r = load(path)
	if(line_number != -1):
		_interface.edit_script(r, line_number)
	else:
		_interface.edit_script(r)


func _add_script_tree_item(script_path, script_json):
	var item = _ctrls.tree.create_item(_root)
	item.set_text(0, script_path)
	var meta = {"type":"script", "json":script_json}
	item.set_metadata(0, meta)

	return item


func _add_assert_item(text, icon, parent_item):
		var assert_item = _ctrls.tree.create_item(parent_item)
		assert_item.set_icon_max_width(0, _max_icon_width)
		assert_item.set_text(0, text)
		assert_item.set_metadata(0, {"type":"assert"})
		assert_item.set_icon(0, icon)
#		assert_item.set_custom_bg_color(0, Color(0, 1, 0), true)

		return assert_item


func _add_test_tree_item(test_name, test_json, script_item):
	if(_hide_passing and test_json['status'] == 'pass'):
		return

	var item = _ctrls.tree.create_item(script_item)
	var status = test_json['status']
	item.set_text(0, test_name)
	item.set_text(1, status)
	var meta = {"type":"test", "json":test_json}
	item.set_metadata(0, meta)
	item.set_icon_max_width(0, _max_icon_width)

	if(status == 'pass'):
		item.set_icon(0, _icons.green)
#		item.set_custom_bg_color(1, Color(0, 1, 0), true)
	elif(status == 'fail'):
		item.set_icon(0, _icons.red)
#		item.set_custom_bg_color(1, Color(1, 0, 0), true)
	else:
		item.set_icon(0, _icons.yellow)
#		item.set_custom_bg_color(1, Color.yellow, true)

	if(!_hide_passing):
		for passing in test_json.passing:
			_add_assert_item('pass: ' + passing, _icons.green, item)

	for failure in test_json.failing:
		_add_assert_item("fail:  " + failure.replace("\n", ''), _icons.red, item)

	for pending in test_json.pending:
		_add_assert_item("pending:  " + pending.replace("\n", ''), _icons.yellow, item)

	return item


func _load_result_tree(j):
	var scripts = j['test_scripts']['scripts']
	var script_keys = scripts.keys()
	# if we made it here, the json is valid and we did something, otherwise the
	# 'nothing to see here' should be visible.
	clear_centered_text()
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


func _get_line_number_from_assert_msg(msg):
	var line = -1
	if(msg.find('at line') > 0):
		line = int(msg.split("at line")[-1].split(" ")[-1])
	return line


func _get_path_and_inner_class_name_from_test_path(path):
	var to_return = {
		path = '',
		inner_class = ''
	}

	to_return.path = path
	if !path.ends_with('.gd'):
		var loc = path.find('.gd')
		to_return.inner_class = path.split('.')[-1]
		to_return.path = path.substr(0, loc + 3)
	return to_return


func _handle_tree_item_select(item):
	var item_type = item.get_metadata(0).type

	var path = '';
	var line = -1;
	var search = ''

	if(item_type == 'test'):
		path = item.get_parent().get_text(0)
		line = -1
		search = item.get_text(0)
	elif(item_type == 'assert'):
		path = item.get_parent().get_parent().get_text(0)
		line = _get_line_number_from_assert_msg(item.get_text(0))
		search = item.get_parent().get_text(0)
	elif(item_type == 'script'):
		path = item.get_text(0)
		line = -1
		search = ''
	else:
		return

	var path_info = _get_path_and_inner_class_name_from_test_path(path)
	_goto_code(path_info.path, line, search, path_info.inner_class)


# starts at beginning of text edit and searches for each search term, moving
# through the text as it goes; ensuring that, when done, it found the first
# occurance of the last srting that happend after the first occurance of
# each string before it.  (Generic way of searching for a method name in an
# inner class that may have be a duplicate of a method name in a different
# inner class)
func _get_line_number_for_seq_search(search_strings):
	var te = _editors.get_current_text_edit()
	var result = null
	var to_return = -1
	var start_line = 0
	var start_col = 0
	var s_flags = 0

	var i = 0
	var string_found = true
	while(i < search_strings.size() and string_found):
		result = te.search(search_strings[i], s_flags, start_line, start_col)
		if(result.size() > 0):
			start_line = result[TextEdit.SEARCH_RESULT_LINE]
			start_col = result[TextEdit.SEARCH_RESULT_COLUMN]
		else:
			string_found = false
		i += 1

	if(string_found):
		to_return = start_line

	return to_return


func _goto_code(path, line, method_name='', inner_class =''):
	if(_interface == null):
		print('going to ', [path, line, method_name, inner_class])
		return

	_open_file(path, line)
	if(line == -1):
		var search_strings = []
		if(inner_class != ''):
			search_strings.append(inner_class)

		if(method_name != ''):
			search_strings.append(method_name)

		line = _get_line_number_for_seq_search(search_strings)
		if(line != -1):
			_interface.get_script_editor().goto_line(line)


func _show_all_passed():
	if(_root.get_children() == null):
		add_centered_text('Everything passed!')


# --------------
# Events
# --------------
func _on_Tree_item_selected():
	_handle_tree_item_select(_ctrls.tree.get_selected())


# --------------
# Public
# --------------
func load_json_file(path):
	var text = _utils.get_file_as_text(path)
	if(text != ''):
		var result = JSON.parse(text)
		if(result.error != OK):
			add_centered_text(str(path, " has invalid json in it \n",
				'Error ', result.error, "@", result.error_line, "\n",
				result.error_string))
			return

		load_json_results(result.result)
	else:
		add_centered_text(str(path, ' was empty or does not exist.'))


func load_json_results(j):
	clear()
	add_centered_text('Nothing Here')
	_load_result_tree(j)


func add_centered_text(t):
	_ctrls.lbl_overlay.text = t


func clear_centered_text():
	_ctrls.lbl_overlay.text = ''


func clear():
	_ctrls.tree.clear()
	_root = _ctrls.tree.create_item()
	clear_centered_text()


func set_interface(which):
	_interface = which


func set_script_text_editors(value):
	_editors = value


func set_font(font_name, size):
	pass
#	var dyn_font = DynamicFont.new()
#	var font_data = DynamicFontData.new()
#	font_data.font_path = 'res://addons/gut/fonts/' + font_name + '-Regular.ttf'
#	font_data.antialiased = true
#	dyn_font.font_data = font_data
#
#	_font = dyn_font
#	_font.size = size
#	_font_size = size
