@tool
extends Control

var EditorCaretContextNotifier = load('res://addons/gut/editor_caret_context_notifier.gd')
var menu_manager = null :
	set(val):
		menu_manager = val
		menu_manager.run_script.connect(_on_BtnRunScript_pressed)
		menu_manager.run_at_cursor.connect(run_at_cursor)
		menu_manager.rerun.connect(rerun)
		menu_manager.run_inner_class.connect(_on_BtnRunInnerClass_pressed)
		menu_manager.run_test.connect(_on_BtnRunMethod_pressed)
		_update_buttons(_last_info)

@onready var _ctrls = {
	btn_script = $HBox/BtnRunScript,
	btn_inner = $HBox/BtnRunInnerClass,
	btn_method = $HBox/BtnRunMethod,
	lbl_none = $HBox/LblNoneSelected,
	arrow_1 = $HBox/Arrow1,
	arrow_2 = $HBox/Arrow2
}

var _caret_notifier = null
# var _editors = null
var _method_prefix = 'test_'
var _cur_editor = null
var _last_line = -1
# var _cur_script_path = null
var _last_info = {
	script = null,
	inner_class = null,
	method = null
}

var disabled = false :
	set(val):
		disabled = val
		if(is_inside_tree()):
			_ctrls.btn_script.disabled = val
			_ctrls.btn_inner.disabled = val
			_ctrls.btn_method.disabled = val


signal run_tests(what)


func _ready():
	_ctrls.lbl_none.visible = true
	_ctrls.btn_script.visible = false
	_ctrls.btn_inner.visible = false
	_ctrls.btn_method.visible = false
	_ctrls.arrow_1.visible = false
	_ctrls.arrow_2.visible = false

	_caret_notifier = EditorCaretContextNotifier.new()
	add_child(_caret_notifier)
	_caret_notifier.it_changed.connect(_on_caret_notifer_changed)

	disabled = disabled


func _on_caret_notifer_changed(data):
	_last_info = data
	print(data)
	if(menu_manager != null and data.is_test_script):
		_update_buttons(_last_info)


# ----------------
# Private
# ----------------
# func _set_editor(which):
# 	_last_line = -1
# 	if(_cur_editor != null and _cur_editor.get_ref()):
# 		_cur_editor.get_ref().caret_changed.disconnect(_on_cursor_changed)

# 	if(which != null):
# 		_cur_editor = weakref(which)
# 		which.caret_changed.connect(_on_cursor_changed.bind(which))

# 		_last_line = which.get_caret_line()
# 		_last_info = _editors.get_line_info()
# 		_update_buttons(_last_info)


func _update_buttons(info):
	_ctrls.lbl_none.visible = false #_cur_script_path == null
	_ctrls.btn_script.visible = info.script != null
	if(info.is_test_script):
		_ctrls.btn_script.text = info.script.resource_path.get_file()
	menu_manager.disable_menu("run_script", info.script == null)
	menu_manager.disable_menu("run_at_cursor", info.script == null)

	_ctrls.btn_inner.visible = info.inner_class != null
	_ctrls.arrow_1.visible = info.inner_class != null
	_ctrls.btn_inner.text = str(info.inner_class)
	_ctrls.btn_inner.tooltip_text = str("Run all tests in Inner-Test-Class ", info.inner_class)
	menu_manager.disable_menu("run_inner_class", info.inner_class == null)

	var is_test_method = info.method != null and info.method.begins_with(_method_prefix)
	_ctrls.btn_method.visible = is_test_method
	_ctrls.arrow_2.visible = is_test_method
	if(is_test_method):
		_ctrls.btn_method.text = str(info.method)
		_ctrls.btn_method.tooltip_text = str("Run test ", info.method)
	menu_manager.disable_menu("run_test", is_test_method)

	menu_manager.disable_menu("rerun", _last_run_info == {})
	# The button's new size won't take effect until the next frame.
	# This appears to be what was causing the button to not be clickable the
	# first time.
	_update_size.call_deferred()


func _update_size():
	custom_minimum_size.x = _ctrls.btn_method.size.x + _ctrls.btn_method.position.x

var _last_run_info = {}
func _emit_run_tests(info):
	_last_run_info = info.duplicate()
	run_tests.emit(info)

# ----------------
# Events
# ----------------
# func _on_cursor_changed(which):
# 	if(which.get_caret_line() != _last_line):
# 		_last_line = which.get_caret_line()
# 		_last_info = _editors.get_line_info()
# 		_update_buttons(_last_info)


func _on_BtnRunScript_pressed():
	var info = _last_info.duplicate()
	info.script = info.script.resource_path.get_file()
	info.inner_class = null
	info.method = null
	_emit_run_tests(info)


func _on_BtnRunInnerClass_pressed():
	var info = _last_info.duplicate()
	info.script = info.script.resource_path.get_file()
	info.method = null
	_emit_run_tests(info)


func _on_BtnRunMethod_pressed():
	var info = _last_info.duplicate()
	info.script = info.script.resource_path.get_file()
	_emit_run_tests(info)


# ----------------
# Public
# ----------------
func rerun():
	if(_last_run_info != {}):
		_emit_run_tests(_last_run_info)


func run_at_cursor():
	if(_ctrls.btn_method.visible):
		_on_BtnRunMethod_pressed()
	elif(_ctrls.btn_inner.visible):
		_on_BtnRunInnerClass_pressed()
	elif(_ctrls.btn_script.visible):
		_on_BtnRunScript_pressed()
	else:
		print("nothing selected")


# func set_script_text_editors(value):
# 	_editors = value


# func activate_for_script(path):
# 	_ctrls.btn_script.visible = true
# 	_ctrls.btn_script.text = path.get_file()
# 	_ctrls.btn_script.tooltip_text = str("Run all tests in script ", path)
# 	_cur_script_path = path
# 	_editors.refresh()
# 	# We have to wait a beat for the visibility to change on
# 	# the editors, otherwise we always get the first one.
# 	await get_tree().process_frame
# 	_set_editor(_editors.get_current_text_edit())


func get_script_button():
	return _ctrls.btn_script


func get_inner_button():
	return _ctrls.btn_inner


func get_test_button():
	return _ctrls.btn_method


func set_method_prefix(value):
	_method_prefix = value


func set_inner_class_prefix(value):
	_caret_notifier.inner_class_prefix = value


# Mashed this function in here b/c it has _editors.  Probably should be
# somewhere else (possibly in script_text_editor_controls).
# func search_current_editor_for_text(txt):
# 	var te = _editors.get_current_text_edit()
# 	var result = te.search(txt, 0, 0, 0)
# 	var to_return = -1

# 	return to_return
