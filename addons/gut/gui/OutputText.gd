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

var _newline_indexes = []
var _cur_search_pos = 0

func _test_running_setup():
	_ctrls.use_colors.text = 'use colors'
	_ctrls.show_search.text = 'search'
	
	set_all_fonts("CourierPrime")
	set_font_size(15)
	
	load_file('user://.gut_editor.bbcode')
	
	
func _ready():
	_ctrls.use_colors.icon = get_icon('RichTextEffect', 'EditorIcons')
	_ctrls.show_search.icon = get_icon('Search', 'EditorIcons')

	if(get_parent() == get_tree().root):
		_test_running_setup()
		

# ------------------
# Private
# ------------------
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


# ------------------
# Events
# ------------------
func _on_CopyButton_pressed():
	copy_to_clipboard()


func _on_UseColors_pressed():
	pass # Replace with function body.


func _on_ClearButton_pressed():
	clear()

func _on_ShowSearch_pressed():
	_ctrls.search_bar.bar.visible = _ctrls.show_search.pressed


# ------------------
# Public
# ------------------
func search(text, start_pos = 0):
	var pos = _ctrls.output.text.findn(text, start_pos)
	if(pos == -1):
		print('"', text, '" not found')
		return

	var i = 0
	var line = 0
	while(pos > _newline_indexes[i] and i < _newline_indexes.size()):
		i += 1
	
	line = i -1
	_ctrls.output.scroll_to_line(line)
	_cur_search_pos = pos + 1
	
	
func copy_to_clipboard():
	OS.clipboard = _ctrls.output.text
	
	
func clear():
	_ctrls.output.clear()


func set_all_fonts(base_name):
	if(base_name == 'Default'):
		_set_font(null, 'normal_font')
		_set_font(null, 'bold_font')
		_set_font(null, 'italics_font')
		_set_font(null, 'bold_italics_font')
	else:
		_set_font(base_name + '-Regular', 'normal_font')
		_set_font(base_name + '-Bold', 'bold_font')
		_set_font(base_name + '-Italic', 'italics_font')
		_set_font(base_name + '-BoldItalic', 'bold_italics_font')


func set_font_size(new_size):
	var rtl = _ctrls.output
	if(rtl.get('custom_fonts/normal_font') != null):
		rtl.get('custom_fonts/bold_italics_font').size = new_size
		rtl.get('custom_fonts/bold_font').size = new_size
		rtl.get('custom_fonts/italics_font').size = new_size
		rtl.get('custom_fonts/normal_font').size = new_size


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
	
	_ctrls.output.grab_focus()
	_ctrls.output.scroll_to_line(_ctrls.output.get_line_count() -1)
	
	var last_n = t.find_last("\n")
	var n_pos = 1
	while(n_pos < last_n and n_pos > 0):
		n_pos = t.find("\n", n_pos) + 2
		_newline_indexes.append(n_pos)


func _on_SearchButton_pressed():
	search(_ctrls.search_bar.search_term.text, _cur_search_pos)


func _on_SearchTerm_text_changed(new_text):
	_cur_search_pos = 0
