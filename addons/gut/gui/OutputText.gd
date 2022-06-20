extends VBoxContainer
tool

onready var _ctrls = {
	copy_button = $Toolbar/CopyButton,
	use_colors = $Toolbar/UseColors,
	clear_button = $Toolbar/ClearButton,
	output = $Output,
	show_search = $Toolbar/ShowSearch,
	search_bar = {
		bar = $Search,
		search_term = $Search/SearchTerm
	}
}

var _cur_search_pos = Vector2(0, 0)

func _test_running_setup():
	_ctrls.use_colors.text = 'use colors'
	_ctrls.show_search.text = 'search'
	
	set_all_fonts("CourierPrime")
	set_font_size(20)
	
	load_file('user://.gut_editor.bbcode')
	
	
func _ready():
	_ctrls.use_colors.icon = get_icon('RichTextEffect', 'EditorIcons')
	_ctrls.show_search.icon = get_icon('Search', 'EditorIcons')

	_setup_colors()
	if(get_parent() == get_tree().root):
		_test_running_setup()
		

# ------------------
# Private
# ------------------
func _setup_colors():
	_ctrls.output.clear_colors()
	var keywords = [
		['Failed', Color.red],
		['Passed', Color.green],
		['Pending', Color.yellow],
		['Orphans', Color.yellow],
		['WARNING', Color.yellow],
		['ERROR', Color.red]
	]
	
	for keyword in keywords:
		_ctrls.output.add_keyword_color(keyword[0], keyword[1])
	
	_ctrls.output.update()


func _set_font(font_name, custom_name):
	var rtl = _ctrls.output
	if(font_name == null):
		rtl.set('custom_fonts/' + custom_name, null)
	else:
		var dyn_font = DynamicFont.new()
		var font_data = DynamicFontData.new()
		font_data.font_path = 'res://addons/gut/fonts/' + font_name + '.ttf'
		font_data.antialiased = true
		dyn_font.font_data = font_data
		rtl.set('custom_fonts/' + custom_name, dyn_font)

	
func _search_text_edit(text, start_pos):
	var result = _ctrls.output.search(text, 0, start_pos.y, start_pos.x)
	var new_pos = Vector2(0, 0)
	if(result.size() == 2):
		new_pos.y = result[_ctrls.output.SEARCH_RESULT_LINE]
		new_pos.x = result[_ctrls.output.SEARCH_RESULT_COLUMN]
	else:
		return Vector2(-1, -1)
		
	_ctrls.output.scroll_vertical = new_pos.y
	return new_pos


# ------------------
# Events
# ------------------
func _on_CopyButton_pressed():
	copy_to_clipboard()


func _on_UseColors_pressed():
	_ctrls.output.syntax_highlighting = _ctrls.use_colors.pressed


func _on_ClearButton_pressed():
	clear()


func _on_ShowSearch_pressed():
	_ctrls.search_bar.bar.visible = _ctrls.show_search.pressed
	_ctrls.search_bar.search_term.grab_focus()
	_ctrls.search_bar.search_term.select_all()


func _on_SearchTerm_focus_entered():
	_ctrls.search_bar.search_term.call_deferred('select_all')


func _on_SearchButton_pressed():
	_cur_search_pos = search(_ctrls.search_bar.search_term.text, _cur_search_pos, true)
	_cur_search_pos.x += 1


func _on_SearchTerm_text_changed(new_text):
	_cur_search_pos = Vector2(0, 0)


func _on_SearchTerm_text_entered(new_text):
	_cur_search_pos = search(new_text, _cur_search_pos, true)
	_cur_search_pos.x += 1

# ------------------
# Public
# ------------------

func search(text, start_pos, highlight=true):
	var new_pos =  _search_text_edit(text, start_pos)
	if(highlight and new_pos.x != -1):
		_ctrls.output.select(new_pos.y, new_pos.x, new_pos.y, new_pos.x + text.length())
	return new_pos
	
	
	
func copy_to_clipboard():
	var selected = _ctrls.output.get_selection_text()
	if(selected != ''):
		OS.clipboard = selected
	else:
		OS.clipboard = _ctrls.output.text
	
	
func clear():
	_ctrls.output.text = ''


func set_all_fonts(base_name):
	if(base_name == 'Default'):
		_set_font(null, 'font')
#		_set_font(null, 'normal_font')
#		_set_font(null, 'bold_font')
#		_set_font(null, 'italics_font')
#		_set_font(null, 'bold_italics_font')
	else:
		_set_font(base_name + '-Regular', 'font')
#		_set_font(base_name + '-Regular', 'normal_font')
#		_set_font(base_name + '-Bold', 'bold_font')
#		_set_font(base_name + '-Italic', 'italics_font')
#		_set_font(base_name + '-BoldItalic', 'bold_italics_font')


func set_font_size(new_size):
	var rtl = _ctrls.output
	if(rtl.get('custom_fonts/font') != null):
		rtl.get('custom_fonts/font').size = new_size
#		rtl.get('custom_fonts/bold_italics_font').size = new_size
#		rtl.get('custom_fonts/bold_font').size = new_size
#		rtl.get('custom_fonts/italics_font').size = new_size
#		rtl.get('custom_fonts/normal_font').size = new_size


func set_use_colors(value):
	pass

	
func get_use_colors():
	return false;

	
func get_rich_text_edit():
	return _ctrls.output
	
	
func load_file(path):
	var f = File.new()
	var result = f.open(path, f.READ)
	if(result != OK):
		return
		
	var t = f.get_as_text()
	f.close()
	_ctrls.output.text = t
	_ctrls.output.scroll_vertical = _ctrls.output.get_line_count()
	_ctrls.output.set_deferred('scroll_vertical', _ctrls.output.get_line_count())
	

func add_text(text):
	if(is_inside_tree()):
		_ctrls.output.text += text


func scroll_to_line(line):
	_ctrls.output.scroll_vertical = line
	_ctrls.output.cursor_set_line(line)

