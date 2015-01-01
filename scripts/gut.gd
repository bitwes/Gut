################################################################################
#(G)odot (U)nit (T)est
#
#Simple tool for executing unit tests.  There are various asserts that you get
#access to through this, as well as a way to automate running tests.
#
#Example of running tests:
#        |-----this script----|                    |-------the test script-------| 
#   load('res://scripts/gut.gd').new().test_script('res://scripts/sample_tests.gd')
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
var _asserts = 0
var _passed = 0
var _failed = 0

#controls
var _text_box = null
var _run_button = null
var _copy_button = null
var _clear_button = null

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func _init():
	_text_box = TextEdit.new()
	_run_button = Button.new()

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func _ready():
	self.set_pos(Vector2(0, 0))
	self.set_size(Vector2(800, 600))
	
	add_child(_text_box)
	_text_box.set_size(Vector2(800, 500))
	_text_box.set_pos(Vector2(0, 0))
	
	add_child(_run_button)
	_run_button.set_text("Run Tests")
	_run_button.set_size(Vector2(100, 50))
	_run_button.set_pos(Vector2(690, 510))
	_run_button.connect("pressed", self, "test_scripts")

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func _init_run():
	_asserts = 0
	_passed = 0
	_failed = 0
	_log_text = ""
	_current_test = 0

#-------------------------------------------------------------------------------
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
#-------------------------------------------------------------------------------
func _fail(text):
	_asserts += 1
	_failed += 1
	_current_test.passed = false
	p("FAILED:  " + text, 2)

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func _pass(text):
	_asserts += 1
	_passed += 1
	if(_log_level >= LOG_LEVEL_ALL_ASSERTS):
		p("PASSED:  " + text, 2)

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func _get_summary_text():
	var to_return = "Results\n--------------------\n" 
	to_return += str(_tests.size()) + " Tests\n" 
	to_return += str(_asserts) + " Asserts\n" 
	to_return += str(_passed) + " Passed\n" 
	to_return += str(_failed) + " Failed\n"
	return to_return

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func get_test_count():
	return _tests.size()

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func get_assert_count():
	return _asserts

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func get_pass_count():
	return _passed

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func get_fail_count():
	return _failed

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func get_tests_ran():
	return _tests

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

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func get_log_leve():
	return _log_level

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func p(text, indent=0):
	var pad = ""
	for i in range(0, indent):
		pad += "  "
	var to_print = pad + text
	
	if(_should_print_to_console):
		print(to_print)

	_log_text += to_print + "\n"
	
	_text_box.insert_text_at_cursor(to_print + "\n")

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func _test_script(script):
	_tests.clear()
	_parse_tests(script)
	
	var test_script = load(script).new()
	test_script.gut = self
	
	test_script.prerun_setup()
	
	for i in range(_tests.size()):
		_current_test = _tests[i]
		test_script.setup()
		test_script.call(_current_test.name)
		test_script.teardown()

	_current_test = null
	test_script.postrun_teardown()
	
	p(_get_summary_text())
	test_script.free()
	
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func test_scripts():
	_init_run()
	self.clear_text()
	for i in range(_test_scripts.size()):
		_test_script(_test_scripts[i])

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func test_script(script):
	_test_scripts.clear()
	_test_scripts.append(script)
	test_scripts()

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func add_script(script):
	_test_scripts.append(script)

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func assert_eq(expected, got, text):
	var disp = "Expected [" + str(expected) + "] to equal [" + str(got) + "]:  " + text
	if(expected != got):
		_fail(disp)
	else:
		_pass(disp)

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func assert_ne(not_expected, got, text):
	var disp = "Expected [" + str(got) + "] to be anything except [" + str(not_expected) + "]:  " + text
	if(got == not_expected):
		_fail(disp)
	else:
		_pass(disp)

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func assert_true(got, text):
	if(!got):
		_fail(text)
	else:
		_pass(text)

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func assert_false(got, text):
	if(got):
		_fail(text)
	else:
		_pass(text)

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func clear_text():
	_text_box.set_text("")


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