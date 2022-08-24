extends Node2D


class GuiHandler:
	var _gui = null
	
	signal end_pause
	
	var _ctrls = {
		prog_script = null,
		prog_test = null,
		path_dir = null, 
		path_file = null,
		rtl = null,
		btn_continue = null
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
		
		_ctrls.btn_continue.visible = false
		_ctrls.btn_continue.pressed.connect(_on_continue_pressed)
		
		
	func _on_continue_pressed():
		end_pause.emit()
		_ctrls.btn_continue.visible = false
		
		
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
		
	func set_num_scripts(val):
		_ctrls.prog_script.value = 0
		_ctrls.prog_script.max = val
		
	func next_script(path, num_tests):
		_ctrls.prog_script.value += 1
		_ctrls.prog_test.value = 0
		_ctrls.prog_test.max = num_tests
		
		_ctrls.path_dir.text = path.get_base_dir()
		_ctrls.path_file.text = path.get_file()
		
	func next_test(test_name):
		_ctrls.prog_test.value += 1
		# do something with the name?
		
	func pause_before_teardown():
		_ctrls.btn_continue.visible = true
		

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

	
func _set_gut(val):
	val.timeout.connect(_on_gut_timeout)
#	val.tests_finished.connect(_on_tests_finished)
#	val.test_finished.connect(_on_test_finished)
#	val.stop_yield_before_teardown.connect(_on_stop_yield_before_teardown)

# potential gui signals.  With these, we can probably remove all references to
# the gui from here.
#signal test_started
#signal start_script
#signal end_script
#signal start_test
#signal end_test
#signal paused

func _on_gut_timeout():
	pass

func _on_tests_finished():
	pass
	
func _on_test_finished():
	pass

func _on_stop_yield_before_teardown():
	pass
