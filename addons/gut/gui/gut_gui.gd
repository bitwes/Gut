extends Control
# ##############################################################################
# This is the decoupled GUI for gut.gd
#
# This is a "generic" interface between a GUI and gut.gd.  It assumes there are
# certain controls with specific names.  It will then interact with those
# controls based on signals emitted from gut.gd in order to give the user
# feedback about the progress of the test run and the results.
#
# Optional controls are marked as such in the _ctrls dictionary.  The names
# of the controls can be found in _populate_ctrls.
# ##############################################################################
var _gui = self
var gui = null :
	get: return _gui
	set(val): _gui = val

var _gut = null

var _ctrls = {
	btn_continue = null,
	path_dir = null,
	path_file = null,
	prog_script = null,
	prog_test = null,
	resize_handle = null,       # optional
	rtl = null,                 # optional
	rtl_bg = null,              # required if rtl exists
	switch_modes = null,
	time_label = null,
	title = null,
	title_bar = null,
}

signal switch_modes()

func _ready():
    _populate_ctrls()

	_ctrls.btn_continue.visible = false
	_ctrls.btn_continue.pressed.connect(_on_continue_pressed)
	_ctrls.switch_modes.pressed.connect(_on_switch_modes_pressed)
	_ctrls.title_bar.gui_input.connect(_on_title_bar_input)
	if(_ctrls.resize_handle != null):
		_ctrls.resize_handle.gui_input.connect(_on_resize_handle_input)
		_ctrls.resize_handle.draw.connect(_draw_resize_handle)

	_ctrls.prog_script.value = 0
	_ctrls.prog_test.value = 0
	_ctrls.path_dir.text = ''
	_ctrls.path_file.text = ''
	_ctrls.time_label.text = ''


# ------------------
# Private
# ------------------
func _populate_ctrls():
	# Brute force, but flexible.  This allows for all the controls to exist
    # anywhere, and as long as they all have the right name, they will be
    # found.
	_ctrls.btn_continue = _get_first_child_named('Continue', _gui)
	_ctrls.path_dir = _get_first_child_named('Path', _gui)
	_ctrls.path_file = _get_first_child_named('File', _gui)
	_ctrls.prog_script = _get_first_child_named('ProgressScript', _gui)
	_ctrls.prog_test = _get_first_child_named('ProgressTest', _gui)
	_ctrls.resize_handle = _get_first_child_named("ResizeHandle", _gui)
	_ctrls.rtl = _get_first_child_named('TestOutput', _gui)
	_ctrls.rtl_bg = _get_first_child_named('OutputBG', _gui)
	_ctrls.switch_modes = _get_first_child_named("SwitchModes", _gui)
	_ctrls.time_label = _get_first_child_named('TimeLabel', _gui)
	_ctrls.title = _get_first_child_named("Title", _gui)
	_ctrls.title_bar = _get_first_child_named("TitleBar", _gui)


func _get_first_child_named(obj_name, parent_obj):
	if(parent_obj == null):
		return null

	var kids = parent_obj.get_children()
	var index = 0
	var to_return = null

	while(index < kids.size() and to_return == null):
		if(str(kids[index]).find(str(obj_name, ':')) != -1):
			to_return = kids[index]
		else:
			to_return = _get_first_child_named(obj_name, kids[index])
			if(to_return == null):
				index += 1

	return to_return

# ------------------
# Events
# ------------------
var _title_mouse = {
	down = false
}
func _on_title_bar_input(event : InputEvent):
	if(event is InputEventMouseMotion):
		if(_title_mouse.down):
			_gui.position += event.relative
	elif(event is InputEventMouseButton):
		if(event.button_index == MOUSE_BUTTON_LEFT):
			_title_mouse.down = event.pressed

var _resize_mouse = {
	down = false
}
func _on_resize_handle_input(event : InputEvent):
	if(event is InputEventMouseMotion):
		if(_resize_mouse.down):
			_gui.size += event.relative
	elif(event is InputEventMouseButton):
		if(event.button_index == MOUSE_BUTTON_LEFT):
			_resize_mouse.down = event.pressed


func _draw_resize_handle(): # needs get_size()
	# Draw the lines in the corner to show where you can
	# drag to resize the dialog
	var grab_margin = 2
	var line_space = 4
	var grab_line_color = Color(.4, .4, .4)
	var rect_size = _ctrls.resize_handle.size

	for i in range(1, 10):
		var x = rect_size - Vector2(i * line_space, grab_margin)
		var y = rect_size - Vector2(grab_margin, i * line_space)
		_ctrls.resize_handle.draw_line(x, y, grab_line_color, 1, true)


func _on_continue_pressed():
	_gut.end_teardown_pause()


func _on_gut_start_run():
	if(_ctrls.rtl != null):
		_ctrls.rtl.clear()
	set_num_scripts(_gut.get_test_collector().scripts.size())


func _on_gut_end_run():
	_ctrls.time_label.text = ''
	_ctrls.prog_test.value = _ctrls.prog_test.max_value
	_ctrls.prog_script.value = _ctrls.prog_script.max_value


func _on_gut_start_script(script_obj):
	next_script(script_obj.get_full_name(), script_obj.tests.size())


func _on_gut_end_script():
	pass


func _on_gut_start_test(test_name):
	next_test(test_name)


func _on_gut_end_test():
	pass


func _on_gut_start_pause():
	pause_before_teardown()


func _on_gut_end_pause():
	_ctrls.btn_continue.visible = false


func _on_switch_modes_pressed():
	switch_modes.emit()

# ------------------
# Public
# ------------------
func set_num_scripts(val):
	_ctrls.prog_script.value = 0
	_ctrls.prog_script.max_value = val


func next_script(path, num_tests):
	_ctrls.prog_script.value += 1
	_ctrls.prog_test.value = 0
	_ctrls.prog_test.max_value = num_tests

	_ctrls.path_dir.text = path.get_base_dir()
	_ctrls.path_file.text = path.get_file()


func next_test(test_name):
	_ctrls.prog_test.value += 1


func pause_before_teardown():
	_ctrls.btn_continue.visible = true


func set_gut(g):
	_gut = g
	g.start_run.connect(_on_gut_start_run)
	g.end_run.connect(_on_gut_end_run)

	g.start_script.connect(_on_gut_start_script)
	g.end_script.connect(_on_gut_end_script)

	g.start_test.connect(_on_gut_start_test)
	g.end_test.connect(_on_gut_end_test)

	g.start_pause_before_teardown.connect(_on_gut_start_pause)
	g.end_pause_before_teardown.connect(_on_gut_end_pause)


func get_textbox():
	return _ctrls.rtl

func set_elapsed_time(t):
	_ctrls.time_label.text = str("%6.1f" % t, 's')


func set_bg_color(c):
	_ctrls.rtl_bg.color = c


func set_title(text):
	_ctrls.title.text = text


func to_top_left():
	_gui.position = Vector2(5, 5)


func to_bottom_right():
	var win_size = DisplayServer.window_get_size()
	_gui.position = win_size - Vector2i(_gui.size) - Vector2i(5, 5)


func align_right():
	var win_size = DisplayServer.window_get_size()
	_gui.position.x = win_size.x - _gui.size.x -5
	_gui.position.y = 5
	_gui.size.y = win_size.y - 10
