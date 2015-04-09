################################################################################
#(G)odot (U)nit (T)est class
#
#How it works
#	
#
#Simple tool for executing unit tests.  There are various asserts that you get
#access to through this, as well as a way to automate running tests.  There's more 
#info in the readme for the project.
#
#Example of running a single script.  Output is sent to console
#        |-----this script----|                    |-------the test script-------| 
#   load('res://scripts/gut.gd').new().test_script('res://scripts/sample_tests.gd')
#
#Example of running multiple scripts.  Output is sent to console and drawn to 
#screen.
#	var tester = load('res://scripts/gut.gd').new()
#	add_child(tester)
#	tester.add_script('res://scripts/sample_tests.gd')
#	tester.add_script('res://scripts/another_set_of_tests.gd', true) #see below
#	tester.tester.test_scripts()
#
#Optionally you can pass a true flag as a second parameter to add_script.  This 
#will cause that script to be the selected script in the drop down and it will 
#only run that script initially.  You can then run any other script you have
#loaded or all the scripts using the drop down.  
################################################################################
extends WindowDialog

const LOG_LEVEL_FAIL_ONLY = 0
const LOG_LEVEL_TEST_AND_FAILURES = 1
const LOG_LEVEL_ALL_ASSERTS = 2

const YIELD_MESSAGE = '/# Yield detected.  Waiting for end_yielded_test to be called. #/'
const WAITING_MESSAGE = '/# waiting #/'
const PAUSE_MESSAGE = '/# Pausing.  Press continue button...#/'


#The prefix used to get tests.
var _test_prefix = "test_"
#Tests to run for the current script
var _tests = []
#all the scripts that should be ran as test scripts
var _test_scripts = []

var _waiting = false
var _done = false

var _should_print_to_console = true
var _current_test = null
var _log_level = 1
var _log_text = ""

var _pause_before_teardown = false
var _wait_timer = Timer.new()

#various counters
var _summary = {
	asserts = 0,
	passed = 0,
	failed = 0,
	tests = 0,
	scripts = 0,
	pending = 0
}

#controls
var _text_box = TextEdit.new()
var _run_button = Button.new()
var _copy_button = Button.new()
var _clear_button = Button.new()
var _continue_button = Button.new()
var _log_level_slider = HSlider.new()
var _scripts_drop_down = OptionButton.new()

var _mouse_down = false
var _mouse_down_pos = null
var _mouse_in = false

var min_size = Vector2(650, 400)

func _set_anchor_bottom_right(obj):
	obj.set_anchor(MARGIN_LEFT, ANCHOR_END)
	obj.set_anchor(MARGIN_RIGHT, ANCHOR_END)
	obj.set_anchor(MARGIN_TOP, ANCHOR_END)
	obj.set_anchor(MARGIN_BOTTOM, ANCHOR_END)

func _set_anchor_bottom_left(obj):
	obj.set_anchor(MARGIN_LEFT, ANCHOR_BEGIN)
	obj.set_anchor(MARGIN_TOP, ANCHOR_END)
	obj.set_anchor(MARGIN_TOP, ANCHOR_END)

#-------------------------------------------------------------------------------
#Initialize controls
#-------------------------------------------------------------------------------
func _ready():
	set_process_input(true)
	
	show()
	set_pos(get_pos() + Vector2(0, 20))
	self.set_size(min_size)
	
	var button_size = Vector2(75, 35)
	var button_spacing = Vector2(10, 0)
	
	add_child(_text_box)
	_text_box.set_size(Vector2(get_size().x - 4, 300))
	_text_box.set_pos(Vector2(2, 0))
	_text_box.set_readonly(true)
	_text_box.set_syntax_coloring(true)
	_text_box.set_anchor(MARGIN_LEFT, ANCHOR_BEGIN)
	_text_box.set_anchor(MARGIN_RIGHT, ANCHOR_END)
	_text_box.set_anchor(MARGIN_TOP, ANCHOR_BEGIN)
	_text_box.set_anchor(MARGIN_BOTTOM, ANCHOR_END)
	
	add_child(_run_button)
	_run_button.set_text("Run Tests")
	_run_button.set_size(button_size)
	_run_button.set_pos(Vector2(get_size().x - 5 - button_size.x, _text_box.get_size().y + 10))
	_run_button.connect("pressed", self, "_on_run_button_pressed")
	_set_anchor_bottom_right(_run_button)

	add_child(_copy_button)
	_copy_button.set_text("Copy")
	_copy_button.set_size(button_size)
	_copy_button.set_pos(_run_button.get_pos() - Vector2(button_size.x, 0) - button_spacing)
	_copy_button.connect("pressed", self, "_copy_button_pressed")
	_set_anchor_bottom_right(_copy_button)
	
	add_child(_clear_button)
	_clear_button.set_text("Clear")
	_clear_button.set_size(button_size)
	_clear_button.set_pos(_copy_button.get_pos() - Vector2(button_size.x, 0) - button_spacing)
	_clear_button.connect("pressed", self, "clear_text")
	_set_anchor_bottom_right(_clear_button)
	
	add_child(_continue_button)
	_continue_button.set_text("Continue")
	_continue_button.set_size(Vector2(100, 25))
	_continue_button.set_pos(Vector2(_clear_button.get_pos().x, _clear_button.get_pos().y + _clear_button.get_size().y + 10))
	_continue_button.set_disabled(true)
	_continue_button.connect("pressed", self, "_on_continue_button_pressed")
	_set_anchor_bottom_right(_continue_button)
	
	var log_label = Label.new()
	add_child(log_label)
	log_label.set_text("Log Level")
	log_label.set_pos(Vector2(10, _text_box.get_size().y + 20))
	_set_anchor_bottom_left(log_label)
	
	add_child(_log_level_slider)
	_log_level_slider.set_size(Vector2(75, 30))
	_log_level_slider.set_pos(Vector2(100, log_label.get_pos().y))
	_log_level_slider.set_min(0)
	_log_level_slider.set_max(2)
	_log_level_slider.set_ticks(3)
	_log_level_slider.set_ticks_on_borders(true)
	_log_level_slider.set_step(1)
	_log_level_slider.set_rounded_values(true)
	_log_level_slider.connect("value_changed", self, "_on_log_level_slider_changed")
	_log_level_slider.set_value(_log_level)
	_set_anchor_bottom_left(_log_level_slider)
	
	add_child(_scripts_drop_down)
	_scripts_drop_down.set_size(Vector2(375, 25))
	_scripts_drop_down.set_pos(Vector2(10, _log_level_slider.get_pos().y + 50))
	_scripts_drop_down.add_item("Run All")
	_set_anchor_bottom_left(_scripts_drop_down)
	
	add_child(_wait_timer)
	_wait_timer.set_wait_time(1)
	_wait_timer.set_one_shot(true)
	
	self.connect("mouse_enter", self, "_on_mouse_enter")
	self.connect("mouse_exit", self, "_on_mouse_exit")
	
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
	_text_box.select_all()
	_text_box.copy()

#-------------------------------------------------------------------------------
#Continue processing after pause.
#-------------------------------------------------------------------------------
func _on_continue_button_pressed():
	_pause_before_teardown = false
	_continue_button.set_disabled(true)

#-------------------------------------------------------------------------------
#Change the log level.  Will be visible the next time tests are run.
#-------------------------------------------------------------------------------
func _on_log_level_slider_changed(value):
	_log_level = _log_level_slider.get_value()

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
	_text_box.clear_colors()
	_text_box.add_keyword_color("PASSED", Color(0, 1, 0))
	_text_box.add_keyword_color("FAILED", Color(1, 0, 0))
	_text_box.add_color_region('/#', '#/', Color(.9, .6, 0))
	_text_box.add_color_region('/-', '-/', Color(1, 1, 0))
	_text_box.add_color_region('/*', '*/', Color(.5, .5, 1))
	_text_box.set_symbol_color(Color(.5, .5, .5))
	_current_test = null

#-------------------------------------------------------------------------------
#Parses out the tests based on the _test_prefix.  Fills the _tests array with
#instances of OneTest.
#-------------------------------------------------------------------------------
func _parse_tests(script):
	var file = File.new()
	var line = ""

	file.open(script, 1)
	while(!file.eof_reached()):
		line = file.get_line()
		#Add a test
		if(line.begins_with("func " + _test_prefix)):
			var from = line.find(_test_prefix)
			var len = line.find("(") - from
			var new_test = OneTest.new()
			new_test.name = line.substr(from, len)
			_tests.append(new_test)

	file.close()

#-------------------------------------------------------------------------------
#Fail an assertion.  Causes test and script to fail as well.
#-------------------------------------------------------------------------------
func _fail(text):
	_summary.asserts += 1
	_summary.failed += 1
	_current_test.passed = false
	p("FAILED:  " + text, LOG_LEVEL_FAIL_ONLY)

#-------------------------------------------------------------------------------
#Pass an assertion.
#-------------------------------------------------------------------------------
func _pass(text):
	_summary.asserts += 1
	_summary.passed += 1
	if(_log_level >= LOG_LEVEL_ALL_ASSERTS):
		p("PASSED:  " + text, LOG_LEVEL_ALL_ASSERTS)

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
	return to_return

#-------------------------------------------------------------------------------
#Run all tests in a script.  This is the core logic for running tests.
#-------------------------------------------------------------------------------
func _test_the_scripts():
	_init_run()
	_run_button.set_disabled(true)
	for s in range(_test_scripts.size()):
		_tests.clear()
		_parse_tests(_test_scripts[s])
		_summary.scripts += 1
		p("/-----------------------------------------")
		p("Testing Script " + _test_scripts[s], 0)
		p("-----------------------------------------/")
		var test_script = load(_test_scripts[s]).new()
		add_child(test_script)
		var script_result = null
		test_script.gut = self
		add_child(test_script)
		test_script.prerun_setup()
		
		for i in range(_tests.size()):
			_current_test = _tests[i]
			p(_current_test.name, 1)
			test_script.setup()
			_summary.tests += 1
			script_result = test_script.call(_current_test.name)
			#When the script yields it will return a GDFunctionState object
			if(script_result != null and typeof(script_result) == TYPE_OBJECT and script_result.get_type() == 'GDFunctionState'):
				p(YIELD_MESSAGE, 1)
				_waiting = true
				while(_waiting):
					p(WAITING_MESSAGE, 2)
					_wait_timer.start()
					yield(_wait_timer, 'timeout')
			#if the test called pause_before_teardown then yield until
			#the continue button is pressed.
			if(_pause_before_teardown):
				p(PAUSE_MESSAGE, 1)
				_waiting = true
				_continue_button.set_disabled(false)
				yield(_continue_button, 'pressed')
			
			test_script.teardown()
			if(_current_test.passed):
				_text_box.add_keyword_color(_current_test.name, Color(0, 1, 0))
			else:
				_text_box.add_keyword_color(_current_test.name, Color(1, 0, 0))
	
		_current_test = null
		test_script.postrun_teardown()
		test_script.free()
		p("\n\n")
	
	p(_get_summary_text(), 0)
	update()
	_run_button.set_disabled(false)

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
				to_print = "*" + _current_test.name
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

		_text_box.insert_text_at_cursor(to_print + "\n")


#-------------------------------------------------------------------------------
#Runs all the scripts that were added using add_script
#-------------------------------------------------------------------------------
func test_scripts():
	clear_text()
	_test_scripts.clear()
	
	if(_scripts_drop_down.get_selected() == 0):
		for idx in range(1, _scripts_drop_down.get_item_count()):
			_test_scripts.append(_scripts_drop_down.get_item_text(idx))
	else:
		print("else")
		_test_scripts.append(_scripts_drop_down.get_item_text(_scripts_drop_down.get_selected()))
		
	_test_the_scripts()
	
#-------------------------------------------------------------------------------
#Runs a single script passed in.
#-------------------------------------------------------------------------------
func test_script(script):
	_test_scripts.clear()
	_test_scripts.append(script)
	test_scripts()
	_test_scripts.clear()

#-------------------------------------------------------------------------------
#Adds a script to be run when test_scripts called
#-------------------------------------------------------------------------------
func add_script(script, select_this_one=false):
	_test_scripts.append(script)
	_scripts_drop_down.add_item(script)
	if(select_this_one):
		_scripts_drop_down.select(_scripts_drop_down.get_item_count() -1)

#-------------------------------------------------------------------------------
#Asserts that the expected value equals the value got.
#-------------------------------------------------------------------------------
func assert_eq(got, expected, text=""):
	var disp = "[" + str(got) + "] expected to equal [" + str(expected) + "]:  " + text
	if(expected != got):
		_fail(disp)
	else:
		_pass(disp)

#-------------------------------------------------------------------------------
#Asserts that the value got does not equal the "not expected" value.  
#-------------------------------------------------------------------------------
func assert_ne(got, not_expected, text=""):
	var disp = "[" + str(got) + "] expected to be anything except [" + str(not_expected) + "]:  " + text
	if(got == not_expected):
		_fail(disp)
	else:
		_pass(disp)
#-------------------------------------------------------------------------------
#Asserts got is greater than expected
#-------------------------------------------------------------------------------
func assert_gt(got, expected, text=""):
	var disp = "[" + str(got) + "] expected to be > than [" + str(expected) + "]:  " + text
	if(got > expected):
		_pass(disp)
	else:
		_fail(disp)

#-------------------------------------------------------------------------------
#Asserts got is less than expected
#-------------------------------------------------------------------------------
func assert_lt(got, expected, text=""):
	var disp = "[" + str(got) + "] expected to be < than [" + str(expected) + "]:  " + text
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
	if(expect_low > expect_high):
		disp = "INVALID range.  [" + str(expect_low) + "] is not less than [" + str(expect_high) + "]"
		_fail(disp)
	else:
		if(got < expect_low or got > expect_high):
			_fail(disp)
		else:
			_pass(disp)
	
#-------------------------------------------------------------------------------
#Mark the current test as pending.
#-------------------------------------------------------------------------------
func pending(text=""):
	_summary.pending += 1
	if(text == ""):
		p("Pending")
	else:
		p("Pending:  " + text)
	
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
	_init_run()
	_text_box.set_text("")
	_text_box.clear_colors()
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
	_log_level_slider.set_value(level)

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

################################################################################
#Class that all test scripts must extend.  Syntax is just a normal extends with
#a .Tests at the end.  Example:  extends "res://scripts/gut.gd".Tests
#
#Once a class extends this class it can be passed off to the test_script method
#of a gut instance.
################################################################################
class Test:
	extends Node
	#Need a reference to the instance that is running the tests.  This
	#is set by the gut class when it runs the tests.  This gets you 
	#access to the asserts in the tests you write.
	var gut = null
	
	#Overridable method that runs before each test.
	func setup():
		pass
	
	#Overridable method that runs after each test
	func teardown():
		pass
	
	#Overridable method that runs before any tests are run
	func prerun_setup():
		pass
	
	#Overridable method that runs after all tests are run 
	func postrun_teardown():
		pass


################################################################################
#OneTest (INTERNAL USE ONLY)
#	Used to keep track of info about each test ran.
################################################################################
class OneTest:
	#indicator if it passed or not.  defaults to true since it takes only
	#one failure to make it not pass.  _fail in gut will set this.
	var passed = true
	#the name of the function
	var name = ""
	#flag to know if the name has been printed yet.
	var has_printed_name = false
	