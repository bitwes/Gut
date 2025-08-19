var _plugin : EditorPlugin = null
var sub_menu : PopupMenu = null

var _menus = {
}

signal run_script
signal run_at_cursor
signal rerun

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


func _on_run_script():
	run_script.emit()


func _on_run_at_cursor():
	run_at_cursor.emit()


func _on_rerun():
	rerun.emit()


func add_menu(display_text, menu_name, callback):
	var index = _menus.size()
	_menus[menu_name] = {
		index = index,
		id = index,
		callback = callback
	}
	sub_menu.add_item(display_text, index)
	return index


func make_menu():
	add_menu("Run All", "run_all", _on_run_all)
	add_menu("Run Script", "run_script", _on_run_script)
	add_menu("Run At Cursor", "run_at_cursor", _on_run_at_cursor)
	add_menu("Rerun", "rerun", _on_rerun)

	set_shortcut("run_script", KEY_MASK_CTRL | KEY_9)
	set_shortcut("run_at_cursor", KEY_MASK_CTRL | KEY_0)


func set_shortcut(menu_name, accelerator):
	sub_menu.set_item_accelerator(_menus[menu_name].index, accelerator)


func disable_menu(menu_name, disabled):
	sub_menu.set_item_disabled(_menus[menu_name].index, disabled)