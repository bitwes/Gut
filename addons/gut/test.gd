################################################################################
#(G)odot (U)nit (T)est class
#
################################################################################
#The MIT License (MIT)
#=====================
#
#Copyright (c) 2017 Tom "Butch" Wesley
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
# Version - see gut.gd
################################################################################
# Class that all test scripts must extend.
#
# This provides all the asserts and other testing features.  Test scripts are
# run by the Gut class in gut.gd
################################################################################
extends Node

# constant for signal when calling yeild_for
const YIELD = 'timeout'

# Need a reference to the instance that is running the tests.  This
# is set by the gut class when it runs the tests.  This gets you
# access to the asserts in the tests you write.
var gut = null
var passed = false
var failed = false
var _disable_strict_datatype_checks = false
var _fail_pass_text = []

# Hash containing all the built in types in Godot.  This provides an English
# name for the types that corosponds with the type constants defined in the
# engine.  This is used for priting out messages when comparing types fails.
var types = {}

func _init_types_dictionary():
	types[TYPE_NIL] = 'TYPE_NIL'
	types[TYPE_BOOL] = 'Bool'
	types[TYPE_INT] = 'Int'
	types[TYPE_REAL] = 'Float/Real'
	types[TYPE_STRING] = 'String'
	types[TYPE_VECTOR2] = 'Vector2'
	types[TYPE_RECT2] = 'Rect2'
	types[TYPE_VECTOR3] = 'Vector3'
	#types[8] = 'Matrix32'
	types[TYPE_PLANE] = 'Plane'
	types[TYPE_QUAT] = 'QUAT'
	types[TYPE_AABB] = 'AABB'
	#types[12] = 'Matrix3'
	types[TYPE_TRANSFORM] = 'Transform'
	types[TYPE_COLOR] = 'Color'
	#types[15] = 'Image'
	types[TYPE_NODE_PATH] = 'Node Path'
	types[TYPE_RID] = 'RID'
	types[TYPE_OBJECT] = 'TYPE_OBJECT'
	#types[19] = 'TYPE_INPUT_EVENT'
	types[TYPE_DICTIONARY] = 'Dictionary'
	types[TYPE_ARRAY] = 'Array'
	types[TYPE_RAW_ARRAY] = 'TYPE_RAW_ARRAY'
	types[TYPE_INT_ARRAY] = 'TYPE_INT_ARRAY'
	types[TYPE_REAL_ARRAY] = 'TYPE_REAL_ARRAY'
	types[TYPE_STRING_ARRAY] = 'TYPE_STRING_ARRAY'
	types[TYPE_VECTOR2_ARRAY] = 'TYPE_VECTOR2_ARRAY'
	types[TYPE_VECTOR3_ARRAY] = 'TYPE_VECTOR3_ARRAY'
	types[TYPE_COLOR_ARRAY] = 'TYPE_COLOR_ARRAY'
	types[TYPE_MAX] = 'TYPE_MAX'

# Summary counts for the test.
var _summary = {
	asserts = 0,
	passed = 0,
	failed = 0,
	tests = 0,
	pending = 0
}

# This is used to watch signals so we can make assertions about them.
var _signal_watcher = load('res://addons/gut/signal_watcher.gd').new()

func _init():
	_init_types_dictionary()

# #######################
# Virtual Methods
# #######################
# Overridable method that runs before each test.
func setup():
	pass

# Overridable method that runs after each test
func teardown():
	pass

# Overridable method that runs before any tests are run
func prerun_setup():
	pass

# Overridable method that runs after all tests are run
func postrun_teardown():
	pass

# ------------------------------------------------------------------------------
# Fail an assertion.  Causes test and script to fail as well.
# ------------------------------------------------------------------------------
func _fail(text):
	_summary.asserts += 1
	_summary.failed += 1
	var msg = 'FAILED:  ' + text
	_fail_pass_text.append(msg)
	if(gut):
		gut.p(msg, gut.LOG_LEVEL_FAIL_ONLY)
		gut._fail()
		gut.end_yielded_test()

# ------------------------------------------------------------------------------
# Pass an assertion.
# ------------------------------------------------------------------------------
func _pass(text):
	_summary.asserts += 1
	_summary.passed += 1
	var msg = "PASSED:  " + text
	_fail_pass_text.append(msg)
	if(gut):
		gut.p(msg, gut.LOG_LEVEL_ALL_ASSERTS)
		gut._pass()
		gut.end_yielded_test()

# Checks if the datatypes passed in match.  If they do not then this will cause
# a fail to occur.  If they match then TRUE is returned, FALSE if not.  This is
# used in all the assertions that compare values.
func _do_datatypes_match__fail_if_not(got, expected, text):
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

# ------------------------------------------------------------------------------
# Asserts that the expected value equals the value got.
# ------------------------------------------------------------------------------
func assert_eq(got, expected, text=""):
	var disp = "[" + str(got) + "] expected to equal [" + str(expected) + "]:  " + text
	if(_do_datatypes_match__fail_if_not(got, expected, text)):
		if(expected != got):
			_fail(disp)
		else:
			_pass(disp)

# ------------------------------------------------------------------------------
# Asserts that the value got does not equal the "not expected" value.
# ------------------------------------------------------------------------------
func assert_ne(got, not_expected, text=""):
	var disp = "[" + str(got) + "] expected to be anything except [" + str(not_expected) + "]:  " + text
	if(_do_datatypes_match__fail_if_not(got, not_expected, text)):
		if(got == not_expected):
			_fail(disp)
		else:
			_pass(disp)
# ------------------------------------------------------------------------------
# Asserts got is greater than expected
# ------------------------------------------------------------------------------
func assert_gt(got, expected, text=""):
	var disp = "[" + str(got) + "] expected to be > than [" + str(expected) + "]:  " + text
	if(_do_datatypes_match__fail_if_not(got, expected, text)):
		if(got > expected):
			_pass(disp)
		else:
			_fail(disp)

# ------------------------------------------------------------------------------
# Asserts got is less than expected
# ------------------------------------------------------------------------------
func assert_lt(got, expected, text=""):
	var disp = "[" + str(got) + "] expected to be < than [" + str(expected) + "]:  " + text
	if(_do_datatypes_match__fail_if_not(got, expected, text)):
		if(got < expected):
			_pass(disp)
		else:
			_fail(disp)

# ------------------------------------------------------------------------------
# asserts that got is true
# ------------------------------------------------------------------------------
func assert_true(got, text=""):
	if(!got):
		_fail(text)
	else:
		_pass(text)

# ------------------------------------------------------------------------------
# Asserts that got is false
# ------------------------------------------------------------------------------
func assert_false(got, text=""):
	if(got):
		_fail(text)
	else:
		_pass(text)

# ------------------------------------------------------------------------------
# Asserts value is between (inclusive) the two expected values.
# ------------------------------------------------------------------------------
func assert_between(got, expect_low, expect_high, text=""):
	var disp = "[" + str(got) + "] expected to be between [" + str(expect_low) + "] and [" + str(expect_high) + "]:  " + text

	if(_do_datatypes_match__fail_if_not(got, expect_low, text) and _do_datatypes_match__fail_if_not(got, expect_high, text)):
		if(expect_low > expect_high):
			disp = "INVALID range.  [" + str(expect_low) + "] is not less than [" + str(expect_high) + "]"
			_fail(disp)
		else:
			if(got < expect_low or got > expect_high):
				_fail(disp)
			else:
				_pass(disp)

# ------------------------------------------------------------------------------
# Uses the 'has' method of the object passed in to determine if it contains
# the passed in element.
# ------------------------------------------------------------------------------
func assert_has(obj, element, text=""):
	var disp = str('Expected [', obj, '] to contain value:  [', element, ']:  ', text)
	if(obj.has(element)):
		_pass(disp)
	else:
		_fail(disp)

# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
func assert_does_not_have(obj, element, text=""):
	var disp = str('Expected [', obj, '] to NOT contain value:  [', element, ']:  ', text)
	if(obj.has(element)):
		_fail(disp)
	else:
		_pass(disp)

# ------------------------------------------------------------------------------
# Asserts that a file exists
# ------------------------------------------------------------------------------
func assert_file_exists(file_path):
	var disp = 'expected [' + file_path + '] to exist.'
	var f = File.new()
	if(f.file_exists(file_path)):
		_pass(disp)
	else:
		_fail(disp)

# ------------------------------------------------------------------------------
# Asserts that a file should not exist
# ------------------------------------------------------------------------------
func assert_file_does_not_exist(file_path):
	var disp = 'expected [' + file_path + '] to NOT exist'
	var f = File.new()
	if(!f.file_exists(file_path)):
		_pass(disp)
	else:
		_fail(disp)

# ------------------------------------------------------------------------------
# Asserts the specified file is empty
# ------------------------------------------------------------------------------
func assert_file_empty(file_path):
	var disp = 'expected [' + file_path + '] to be empty'
	var f = File.new()
	if(f.file_exists(file_path) and gut.is_file_empty(file_path)):
		_pass(disp)
	else:
		_fail(disp)

# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
func assert_file_not_empty(file_path):
	var disp = 'expected [' + file_path + '] to contain data'
	if(!gut.is_file_empty(file_path)):
		_pass(disp)
	else:
		_fail(disp)

# ------------------------------------------------------------------------------
# Verifies the object has get and set methods for the property passed in.  The
# property isn't tied to anything, just a name to be appended to the end of
# get_ and set_.  Asserts the get_ and set_ methods exist, if not, it stops there.
# If they exist then it asserts get_ returns the expected default then calls
# set_ and asserts get_ has the value it was set to.
# ------------------------------------------------------------------------------
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


# ------------------------------------------------------------------------------
# Signal assertion helper.  Do not call directly, use _can_make_signal_assertions
# ------------------------------------------------------------------------------
func _fail_if_does_not_have_signal(object, signal_name):
	var did_fail = false
	if(!_signal_watcher.does_object_have_signal(object, signal_name)):
		_fail(str('Object ', object, ' does not have the signal [', signal_name, ']'))
		did_fail = true
	return did_fail
# ------------------------------------------------------------------------------
# Signal assertion helper.  Do not call directly, use _can_make_signal_assertions
# ------------------------------------------------------------------------------
func _fail_if_not_watching(object):
	var did_fail = false
	if(!_signal_watcher.is_watching_object(object)):
		_fail(str('Cannot make signal assertions because the object ', object, \
		          ' is not being watched.  Call watch_signals(some_object) to be able to make assertions about signals.'))
		did_fail = true
	return did_fail

# ------------------------------------------------------------------------------
# Signal assertion helper.
#
# Verifies that the object and signal are valid for making signal assertions.
# This will fail with specific messages that indicate why they are not valid.
# This returns true/false to indicate if the object and signal are valid.
# ------------------------------------------------------------------------------
func _can_make_signal_assertions(object, signal_name):
	return !(_fail_if_not_watching(object) or _fail_if_does_not_have_signal(object, signal_name))

# ------------------------------------------------------------------------------
# Watch the signals for an object.  This must be called before you can make
# any assertions about the signals themselves.
# ------------------------------------------------------------------------------
func watch_signals(object):
	_signal_watcher.watch_signals(object)

# ------------------------------------------------------------------------------
# Asserts that a signal has been emitted at least once.
#
# This will fail with specific messages if the object is not being watched or
# the object does not have the specified signal
# ------------------------------------------------------------------------------
func assert_signal_emitted(object, signal_name, text=""):
	var disp = str('Expected object ', object, ' to emit signal [', signal_name, ']:  ', text)
	if(_can_make_signal_assertions(object, signal_name)):
		if(_signal_watcher.did_emit(object, signal_name)):
			_pass(disp)
		else:
			_fail(disp)

# ------------------------------------------------------------------------------
# Asserts that a signal has not been emitted.
#
# This will fail with specific messages if the object is not being watched or
# the object does not have the specified signal
# ------------------------------------------------------------------------------
func assert_signal_not_emitted(object, signal_name, text=""):
	var disp = str('Expected object ', object, ' to NOT emit signal [', signal_name, ']:  ', text)
	if(_can_make_signal_assertions(object, signal_name)):
		if(_signal_watcher.did_emit(object, signal_name)):
			_fail(disp)
		else:
			_pass(disp)

# ------------------------------------------------------------------------------
# Asserts that a signal was fired with the specified parameters.  The expected
# parameters should be passed in as an array.  An optional index can be passed
# when a signal has fired more than once.  The default is to retrieve the most
# recent emission of the signal.
#
# This will fail with specific messages if the object is not being watched or
# the object does not have the specified signal
# ------------------------------------------------------------------------------
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

# ------------------------------------------------------------------------------
# Assert that a signal has been emitted a specific number of times.
#
# This will fail with specific messages if the object is not being watched or
# the object does not have the specified signal
# ------------------------------------------------------------------------------
func assert_signal_emit_count(object, signal_name, times, text=""):

	if(_can_make_signal_assertions(object, signal_name)):
		var count = _signal_watcher.get_emit_count(object, signal_name)
		var disp = str('Expected the signal [', signal_name, '] emit count of [', count, '] to equal [', times, ']: ', text)
		if(count== times):
			_pass(disp)
		else:
			_fail(disp)

# ------------------------------------------------------------------------------
# Assert that the passed in object has the specfied signal
# ------------------------------------------------------------------------------
func assert_has_signal(object, signal_name, text=""):
	var disp = str('Expected object ', object, ' to have signal [', signal_name, ']:  ', text)
	if(_signal_watcher.does_object_have_signal(object, signal_name)):
		_pass(disp)
	else:
		_fail(disp)

# ------------------------------------------------------------------------------
# Returns the number of times a signal was emitted.  -1 returned if the object
# is not being watched.
# ------------------------------------------------------------------------------
func get_signal_emit_count(object, signal_name):
	return _signal_watcher.get_emit_count(object, signal_name)

# ------------------------------------------------------------------------------
# Get the parmaters of a fired signal.  If the signal was not fired null is
# returned.  You can specify an optional index (use get_signal_emit_count to
# determine the number of times it was emitted).  The default index is the
# latest time the signal was fired (size() -1 insetead of 0).  The parameters
# returned are in an array.
# ------------------------------------------------------------------------------
func get_signal_parameters(object, signal_name, index=-1):
	return _signal_watcher.get_signal_parameters(object, signal_name, index)

# ------------------------------------------------------------------------------
# Assert that object is an instance of a_class
# ------------------------------------------------------------------------------
func assert_extends(object, a_class, text=''):
	var disp = str('Expected [', object, '] to be type of [', a_class, ']: ', text)
	var NATIVE_CLASS = 'GDScriptNativeClass'
	var GDSCRIPT_CLASS = 'GDScript'
	var bad_param_2 = 'Parameter 2 must be a Class (like Node2D or Label).  You passed '

	if(typeof(object) != TYPE_OBJECT):
		_fail(str('Parameter 1 must be an instance of an object.  You passed:  ', types[typeof(object)]))
	elif(typeof(a_class) != TYPE_OBJECT):
		_fail(str(bad_param_2, types[typeof(a_class)]))
	else:
		disp = str('Expected [', object.get_class(), '] to extend [', a_class.get_class(), ']: ', text)
		if(a_class.get_class() != NATIVE_CLASS and a_class.get_class() != GDSCRIPT_CLASS):
			_fail(str(bad_param_2, a_class.get_class(), '  ', types[typeof(a_class)]))
		else:
			if(object is a_class):
				_pass(disp)
			else:
				_fail(disp)

# ------------------------------------------------------------------------------
# Mark the current test as pending.
# ------------------------------------------------------------------------------
func pending(text=""):
	_summary.pending += 1
	if(gut):
		if(text == ""):
			gut.p("Pending")
		else:
			gut.p("Pending:  " + text)
		gut.end_yielded_test()

# ------------------------------------------------------------------------------
# Returns the number of times a signal was emitted.  -1 returned if the object
# is not being watched.
# ------------------------------------------------------------------------------

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

func get_assert_count():
	return _summary.asserts

func clear_signal_watcher():
	_signal_watcher.clear()

# ------------------------------------------------------------------------------
# Convert the _summary dictionary into text
# ------------------------------------------------------------------------------
func get_summary_text():
	var to_return = get_script().get_path() + "\n"
	to_return += str('  ', _summary.passed, ' of ', _summary.asserts, ' passed.')
	if(_summary.pending > 0):
		to_return += str("\n  ", _summary.pending, ' pending')
	if(_summary.failed > 0):
		to_return += str("\n  ", _summary.failed, ' failed.')
	# to_return += str('  tests:     ', _summary.tests, "\n")
	# to_return += str('  asserts:   ', _summary.asserts, "\n")
	# to_return += str('  passed:    ', _summary.passed, "\n")
	# to_return += str('  pending:   ', _summary.pending, "\n")
	# to_return += str('  failed:    ', _summary.failed)
	return to_return
