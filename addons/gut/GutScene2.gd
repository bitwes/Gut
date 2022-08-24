extends Node2D


class GuiHandler:
	var _gui = null
	var _gut = null
	
	var _ctrls = {
		prog_script = null,
		prog_test = null,
		path_dir = null, 
		path_file = null,
		rtl = null,
		btn_continue = null,
		time_label = null
	}
	
	func _init(gui):
		_gui = gui
		
		# Brute force, but flexible.
		_ctrls.prog_script = _get_first_child_named('ProgressScript', _gui)
		_ctrls.prog_test = _get_first_child_named('ProgressTest', _gui)
		_ctrls.path_dir = _get_first_child_named('Path', _gui)
		_ctrls.path_file = _get_first_child_named('File', _gui)
		_ctrls.btn_continue = _get_first_child_named('Continue', _gui)
		_ctrls.rtl = _get_first_child_named('Output', _gui)
		_ctrls.time_label = _get_first_child_named('TimeLabel', _gui)
		
		_ctrls.btn_continue.visible = false
		_ctrls.btn_continue.pressed.connect(_on_continue_pressed)
		
		_ctrls.prog_script.value = 0
		_ctrls.prog_test.value = 0
		_ctrls.path_dir.text = ''
		_ctrls.path_file.text = ''
		_ctrls.time_label.text = ''
		
		print(_ctrls)
		
		
	# ------------------
	# Events
	# ------------------
	func _on_continue_pressed():
		_gut.end_teardown_pause()
		_ctrls.btn_continue.visible = false

		
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
