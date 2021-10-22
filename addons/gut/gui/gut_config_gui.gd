var _base_container = null
var _base_control = null
const DIRS_TO_LIST = 6
var _cfg_ctrls = {}
var _avail_fonts = ['AnonymousPro', 'CourierPrime', 'LobsterTwo', 'Default']

func _init(cont):
	_base_container = cont

	_base_control = HBoxContainer.new()
	_base_control.size_flags_horizontal = _base_control.SIZE_EXPAND_FILL
	var lbl = Label.new()
	lbl.size_flags_horizontal = lbl.SIZE_EXPAND_FILL
	_base_control.add_child(lbl)



func set_options(options):
	_add_title("Settings")
	_add_number("log_level", options.log_level, "Log Level", 0, 3)
	_add_boolean('ignore_pause', options.ignore_pause, 'Ignore Pause')
	_add_boolean('should_exit', options.should_exit, 'Exit on Finish')
	_add_boolean('should_exit_on_success', options.should_exit_on_success, 'Exit on Success')
	_add_boolean('should_maximize', options.should_maximize, 'Maximize')
	_add_number('opacity', options.opacity, 'Opacity', 0, 100)

	_add_title("XML Output")
	_add_value("junit_xml_file", options.junit_xml_file, "Output Path")
	_add_boolean("junit_xml_timestamp", options.junit_xml_timestamp, "Include timestamp")

	_add_title('Font')
	_add_select('font_name', options.font_name, _avail_fonts, 'Font')
	_add_number('font_size', options.font_size, 'Font Size', 5, 100)

	_add_title('Directories')
	_add_boolean('include_subdirs', options.include_subdirs, 'Include Subdirs')
	for i in range(DIRS_TO_LIST):
		var value = ''
		if(options.dirs.size() > i):
			value = options.dirs[i]

		_add_value(str('directory_', i), value, str('Directory ', i))

	_add_title('Misc')
	_add_value('prefix', options.prefix, 'Script Prefix')



func _add_title(text):
	var row = _base_control.duplicate()
	var lbl = row.get_node('Label')
	lbl.text = text
	lbl.align = Label.ALIGN_CENTER
	_base_container.add_child(row)


func _new_row(key, disp_text):
	var ctrl = _base_control.duplicate()
	ctrl.get_node("Label").text = disp_text
	_base_container.add_child(ctrl)
	return ctrl


func _add_number(key, value, disp_text, v_min, v_max):
	var ctrl = _new_row(key, disp_text)

	var value_ctrl = SpinBox.new()
	value_ctrl.value = value
	value_ctrl.min_value = v_min
	value_ctrl.max_value = v_max
	_cfg_ctrls[key] = value_ctrl

	ctrl.add_child(value_ctrl)


func _add_select(key, value, values, disp_text):
	var ctrl = _new_row(key, disp_text)

	var value_ctrl = OptionButton.new()
	var select_idx = 0
	for i in range(values.size()):
		value_ctrl.add_item(values[i])
		if(value == values[i]):
			select_idx = i
	value_ctrl.selected = select_idx
	_cfg_ctrls[key] = value_ctrl

	ctrl.add_child(value_ctrl)


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

	to_return.log_level = _cfg_ctrls.log_level.value
	to_return.ignore_pause = _cfg_ctrls.ignore_pause.pressed
	to_return.should_exit = _cfg_ctrls.should_exit.pressed
	to_return.should_exit_on_success = _cfg_ctrls.should_exit_on_success.pressed
	to_return.should_maximize = _cfg_ctrls.should_maximize.pressed
	to_return.opacity = _cfg_ctrls.opacity.value

	to_return.junit_xml_file = _cfg_ctrls.junit_xml_file.text
	to_return.junit_xml_timestamp = _cfg_ctrls.junit_xml_timestamp.pressed

	to_return.font_name = _cfg_ctrls.font_name.get_item_text(
		_cfg_ctrls.font_name.selected)
	to_return.font_size = _cfg_ctrls.font_size.value

	to_return.include_subdirs = _cfg_ctrls.include_subdirs.pressed
	var dirs = []
	for i in range(DIRS_TO_LIST):
		var key = str('directory_', i)
		var val = _cfg_ctrls[key].text
		if(val != '' and val != null):
			dirs.append(val)
	to_return.dirs = dirs

	to_return.prefix = _cfg_ctrls.prefix.text


	return to_return
