@tool
extends Control
var _results_tree = load('res://addons/gut/gui/ResultsTree.gd').new()
var _interface = null
var _utils = load('res://addons/gut/utils.gd').new()

var _font = null
var _font_size = null
var _root = null
var _editors = null # script_text_editor_controls.gd

var _output_control = null


signal search_for_text(text)

@onready var _ctrls = {
	tree = $VBox/Output/Scroll/Tree,
	lbl_overlay = $VBox/Output/OverlayMessage,
	chk_hide_passing = $VBox/Toolbar/HidePassing,
	toolbar = {
		toolbar = $VBox/Toolbar,
		collapse = $VBox/Toolbar/Collapse,
		collapse_all = $VBox/Toolbar/CollapseAll,
		expand = $VBox/Toolbar/Expand,
		expand_all = $VBox/Toolbar/ExpandAll,
		hide_passing = $VBox/Toolbar/HidePassing,
		show_script = $VBox/Toolbar/ShowScript,
		scroll_output = $VBox/Toolbar/ScrollOutput
	}
}

func _test_running_setup():
	_results_tree._hide_passing = false
	_results_tree._show_orphans = false
	var _gut_config = load('res://addons/gut/gut_config.gd').new()
	_gut_config.load_panel_options('res://.gut_editor_config.json')
	set_font(
		_gut_config.options.panel_options.font_name,
		_gut_config.options.panel_options.font_size)

	_ctrls.toolbar.hide_passing.text = '[hp]'
	_results_tree.load_json_file('user://.gut_editor.json')


func _set_toolbutton_icon(btn, icon_name, text):
	if(Engine.is_editor_hint()):
		btn.icon = get_theme_icon(icon_name, 'EditorIcons')
	else:
		btn.text = str('[', text, ']')


func _ready():
	var f = null
	if ($FontSampler.get_label_settings() == null) :
		f = get_theme_default_font()
	else :
		f = $FontSampler.get_label_settings().font
	var s_size = f.get_string_size("000 of 000 passed")

	_results_tree.set_tree(_ctrls.tree)
	_results_tree.set_summary_min_width(s_size.x)

	_set_toolbutton_icon(_ctrls.toolbar.collapse, 'CollapseTree', 'c')
	_set_toolbutton_icon(_ctrls.toolbar.collapse_all, 'CollapseTree', 'c')
	_set_toolbutton_icon(_ctrls.toolbar.expand, 'ExpandTree', 'e')
	_set_toolbutton_icon(_ctrls.toolbar.expand_all, 'ExpandTree', 'e')
	_set_toolbutton_icon(_ctrls.toolbar.show_script, 'Script', 'ss')
	_set_toolbutton_icon(_ctrls.toolbar.scroll_output, 'Font', 'so')

	_ctrls.toolbar.hide_passing.set('custom_icons/checked', get_theme_icon('GuiVisibilityHidden', 'EditorIcons'))
	_ctrls.toolbar.hide_passing.set('custom_icons/unchecked', get_theme_icon('GuiVisibilityVisible', 'EditorIcons'))

	if(get_parent() == get_tree().root):
		_test_running_setup()

	call_deferred('_update_min_width')


func _update_min_width():
	custom_minimum_size.x = _ctrls.toolbar.toolbar.size.x


func _open_file(path, line_number):
	if(_interface == null):
		print('Too soon, wait a bit and try again.')
		return

	var r = load(path)
	if(line_number != null and line_number != -1):
		_interface.edit_script(r, line_number)
	else:
		_interface.edit_script(r)

	if(_ctrls.toolbar.show_script.pressed):
		_interface.set_main_screen_editor('Script')











func _get_line_number_from_assert_msg(msg):
	var line = -1
	if(msg.find('at line') > 0):
		line = msg.split("at line")[-1].split(" ")[-1].to_int()
	return line




#func _handle_tree_item_select(item, force_scroll):
#	var item_meta = item.get_metadata(0)
#	var item_type = null
#
#	if(item_meta == null):
#		return
#	else:
#		item_type = item_meta.type
#
#	var path = '';
#	var line = -1;
#	var method_name = ''
#	var inner_class = ''
#
#	if(item_type == 'test'):
#		var s_item = item.get_parent()
#		path = s_item.get_metadata(0)['path']
#		inner_class = s_item.get_metadata(0)['inner_class']
#		line = -1
#		method_name = item.get_text(0)
#	elif(item_type == 'assert'):
#		var s_item = item.get_parent().get_parent()
#		path = s_item.get_metadata(0)['path']
#		inner_class = s_item.get_metadata(0)['inner_class']
#
#		line = _get_line_number_from_assert_msg(item.get_text(0))
#		method_name = item.get_parent().get_text(0)
#	elif(item_type == 'script'):
#		path = item.get_metadata(0)['path']
#		if(item.get_parent() != _root):
#			inner_class = item.get_text(0)
#		line = -1
#		method_name = ''
#	else:
#		return
#
#	var path_info = _get_path_and_inner_class_name_from_test_path(path)
#	if(force_scroll or _ctrls.toolbar.show_script.pressed):
#		_goto_code(path, line, method_name, inner_class)
#	if(force_scroll or _ctrls.toolbar.scroll_output.pressed):
#		_goto_output(path, method_name, inner_class)




# starts at beginning of text edit and searches for each search term, moving
# through the text as it goes; ensuring that, when done, it found the first
# occurance of the last srting that happend after the first occurance of
# each string before it.  (Generic way of searching for a method name in an
# inner class that may have be a duplicate of a method name in a different
# inner class)
func _get_line_number_for_seq_search(search_strings, te):
	if(te == null):
		print("No Text editor to get line number for")
		return 0;

	var result = null
	var line = Vector2i(-1, -1)
	var s_flags = 0

	var i = 0
	var string_found = true
	while(i < search_strings.size() and string_found):
		result = te.search(search_strings[i], s_flags, line.y, line.x)
		if(result.x != -1):
			line = result
		else:
			string_found = false
		i += 1

	return line.y


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

		line = _get_line_number_for_seq_search(search_strings, _editors.get_current_text_edit())
		if(line != null and line != -1):
			_interface.get_script_editor().goto_line(line)


func _goto_output(path, method_name, inner_class):
	if(_output_control == null):
		return

	var search_strings = [path]

	if(inner_class != ''):
		search_strings.append(inner_class)

	if(method_name != ''):
		search_strings.append(method_name)

	var line = _get_line_number_for_seq_search(search_strings, _output_control.get_rich_text_edit())
	if(line != null and line != -1):
		_output_control.scroll_to_line(line)



func _set_collapsed_on_all(item, value):
	item.set_collapsed_recursive(value)
	if(item == _root and value):
		item.set_collapsed(false)

# --------------
# Events
# --------------
func _on_Tree_item_selected():
	# do not force scroll
	var item = _ctrls.tree.get_selected()
#	_handle_tree_item_select(item, false)
	# it just looks better if the left is always selected.
	if(item.is_selected(1)):
		item.deselect(1)
		item.select(0)


func _on_Tree_item_activated():
	pass
	# force scroll
#	_handle_tree_item_select(_ctrls.tree.get_selected(), true)

func _on_Collapse_pressed():
	collapse_selected()


func _on_Expand_pressed():
	expand_selected()


func _on_CollapseAll_pressed():
	collapse_all()


func _on_ExpandAll_pressed():
	expand_all()


func _on_Hide_Passing_pressed():
	_results_tree._hide_passing = _ctrls.toolbar.hide_passing.button_pressed

# --------------
# Public
# --------------


func add_centered_text(t):
	_ctrls.lbl_overlay.text = t


func clear_centered_text():
	_ctrls.lbl_overlay.text = ''


func clear():
	_results_tree.clear()
	clear_centered_text()


func set_interface(which):
	_interface = which


func set_script_text_editors(value):
	_editors = value


func collapse_all():
	_set_collapsed_on_all(_root, true)


func expand_all():
	_set_collapsed_on_all(_root, false)


func collapse_selected():
	var item = _ctrls.tree.get_selected()
	if(item != null):
		_set_collapsed_on_all(item, true)


func expand_selected():
	var item = _ctrls.tree.get_selected()
	if(item != null):
		_set_collapsed_on_all(item, false)


func set_show_orphans(should):
	_results_tree._show_orphans = should


func set_font(font_name, size):
	pass
#	var dyn_font = FontFile.new()
#	var font_data = FontFile.new()
#	font_data.font_path = 'res://addons/gut/fonts/' + font_name + '-Regular.ttf'
#	font_data.antialiased = true
#	dyn_font.font_data = font_data
#
#	_font = dyn_font
#	_font.size = size
#	_font_size = size


func set_output_control(value):
	_output_control = value
