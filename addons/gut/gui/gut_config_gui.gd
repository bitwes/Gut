# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
class DirectoryCtrl:
	extends HBoxContainer

	var text = '' setget set_text, get_text
	var _txt_path = LineEdit.new()
	var _btn_dir = Button.new()
	var _dialog = FileDialog.new()

	func _init():
		_btn_dir.text = '...'
		_btn_dir.connect('pressed', self, '_on_dir_button_pressed')

		_txt_path.size_flags_horizontal = _txt_path.SIZE_EXPAND_FILL

		_dialog.mode = _dialog.MODE_OPEN_DIR
		_dialog.resizable = true
		_dialog.connect("dir_selected", self, '_on_selected')
		_dialog.connect("file_selected", self, '_on_selected')
		_dialog.rect_size = Vector2(1000, 700)

	func _on_selected(path):
		set_text(path)

	func _on_dir_button_pressed():
		_dialog.current_dir = _txt_path.text
		_dialog.popup_centered()


	func _ready():
		add_child(_txt_path)
		add_child(_btn_dir)
		add_child(_dialog)

	func get_text():
		return _txt_path.text

	func set_text(t):
		text = t
		_txt_path.text = text

# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
class FileCtrl:
	extends DirectoryCtrl

	func _init():
		_dialog.mode = _dialog.MODE_OPEN_FILE


# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
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

	# I don't remember what this is all about at all.  Could be
	# garbage.  Decided to spend more time typing this message
	# than figuring it out.
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

func _add_directory(key, value, disp_text, hint=''):
	var value_ctrl = DirectoryCtrl.new()
	value_ctrl.size_flags_horizontal = value_ctrl.SIZE_EXPAND_FILL
	value_ctrl.text = value

	var ctrl = _new_row(key, disp_text, value_ctrl, hint)


func _add_file(key, value, disp_text, hint=''):
	var value_ctrl = FileCtrl.new()
	value_ctrl.size_flags_horizontal = value_ctrl.SIZE_EXPAND_FILL
	value_ctrl.text = value

	var ctrl = _new_row(key, disp_text, value_ctrl, hint)


func _add_color(key, value, disp_text, hint=''):
	var value_ctrl = ColorPickerButton.new()
	value_ctrl.size_flags_horizontal = value_ctrl.SIZE_EXPAND_FILL
	value_ctrl.color = value

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
	_add_boolean('hide_orphans', options.hide_orphans, 'Hide Orphans',
		'Do not display orphan counts in output.')
	_add_boolean('should_exit', options.should_exit, 'Exit on Finish',
		"Exit when tests finished.")
	_add_boolean('should_exit_on_success', options.should_exit_on_success, 'Exit on Success',
		"Exit if there are no failures.  Does nothing if 'Exit on Finish' is enabled.")


	_add_title("XML Output")
	_add_value("junit_xml_file", options.junit_xml_file, "Output Path",
		"Path and filename where GUT should create the JUnit XML file.")
	_add_boolean("junit_xml_timestamp", options.junit_xml_timestamp, "Include timestamp",
		"Include a timestamp in the filename so that each run gets its own xml file.")

	_add_title("Output")
	_add_select('output_font_name', options.panel_options.font_name, _avail_fonts, 'Font',
		"The name of the font to use when running tests and in the output panel to the left.")
	_add_number('output_font_size', options.panel_options.font_size, 'Font Size', 5, 100,
		"The font size to use when running tests and in the output panel to the left.")


	_add_title('Runner Appearance')
	_add_select('font_name', options.font_name, _avail_fonts, 'Font',
		"The name of the font to use when running tests and in the output panel to the left.")
	_add_number('font_size', options.font_size, 'Font Size', 5, 100,
		"The font size to use when running tests and in the output panel to the left.")
	_add_boolean('should_maximize', options.should_maximize, 'Maximize',
		"Maximize GUT when tests are being run.")
	_add_number('opacity', options.opacity, 'Opacity', 0, 100,
		"The opacity of GUT when tests are running.")
	_add_color('background_color', options.background_color, 'Background Color')
	_add_color('font_color', options.font_color, 'Font Color')


	_add_title('Directories')
	_add_boolean('include_subdirs', options.include_subdirs, 'Include Subdirs',
		"Include subdirectories of the directories configured below.")
	for i in range(DIRS_TO_LIST):
		var value = ''
		if(options.dirs.size() > i):
			value = options.dirs[i]

		_add_directory(str('directory_', i), value, str('Directory ', i))


	_add_title('Hooks')
	_add_file('pre_run_script', options.pre_run_script, 'Pre-Run Hook', 'This script will be run by GUT before any tests are run.')
	_add_file('post_run_script', options.post_run_script, 'Post-Run Hook', 'This script will be run by GUT after all tests are run.')


	_add_title('Misc')
	_add_value('prefix', options.prefix, 'Script Prefix',
		"The filename prefix for all test scripts.")


func get_options(base_opts):
	var to_return = base_opts.duplicate()

	# Settings
	to_return.log_level = _cfg_ctrls.log_level.value
	to_return.ignore_pause = _cfg_ctrls.ignore_pause.pressed
	to_return.hide_orphans = _cfg_ctrls.hide_orphans.pressed
	to_return.should_exit = _cfg_ctrls.should_exit.pressed
	to_return.should_exit_on_success = _cfg_ctrls.should_exit_on_success.pressed

	# XML Output
	to_return.junit_xml_file = _cfg_ctrls.junit_xml_file.text
	to_return.junit_xml_timestamp = _cfg_ctrls.junit_xml_timestamp.pressed

	#Output
	to_return.panel_options.font_name = _cfg_ctrls.output_font_name.get_item_text(
		_cfg_ctrls.output_font_name.selected)
	to_return.panel_options.font_size = _cfg_ctrls.output_font_size.value

	# Runner Appearance
	to_return.font_name = _cfg_ctrls.font_name.get_item_text(
		_cfg_ctrls.font_name.selected)
	to_return.font_size = _cfg_ctrls.font_size.value
	to_return.should_maximize = _cfg_ctrls.should_maximize.pressed
	to_return.opacity = _cfg_ctrls.opacity.value
	to_return.background_color = _cfg_ctrls.background_color.color.to_html()
	to_return.font_color = _cfg_ctrls.font_color.color.to_html()


	# Directories
	to_return.include_subdirs = _cfg_ctrls.include_subdirs.pressed
	var dirs = []
	for i in range(DIRS_TO_LIST):
		var key = str('directory_', i)
		var val = _cfg_ctrls[key].text
		if(val != '' and val != null):
			dirs.append(val)
	to_return.dirs = dirs

	# Hooks
	to_return.pre_run_script = _cfg_ctrls.pre_run_script.text
	to_return.post_run_script = _cfg_ctrls.post_run_script.text

	# Misc
	to_return.prefix = _cfg_ctrls.prefix.text

	return to_return
