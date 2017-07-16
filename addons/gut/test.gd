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
# Class that all test scripts must extend.
#
# Once a class extends this class it sent (via the numerous script loading
# methods) to a Gut object to run the tests.
################################################################################
extends Node

# constant for signal when calling yeild_for
const YIELD = 'timeout'

#Need a reference to the instance that is running the tests.  This
#is set by the gut class when it runs the tests.  This gets you
#access to the asserts in the tests you write.
var gut = null
var passed = false
var failed = false
var _disable_strict_datatype_checks = false

var types = {}

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

var _summary = {
	asserts = 0,
	passed = 0,
	failed = 0,
	tests = 0,
	pending = 0
}

var _signal_watcher = load('res://addons/Gut/signal_watcher.gd').new()

func _init():
	_init_types_dictionary()

# #######################
# Virtual Methods
# #######################
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


#-------------------------------------------------------------------------------
#Fail an assertion.  Causes test and script to fail as well.
#-------------------------------------------------------------------------------
func _fail(text):
	_summary.asserts += 1
	_summary.failed += 1
	if(gut):
		gut.p('FAILED:  ' + text, gut.LOG_LEVEL_FAIL_ONLY)
		gut._fail()
		gut.end_yielded_test()


#-------------------------------------------------------------------------------
#Pass an assertion.
#-------------------------------------------------------------------------------
func _pass(text):
	_summary.asserts += 1
	_summary.passed += 1
	if(gut):
		if(gut.get_log_level() >= gut.LOG_LEVEL_ALL_ASSERTS):
			gut.p("PASSED:  " + text, gut.LOG_LEVEL_ALL_ASSERTS)
		gut.end_yielded_test()

# #######################
# Convenience Methods
# #######################
func _pass_if_datatypes_match(got, expected, text):
	var passed = true

	if(!_disable_strict_datatype_checks):
		var got_type = typeof(got)
		var expect_type = typeof(expected)
		if(got_type != expect_type and got != null and expected != null):
			# If we have a mismatch between float and int (types 2 and 3) then
			# print out a warning but do not fail.
			if([2, 3].has(got_type) and [2, 3].has(expect_type)):
				if(gut):
					gut.p(str('Warn:  Float/Int comparison.  Got ', types[got_type], ' but expected ', types[expect_type]), 1)
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
	if(f.file_exists(file_path) and gut.is_file_empty(file_path)):
		_pass(disp)
	else:
		_fail(disp)

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func assert_file_not_empty(file_path):
	var disp = 'expected [' + file_path + '] to contain data'
	if(!gut.is_file_empty(file_path)):
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
	var fail_count = _summary.failed
	var get = 'get_' + property
	var set = 'set_' + property
	assert_true(obj.has_method(get), 'Should have get method:  ' + get)
	assert_true(obj.has_method(set), 'Should have set method:  ' + set)
	if(_summary.failed > fail_count):
		return
	assert_eq(obj.call(get), default, 'It should have the expected default value.')
	obj.call(set, set_to)
	assert_eq(obj.call(get), set_to, 'The set value should have been returned.')


#-------------------------------------------------------------------------------
# Signal assertion helper.  Do not call directly, use _can_make_signal_assertions
#-------------------------------------------------------------------------------
func _fail_if_does_not_have_signal(object, signal_name):
	var did_fail = false
	if(!object.has_user_signal(signal_name)):
		_fail(str('Object ', object, ' does not have the signal [', signal_name, ']'))
		did_fail = true
	return did_fail
#-------------------------------------------------------------------------------
# Signal assertion helper.  Do not call directly, use _can_make_signal_assertions
#-------------------------------------------------------------------------------
func _fail_if_not_watching(object):
	var did_fail = false
	if(!_signal_watcher.is_watching_object(object)):
		_fail(str('Cannot make signal assertions because the object ', object, \
		          ' is not being watched.  Call watch_signals(some_object) to be able to make assertions about signals.'))
		did_fail = true
	return did_fail

#-------------------------------------------------------------------------------
# Signal assertion helper.
#
# Verifies that the object and signal are valid for making signal assertions.
# This will fail with specific messages that indicate why they are not valid.
# This returns true/false to indicate if the object and signal are valid.
#-------------------------------------------------------------------------------
func _can_make_signal_assertions(object, signal_name):
	return !(_fail_if_not_watching(object) or _fail_if_does_not_have_signal(object, signal_name))

#-------------------------------------------------------------------------------
# Watch the signals for an object.  This must be called before you can make
# any assertions about the signals themselves.
#-------------------------------------------------------------------------------
func watch_signals(object):
	_signal_watcher.watch_signals(object)

#-------------------------------------------------------------------------------
# Asserts that a signal has been emitted at least once.
#
# This will fail with specific messages if the object is not being watched or
# the object does not have the specified signal
#-------------------------------------------------------------------------------
func assert_signal_emitted(object, signal_name, text=""):
	var disp = str('Expected object ', object, ' to emit signal [', signal_name, ']:  ', text)
	if(_can_make_signal_assertions(object, signal_name)):
		if(_signal_watcher.did_emit(object, signal_name)):
			_pass(disp)
		else:
			_fail(disp)

#-------------------------------------------------------------------------------
# Asserts that a signal has not been emitted.
#
# This will fail with specific messages if the object is not being watched or
# the object does not have the specified signal
#-------------------------------------------------------------------------------
func assert_signal_not_emitted(object, signal_name, text=""):
	var disp = str('Expected object ', object, ' to NOT emit signal [', signal_name, ']:  ', text)
	if(_can_make_signal_assertions(object, signal_name)):
		if(_signal_watcher.did_emit(object, signal_name)):
			_fail(disp)
		else:
			_pass(disp)

#-------------------------------------------------------------------------------
# Asserts that a signal was fired with the specified parameters.  The expected
# parameters should be passed in as an array.  An optional index can be passed
# when a signal has fired more than once.  The default is to retrieve the most
# recent emission of the signal.
#
# This will fail with specific messages if the object is not being watched or
# the object does not have the specified signal
#-------------------------------------------------------------------------------
func assert_signal_emitted_with_parameters(object, signal_name, parameters, index=-1):
	var disp = str('Expected object ', object, ' to emit signal [', signal_name, '] with parameters ', parameters, ', got ')
	if(_can_make_signal_assertions(object, signal_name)):
		if(_signal_watcher.did_emit(object, signal_name)):
			var parms_got = _signal_watcher.get_signal_parameters(object, signal_name, index)
			if(parameters == parms_got):
				_pass(str(disp, parms_got))
			else:
				_fail(str(disp, parms_got))
		else:
			_fail(str('Object ', object, ' did not emit signal [', signal_name, ']'))

#-------------------------------------------------------------------------------
# Assert that a signal has been emitted a specific number of times.
#
# This will fail with specific messages if the object is not being watched or
# the object does not have the specified signal
#-------------------------------------------------------------------------------
func assert_signal_emit_count(object, signal_name, times, text=""):

	if(_can_make_signal_assertions(object, signal_name)):
		var count = _signal_watcher.get_emit_count(object, signal_name)
		var disp = str('Expected the signal [', signal_name, '] emit count of [', count, '] to equal [', times, ']: ', text)
		if(count== times):
			_pass(disp)
		else:
			_fail(disp)

#-------------------------------------------------------------------------------
# Assert that the passed in object has the specfied signal
#-------------------------------------------------------------------------------
func assert_has_signal(object, signal_name, text=""):
	var disp = str('Expected object ', object, ' to have signal [', signal_name, ']:  ', text)
	if(object.has_user_signal(signal_name)):
		_pass(disp)
	else:
		_fail(disp)

#-------------------------------------------------------------------------------
# Returns the number of times a signal was emitted.  -1 returned if the object
# is not being watched.
#-------------------------------------------------------------------------------
func get_signal_emit_count(object, signal_name):
	return _signal_watcher.get_emit_count(object, signal_name)

#-------------------------------------------------------------------------------
# Get the parmaters of a fired signal.  If the signal was not fired null is
# returned.  You can specify an optional index (use get_signal_emit_count to
# determine the number of times it was emitted).  The default index is the
# latest time the signal was fired (size() -1 insetead of 0).  The parameters
# returned are in an array.
#-------------------------------------------------------------------------------
func get_signal_parameters(object, signal_name, index=-1):
	return _signal_watcher.get_signal_parameters(object, signal_name, index)

#-------------------------------------------------------------------------------
# Mark the current test as pending.
#-------------------------------------------------------------------------------
func pending(text=""):
	_summary.pending += 1
	if(gut):
		if(text == ""):
			gut.p("Pending")
		else:
			gut.p("Pending:  " + text)
		gut.end_yielded_test()

#-------------------------------------------------------------------------------
# Returns the number of times a signal was emitted.  -1 returned if the object
# is not being watched.
#-------------------------------------------------------------------------------

# I think this reads better than set_yield_time, but don't want to break anything
func yield_for(time, msg=''):
	return gut.set_yield_time(time, msg)

func end_test():
	gut.end_yielded_test()

func get_summary():
	return _summary

func get_fail_count():
	return _summary.failed

func get_pass_count():
	return _summary.passed

func get_pending_count():
	return _summary.pending
