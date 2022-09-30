extends Node2D


class GuiHandler:
	var _gui = null
	var _gut = null

	var _ctrls = {
		btn_continue = null,
		path_dir = null,
		path_file = null,
		prog_script = null,
		prog_test = null,
		rtl = null,
		rtl_bg = null,
		time_label = null
	}

	func _init(gui):
		_gui = gui

		# Brute force, but flexible.
		_ctrls.btn_continue = _get_first_child_named('Continue', _gui)
		_ctrls.path_dir = _get_first_child_named('Path', _gui)
		_ctrls.path_file = _get_first_child_named('File', _gui)
		_ctrls.prog_script = _get_first_child_named('ProgressScript', _gui)
		_ctrls.prog_test = _get_first_child_named('ProgressTest', _gui)
		_ctrls.rtl = _get_first_child_named('Output', _gui)
		_ctrls.rtl_bg = _get_first_child_named('OutputBG', _gui)
		_ctrls.time_label = _get_first_child_named('TimeLabel', _gui)

		_ctrls.btn_continue.visible = false
		_ctrls.btn_continue.pressed.connect(_on_continue_pressed)

		_ctrls.prog_script.value = 0
		_ctrls.prog_test.value = 0
		_ctrls.path_dir.text = ''
		_ctrls.path_file.text = ''
		_ctrls.time_label.text = ''


	# ------------------
	# Events
	# ------------------
	func _on_continue_pressed():
		_ctrls.btn_continue.visible = false
		_gut.end_teardown_pause()


	func _on_gut_start_run():
		if(_ctrls.rtl != null):
			_ctrls.rtl.clear()
		set_num_scripts(_gut.get_test_collector().scripts.size())


	func _on_gut_end_run():
		_ctrls.time_label.text = ''


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
		pass
	# ------------------
	# Private
	# ------------------
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
		_ctrls.time_label.text = str(t, 's')


	func set_bg_color(c):
		_ctrls.rtl_bg.color = c

# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
var _large_handler = null
var _min_handler = null
var gut = null :
	set(val):
		gut = val
		_set_gut(val)


func _ready():
	_large_handler = GuiHandler.new($Large)
	_min_handler = GuiHandler.new($Min)

	$Min.visible = false
	$Large.visible = !$Min.visible

func _process(_delta):
	if(gut != null and gut.is_running()):
		_large_handler.set_elapsed_time(gut.get_elapsed_time())
		_min_handler.set_elapsed_time(gut.get_elapsed_time())

func _set_gut(val):
	_large_handler.set_gut(val)
	_min_handler.set_gut(val)

func get_textbox():
	return _large_handler.get_textbox()


func set_font_size(new_size):
	var rtl = _large_handler.get_textbox()
	if(rtl.get('custom_fonts/normal_font') != null):
		rtl.get('custom_fonts/bold_italics_font').size = new_size
		rtl.get('custom_fonts/bold_font').size = new_size
		rtl.get('custom_fonts/italics_font').size = new_size
		rtl.get('custom_fonts/normal_font').size = new_size

func set_font(font_name):
	pass
	#_set_all_fonts_in_rtl(_large_handler.get_textbox(), font_name)

# Needs rework for 4.0, DynamicFont DNE
func _set_font(rtl, font_name, custom_name):
	pass
	# if(font_name == null):
	# 	rtl.set('custom_fonts/' + custom_name, null)
	# else:
	# 	var dyn_font = DynamicFont.new()
	# 	var font_data = DynamicFontData.new()
	# 	font_data.font_path = 'res://addons/gut/fonts/' + font_name + '.ttf'
	# 	font_data.antialiased = true
	# 	dyn_font.font_data = font_data
	# 	rtl.set('custom_fonts/' + custom_name, dyn_font)


func _set_all_fonts_in_rtl(rtl, base_name):
	if(base_name == 'Default'):
		_set_font(rtl, null, 'normal_font')
		_set_font(rtl, null, 'bold_font')
		_set_font(rtl, null, 'italics_font')
		_set_font(rtl, null, 'bold_italics_font')
	else:
		_set_font(rtl, base_name + '-Regular', 'normal_font')
		_set_font(rtl, base_name + '-Bold', 'bold_font')
		_set_font(rtl, base_name + '-Italic', 'italics_font')
		_set_font(rtl, base_name + '-BoldItalic', 'bold_italics_font')


func set_default_font_color(color):
	_large_handler.get_textbox().set('custom_colors/default_color', color)


func set_background_color(color):
	_large_handler.set_bg_color(color)
