tool
extends Control


var ScriptTextEditors = load('res://addons/gut/gui/script_text_editor_controls.gd')

onready var _ctrls = {
	btn_script = $HBox/BtnRunScript,
	btn_inner = $HBox/BtnRunInnerClass,
	btn_method = $HBox/BtnRunMethod,
	lbl_none = $HBox/LblNoneSelected
}

var _editors = null
var _script_editor = null
var _cur_editor = null
var _last_line = -1
var _cur_script_path = null
var _last_info = null

signal run_tests(what)


func _ready():
	_ctrls.lbl_none.visible = true
	_ctrls.btn_script.visible = false
	_ctrls.btn_inner.visible = false
	_ctrls.btn_method.visible = false


func _set_editor(which):
	_last_line = -1
	if(_cur_editor != null):
		_cur_editor.disconnect('cursor_changed', self, '_on_cursor_changed')

	if(which != null):
		_cur_editor = which
		_cur_editor.connect('cursor_changed', self, '_on_cursor_changed', [which])

		_last_line = which.cursor_get_line()
		_last_info = _editors.get_line_info()
		_update_buttons(_last_info)



func _update_buttons(info):
	_ctrls.lbl_none.visible = _cur_script_path == null
	_ctrls.btn_script.visible = _cur_script_path != null

	_ctrls.btn_inner.visible = info.inner_class != null
	_ctrls.btn_inner.text = str(info.inner_class)

	_ctrls.btn_method.visible = info.test_method != null
	_ctrls.btn_method.text = str(info.test_method)

	rect_min_size.x = _ctrls.btn_method.rect_size.x + _ctrls.btn_method.rect_position.x


func _on_cursor_changed(which):
	if(which.cursor_get_line() != _last_line):
		_last_line = which.cursor_get_line()
		_last_info = _editors.get_line_info()
		_update_buttons(_last_info)


func set_script_editor(value):
	_script_editor = value
	_editors = ScriptTextEditors.new(value)


func activate_for_script(path):
	_ctrls.btn_script.visible = true
	_ctrls.btn_script.text = path.get_file()
	_cur_script_path = path
	_editors.refresh()
	_set_editor(_editors.get_current_text_edit())


func _on_BtnRunScript_pressed():
	var info = _last_info.duplicate()
	info.script = _cur_script_path.get_file()
	info.inner_class = null
	info.test_method = null
	emit_signal("run_tests", info)


func _on_BtnRunInnerClass_pressed():
	var info = _last_info.duplicate()
	info.script = _cur_script_path.get_file()
	info.test_method = null
	emit_signal("run_tests", info)


func _on_BtnRunMethod_pressed():
	var info = _last_info.duplicate()
	info.script = _cur_script_path.get_file()
	emit_signal("run_tests", info)


func get_script_button():
	return _ctrls.btn_script


func get_inner_button():
	return _ctrls.btn_inner


func get_test_button():
	return _ctrls.btn_method
