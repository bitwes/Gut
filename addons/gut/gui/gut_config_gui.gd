var _base_container = null
var _base_control = null
const DIRS_TO_LIST = 6
var _cfg_ctrls = {}

func _init(cont):
	_base_container = cont
	_base_control = _base_container.get_node("Row")
	_base_container.remove_child(_base_control)


func set_options(options):
	_add_boolean('include_subdirs', options.include_subdirs, 'Include Subdirs')
	for i in range(DIRS_TO_LIST):
		var value = ''
		if(options.dirs.size() > i):
			value = options.dirs[i]

		_add_value(str('directory_', i), value, str('Directory ', i))

	_add_boolean('should_exit', options.should_exit, 'Should Exit')


func _new_row(key, disp_text):
	var ctrl = _base_control.duplicate()
	ctrl.get_node("Label").text = disp_text
	_base_container.add_child(ctrl)
	return ctrl


func _add_value(key, value, disp_text):
	var ctrl = _new_row(key, disp_text)

	var value_ctrl = LineEdit.new()
	value_ctrl.size_flags_horizontal = value_ctrl.SIZE_EXPAND_FILL
	value_ctrl.text = value
	_cfg_ctrls[key] = value_ctrl

	ctrl.add_child(value_ctrl)



func _add_boolean(key, value, disp_text):
	var ctrl = _new_row(key, disp_text)

	var value_ctrl = CheckBox.new()
	value_ctrl.pressed = value
	_cfg_ctrls[key] = value_ctrl

	ctrl.add_child(value_ctrl)

func get_options(base_opts):
	var to_return = base_opts.duplicate()
	var dirs = []
	for i in range(DIRS_TO_LIST):
		var key = str('directory_', i)
		var val = _cfg_ctrls[key].text
		if(val != '' and val != null):
			dirs.append(val)

	to_return.include_subdirs = _cfg_ctrls.include_subdirs.pressed
	to_return.should_exit = _cfg_ctrls.should_exit.pressed
	to_return.dirs = dirs
	return to_return
