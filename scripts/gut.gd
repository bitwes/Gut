################################################################################
#(G)odot (U)nit (T)est
#
#Simple tool for executing unit tests.  There are various asserts that you get
#access to through this, as well as a way to automate running tests.
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
#	tester.add_script('res://scripts/another_set_of_tests.gd')
#	tester.tester.test_scripts()
################################################################################
extends Panel

const LOG_LEVEL_FAIL_ONLY = 0
const LOG_LEVEL_TEST_AND_FAILURES = 1
const LOG_LEVEL_ALL_ASSERTS = 2

#The prefix used to get tests.
var _test_prefix = "test_"
#Tests to run for the current script
var _tests = []
#all the scripts that should be ran as test scripts
var _test_scripts = []

var _should_print_to_console = true
var _current_test = null
var _log_level = 1
var _log_text = ""

#various counters
var _summary = {
	asserts = 0,
	passed = 0,
	failed = 0,
	tests = 0,
	scripts = 0
}

#controls
var _text_box = TextEdit.new()
var _run_button = Button.new()
var _copy_button = Button.new()
var _clear_button = Button.new()
var _log_level_slider = HSlider.new()
var _scripts_drop_down = OptionButton.new()


#-------------------------------------------------------------------------------
#Initialize controls
#-------------------------------------------------------------------------------
func _ready():
	self.set_pos(Vector2(0, 0))
	self.set_size(Vector2(800, 600))
	
	add_child(_text_box)
	_text_box.set_size(Vector2(800, 500))
	_text_box.set_pos(Vector2(0, 0))
	_text_box.set_readonly(true)
	_text_box.set_syntax_coloring(true)
	
	add_child(_run_button)
	_run_button.set_text("Run Tests")
	_run_button.set_size(Vector2(100, 50))
	_run_button.set_pos(Vector2(690, 510))
	_run_button.connect("pressed", self, "_on_run_button_pressed")

	add_child(_copy_button)
	_copy_button.set_text("Copy")
	_copy_button.set_size(Vector2(100, 50))
	_copy_button.set_pos(Vector2(580, 510))
	_copy_button.connect("pressed", self, "_copy_button_pressed")
	
	add_child(_clear_button)
	_clear_button.set_text("Clear")
	_clear_button.set_size(Vector2(100, 50))
	_clear_button.set_pos(Vector2(470, 510))
	_clear_button.connect("pressed", self, "clear_text")
	
	var log_label = Label.new()
	add_child(log_label)
	log_label.set_text("Log Level")
	log_label.set_pos(Vector2(10, 510))
	add_child(_log_level_slider)
	_log_level_slider.set_size(Vector2(75, 30))
	_log_level_slider.set_pos(Vector2(100, 510))
	_log_level_slider.set_min(0)
	_log_level_slider.set_max(2)
	_log_level_slider.set_ticks(3)
	_log_level_slider.set_ticks_on_borders(true)
	_log_level_slider.set_step(1)
	_log_level_slider.set_rounded_values(true)
	_log_level_slider.connect("value_changed", self, "on_log_level_slider_changed")
	
	
	add_child(_scripts_drop_down)
	_scripts_drop_down.set_size(Vector2(375, 25))
	_scripts_drop_down.set_pos(Vector2(10, 550))
	_scripts_drop_down.add_item("Run All")
	
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func _draw():
	var where = Vector2(430, 565)
	var r = 25
	if(_summary.tests > 0):
		if(_summary.failed > 0):
			draw_circle(where, r , Color(1, 0, 0, 1))
		else:
			draw_circle(where, r, Color(0, 1, 0, 1))

#-------------------------------------------------------------------------------
#Initialize variables for each run of tests.
#-------------------------------------------------------------------------------
func _init_run():
	_summary.asserts = 0
	_summary.passed = 0
	_summary.failed = 0
	_summary.tests = 0
	_summary.scripts = 0
	_log_text = ""
	_text_box.clear_colors()
	_text_box.add_keyword_color("PASSED", Color(0, 1, 0))
	_text_box.add_keyword_color("FAILED", Color(1, 0, 0))
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
	to_return += str(_summary.failed) + " Failed\n"
	return to_return

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func _test_script(script):
	_tests.clear()
	_parse_tests(script)
	_summary.scripts += 1
	p("/-----------------------------------------")
	p("Testing Script " + script, 0)
	p("-----------------------------------------/")
	var test_script = load(script).new()
	test_script.gut = self
	
	test_script.prerun_setup()
	
	for i in range(_tests.size()):
		_current_test = _tests[i]
		p(_current_test.name, 1)
		test_script.setup()
		_summary.tests += 1
		test_script.call(_current_test.name)
		test_script.teardown()
		if(_current_test.passed):
			_text_box.add_keyword_color(_current_test.name, Color(0, 1, 0))
		else:
			_text_box.add_keyword_color(_current_test.name, Color(1, 0, 0))

	_current_test = null
	test_script.postrun_teardown()
	test_script.free()
	p("\n\n")

#-------------------------------------------------------------------------------
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
#-------------------------------------------------------------------------------
func test_scripts():
	_init_run()
	for i in range(_test_scripts.size()):
		_test_script(_test_scripts[i])
	p(_get_summary_text(), 0)
	update()

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func test_script(script):
	_test_scripts.clear()
	_test_scripts.append(script)
	test_scripts()
	_test_scripts.clear()

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func add_script(script):
	_test_scripts.append(script)
	_scripts_drop_down.add_item(script)

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func assert_eq(expected, got, text=""):
	var disp = "Expected [" + str(expected) + "] to equal [" + str(got) + "]:  " + text
	if(expected != got):
		_fail(disp)
	else:
		_pass(disp)

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func assert_ne(not_expected, got, text=""):
	var disp = "Expected [" + str(got) + "] to be anything except [" + str(not_expected) + "]:  " + text
	if(got == not_expected):
		_fail(disp)
	else:
		_pass(disp)

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func assert_true(got, text=""):
	if(!got):
		_fail(text)
	else:
		_pass(text)

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func assert_false(got, text=""):
	if(got):
		_fail(text)
	else:
		_pass(text)

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func clear_text():
	_init_run()
	_text_box.set_text("")
	_text_box.clear_colors()
	update()

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func _on_run_button_pressed():
	clear_text()
	if(_scripts_drop_down.get_selected() == 0):
		_test_scripts.clear()
		for idx in range(1, _scripts_drop_down.get_item_count()):
			_test_scripts.append(_scripts_drop_down.get_item_text(idx))
	else:
		_test_scripts.clear()
		_test_scripts.append(_scripts_drop_down.get_item_text(_scripts_drop_down.get_selected()))
	
	test_scripts()
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func _copy_button_pressed():
	_text_box.select_all()
	_text_box.copy()

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func on_log_level_slider_changed(value):
	_log_level = _log_level_slider.get_value()

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func get_test_count():
	return _summary.tests

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func get_assert_count():
	return _summary.asserts

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func get_pass_count():
	return _summary.passed

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func get_fail_count():
	return _summary.failed

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func get_tests_ran():
	return _summary.tests

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func set_should_print_to_console(should):
	_should_print_to_console = should

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func get_should_print_to_console():
	return _should_print_to_console

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func get_result_text():
	return _log_text
	
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func set_log_level(level):
	_log_level = level
	_log_level_slider.set_value(level)

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func get_log_leve():
	return _log_level

################################################################################
#Class that all test scripts must extend.  Syntax is just a normal extends with
#a .Tests at the end.  Example:  extends "res://scripts/gut.gd".Tests
#
#Once a class extends this class it can be passed off to the test_script method
#of a gut instance.
################################################################################
class Tests:
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
	#any gut.p statements processed while this test is running
	#will be channled into this property.
	var output = ""
	#indicator if it passed or not.  defaults to true since it takes only
	#one failure to make it not pass.  _fail in gut will set this.
	var passed = true
	#the name of the function
	var name = ""
	#flag to know if the name has been printed yet.
	var has_printed_name = false
	