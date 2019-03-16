################################################################################
#(G)odot (U)nit (T)est class
#
################################################################################
#The MIT License (MIT)
#=====================
#
#Copyright (c) 2019 Tom "Butch" Wesley
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

# constant for signal when calling yield_for
const YIELD = 'timeout'

# Need a reference to the instance that is running the tests.  This
# is set by the gut class when it runs the tests.  This gets you
# access to the asserts in the tests you write.
var gut = null
var passed = false
var failed = false
var _disable_strict_datatype_checks = false
# Holds all the text for a test's fail/pass.  This is used for testing purposes
# to see the text of a failed sub-test in test_test.gd
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

const EDITOR_PROPERTY = PROPERTY_USAGE_SCRIPT_VARIABLE | PROPERTY_USAGE_DEFAULT
const VARIABLE_PROPERTY = PROPERTY_USAGE_SCRIPT_VARIABLE

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

# Convenience copy of _utils.DOUBLE_STRATEGY
var DOUBLE_STRATEGY = null

var _utils = load('res://addons/gut/utils.gd').new()
var _lgr = _utils.get_logger()

func _init():
	_init_types_dictionary()
	DOUBLE_STRATEGY = _utils.DOUBLE_STRATEGY # yes, this is right

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
		gut._fail(text)

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
		gut._pass(text)

# ------------------------------------------------------------------------------
# Checks if the datatypes passed in match.  If they do not then this will cause
# a fail to occur.  If they match then TRUE is returned, FALSE if not.  This is
# used in all the assertions that compare values.
# ------------------------------------------------------------------------------
func _do_datatypes_match__fail_if_not(got, expected, text):
	var passed = true

	if(!_disable_strict_datatype_checks):
		var got_type = typeof(got)
		var expect_type = typeof(expected)
		if(got_type != expect_type and got != null and expected != null):
			# If we have a mismatch between float and int (types 2 and 3) then
			# print out a warning but do not fail.
			if([2, 3].has(got_type) and [2, 3].has(expect_type)):
				_lgr.warn(str('Warn:  Float/Int comparison.  Got ', types[got_type], ' but expected ', types[expect_type]))
			else:
				_fail('Cannot compare ' + types[got_type] + '[' + str(got) + '] to ' + types[expect_type] + '[' + str(expected) + '].  ' + text)
				passed = false

	return passed

# ------------------------------------------------------------------------------
# Create a string that lists all the methods that were called on an spied
# instance.
# ------------------------------------------------------------------------------
func _get_desc_of_calls_to_instance(inst):
	var BULLET = '  * '
	var calls = gut.get_spy().get_call_list_as_string(inst)
	# indent all the calls
	calls = BULLET + calls.replace("\n", "\n" + BULLET)
	# remove trailing newline and bullet
	calls = calls.substr(0, calls.length() - BULLET.length() - 1)
	return "Calls made on " + str(inst) + "\n" + calls

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
# Returns text that contains original text and a list of all the signals that
# were emitted for the passed in object.
# ------------------------------------------------------------------------------
func _get_fail_msg_including_emitted_signals(text, object):
	return str(text," (Signals emitted: ", _signal_watcher.get_signals_emitted(object), ")")

# #######################
# Virtual Methods
# #######################

# alias for prerun_setup
func before_all():
	pass

# alias for setup
func before_each():
	pass

# alias for postrun_teardown
func after_all():
	pass

# alias for teardown
func after_each():
	pass

# #######################
# Public
# #######################

func get_logger():
	return _lgr

func set_logger(logger):
	_lgr = logger


# #######################
# Asserts
# #######################

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
# Asserts that the expected value almost equals the value got.
# ------------------------------------------------------------------------------
func assert_almost_eq(got, expected, error_interval, text=''):
	var disp = "[" + str(got) + "] expected to equal [" + str(expected) + "] +/- [" + str(error_interval) + "]:  " + text
	if(_do_datatypes_match__fail_if_not(got, expected, text) and _do_datatypes_match__fail_if_not(got, error_interval, text)):
		if(got < (expected - error_interval) or got > (expected + error_interval)):
			_fail(disp)
		else:
			_pass(disp)

# ------------------------------------------------------------------------------
# Asserts that the expected value does not almost equal the value got.
# ------------------------------------------------------------------------------
func assert_almost_ne(got, not_expected, error_interval, text=''):
	var disp = "[" + str(got) + "] expected to not equal [" + str(not_expected) + "] +/- [" + str(error_interval) + "]:  " + text
	if(_do_datatypes_match__fail_if_not(got, not_expected, text) and _do_datatypes_match__fail_if_not(got, error_interval, text)):
		if(got < (not_expected - error_interval) or got > (not_expected + error_interval)):
			_pass(disp)
		else:
			_fail(disp)

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
# Asserts the specified file is not empty
# ------------------------------------------------------------------------------
func assert_file_not_empty(file_path):
	var disp = 'expected [' + file_path + '] to contain data'
	if(!gut.is_file_empty(file_path)):
		_pass(disp)
	else:
		_fail(disp)

# ------------------------------------------------------------------------------
# Asserts the object has the specified method
# ------------------------------------------------------------------------------
func assert_has_method(obj, method):
	assert_true(obj.has_method(method), 'Should have method: ' + method)

# Old deprecated method name
func assert_get_set_methods(obj, property, default, set_to):
	_lgr.deprecated('assert_get_set_methods', 'assert_accessors')
	assert_accessors(obj, property, default, set_to)

# ------------------------------------------------------------------------------
# Verifies the object has get and set methods for the property passed in.  The
# property isn't tied to anything, just a name to be appended to the end of
# get_ and set_.  Asserts the get_ and set_ methods exist, if not, it stops there.
# If they exist then it asserts get_ returns the expected default then calls
# set_ and asserts get_ has the value it was set to.
# ------------------------------------------------------------------------------
func assert_accessors(obj, property, default, set_to):
	var fail_count = _summary.failed
	var get = 'get_' + property
	var set = 'set_' + property
	assert_has_method(obj, get)
	assert_has_method(obj, set)
	# SHORT CIRCUIT
	if(_summary.failed > fail_count):
		return
	assert_eq(obj.call(get), default, 'It should have the expected default value.')
	obj.call(set, set_to)
	assert_eq(obj.call(get), set_to, 'The set value should have been returned.')


# ---------------------------------------------------------------------------
# Property search helper.  Used to retrieve Dictionary of specified property
# from passed object. Returns null if not found.
# If provided, property_usage constrains the type of property returned by
# passing either:
# EDITOR_PROPERTY for properties defined as: export(int) var some_value
# VARIABLE_PROPERTY for properties definded as: var another_value
# ---------------------------------------------------------------------------
func _find_object_property(obj, property_name, property_usage=null):
	var result = null
	var found = false
	var properties = obj.get_property_list()

	while !found and !properties.empty():
		var property = properties.pop_back()
		if property['name'] == property_name:
			if property_usage == null or property['usage'] == property_usage:
				result = property
				found = true
	return result

# ------------------------------------------------------------------------------
# Asserts a class exports a variable.
# ------------------------------------------------------------------------------
func assert_exports(obj, property_name, type):
	var disp = 'expected %s to have editor property [%s]' % [obj, property_name]
	var property = _find_object_property(obj, property_name, EDITOR_PROPERTY)
	if property != null:
		disp += ' of type [%s]. Got type [%s].' % [types[type], types[property['type']]]
		if property['type'] == type:
			_pass(disp)
		else:
			_fail(disp)
	else:
		_fail(disp)

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
	var disp = str('Expected object ', object, ' to have emitted signal [', signal_name, ']:  ', text)
	if(_can_make_signal_assertions(object, signal_name)):
		if(_signal_watcher.did_emit(object, signal_name)):
			_pass(disp)
		else:
			_fail(_get_fail_msg_including_emitted_signals(disp, object))

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
			var text = str('Object ', object, ' did not emit signal [', signal_name, ']')
			_fail(_get_fail_msg_including_emitted_signals(text, object))

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
			_fail(_get_fail_msg_including_emitted_signals(disp, object))

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
# Get the parameters for a method call to a doubled object.  By default it will
# return the most recent call.  You can optionally specify an index.
#
# Returns:
# * an array of parameter values if a call the method was found
# * null when a call to the method was not found or the index specified was
#   invalid.
# ------------------------------------------------------------------------------
func get_call_parameters(object, method_name, index=-1):
	var to_return = null
	if(_utils.is_double(object)):
		to_return = gut.get_spy().get_call_parameters(object, method_name, index)
	else:
		_lgr.error('You must pass a doulbed object to get_call_parameters.')

	return to_return

# ------------------------------------------------------------------------------
# Assert that object is an instance of a_class
# ------------------------------------------------------------------------------
func assert_extends(object, a_class, text=''):
	_lgr.deprecated('assert_extends', 'assert_is')
	assert_is(object, a_class, text)

# Alias for assert_extends
func assert_is(object, a_class, text=''):
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
# Assert that text contains given search string.
# The match_case flag determines case sensitivity.
# ------------------------------------------------------------------------------
func assert_string_contains(text, search, match_case=true):
	var empty_search = 'Expected text and search strings to be non-empty. You passed \'%s\' and \'%s\'.'
	var disp = 'Expected \'%s\' to contain \'%s\', match_case=%s' % [text, search, match_case]
	if(text == '' or search == ''):
		_fail(empty_search % [text, search])
	elif(match_case):
		if(text.find(search) == -1):
			_fail(disp)
		else:
			_pass(disp)
	else:
		if(text.to_lower().find(search.to_lower()) == -1):
			_fail(disp)
		else:
			_pass(disp)

# ------------------------------------------------------------------------------
# Assert that text starts with given search string.
# match_case flag determines case sensitivity.
# ------------------------------------------------------------------------------
func assert_string_starts_with(text, search, match_case=true):
	var empty_search = 'Expected text and search strings to be non-empty. You passed \'%s\' and \'%s\'.'
	var disp = 'Expected \'%s\' to start with \'%s\', match_case=%s' % [text, search, match_case]
	if(text == '' or search == ''):
		_fail(empty_search % [text, search])
	elif(match_case):
		if(text.find(search) == 0):
			_pass(disp)
		else:
			_fail(disp)
	else:
		if(text.to_lower().find(search.to_lower()) == 0):
			_pass(disp)
		else:
			_fail(disp)

# ------------------------------------------------------------------------------
# Assert that text ends with given search string.
# match_case flag determines case sensitivity.
# ------------------------------------------------------------------------------
func assert_string_ends_with(text, search, match_case=true):
	var empty_search = 'Expected text and search strings to be non-empty. You passed \'%s\' and \'%s\'.'
	var disp = 'Expected \'%s\' to end with \'%s\', match_case=%s' % [text, search, match_case]
	var required_index = len(text) - len(search)
	if(text == '' or search == ''):
		_fail(empty_search % [text, search])
	elif(match_case):
		if(text.find(search) == required_index):
			_pass(disp)
		else:
			_fail(disp)
	else:
		if(text.to_lower().find(search.to_lower()) == required_index):
			_pass(disp)
		else:
			_fail(disp)

# ------------------------------------------------------------------------------
# Assert that a method was called on an instance of a doubled class.  If
# parameters are supplied then the params passed in when called must match.
# TODO make 3rd paramter "param_or_text" and add fourth parameter of "text" and
#      then work some magic so this can have a "text" parameter without being
#      annoying.
# ------------------------------------------------------------------------------
func assert_called(inst, method_name, parameters=null):
	var disp = str('Expected [',method_name,'] to have been called on ',inst)

	if(!_utils.is_double(inst)):
		_fail('You must pass a doubled instance to assert_called.  Check the wiki for info on using double.')
	else:
		if(gut.get_spy().was_called(inst, method_name, parameters)):
			_pass(disp)
		else:
			if(parameters != null):
				disp += str(' with parameters ', parameters)
			_fail(str(disp, "\n", _get_desc_of_calls_to_instance(inst)))

# ------------------------------------------------------------------------------
# Assert that a method was not called on an instance of a doubled class.  If
# parameters are specified then this will only fail if it finds a call that was
# sent matching parameters.
# ------------------------------------------------------------------------------
func assert_not_called(inst, method_name, parameters=null):
	var disp = str('Expected [', method_name, '] to NOT have been called on ', inst)

	if(!_utils.is_double(inst)):
		_fail('You must pass a doubled instance to assert_not_called.  Check the wiki for info on using double.')
	else:
		if(gut.get_spy().was_called(inst, method_name, parameters)):
			if(parameters != null):
				disp += str(' with parameters ', parameters)
			_fail(str(disp, "\n", _get_desc_of_calls_to_instance(inst)))
		else:
			_pass(disp)

# ------------------------------------------------------------------------------
# Assert that a method on an instance of a doubled class was called a number
# of times.  If parameters are specified then only calls with matching
# parameter values will be counted.
# ------------------------------------------------------------------------------
func assert_call_count(inst, method_name, expected_count, parameters=null):
	var count = gut.get_spy().call_count(inst, method_name, parameters)

	var param_text = ''
	if(parameters):
		param_text = ' with parameters ' + str(parameters)
	var disp = 'Expected [%s] on %s to be called [%s] times%s.  It was called [%s] times.'
	disp = disp % [method_name, inst, expected_count, param_text, count]

	if(!_utils.is_double(inst)):
		_fail('You must pass a doubled instance to assert_call_count.  Check the wiki for info on using double.')
	else:
		if(count == expected_count):
			_pass(disp)
		else:
			_fail(str(disp, "\n", _get_desc_of_calls_to_instance(inst)))

# ------------------------------------------------------------------------------
# Asserts the passed in value is null
# ------------------------------------------------------------------------------
func assert_null(got, text=''):
	var disp = str('Expected [', got, '] to be NULL:  ', text)
	if(got == null):
		_pass(disp)
	else:
		_fail(disp)

# ------------------------------------------------------------------------------
# Asserts the passed in value is null
# ------------------------------------------------------------------------------
func assert_not_null(got, text=''):
	var disp = str('Expected [', got, '] to be anything but NULL:  ', text)
	if(got == null):
		_fail(disp)
	else:
		_pass(disp)

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
		gut._pending(text)

# ------------------------------------------------------------------------------
# Returns the number of times a signal was emitted.  -1 returned if the object
# is not being watched.
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Yield for the time sent in.  The optional message will be printed when
# Gut detects the yeild.  When the time expires the YIELD signal will be
# emitted.
# ------------------------------------------------------------------------------
func yield_for(time, msg=''):
	return gut.set_yield_time(time, msg)

# ------------------------------------------------------------------------------
# Yield to a signal or a maximum amount of time, whichever comes first.  When
# the conditions are met the YIELD signal will be emitted.
# ------------------------------------------------------------------------------
func yield_to(obj, signal_name, max_wait, msg=''):
	watch_signals(obj)
	gut.set_yield_signal_or_time(obj, signal_name, max_wait, msg)

	return gut

# ------------------------------------------------------------------------------
# Ends a test that had a yield in it.  You only need to use this if you do
# not make assertions after a yield.
# ------------------------------------------------------------------------------
func end_test():
	_lgr.deprecated('end_test is no longer necessary, you can remove it.')
	#gut.end_yielded_test()

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

func get_double_strategy():
	return gut.get_doubler().get_strategy()

func set_double_strategy(double_strategy):
	gut.get_doubler().set_strategy(double_strategy)

func pause_before_teardown():
	gut.pause_before_teardown()
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
	return to_return

# ------------------------------------------------------------------------------
# Double a script, inner class, or scene using a path or a loaded script/scene.
#
#
# ------------------------------------------------------------------------------
func double(thing, p2=null, p3=null):
	var strategy = p2
	var subpath = null

	if(typeof(p2) == TYPE_STRING):
		strategy = p3
		subpath = p2

	var path = null
	if(typeof(thing) == TYPE_OBJECT):
		path = thing.resource_path
	else:
		path = thing

	var extension = path.get_extension()
	var to_return = null

	if(extension == 'tscn'):
		to_return =  double_scene(path, strategy)
	elif(extension == 'gd'):
		if(subpath == null):
			to_return = double_script(path, strategy)
		else:
			to_return = double_inner(path, subpath, strategy)

	return to_return

# ------------------------------------------------------------------------------
# Specifically double a scene
# ------------------------------------------------------------------------------
func double_scene(path, strategy=null):
	var override_strat = _utils.nvl(strategy, gut.get_doubler().get_strategy())
	return gut.get_doubler().double_scene(path, override_strat)

# ------------------------------------------------------------------------------
# Specifically double a script
# ------------------------------------------------------------------------------
func double_script(path, strategy=null):
	var override_strat = _utils.nvl(strategy, gut.get_doubler().get_strategy())
	return gut.get_doubler().double(path, override_strat)

# ------------------------------------------------------------------------------
# Specifically double an Inner class in a a script
# ------------------------------------------------------------------------------
func double_inner(path, subpath, strategy=null):
	var override_strat = _utils.nvl(strategy, gut.get_doubler().get_strategy())
	return gut.get_doubler().double_inner(path, subpath, override_strat)

# ------------------------------------------------------------------------------
# Stub something.
#
# Parameters
# 1: the thing to stub, a file path or a instance or a class
# 2: either an inner class subpath or the method name
# 3: the method name if an inner class subpath was specified
# NOTE:  right now we cannot stub inner classes at the path level so this should
#        only be called with two parameters.  I did the work though so I'm going
#        to leave it but not update the wiki.
# ------------------------------------------------------------------------------
func stub(thing, p2, p3=null):
	var method_name = p2
	var subpath = null
	if(p3 != null):
		subpath = p2
		method_name = p3
	var sp = _utils.StubParams.new(thing, method_name, subpath)
	gut.get_stubber().add_stub(sp)
	return sp

# ------------------------------------------------------------------------------
# convenience wrapper.
# ------------------------------------------------------------------------------
func simulate(obj, times, delta):
	gut.simulate(obj, times, delta)

# ------------------------------------------------------------------------------
# Replace the node at base_node.get_node(path) with with_this.  All refrences
# to the node via $ and get_node(...) will now return with_this.  with_this will
# get all the groups that the node that was replaced had.
#
# The node that was replaced is queued to be freed.
# ------------------------------------------------------------------------------
func replace_node(base_node, path_or_node, with_this):
	var path = path_or_node

	if(typeof(path_or_node) != TYPE_STRING):
		# This will cause an engine error if it fails.  It always returns a
		# NodePath, even if it fails.  Checking the name count is the only way
		# I found to check if it found something or not (after it worked I
		# didn't look any farther).
		path = base_node.get_path_to(path_or_node)
		if(path.get_name_count() == 0):
			_lgr.error('You passed an objet that base_node does not have.  Cannot replace node.')
			return

	if(!base_node.has_node(path)):
		_lgr.error(str('Could not find node at path [', path, ']'))
		return

	var to_replace = base_node.get_node(path)
	var parent = to_replace.get_parent()
	var replace_name = to_replace.get_name()

	parent.remove_child(to_replace)
	parent.add_child(with_this)
	with_this.set_name(replace_name)
	with_this.set_owner(parent)

	var groups = to_replace.get_groups()
	for i in range(groups.size()):
		with_this.add_to_group(groups[i])

	to_replace.queue_free()
