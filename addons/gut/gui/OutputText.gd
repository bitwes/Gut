@tool
extends VBoxContainer

# ##############################################################################
# Keeps search results from teh TextEdit
# ##############################################################################
class SearchResults:
	var L = 0
	var C = 0

	var positions = []
	var te = null
	var _last_term = ''

	func _search_te(text, start_position, flags=0):
		var start_pos = start_position
		if(start_pos[L] < 0 or start_pos[L] > te.get_line_count()):
			start_pos[L] = 0
		if(start_pos[C] < 0):
			start_pos[L] = 0

		var result = te.search(text, flags, start_pos[L], start_pos[C])
		if(result.size() == 2 and result[L] == start_position[L] and
			result[C] == start_position[C] and text == _last_term):
			if(flags == TextEdit.SEARCH_BACKWARDS):
				result[C] -= 1
			else:
				result[C] += 1
			result = _search_te(text, result, flags)
			L = result.y
			C = result.x
		elif(result.size() == 2):
			te.scroll_vertical = result[L]
			te.select(result[L], result[C], result[L], result[C] + text.length())
			te.set_caret_column(result[C])
			te.set_caret_line(result[L])
			te.center_viewport_to_caret()
			L = result.y
			C = result.x

		_last_term = text
		te.center_viewport_to_caret()
		return result

	func _cursor_to_pos():
		var to_return = [0, 0]
		to_return[L] = te.get_caret_line()
		to_return[C] = te.get_caret_column()
		return to_return

	func find_next(term):
		return _search_te(term, _cursor_to_pos())

	func find_prev(term):
		var new_pos = _search_te(term, _cursor_to_pos(), TextEdit.SEARCH_BACKWARDS)
		return new_pos

	func get_next_pos():
		pass

	func get_prev_pos():
		pass

	func clear():
		pass

	func find_all(text):
		var c_pos = [0, 0]
		var found = true
		var last_pos = [0, 0]
		positions.clear()

		while(found):
			c_pos = te.search(text, 0, c_pos[L], c_pos[C])

			if(c_pos.size() > 0 and
				(c_pos[L] > last_pos[L] or
					(c_pos[L] == last_pos[L] and c_pos[C] > last_pos[C]))):
				positions.append([c_pos[L], c_pos[C]])
				c_pos[C] += 1
				last_pos = c_pos
			else:
				found = false



# ##############################################################################
# Start OutputText control code
# ##############################################################################
@onready var _ctrls = {
	output = $Output,

	copy_button = $Toolbar/CopyButton,
	use_colors = $Toolbar/UseColors,
	clear_button = $Toolbar/ClearButton,
	word_wrap = $Toolbar/WordWrap,
	show_search = $Toolbar/ShowSearch,

	search_bar = {
		bar = $Search,
		search_term = $Search/SearchTerm,
	}
}

var _sr = SearchResults.new()
var _highlighter = _create_highlighter()

# Automatically used when running the OutputText scene from the editor.  Changes
# to this method only affect test-running the control through the editor.
func _test_running_setup():
	_ctrls.use_colors.text = 'use colors'
	_ctrls.show_search.text = 'search'
	_ctrls.word_wrap.text = 'ww'

	set_all_fonts("CourierPrime")
#	set_all_fonts("LobsterTwo")
	set_font_size(5)
	print(_ctrls.output.get_theme_font_size("normal_font"))
	_ctrls.output.queue_redraw()

	load_file('user://.gut_editor.bbcode')


func _ready():
	_sr.te = _ctrls.output
	_ctrls.use_colors.icon = get_theme_icon('RichTextEffect', 'EditorIcons')
	_ctrls.show_search.icon = get_theme_icon('Search', 'EditorIcons')
	_ctrls.word_wrap.icon = get_theme_icon('Loop', 'EditorIcons')

	_ctrls.use_colors.button_pressed = true
	_setup_colors()
	
	if(get_parent() == get_tree().root):
		_test_running_setup()

# ------------------
# Private
# ------------------

# Call this after changes in colors and the like to get them to apply.  reloads
# the text of the output control.
func _refresh_output():
	var orig_pos = _ctrls.output.scroll_vertical
	var text = _ctrls.output.text

	_ctrls.output.text = text
	_ctrls.output.scroll_vertical = orig_pos


func _create_highlighter():
	var to_return = CodeHighlighter.new()

	var keywords = [
		['Failed', Color.RED],
		['Passed', Color.GREEN],
		['Pending', Color.YELLOW],
		['Orphans', Color.YELLOW],
		['WARNING', Color.YELLOW],
		['ERROR', Color.RED]
	]

	for keyword in keywords:
		to_return.add_keyword_color(keyword[0], keyword[1])

	return to_return


func _setup_colors():
	_ctrls.output.clear()

	var f_color = null
	if (_ctrls.output.theme == null) :
		f_color = get_theme_color("font_color")
	else :
		f_color = _ctrls.output.theme.font_color

	_ctrls.output.add_theme_color_override("font_color_readonly", f_color)
	_ctrls.output.add_theme_color_override("function_color", f_color)
	_ctrls.output.add_theme_color_override("member_variable_color", f_color)
	_ctrls.output.queue_redraw()


func _set_font(font_name, custom_name):
	var rtl = _ctrls.output
	if(font_name == null):
		rtl.add_theme_font_override(custom_name, null)
	else:
		var dyn_font = FontFile.new()
		dyn_font.load_dynamic_font('res://addons/gut/fonts/' + font_name + '.ttf')
		rtl.add_theme_font_override(custom_name, dyn_font)


# ------------------
# Events
# ------------------
func _on_CopyButton_pressed():
	copy_to_clipboard()


func _on_UseColors_pressed():
	if(_ctrls.use_colors.button_pressed):
		_ctrls.output.syntax_highlighter = _highlighter
	else:
		_ctrls.output.syntax_highlighter = null
	_refresh_output()


func _on_ClearButton_pressed():
	clear()


func _on_ShowSearch_pressed():
	show_search(_ctrls.show_search.button_pressed)


func _on_SearchTerm_focus_entered():
	_ctrls.search_bar.search_term.call_deferred('select_all')

func _on_SearchNext_pressed():
	_sr.find_next(_ctrls.search_bar.search_term.text)


func _on_SearchPrev_pressed():
	_sr.find_prev(_ctrls.search_bar.search_term.text)


func _on_SearchTerm_text_changed(new_text):
	if(new_text == ''):
		_ctrls.output.deselect()
	else:
		_sr.find_next(new_text)


func _on_SearchTerm_text_entered(new_text):
	if(Input.is_physical_key_pressed(KEY_SHIFT)):
		_sr.find_prev(new_text)
	else:
		_sr.find_next(new_text)


func _on_SearchTerm_gui_input(event):
	if(event is InputEventKey and !event.pressed and event.scancode == KEY_ESCAPE):
		show_search(false)

func _on_WordWrap_pressed():
	if(_ctrls.word_wrap.button_pressed):
		_ctrls.output.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	else:
		_ctrls.output.wrap_mode = TextEdit.LINE_WRAPPING_NONE
	
	_ctrls.output.queue_redraw()

# ------------------
# Public
# ------------------
func show_search(should):
	_ctrls.search_bar.bar.visible = should
	if(should):
		_ctrls.search_bar.search_term.grab_focus()
		_ctrls.search_bar.search_term.select_all()
	_ctrls.show_search.button_pressed = should


func search(text, start_pos, highlight=true):
	return _sr.find_next(text)


func copy_to_clipboard():
	var selected = _ctrls.output.get_selected_text()
	if(selected != ''):
		DisplayServer.clipboard_set(selected)
	else:
		DisplayServer.clipboard_set(_ctrls.output.text)


func clear():
	_ctrls.output.text = ''


func set_all_fonts(base_name):
	if(base_name == 'Default'):
		_set_font(null, 'font')
		_set_font(null, 'normal_font')
		_set_font(null, 'bold_font')
		_set_font(null, 'italics_font')
		_set_font(null, 'bold_italics_font')
	else:
		_set_font(base_name + '-Regular', 'font')
		_set_font(base_name + '-Regular', 'normal_font')
		_set_font(base_name + '-Bold', 'bold_font')
		_set_font(base_name + '-Italic', 'italics_font')
		_set_font(base_name + '-BoldItalic', 'bold_italics_font')


func set_font_size(new_size):
	return # this isn't working.
	var rtl = _ctrls.output
#	rtl.add_theme_font_size_override("font", new_size)
#	rtl.add_theme_font_size_override("normal_font", new_size)
#	rtl.add_theme_font_size_override("bold_font", new_size)
#	rtl.add_theme_font_size_override("italics_font", new_size)
#	rtl.add_theme_font_size_override("bold_italics_font", new_size)
	rtl.set("theme_override_font_sizes/size", new_size)
	print(rtl.get("theme_override_font_sizes/size"))
	
#	if(rtl.get('custom_fonts/font') != null):
#		rtl.get('custom_fonts/font').size = new_size
#		rtl.get('custom_fonts/bold_italics_font').size = new_size
#		rtl.get('custom_fonts/bold_font').size = new_size
#		rtl.get('custom_fonts/italics_font').size = new_size
#		rtl.get('custom_fonts/normal_font').size = new_size


func set_use_colors(value):
	pass


func get_use_colors():
	return false;


func get_rich_text_edit():df
	return _ctrls.output


func load_file(path):
	var f = FileAccess.open(path, FileAccess.READ)
	if(f == null):
		return

	var t = f.get_as_text()
	f = null # closes file
	_ctrls.output.text = t
	_ctrls.output.scroll_vertical = _ctrls.output.get_line_count()
	_ctrls.output.set_deferred('scroll_vertical', _ctrls.output.get_line_count())


func add_text(text):
	if(is_inside_tree()):
		_ctrls.output.text += text


func scroll_to_line(line):
	_ctrls.output.scroll_vertical = line
	_ctrls.output.set_caret_line(line)
