################################################################################
#(G)odot (U)nit (T)est class
#
################################################################################
#The MIT License (MIT)
#=====================
#
#Copyright (c) 2015 Tom "Butch" Wesley
#
#Permission is hereby granted, free of charge, to any person obtaining a copy
#of this software and associated documentation files (the "Software"), to deal
#in the Software without restriction, including without limitation the rights
#to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#copies of the Software, and to permit persons to whom the Software is
#furnished to do so, subject to the following conditions:
#
#The above copyright notice and this permission notice shall be included in
#all copies or substantial portions of the Software.
#
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
#THE SOFTWARE.
#
################################################################################
# View readme for usage details.
#
# Version 4.0.0
################################################################################
extends WindowDialog


# ###########################
# Editor Variables
# ###########################
export var _run_on_load = false
export(String) var _select_script = null
export(String) var _tests_like = null
export var _should_print_to_console = true setget set_should_print_to_console, get_should_print_to_console
export(int, 'Failures only', 'Tests and failures', 'Everything') var _log_level = 1 setget set_log_level, get_log_level

# This var is JUST used to expose this setting in the editor
# the var that is used is in the _yield_between hash.
export var _yield_between_tests = true setget set_yield_between_tests, get_yield_between_tests
export var _disable_strict_datatype_checks = false setget disable_strict_datatype_checks, is_strict_datatype_checks_disabled
# The prefix used to get tests.
export var _test_prefix = 'test_'
export var _file_prefix = 'test_'
export var _file_extension = '.gd'


# Allow user to add test directories via editor.  This is done with strings
# instead of an array because the interface for editing arrays is really
# cumbersome and complicates testing because arrays set through the editor
# apply to ALL instances.  This also allows the user to use the built in
# dialog to pick a directory.
export(String, DIR) var _directory1 = ''
export(String, DIR) var _directory2 = ''
export(String, DIR) var _directory3 = ''
export(String, DIR) var _directory4 = ''
export(String, DIR) var _directory5 = ''
export(String, DIR) var _directory6 = ''


# ###########################
# Other Vars
# ###########################
const LOG_LEVEL_FAIL_ONLY = 0
const LOG_LEVEL_TEST_AND_FAILURES = 1
const LOG_LEVEL_ALL_ASSERTS = 2
const WAITING_MESSAGE = '/# waiting #/'
const PAUSE_MESSAGE = '/# Pausing.  Press continue button...#/'

var _is_running = false
var _stop_pressed = false


# Tests to run for the current script
var _tests = []
# all the scripts that should be ran as test scripts
var _test_scripts = []

var _waiting = false
var _done = false

var _current_test = null
var _log_text = ""

var _pause_before_teardown = false
# when true _pase_before_teardown will be ignored.  useful
# when batch processing and you don't want to watch.
var _ignore_pause_before_teardown = false
var _wait_timer = Timer.new()

var _yield_between = {
	should = false,
	timer = Timer.new(),
	after_x_tests = 5,
	tests_since_last_yield = 0
}

var types = {}

var _set_yield_time_called = false
# used when yielding to gut instead of some other
# signal.  Start with set_yield_time()
var _yield_timer = Timer.new()
var _runtime_timer = Timer.new()
const RUNTIME_START_TIME = float(20000.0)

# various counters
var _summary = {
	asserts = 0,
	passed = 0,
	failed = 0,
	tests = 0,
	scripts = 0,
	pending = 0
}

#controls
var _ctrls = {
	text_box = TextEdit.new(),
	run_button = Button.new(),
	copy_button = Button.new(),
	clear_button = Button.new(),
	continue_button = Button.new(),
	log_level_slider = HSlider.new(),
	scripts_drop_down = OptionButton.new(),
	next_button = Button.new(),
	previous_button = Button.new(),
	stop_button = Button.new(),
	script_progress = ProgressBar.new(),
	test_progress = ProgressBar.new(),
	runtime_label = Label.new(),
	ignore_continue_checkbox = CheckBox.new(),
	pass_count = Label.new(),
	run_rest = Button.new()
}

var _mouse_down = false
var _mouse_down_pos = null
var _mouse_in = false

var _unit_test_name = ''

var min_size = Vector2(650, 400)

const SIGNAL_TESTS_FINISHED = 'tests_finished'
signal tests_finished
const SIGNAL_STOP_YIELD_BEFORE_TEARDOWN = 'stop_yeild_before_teardown'

func _set_anchor_top_right(obj):
	obj.set_anchor(MARGIN_RIGHT, ANCHOR_BEGIN)
	obj.set_anchor(MARGIN_LEFT, ANCHOR_END)
	obj.set_anchor(MARGIN_TOP, ANCHOR_BEGIN)

func _set_anchor_bottom_right(obj):
	obj.set_anchor(MARGIN_LEFT, ANCHOR_END)
	obj.set_anchor(MARGIN_RIGHT, ANCHOR_END)
	obj.set_anchor(MARGIN_TOP, ANCHOR_END)
	obj.set_anchor(MARGIN_BOTTOM, ANCHOR_END)

func _set_anchor_bottom_left(obj):
	obj.set_anchor(MARGIN_LEFT, ANCHOR_BEGIN)
	obj.set_anchor(MARGIN_TOP, ANCHOR_END)
	obj.set_anchor(MARGIN_TOP, ANCHOR_END)

func _init_types_dictionary():
	types[0] = 'TYPE_NIL'
	types[1] = 'Bool'
	types[2] = 'Int'
	types[3] = 'Float/Real'
	types[4] = 'String'
	types[5] = 'Vector2'
	types[6] = 'Rect2'
	types[7] = 'Vector3'
	types[8] = 'Matrix32'
	types[9] = 'Plane'
	types[10] = 'QUAT'
	types[11] = 'AABB'
	types[12] = 'Matrix3'
	types[13] = 'Transform'
	types[14] = 'Color'
	types[15] = 'Image'
	types[16] = 'Node Path'
	types[17] = 'RID'
	types[18] = 'Object'
	types[19] = 'TYPE_INPUT_EVENT'
	types[20] = 'Dictionary'
	types[21] = 'Array'
	types[22] = 'TYPE_RAW_ARRAY'
	types[23] = 'TYPE_INT_ARRAY'
	types[24] = 'TYPE_REAL_ARRAY'
	types[25] = 'TYPE_STRING_ARRAY'
	types[26] = 'TYPE_VECTOR2_ARRAY'
	types[27] = 'TYPE_VECTOR3_ARRAY'
	types[28] = 'TYPE_COLOR_ARRAY'
	types[29] = 'TYPE_MAX'

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func setup_controls():
	var button_size = Vector2(75, 35)
	var button_spacing = Vector2(10, 0)
	var pos = Vector2(0, 0)

	add_child(_ctrls.text_box)
	_ctrls.text_box.set_size(Vector2(get_size().x - 4, 300))
	_ctrls.text_box.set_pos(Vector2(2, 0))
	_ctrls.text_box.set_readonly(true)
	_ctrls.text_box.set_syntax_coloring(true)
	_ctrls.text_box.set_anchor(MARGIN_LEFT, ANCHOR_BEGIN)
	_ctrls.text_box.set_anchor(MARGIN_RIGHT, ANCHOR_END)
	_ctrls.text_box.set_anchor(MARGIN_TOP, ANCHOR_BEGIN)
	_ctrls.text_box.set_anchor(MARGIN_BOTTOM, ANCHOR_END)

	add_child(_ctrls.copy_button)
	_ctrls.copy_button.set_text("Copy")
	_ctrls.copy_button.set_size(button_size)
	_ctrls.copy_button.set_pos(Vector2(get_size().x - 5 - button_size.x, _ctrls.text_box.get_size().y + 10))
	_ctrls.copy_button.connect("pressed", self, "_copy_button_pressed")
	_set_anchor_bottom_right(_ctrls.copy_button)

	add_child(_ctrls.clear_button)
	_ctrls.clear_button.set_text("Clear")
	_ctrls.clear_button.set_size(button_size)
	_ctrls.clear_button.set_pos(_ctrls.copy_button.get_pos() - Vector2(button_size.x, 0) - button_spacing)
	_ctrls.clear_button.connect("pressed", self, "clear_text")
	_set_anchor_bottom_right(_ctrls.clear_button)

	add_child(_ctrls.pass_count)
	_ctrls.pass_count.set_text('0 - 0')
	_ctrls.pass_count.set_size(Vector2(100, 30))
	_ctrls.pass_count.set_pos(Vector2(550, 0))
	_ctrls.pass_count.set_align(HALIGN_RIGHT)
	_set_anchor_top_right(_ctrls.pass_count)

	add_child(_ctrls.continue_button)
	_ctrls.continue_button.set_text("Continue")
	_ctrls.continue_button.set_size(Vector2(100, 25))
	_ctrls.continue_button.set_pos(Vector2(_ctrls.clear_button.get_pos().x, _ctrls.clear_button.get_pos().y + _ctrls.clear_button.get_size().y + 10))
	_ctrls.continue_button.set_disabled(true)
	_ctrls.continue_button.connect("pressed", self, "_on_continue_button_pressed")
	_set_anchor_bottom_right(_ctrls.continue_button)

	add_child(_ctrls.ignore_continue_checkbox)
	_ctrls.ignore_continue_checkbox.set_text("Ignore pauses")
	_ctrls.ignore_continue_checkbox.set_pressed(_ignore_pause_before_teardown)
	_ctrls.ignore_continue_checkbox.connect('pressed', self, '_on_ignore_continue_checkbox_pressed')
	_ctrls.ignore_continue_checkbox.set_size(Vector2(50, 30))
	_ctrls.ignore_continue_checkbox.set_pos(Vector2(_ctrls.continue_button.get_pos().x, _ctrls.continue_button.get_pos().y + _ctrls.continue_button.get_size().y - 5))
	_set_anchor_bottom_right(_ctrls.ignore_continue_checkbox)

	var log_label = Label.new()
	add_child(log_label)
	log_label.set_text("Log Level")
	log_label.set_pos(Vector2(10, _ctrls.text_box.get_size().y + 1))
	_set_anchor_bottom_left(log_label)

	add_child(_ctrls.log_level_slider)
	_ctrls.log_level_slider.set_size(Vector2(75, 30))
	_ctrls.log_level_slider.set_pos(Vector2(10, log_label.get_pos().y + 20))
	_ctrls.log_level_slider.set_min(0)
	_ctrls.log_level_slider.set_max(2)
	_ctrls.log_level_slider.set_ticks(3)
	_ctrls.log_level_slider.set_ticks_on_borders(true)
	_ctrls.log_level_slider.set_step(1)
	_ctrls.log_level_slider.set_rounded_values(true)
	_ctrls.log_level_slider.connect("value_changed", self, "_on_log_level_slider_changed")
	_ctrls.log_level_slider.set_value(_log_level)
	_set_anchor_bottom_left(_ctrls.log_level_slider)

	var script_prog_label = Label.new()
	add_child(script_prog_label)
	script_prog_label.set_pos(Vector2(100, log_label.get_pos().y))
	script_prog_label.set_text('Scripts:')
	_set_anchor_bottom_left(script_prog_label)

	add_child(_ctrls.script_progress)
	_ctrls.script_progress.set_size(Vector2(200, 10))
	_ctrls.script_progress.set_pos(script_prog_label.get_pos() + Vector2(70, 0))
	_ctrls.script_progress.set_min(0)
	_ctrls.script_progress.set_max(1)
	_ctrls.script_progress.set_unit_value(1)
	_set_anchor_bottom_left(_ctrls.script_progress)

	var test_prog_label = Label.new()
	add_child(test_prog_label)
	test_prog_label.set_pos(Vector2(100, log_label.get_pos().y + 15))
	test_prog_label.set_text('Tests:')
	_set_anchor_bottom_left(test_prog_label)

	add_child(_ctrls.test_progress)
	_ctrls.test_progress.set_size(Vector2(200, 10))
	_ctrls.test_progress.set_pos(test_prog_label.get_pos() + Vector2(70, 0))
	_ctrls.test_progress.set_min(0)
	_ctrls.test_progress.set_max(1)
	_ctrls.test_progress.set_unit_value(1)
	_set_anchor_bottom_left(_ctrls.test_progress)

	add_child(_ctrls.previous_button)
	_ctrls.previous_button.set_size(Vector2(50, 25))
	pos = _ctrls.test_progress.get_pos() + Vector2(250, 25)
	pos.x -= 300
	_ctrls.previous_button.set_pos(pos)
	_ctrls.previous_button.set_text("<")
	_ctrls.previous_button.connect("pressed", self, '_on_previous_button_pressed')
	_set_anchor_bottom_left(_ctrls.previous_button)

	add_child(_ctrls.stop_button)
	_ctrls.stop_button.set_size(Vector2(50, 25))
	pos.x += 60
	_ctrls.stop_button.set_pos(pos)
	_ctrls.stop_button.set_text('stop')
	_ctrls.stop_button.connect("pressed", self, '_on_stop_button_pressed')
	_set_anchor_bottom_left(_ctrls.stop_button)

	add_child(_ctrls.run_rest)
	_ctrls.run_rest.set_text('run')
	_ctrls.run_rest.set_size(Vector2(50, 25))
	pos.x += 60
	_ctrls.run_rest.set_pos(pos)
	_ctrls.run_rest.connect('pressed', self, '_on_run_rest_pressed')
	_set_anchor_bottom_left(_ctrls.run_rest)

	add_child(_ctrls.next_button)
	_ctrls.next_button.set_size(Vector2(50, 25))
	pos.x += 60
	_ctrls.next_button.set_pos(pos)
	_ctrls.next_button.set_text(">")
	_ctrls.next_button.connect("pressed", self, '_on_next_button_pressed')
	_set_anchor_bottom_left(_ctrls.next_button)

	add_child(_ctrls.runtime_label)
	_ctrls.runtime_label.set_text('0.0')
	_ctrls.runtime_label.set_size(Vector2(50, 30))
	_ctrls.runtime_label.set_pos(Vector2(_ctrls.clear_button.get_pos().x - 90, _ctrls.next_button.get_pos().y))
	_set_anchor_bottom_right(_ctrls.runtime_label)

	# the drop down has to be one of the last added so that when then list of
	# scripts is displayed, other controls do not get in the way of selecting
	# an item in the list.
	add_child(_ctrls.scripts_drop_down)
	_ctrls.scripts_drop_down.set_size(Vector2(375, 25))
	_ctrls.scripts_drop_down.set_pos(Vector2(10, _ctrls.log_level_slider.get_pos().y + 50))
	_set_anchor_bottom_left(_ctrls.scripts_drop_down)
	_ctrls.scripts_drop_down.connect('item_selected', self, '_on_script_selected')
	_ctrls.scripts_drop_down.set_clip_text(true)

	add_child(_ctrls.run_button)
	_ctrls.run_button.set_text('<- run')
	_ctrls.run_button.set_size(Vector2(50, 25))
	_ctrls.run_button.set_pos(_ctrls.scripts_drop_down.get_pos() + Vector2(_ctrls.scripts_drop_down.get_size().x + 5, 0))
	_ctrls.run_button.connect("pressed", self, "_on_run_button_pressed")
	_set_anchor_bottom_left(_ctrls.run_button)


#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func _init():
	add_user_signal(SIGNAL_TESTS_FINISHED)
	add_user_signal(SIGNAL_STOP_YIELD_BEFORE_TEARDOWN)
	add_user_signal('timeout')
	_init_types_dictionary()

#-------------------------------------------------------------------------------
#Initialize controls
#-------------------------------------------------------------------------------
func _ready():
	set_process_input(true)

	show()
	set_pos(get_pos() + Vector2(0, 20))
	self.set_size(min_size)

	setup_controls()

	add_child(_wait_timer)
	_wait_timer.set_wait_time(1)
	_wait_timer.set_one_shot(true)

	add_child(_yield_between.timer)
	_wait_timer.set_one_shot(true)

	add_child(_yield_timer)
	_yield_timer.set_one_shot(true)
	_yield_timer.connect('timeout', self, '_on_yield_timer_timeout')

	# This timer is started, but it should never finish.  Used
	# to determine how long it took to run the tests since
	# getting the time and doing time math is rediculous in godot.
	add_child(_runtime_timer)
	_runtime_timer.set_one_shot(true)
	_runtime_timer.set_wait_time(RUNTIME_START_TIME)

	self.connect("mouse_enter", self, "_on_mouse_enter")
	self.connect("mouse_exit", self, "_on_mouse_exit")
	set_process(true)

	set_pause_mode(PAUSE_MODE_PROCESS)
	add_directory(_directory1)
	add_directory(_directory2)
	add_directory(_directory3)
	add_directory(_directory4)
	add_directory(_directory5)
	add_directory(_directory6)

	_update_controls()

	if(_select_script != null):
		select_script(_select_script)

	if(_tests_like != null):
		set_unit_test_name(_tests_like)

	if(_run_on_load):
		test_scripts(_select_script == null)

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func _process(delta):
	if(_is_running):
		_ctrls.runtime_label.set_text(str(RUNTIME_START_TIME - _runtime_timer.get_time_left()).pad_decimals(3) + ' s')

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func _input(event):
	#if the mouse is somewhere within the debug window
	if(_mouse_in):
		#Check for mouse click inside the resize handle
		if(event.type == InputEvent.MOUSE_BUTTON):
			if (event.button_index == 1):
				#It's checking a square area for the bottom right corner, but that's close enough.  I'm lazy
				if(event.pos.x > get_size().x + get_pos().x - 10 and event.pos.y > get_size().y + get_pos().y - 10):
					if event.pressed:
						_mouse_down = true
						_mouse_down_pos = event.pos
					else:
						_mouse_down = false
		#Reszie
		if(event.type == InputEvent.MOUSE_MOTION):
			if(_mouse_down):
				if(get_size() >= min_size):
					var new_size = get_size() + event.pos - _mouse_down_pos
					var new_mouse_down_pos = event.pos

					if(new_size.x < min_size.x):
						new_size.x = min_size.x
						new_mouse_down_pos.x = _mouse_down_pos.x

					if(new_size.y < min_size.y):
						new_size.y = min_size.y
						new_mouse_down_pos.y = _mouse_down_pos.y

					_mouse_down_pos = new_mouse_down_pos
					set_size(new_size)

#-------------------------------------------------------------------------------
#Custom drawing to indicate results.
#-------------------------------------------------------------------------------
func _draw():
	#Draw the lines in the corner to show where you can
	#drag to resize the dialog
	var grab_margin = 2
	var line_space = 3
	var grab_line_color = Color(.4, .4, .4)
	for i in range(1, 6):
		draw_line(get_size() - Vector2(i * line_space, grab_margin), get_size() - Vector2(grab_margin, i * line_space), grab_line_color)

	return

	var where = Vector2(430, 565)
	var r = 25
	if(_summary.tests > 0):
		if(_summary.failed > 0):
			draw_circle(where, r , Color(1, 0, 0, 1))
		else:
			draw_circle(where, r, Color(0, 1, 0, 1))

#####################
#
# Events
#
#####################

#-------------------------------------------------------------------------------
#Timeout for the built in timer.  emits the timeout signal.  Start timer
#with set_yield_time()
#-------------------------------------------------------------------------------
func _on_yield_timer_timeout():
	emit_signal('timeout')

#-------------------------------------------------------------------------------
#detect mouse movement
#-------------------------------------------------------------------------------
func _on_mouse_enter():
	_mouse_in = true

#-------------------------------------------------------------------------------
#detect mouse movement
#-------------------------------------------------------------------------------
func _on_mouse_exit():
	_mouse_in = false
	_mouse_down = false

#-------------------------------------------------------------------------------
#Run either the selected test or all tests.
#-------------------------------------------------------------------------------
func _on_run_button_pressed():
	test_scripts()

#-------------------------------------------------------------------------------
#Send text box text to clipboard
#-------------------------------------------------------------------------------
func _copy_button_pressed():
	_ctrls.text_box.select_all()
	_ctrls.text_box.copy()

#-------------------------------------------------------------------------------
#Continue processing after pause.
#-------------------------------------------------------------------------------
func _on_continue_button_pressed():
	_pause_before_teardown = false
	_ctrls.continue_button.set_disabled(true)
	emit_signal(SIGNAL_STOP_YIELD_BEFORE_TEARDOWN)

#-------------------------------------------------------------------------------
#Change the log level.  Will be visible the next time tests are run.
#-------------------------------------------------------------------------------
func _on_log_level_slider_changed(value):
	_log_level = _ctrls.log_level_slider.get_value()

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func _on_previous_button_pressed():
	if(_ctrls.scripts_drop_down.get_selected() > 0):
		_ctrls.scripts_drop_down.select(_ctrls.scripts_drop_down.get_selected() -1)
	_update_controls()

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func _on_next_button_pressed():
	if(_ctrls.scripts_drop_down.get_selected() < _ctrls.scripts_drop_down.get_item_count() -1):
		_ctrls.scripts_drop_down.select(_ctrls.scripts_drop_down.get_selected() +1)
	_update_controls()

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func _on_stop_button_pressed():
	_stop_pressed = true
	_ctrls.stop_button.set_disabled(true)
	# short circuit any yielding or yielded tests
	if(!_ctrls.continue_button.is_disabled()):
		_on_continue_button_pressed()
	else:
		_waiting = false

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func _on_ignore_continue_checkbox_pressed():
	_ignore_pause_before_teardown = _ctrls.ignore_continue_checkbox.is_pressed()
	# If you want to ignore them, then you probably just want to continue
	# running, so we'll save you a click.
	if(!_ctrls.continue_button.is_disabled()):
		_on_continue_button_pressed()

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func _on_script_selected(id):
	_update_controls()

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func _on_run_rest_pressed():
	test_scripts(true)

#####################
#
# Private
#
#####################
#-------------------------------------------------------------------------------
# Updates the display
#-------------------------------------------------------------------------------
func _update_controls():
	if(_is_running):
		_ctrls.previous_button.set_disabled(true)
		_ctrls.next_button.set_disabled(true)
		_ctrls.pass_count.show()
	else:
		_ctrls.previous_button.set_disabled(_ctrls.scripts_drop_down.get_selected() == 0)
		_ctrls.next_button.set_disabled(_ctrls.scripts_drop_down.get_selected() == _ctrls.scripts_drop_down.get_item_count() -1)
		_ctrls.pass_count.hide()

	# disabled during run
	_ctrls.run_button.set_disabled(_is_running)
	_ctrls.run_rest.set_disabled(_is_running)
	_ctrls.scripts_drop_down.set_disabled(_is_running)

	# enabled during run
	_ctrls.stop_button.set_disabled(!_is_running)
	_ctrls.pass_count.set_text(str( _summary.passed, ' - ', _summary.failed))



#-------------------------------------------------------------------------------
#Parses out the tests based on the _test_prefix.  Fills the _tests array with
#instances of OneTest.
#-------------------------------------------------------------------------------
func _parse_tests(script):
	var file = File.new()
	var line = ""
	var line_count = 0

	file.open(script, 1)
	while(!file.eof_reached()):
		line_count += 1
		line = file.get_line()
		#Add a test
		if(line.begins_with("func " + _test_prefix)):
			var from = line.find(_test_prefix)
			var len = line.find("(") - from
			var new_test = OneTest.new()
			new_test.name = line.substr(from, len)
			new_test.line_number = line_count
			_tests.append(new_test)

	file.close()

#-------------------------------------------------------------------------------
#Fail an assertion.  Causes test and script to fail as well.
#-------------------------------------------------------------------------------
func _fail(text):
	_summary.asserts += 1
	_summary.failed += 1
	if(_current_test != null):
		_current_test.passed = false
	p('FAILED:  ' + text, LOG_LEVEL_FAIL_ONLY)
	if(_current_test != null):
		p('  at line ' + str(_current_test.line_number), LOG_LEVEL_FAIL_ONLY)
	_update_controls()
	end_yielded_test()


#-------------------------------------------------------------------------------
#Pass an assertion.
#-------------------------------------------------------------------------------
func _pass(text):
	_summary.asserts += 1
	_summary.passed += 1
	if(_log_level >= LOG_LEVEL_ALL_ASSERTS):
		p("PASSED:  " + text, LOG_LEVEL_ALL_ASSERTS)
	_update_controls()
	end_yielded_test()


#-------------------------------------------------------------------------------
#Convert the _summary struct into text for display
#-------------------------------------------------------------------------------
func _get_summary_text():
	var to_return = "/*****************\nSummary\n*****************/\n"
	to_return += str(_summary.scripts) + " Scripts\n"
	to_return += str(_summary.tests) + " Tests\n"
	to_return += str(_summary.asserts) + " Asserts\n"
	to_return += str(_summary.passed) + " Passed\n"
	to_return += str(_summary.pending) + " Pending\n"
	to_return += str(_summary.failed) + " Failed\n"
	to_return += "\n\n"
	if(_summary.tests > 0):
		to_return +=  '+++ ' + str(_summary.passed) + ' passed ' + str(_summary.failed) + ' failed.  ' + \
		              "Tests finished in:  " + _ctrls.runtime_label.get_text() + ' +++'
		var c = Color(0, 1, 0)
		if(_summary.passed != _summary.asserts):
			c = Color(1, 0, 0)
		_ctrls.text_box.add_color_region('+++', '+++', c)
	else:
		to_return += '+++ No tests ran +++'
		_ctrls.text_box.add_color_region('+++', '+++', Color(1, 0, 0))
	return to_return

#-------------------------------------------------------------------------------
#Initialize variables for each run of a single test script.
#-------------------------------------------------------------------------------
func _init_run():
	_summary.asserts = 0
	_summary.passed = 0
	_summary.failed = 0
	_summary.tests = 0
	_summary.scripts = 0
	_summary.pending = 0

	_log_text = ""
	_ctrls.text_box.clear_colors()
	_ctrls.text_box.add_keyword_color("PASSED", Color(0, 1, 0))
	_ctrls.text_box.add_keyword_color("FAILED", Color(1, 0, 0))
	_ctrls.text_box.add_color_region('/#', '#/', Color(.9, .6, 0))
	_ctrls.text_box.add_color_region('/-', '-/', Color(1, 1, 0))
	_ctrls.text_box.add_color_region('/*', '*/', Color(.5, .5, 1))
	_ctrls.text_box.set_symbol_color(Color(.5, .5, .5))

	_ctrls.runtime_label.set_text('0.0')

	_current_test = null

	_is_running = true
	_update_controls()

	_ctrls.script_progress.set_max(_test_scripts.size())
	_ctrls.script_progress.set_value(0)
	_ctrls.test_progress.set_max(1)
	_runtime_timer.start()

	_yield_between.tests_since_last_yield = 0


#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func _end_run():
	p(_get_summary_text(), 0)
	_runtime_timer.stop()
	_is_running = false
	update()
	_update_controls()
	emit_signal(SIGNAL_TESTS_FINISHED)
	set_title("Finished.  " + str(get_fail_count()) + " failures.")

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func _is_function_state(script_result):
	return script_result != null and \
	       typeof(script_result) == TYPE_OBJECT and \
	       script_result.get_type() == 'GDFunctionState'


#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func _print_script_heading(script_name):
	p("/-----------------------------------------")
	p("Testing Script " + script_name, 0)
	if(_unit_test_name != ''):
		p('  Only running tests like: "' + _unit_test_name + '"')
	p("-----------------------------------------/")

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func _init_test_script(script_path):
	_parse_tests(script_path)
	var test_script = load(script_path).new()
	add_child(test_script)
	test_script.gut = self

	return test_script

#-------------------------------------------------------------------------------
# just gets more logic out of _test_the_scripts.  Decides if we should yield after
# this test based on flags and counters.
#-------------------------------------------------------------------------------
func _should_yield_now():
	var should = _yield_between.should and \
	             _yield_between.tests_since_last_yield == _yield_between.after_x_tests
	if(should):
		_yield_between.tests_since_last_yield = 0
	else:
		_yield_between.tests_since_last_yield += 1
	return should

#-------------------------------------------------------------------------------
#Run all tests in a script.  This is the core logic for running tests.
#
#Note, this has to stay as a giant monstrosity of a method because of the
#yields.
#-------------------------------------------------------------------------------
func _test_the_scripts():
	_init_run()
	var file = File.new()

	for s in range(_test_scripts.size()):
		_tests.clear()
		set_title('Running:  ' + _test_scripts[s])
		_print_script_heading(_test_scripts[s])

		if(!file.file_exists(_test_scripts[s])):
			p("FAILED   COULD NOT FIND FILE:  " + _test_scripts[s])
		else:
			var test_script = _init_test_script(_test_scripts[s])
			var script_result = null
			_summary.scripts += 1

			test_script.prerun_setup()

			#yield between test scripts so things paint
			if(_yield_between.should):
				_yield_between.timer.set_wait_time(0.01)
				_yield_between.timer.start()
				yield(_yield_between.timer, 'timeout')

			_ctrls.test_progress.set_max(_tests.size())
			for i in range(_tests.size()):
				_current_test = _tests[i]
				if((_unit_test_name != '' and _current_test.name.find(_unit_test_name) > -1) or
				   (_unit_test_name == '')):
					p(_current_test.name, 1)

					#yield so things paint
					if(_should_yield_now()):
						_yield_between.timer.set_wait_time(0.001)
						_yield_between.timer.start()
						yield(_yield_between.timer, 'timeout')

					test_script.setup()
					_summary.tests += 1

					script_result = test_script.call(_current_test.name)
					#When the script yields it will return a GDFunctionState object
					if(_is_function_state(script_result)):
						if(!_set_yield_time_called):
							p('/# Yield detected, waiting #/')
						_set_yield_time_called = false
						_waiting = true
						while(_waiting):
							p(WAITING_MESSAGE, 2)
							_wait_timer.start()
							yield(_wait_timer, 'timeout')

					#if the test called pause_before_teardown then yield until
					#the continue button is pressed.
					if(_pause_before_teardown and !_ignore_pause_before_teardown):
						p(PAUSE_MESSAGE, 1)
						_waiting = true
						_ctrls.continue_button.set_disabled(false)
						yield(self, SIGNAL_STOP_YIELD_BEFORE_TEARDOWN)

					test_script.teardown()
					if(_current_test.passed):
						_ctrls.text_box.add_keyword_color(_current_test.name, Color(0, 1, 0))
					else:
						_ctrls.text_box.add_keyword_color(_current_test.name, Color(1, 0, 0))

					# !!! STOP BUTTON SHORT CIRCUIT !!!
					if(_stop_pressed):
						_is_running = false
						_update_controls()
						_stop_pressed = false
						p("STOPPED")
						return

					_ctrls.test_progress.set_value(i + 1)
			test_script.postrun_teardown()
			test_script.free()
			#END TESTS IN SCRIPT LOOP

		_current_test = null
		p("\n\n")
		_ctrls.script_progress.set_value(s + 1)
		#END TEST SCRIPT LOOP

	_end_run()


#########################
#
# public
#
#########################

#-------------------------------------------------------------------------------
#Conditionally prints the text to the console/results variable based on the
#current log level and what level is passed in.  Whenever currently in a test,
#the text will be indented under the test.  It can be further indented if
#desired.
#-------------------------------------------------------------------------------
func p(text, level=0, indent=0):
	var to_print = ""
	var printing_test_name = false

	if(level <= _log_level):
		if(_current_test != null):
			#make sure everyting printed during the execution
			#of a test is at least indented once under the test
			if(indent == 0):
				indent = 1

			#Print the name of the current test if we haven't
			#printed it already.
			if(!_current_test.has_printed_name):
				to_print = "* " + _current_test.name
				_current_test.has_printed_name = true
				printing_test_name = text == _current_test.name

		if(!printing_test_name):
			if(to_print != ""):
				to_print += "\n"
			#Make the indent
			var pad = ""
			for i in range(0, indent):
				pad += "    "
			to_print += pad + text

		if(_should_print_to_console):
			print(to_print)

		_log_text += to_print + "\n"

		_ctrls.text_box.insert_text_at_cursor(to_print + "\n")

################
#
# RUN TESTS/ADD SCRIPTS
#
################

#-------------------------------------------------------------------------------
#Runs all the scripts that were added using add_script
#-------------------------------------------------------------------------------
func test_scripts(run_rest=false):
	clear_text()
	_test_scripts.clear()

	if(run_rest):
		for idx in range(_ctrls.scripts_drop_down.get_selected(), _ctrls.scripts_drop_down.get_item_count()):
			_test_scripts.append(_ctrls.scripts_drop_down.get_item_text(idx))
	else:
		_test_scripts.append(_ctrls.scripts_drop_down.get_item_text(_ctrls.scripts_drop_down.get_selected()))

	_test_the_scripts()


#-------------------------------------------------------------------------------
#Runs a single script passed in.
#-------------------------------------------------------------------------------
func test_script(script):
	_test_scripts.clear()
	_test_scripts.append(script)
	_test_the_scripts()
	_test_scripts.clear()

#-------------------------------------------------------------------------------
#Adds a script to be run when test_scripts called
#-------------------------------------------------------------------------------
func add_script(script, select_this_one=false):
	if(_test_scripts.has(script)):
		return

	_test_scripts.append(script)
	_ctrls.scripts_drop_down.add_item(script)
	# Move the run_button in case the size of the path of the script caused the
	# drop down to resize.
	_ctrls.run_button.set_pos(_ctrls.scripts_drop_down.get_pos() + \
	                          Vector2(_ctrls.scripts_drop_down.get_size().x + 5, 0))

	if(select_this_one):
		_ctrls.scripts_drop_down.select(_ctrls.scripts_drop_down.get_item_count() -1)

#-------------------------------------------------------------------------------
# Add all scripts in the specified directory that start with the prefix and end
# with the suffix.  Does not look in sub directories.  Can be called multiple
# times.
#-------------------------------------------------------------------------------
func add_directory(path, prefix=_file_prefix, suffix=_file_extension):
	var d = Directory.new()
	if(!d.dir_exists(path)):
		return
	d.open(path)
	d.list_dir_begin()

	#Traversing a directory is kinda odd.  You have to start the process of listing
	#the contents of a directory with list_dir_begin then use get_next until it
	#returns an empty string.  Then I guess you should end it.
	var thing = d.get_next()
	var full_path = ''
	while(thing != ''):
		full_path = path + "/" + thing
		#file_exists returns fasle for directories
		if(d.file_exists(full_path)):
			if(thing.begins_with(prefix) and thing.find(suffix) != -1):
				add_script(full_path)
		thing = d.get_next()
	d.list_dir_end()

#-------------------------------------------------------------------------------
# This will try to find a script in the list of scripts to test that contains
# the specified script name.  It does not have to be a full match.  It will
# select the first matching occurance so that this script will run when run_tests
# is called.  Works the same as the select_this_one option of add_script.
#
# returns whether it found a match or not
#-------------------------------------------------------------------------------
func select_script(script_name):
	var found = false
	var idx = 0

	while(idx < _ctrls.scripts_drop_down.get_item_count() and !found):
		if(_ctrls.scripts_drop_down.get_item_text(idx).find(script_name) != -1):
			_ctrls.scripts_drop_down.select(idx)
			found = true
		else:
			idx += 1

	return found
################
#
# ASSERTS
#
################
func _pass_if_datatypes_match(got, expected, text):
	var passed = true

	if(!_disable_strict_datatype_checks):
		var got_type = typeof(got)
		var expect_type = typeof(expected)
		if(got_type != expect_type and got != null and expected != null):
			# If we have a mismatch between float and int (types 2 and 3) then
			# print out a warning but do not fail.
			if([2, 3].has(got_type) and [2, 3].has(expect_type)):
				p(str('Warn:  Float/Int comparison.  Got ', types[got_type], ' but expected ', types[expect_type]), 1)
			else:
				_fail('Cannot compare ' + types[got_type] + '[' + str(got) + '] to ' + types[expect_type] + '[' + str(expected) + '].  ' + text)
				passed = false

	return passed

#-------------------------------------------------------------------------------
#Asserts that the expected value equals the value got.
#-------------------------------------------------------------------------------
func assert_eq(got, expected, text=""):
	var disp = "[" + str(got) + "] expected to equal [" + str(expected) + "]:  " + text
	if(_pass_if_datatypes_match(got, expected, text)):
		if(expected != got):
			_fail(disp)
		else:
			_pass(disp)

#-------------------------------------------------------------------------------
#Asserts that the value got does not equal the "not expected" value.
#-------------------------------------------------------------------------------
func assert_ne(got, not_expected, text=""):
	var disp = "[" + str(got) + "] expected to be anything except [" + str(not_expected) + "]:  " + text
	if(_pass_if_datatypes_match(got, not_expected, text)):
		if(got == not_expected):
			_fail(disp)
		else:
			_pass(disp)
#-------------------------------------------------------------------------------
#Asserts got is greater than expected
#-------------------------------------------------------------------------------
func assert_gt(got, expected, text=""):
	var disp = "[" + str(got) + "] expected to be > than [" + str(expected) + "]:  " + text
	if(_pass_if_datatypes_match(got, expected, text)):
		if(got > expected):
			_pass(disp)
		else:
			_fail(disp)

#-------------------------------------------------------------------------------
#Asserts got is less than expected
#-------------------------------------------------------------------------------
func assert_lt(got, expected, text=""):
	var disp = "[" + str(got) + "] expected to be < than [" + str(expected) + "]:  " + text
	if(_pass_if_datatypes_match(got, expected, text)):
		if(got < expected):
			_pass(disp)
		else:
			_fail(disp)

#-------------------------------------------------------------------------------
#asserts that got is true
#-------------------------------------------------------------------------------
func assert_true(got, text=""):
	if(!got):
		_fail(text)
	else:
		_pass(text)

#-------------------------------------------------------------------------------
#Asserts that got is false
#-------------------------------------------------------------------------------
func assert_false(got, text=""):
	if(got):
		_fail(text)
	else:
		_pass(text)

#-------------------------------------------------------------------------------
#Asserts value is between (inclusive) the two expected values.
#-------------------------------------------------------------------------------
func assert_between(got, expect_low, expect_high, text=""):
	var disp = "[" + str(got) + "] expected to be between [" + str(expect_low) + "] and [" + str(expect_high) + "]:  " + text

	if(_pass_if_datatypes_match(got, expect_low, text) and _pass_if_datatypes_match(got, expect_high, text)):
		if(expect_low > expect_high):
			disp = "INVALID range.  [" + str(expect_low) + "] is not less than [" + str(expect_high) + "]"
			_fail(disp)
		else:
			if(got < expect_low or got > expect_high):
				_fail(disp)
			else:
				_pass(disp)

#-------------------------------------------------------------------------------
# Uses the 'has' method of the object passed in to determine if it contains
# the passed in element.
#-------------------------------------------------------------------------------
func assert_has(obj, element, text=""):
	var disp = str('Expected [', obj, '] to contain value:  [', element, ']:  ', text)
	if(obj.has(element)):
		_pass(disp)
	else:
		_fail(disp)

func assert_does_not_have(obj, element, text=""):
	var disp = str('Expected [', obj, '] to NOT contain value:  [', element, ']:  ', text)
	if(obj.has(element)):
		_fail(disp)
	else:
		_pass(disp)
#-------------------------------------------------------------------------------
#Asserts that a file exists
#-------------------------------------------------------------------------------
func assert_file_exists(file_path):
	var disp = 'expected [' + file_path + '] to exist.'
	var f = File.new()
	if(f.file_exists(file_path)):
		_pass(disp)
	else:
		_fail(disp)

#-------------------------------------------------------------------------------
#Asserts that a file should not exist
#-------------------------------------------------------------------------------
func assert_file_does_not_exist(file_path):
	var disp = 'expected [' + file_path + '] to NOT exist'
	var f = File.new()
	if(!f.file_exists(file_path)):
		_pass(disp)
	else:
		_fail(disp)

#-------------------------------------------------------------------------------
# Asserts the specified file is empty
#-------------------------------------------------------------------------------
func assert_file_empty(file_path):
	var disp = 'expected [' + file_path + '] to be empty'
	var f = File.new()
	if(f.file_exists(file_path) and is_file_empty(file_path)):
		_pass(disp)
	else:
		_fail(disp)

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func assert_file_not_empty(file_path):
	var disp = 'expected [' + file_path + '] to contain data'
	if(!is_file_empty(file_path)):
		_pass(disp)
	else:
		_fail(disp)

#-------------------------------------------------------------------------------
# Verifies the object has get and set methods for the property passed in.  The
# property isn't tied to anything, just a name to be appended to the end of
# get_ and set_.  Asserts the get_ and set_ methods exist, if not, it stops there.
# If they exist then it asserts get_ returns the expected default then calls
# set_ and asserts get_ has the value it was set to.
#-------------------------------------------------------------------------------
func assert_get_set_methods(obj, property, default, set_to):
	var fail_count = get_fail_count()
	var get = 'get_' + property
	var set = 'set_' + property
	assert_true(obj.has_method(get), 'Should have get method:  ' + get)
	assert_true(obj.has_method(set), 'Should have set method:  ' + set)
	if(get_fail_count() > fail_count):
		return
	assert_eq(obj.call(get), default, 'It should have the expected default value.')
	obj.call(set, set_to)
	assert_eq(obj.call(get), set_to, 'The set value should have been returned.')

#-------------------------------------------------------------------------------
#Mark the current test as pending.
#-------------------------------------------------------------------------------
func pending(text=""):
	_summary.pending += 1
	if(text == ""):
		p("Pending")
	else:
		p("Pending:  " + text)
	end_yielded_test()
################
#
# MISC
#
################
func disable_strict_datatype_checks(should):
	_disable_strict_datatype_checks = should

func is_strict_datatype_checks_disabled():
	return _disable_strict_datatype_checks

#-------------------------------------------------------------------------------
#Pauses the test and waits for you to press a confirmation button.  Useful when
#you want to watch a test play out onscreen or inspect results.
#-------------------------------------------------------------------------------
func end_yielded_test():
	_waiting = false

#-------------------------------------------------------------------------------
#Clears the text of the text box.  This resets all counters.
#-------------------------------------------------------------------------------
func clear_text():
	_ctrls.text_box.set_text("")
	_ctrls.text_box.clear_colors()
	update()

#-------------------------------------------------------------------------------
#Get the number of tests that were ran
#-------------------------------------------------------------------------------
func get_test_count():
	return _summary.tests

#-------------------------------------------------------------------------------
#Get the number of assertions that were made
#-------------------------------------------------------------------------------
func get_assert_count():
	return _summary.asserts

#-------------------------------------------------------------------------------
#Get the number of assertions that passed
#-------------------------------------------------------------------------------
func get_pass_count():
	return _summary.passed

#-------------------------------------------------------------------------------
#Get the number of assertions that failed
#-------------------------------------------------------------------------------
func get_fail_count():
	return _summary.failed

#-------------------------------------------------------------------------------
#Get the number of tests flagged as pending
#-------------------------------------------------------------------------------
func get_pending_count():
	return _summary.pending

#-------------------------------------------------------------------------------
#Set whether it should print to console or not.  Default is yes.
#-------------------------------------------------------------------------------
func set_should_print_to_console(should):
	_should_print_to_console = should

#-------------------------------------------------------------------------------
#Get whether it is printing to the console
#-------------------------------------------------------------------------------
func get_should_print_to_console():
	return _should_print_to_console

#-------------------------------------------------------------------------------
#Get the results of all tests ran as text.  This string is the same as is
#displayed in the text box, and simlar to what is printed to the console.
#-------------------------------------------------------------------------------
func get_result_text():
	return _log_text

#-------------------------------------------------------------------------------
#Set the log level.  Use one of the various LOG_LEVEL_* constants.
#-------------------------------------------------------------------------------
func set_log_level(level):
	_log_level = level
	_ctrls.log_level_slider.set_value(level)

#-------------------------------------------------------------------------------
#Get the current log level.
#-------------------------------------------------------------------------------
func get_log_level():
	return _log_level

#-------------------------------------------------------------------------------
#DISABLED, does not work in 1.0
#Call this method to make the test pause before teardown so that you can inspect
#anything that you have rendered to the screen.
#-------------------------------------------------------------------------------
func pause_before_teardown():
	_pause_before_teardown = true;

#-------------------------------------------------------------------------------
# For batch processing purposes, you may want to ignore any calls to
# pause_before_teardown that you forgot to remove.
#-------------------------------------------------------------------------------
func set_ignore_pause_before_teardown(should_ignore):
	_ignore_pause_before_teardown = should_ignore
	_ctrls.ignore_continue_checkbox.set_pressed(should_ignore)

func get_ignore_pause_before_teardown():
	return _ignore_pause_before_teardown

#-------------------------------------------------------------------------------
#Set to true so that painting of the screen will occur between tests.  Allows you
#to see the output as tests occur.  Especially useful with long running tests that
#make it appear as though it has humg.
#
#NOTE:  not compatible with 1.0 so this is disabled by default.  This will
#change in future releases.
#-------------------------------------------------------------------------------
func set_yield_between_tests(should):
	_yield_between.should = should

func get_yield_between_tests():
	return _yield_between.should

#-------------------------------------------------------------------------------
#Call _process or _fixed_process, if they exist, on obj and all it's children
#and their children and so and so forth.  Delta will be passed through to all
#the _process or _fixed_process methods.
#-------------------------------------------------------------------------------
func simulate(obj, times, delta):
	for i in range(times):
		if(obj.has_method("_process")):
			obj._process(delta)
		if(obj.has_method("_fixed_process")):
			obj._fixed_process(delta)

		for kid in obj.get_children():
			simulate(kid, 1, delta)

#-------------------------------------------------------------------------------
# Starts an internal timer with a timeout of the passed in time.  A 'timeout'
# signal will be sent when the timer ends.  Returns itself so that it can be
# used in a call to yield...cutting down on lines of code.
#
# Example, yield to the Gut object for 10 seconds:
#  yield(gut.set_yield_time(10), 'timeout')
#-------------------------------------------------------------------------------
func set_yield_time(time, text=''):
	_yield_timer.set_wait_time(time)
	_yield_timer.start()
	var msg = '/# Yeilding (' + str(time) + 's)'
	if(text == ''):
		msg += ' #/'
	else:
		msg +=  ':  ' + text + ' #/'
	p(msg, 1)
	_set_yield_time_called = true
	return self

#-------------------------------------------------------------------------------
# get the specific unit test that should be run
#-------------------------------------------------------------------------------
func get_unit_test_name():
	return _unit_test_name

#-------------------------------------------------------------------------------
# set the specific unit test that should be run.
#-------------------------------------------------------------------------------
func set_unit_test_name(test_name):
	_unit_test_name = test_name

#-------------------------------------------------------------------------------
# Creates an empty file at the specified path
#-------------------------------------------------------------------------------
func file_touch(path):
	var f = File.new()
	f.open(path, f.WRITE)
	f.close()

#-------------------------------------------------------------------------------
# deletes the file at the specified path
#-------------------------------------------------------------------------------
func file_delete(path):
	var d = Directory.new()
	d.open(path.get_base_dir())
	d.remove(path)

#-------------------------------------------------------------------------------
# Checks to see if the passed in file has any data in it.
#-------------------------------------------------------------------------------
func is_file_empty(path):
	var f = File.new()
	f.open(path, f.READ)
	var empty = f.get_len() == 0
	f.close()
	return empty

#-------------------------------------------------------------------------------
# deletes all files in a given directory
#-------------------------------------------------------------------------------
func directory_delete_files(path):
	var d = Directory.new()
	d.open(path)
	d.list_dir_begin()

	#Traversing a directory is kinda odd.  You have to start the process of listing
	#the contents of a directory with list_dir_begin then use get_next until it
	#returns an empty string.  Then I guess you should end it.
	var thing = d.get_next()
	var full_path = ''
	while(thing != ''):
		full_path = path + "/" + thing
		#file_exists returns fasle for directories
		if(d.file_exists(full_path)):
			d.remove(full_path)
		thing = d.get_next()
	d.list_dir_end()

################################################################################
# OneTest (INTERNAL USE ONLY)
#	Used to keep track of info about each test ran.
################################################################################
class OneTest:
	# indicator if it passed or not.  defaults to true since it takes only
	# one failure to make it not pass.  _fail in gut will set this.
	var passed = true
	# the name of the function
	var name = ""
	# flag to know if the name has been printed yet.
	var has_printed_name = false
	# the line number the test is on
	var line_number = -1
