var _base_container = null
var _base_control = null
const DIRS_TO_LIST = 6
var _cfg_ctrls = {}
var _avail_fonts = ['AnonymousPro', 'CourierPrime', 'LobsterTwo', 'Default']


signal settings_changed

func _init(cont):
	_base_container = cont

	_base_control = HBoxContainer.new()
	_base_control.size_flags_horizontal = _base_control.SIZE_EXPAND_FILL
	_base_control.mouse_filter = _base_control.MOUSE_FILTER_PASS
	
	var lbl = Label.new()
	lbl.size_flags_horizontal = lbl.SIZE_EXPAND_FILL
	lbl.mouse_filter = lbl.MOUSE_FILTER_STOP
	_base_control.add_child(lbl)

# ------------------
# Private
# ------------------
func _new_row(key, disp_text, value_ctrl, hint):
	var ctrl = _base_control.duplicate()
	var lbl = ctrl.get_node("Label")
	
	lbl.hint_tooltip = hint
	lbl.text = disp_text
	_base_container.add_child(ctrl)
	
	_cfg_ctrls[key] = value_ctrl
	ctrl.add_child(value_ctrl)

	return ctrl


func _add_title(text):
	var row = _base_control.duplicate()
	var lbl = row.get_node('Label')
	
	lbl.text = text
	lbl.align = Label.ALIGN_CENTER
	_base_container.add_child(row)
	
	row.connect('draw', self, '_on_title_cell_draw', [row])


func _add_number(key, value, disp_text, v_min, v_max, hint=''):
	var value_ctrl = SpinBox.new()
	value_ctrl.value = value
	value_ctrl.min_value = v_min
	value_ctrl.max_value = v_max
	
	var ctrl = _new_row(key, disp_text, value_ctrl, hint)


func _add_select(key, value, values, disp_text, hint=''):
	var value_ctrl = OptionButton.new()
	var select_idx = 0
	for i in range(values.size()):
		value_ctrl.add_item(values[i])
		if(value == values[i]):
			select_idx = i
	value_ctrl.selected = select_idx
	
	var ctrl = _new_row(key, disp_text, value_ctrl, hint)


func _add_value(key, value, disp_text, hint=''):
	var value_ctrl = LineEdit.new()
	value_ctrl.size_flags_horizontal = value_ctrl.SIZE_EXPAND_FILL
	value_ctrl.text = value
	
	var ctrl = _new_row(key, disp_text, value_ctrl, hint)


func _add_boolean(key, value, disp_text, hint=''):
	var value_ctrl = CheckBox.new()
	value_ctrl.pressed = value
	
	var ctrl = _new_row(key, disp_text, value_ctrl, hint)


# ------------------
# Events
# ------------------
func _on_ctrl_value_changed(which):
	pass
	
	
func _on_title_cell_draw(which):
	which.draw_rect(Rect2(Vector2(0, 0), which.rect_size), Color(0, 0, 0, .15))

# ------------------
# Public
# ------------------
func get_config_issues():
	var to_return = []
	var has_directory = false
	var dir = Directory.new()
	
	for i in range(DIRS_TO_LIST):
		var key = str('directory_', i)
		var path = _cfg_ctrls[key].text
		if(path != null and path != ''):
			has_directory = true
			if(!dir.dir_exists(path)):
				to_return.append(str('Test directory ', path, ' does not exist.'))
				
	if(!has_directory):
		to_return.append('You do not have any directories set.')
				
	if(_cfg_ctrls['prefix'].text == ''):
		to_return.append("You must set a Script prefix or GUT won't find any scripts")
		
	return to_return


func set_options(options):
	_add_title("Settings")
	_add_number("log_level", options.log_level, "Log Level", 0, 3,
		"Detail level for log messages.")
	_add_boolean('ignore_pause', options.ignore_pause, 'Ignore Pause', 
		"Ignore calls to pause_before_teardown")
	_add_boolean('should_exit', options.should_exit, 'Exit on Finish',
		"Exit when tests finished.")
	_add_boolean('should_exit_on_success', options.should_exit_on_success, 'Exit on Success',
		"Exit if there are no failures.  Does nothing if 'Exit on Finish' is set.")
	_add_boolean('should_maximize', options.should_maximize, 'Maximize',
		"Maximize GUT when tests are being run.")
	_add_number('opacity', options.opacity, 'Opacity', 0, 100,
		"The opacity of GUT when tests are running.")

	_add_title("XML Output")
	_add_value("junit_xml_file", options.junit_xml_file, "Output Path",
		"Path and filename where GUT should create the JUnit XML file.")
	_add_boolean("junit_xml_timestamp", options.junit_xml_timestamp, "Include timestamp",
		"Include a timestamp in the filename so that each run gets its own xml file.")

	_add_title('Font')
	_add_select('font_name', options.font_name, _avail_fonts, 'Font',
		"The name of the font to use when running tests and in the output panel to the left.")
	_add_number('font_size', options.font_size, 'Font Size', 5, 100,
		"The font size to use when running tests and in the output panel to the left.")

	_add_title('Directories')
	_add_boolean('include_subdirs', options.include_subdirs, 'Include Subdirs', 
		"Include subdirectories of the directories configured below.")
	for i in range(DIRS_TO_LIST):
		var value = ''
		if(options.dirs.size() > i):
			value = options.dirs[i]

		_add_value(str('directory_', i), value, str('Directory ', i))

	_add_title('Misc')
	_add_value('prefix', options.prefix, 'Script Prefix',
		"The filename prefix for all test scripts.")



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
