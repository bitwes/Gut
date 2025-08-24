var _plugin : EditorPlugin = null
var sub_menu : PopupMenu = null

var _menus = {
}

signal run_all
signal run_script
signal run_at_cursor
signal rerun
signal run_inner_class
signal run_test
signal toggle_windowed
signal about

func _init(plugin : EditorPlugin):
	_plugin = plugin
	sub_menu = PopupMenu.new()
	plugin.add_tool_submenu_item("GUT", sub_menu)
	sub_menu.index_pressed.connect(_on_sub_menu_index_pressed)
	make_menu()


func _invalid_index():
	print("bad menu index")


func _on_sub_menu_index_pressed(index):
	var to_call : Callable = _invalid_index
	for key in _menus:
		if(_menus[key].index == index):
			to_call = _menus[key].callback

	to_call.call()


func _on_run_all():
	_plugin._bottom_panel._run_all()


#func add_separator(text = ''):
	#sub_menu.add_separator(text)
	#sub_menu.item_count

func add_menu(display_text, menu_name, callback, tooltip=''):
	var index = sub_menu.item_count
	_menus[menu_name] = {
		index = index,
		id = index,
		callback = callback
	}
	sub_menu.add_item(display_text, index)
	sub_menu.set_item_tooltip(index, tooltip)
	return index


func make_menu():
	add_menu("Toggle Windowed", "toggle_windowed", toggle_windowed.emit, '')

	sub_menu.add_separator('Run')
	add_menu("Run All", "run_all",run_all.emit,
		"Run all tests")
	add_menu("Run Script", "run_script", run_script.emit,
		"Run the currently selected script")
	add_menu("Run Inner Class", "run_inner_class", run_inner_class.emit,
		"Run the currently selected inner test class")
	add_menu("Run Test", "run_test", run_test.emit,
		"Run the currently selected test")
	add_menu("Run At Cursor", "run_at_cursor", run_at_cursor.emit,
		"Run the most specific of script/inner class/test based on cursor position")
	add_menu("Rerun", "rerun", rerun.emit,
		"Rerun the last test(s) ran", )
	
	sub_menu.add_separator()
	add_menu("About", "about", about.emit, 
		'All about GUT')
	

func set_shortcut(menu_name, accel_or_input_key):
	if(typeof(accel_or_input_key) == TYPE_INT):
		sub_menu.set_item_accelerator(_menus[menu_name].index, accel_or_input_key)
	elif(typeof(accel_or_input_key) == TYPE_OBJECT and accel_or_input_key is InputEventKey):
		sub_menu.set_item_accelerator(_menus[menu_name].index, accel_or_input_key.get_keycode_with_modifiers())


func disable_menu(menu_name, disabled):
	sub_menu.set_item_disabled(_menus[menu_name].index, disabled)
