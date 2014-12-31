################################################################################
#(G)odot (U)nit (T)est
#
#Simple tool for executing unit tests.  There are various asserts that you get
#access to through this, as well as a way to automate running tests.
#
#Example of running tests:
#        |-----this script----|                    |-------the test script-------| 
#	load('res://scripts/gut.gd').new().test_script('res://scripts/sample_tests.gd')
################################################################################
extends Node2D

const LOG_LEVEL_FAIL_ONLY = 0
const LOG_LEVEL_TEST_AND_FAILURES = 1
const LOG_LEVEL_ALL_ASSERTS = 2

var _test_prefix = "test_"
var _tests = []
var _should_print = true
var _current_test = null
var _log_level = 1

#various counters
var _asserts = 0
var _passed = 0
var _failed = 0

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func _init_run():
	_asserts = 0
	_passed = 0
	_failed = 0
	_tests.clear()

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
func set_should_print(should):
	_should_print = should

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func get_should_print():
	return _should_print

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func get_result_text():
	var to_return = ""
	
	for i in range(_tests.size()):
		if(_log_level == LOG_LEVEL_FAIL_ONLY):
			if(!_tests[i].passed):
				to_return += _tests[i].name + "\n" + _tests[i].output + "\n"
		elif(_log_level >= LOG_LEVEL_TEST_AND_FAILURES):
			to_return += _tests[i].name + "\n"
			if(!_tests[i].passed or _log_level >= LOG_LEVEL_ALL_ASSERTS):
				to_return += _tests[i].output + "\n"
	
	to_return += "\n" + _get_summary_text()
	return to_return

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
	
	if(_should_print):
		if(!_current_test.has_printed_name):
			print(_current_test.name)
			_current_test.has_printed_name = true
		print(pad + text)
	
	if(_current_test != null):
		_current_test.output += "\n " + pad + text

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func test_script(script):
	_init_run()
	_parse_tests(script)
	
	var tests = load(script).new()
	tests.gut = self
	
	tests.prerun_setup()
	
	for i in range(_tests.size()):
		_current_test = _tests[i]
		tests.setup()
		tests.call(_current_test.name)
		tests.teardown()

	_current_test = null
	tests.postrun_teardown()
	
	p(_get_summary_text())
	
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




################################################################################
#Class that all test scripts must extend.  Syntax is just a normal extends with
#a .Tests at the end.  Example:  extends "res://scripts/gut.gd".Tests
#
#Once a class extends this class it can be passed off to the test_script method
#of a gut instance.
################################################################################
class Tests:
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