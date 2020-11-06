# ------------------------------------------------------------------------------
# Tests test.gd.  test.gd contains all the asserts and is the class that all
# test scripts inherit from.
# ------------------------------------------------------------------------------
extends "res://addons/gut/test.gd"

class BaseTestClass:
	extends "res://test/gut_test.gd"
	# !! Use this for debugging to see the results of all the subtests that
	# are run using assert_fail_pass, assert_fail and assert_pass that are
	# built into this class
	var _print_all_subtests = true

	# GlobalReset(gr) variables to be used by tests.
	# The values of these are reset in the setup or
	# teardown methods.
	var gr = {
		test = null,
		signal_object = null,
		test_with_gut = null
	}

	func print_fail_pass_text(t):
		for i in range(t._fail_pass_text.size()):
			gut.p('sub-test:  ' + t._fail_pass_text[i], gut.LOG_LEVEL_FAIL_ONLY)

	func assert_fail_pass(t, fail_count, pass_count, msg=''):
		var self_fail_count = get_fail_count()
		assert_eq(t.get_fail_count(), fail_count, 'Bad FAIL COUNT:  ' + msg)
		assert_eq(t.get_pass_count(), pass_count, 'Bad PASS COUNT:  ' + msg)
		if(get_fail_count() != self_fail_count or _print_all_subtests):
			print_fail_pass_text(t)

	# convenience method to assert the number of failures on the gr.test_gut object.
	func assert_fail(t, count=1, msg=''):
		var self_fail_count = get_fail_count()
		assert_eq(t.get_fail_count(), count, 'Expected FAIL COUNT:  ' + msg)
		if(t.get_pass_count() > 0 and count != t.get_assert_count()):
			assert_eq(t.get_pass_count(), 0, 'When checking for failures there should be no passing')
		if(get_fail_count() != self_fail_count or _print_all_subtests):
			print_fail_pass_text(t)

	# convenience method to assert the number of passes on the gr.test_gut object.
	func assert_pass(t, count=1, msg=''):
		var self_fail_count = get_fail_count()
		assert_eq(t.get_pass_count(), count, 'Expected PASS COUNT:  ' + msg)
		if(t.get_fail_count() != 0 and count != t.get_assert_count()):
			assert_eq(t.get_fail_count(), 0, 'When checking for passes there should be no failures.')
		if(get_fail_count() != self_fail_count or _print_all_subtests):
			print_fail_pass_text(t)

	func assert_fail_msg_contains(t, text):
		if(t.get_fail_count() != 1):
			assert_fail(t, 1, 'assert_fail_msg_contains requires single failing assert.')
		elif(t.get_pass_count() != 0):
			assert_pass(t, 0, 'assert_fail_msg_contains requires no passing asserts.')
		else:
			assert_string_contains(t._fail_pass_text[0], text)


	# #############
	# Seutp/Teardown
	# #############
	func before_each():
		gr.test = Test.new()
		gr.test_with_gut = Test.new()
		var g = autofree(Gut.new())
		g._should_print_versions = false
		gr.test_with_gut.gut = g
		add_child(gr.test_with_gut.gut)

	func after_each():
		gr.test_with_gut.gut.get_doubler().clear_output_directory()
		gr.test_with_gut.gut.get_spy().clear()

		gr.test.free()
		gr.test = null
		gr.test_with_gut.gut.free()
		gr.test_with_gut.free()

class TestMiscTests:
	extends BaseTestClass

	func test_script_object_added_to_tree():
		gr.test.assert_ne(get_tree(), null, "The tree should not be null if we are added to it")
		assert_pass(gr.test)

	func test_get_set_logger():
		assert_ne(gr.test.get_logger(), null)
		var dlog = double(Logger).new()
		gr.test.set_logger(dlog)
		assert_eq(gr.test.get_logger(), dlog)

	func test_not_freeing_children_generates_warning():
		pass
		# I cannot think of a way to test this without some giant amount of
		# testing legwork.


class TestAssertEq:
	extends BaseTestClass

	func test_passes_when_integer_equal():
		gr.test.assert_eq(1, 1)
		assert_pass(gr.test)

	func test_fails_when_number_not_equal():
		gr.test.assert_eq(1, 2)
		assert_fail(gr.test, 1, "Should fail.  1 != 2")

	func test_passes_when_float_eq():
		gr.test.assert_eq(1.0, 1.0)
		assert_pass(gr.test)

	func test_fails_when_float_eq_fail():
		gr.test.assert_eq(.19, 1.9)
		assert_fail(gr.test)

	var _float_vals = [['0.92', 0.92], ['1', 1.0], ['1.5', 1.5], ['1.92', 1.92], ['1.9', 1.9]]
	func test_passes_when_cast_char_to_float(vals=use_parameters(_float_vals)):
		var sval = vals[0]
		var fval = vals[1]

		assert_eq(float(sval), fval, 'float(string)')
		assert_eq(sval.to_float(), fval, '.to_float()')

	func test_fails_when_comparing_float_cast_as_int():
		# int cast will make it 0
		gr.test.assert_eq(int(0.5), 0.5)
		assert_fail(gr.test)

	func test_passes_when_cast_int_expression_to_float():
		var i = 2
		gr.test.assert_eq(5 / float(i), 2.5)
		assert_pass(gr.test)

	func test_fails_when_string_not_equal():
		gr.test.assert_eq("one", "two", "Should Fail")
		assert_fail(gr.test)

	func test_passes_when_string_equal():
		gr.test.assert_eq("one", "one", "Should Pass")
		assert_pass(gr.test)

	func test_warns_when_comparing_float_and_int():
		gr.test.assert_eq(1.0, 1, 'Should pass and warn')
		assert_warn(gr.test)

	var array_vals = [
		[[1, 2, 3], ['1', '2', '3'], false],
		[[4, 5, 6], [4, 5, 6], true],
		[[10, 20.0, 30], [10.0, 20, 30.0], false],
		[[1, 2], [1, 2, 3, 4, 5], false],
		[[1, 2, 3, 4, 5], [1, 2], false],
		[[{'a':1}], [{'a':1}], false],
		[[[1, 2], [3, 4]], [[5, 6], [7, 8]], false],
		[
			[[1, [2, 3]], [4, [5, 6]]],
			[[1, [2, 'a']], [4, ['b', 6]]],
			false
		]
	]
	func test_with_array(p = use_parameters(array_vals)):
		gr.test.assert_eq(p[0], p[1])
		if(p[2]):
			assert_pass(gr.test)
		else:
			assert_fail(gr.test)

	func test_with_dictionary_references():
		var d = {}
		var d_pointer = d
		gr.test.assert_eq(d, d_pointer)
		assert_pass(gr.test)
		assert_string_contains(gr.test._fail_pass_text[0], _compare.DICTIONARY_DISCLAIMER)

	func test_dictionary_not_compared_by_value():
		var d  = {'a':1}
		var d2 = {'a':1}
		gr.test.assert_eq(d, d2)
		assert_fail(gr.test)
		assert_string_contains(gr.test._fail_pass_text[0], _compare.DICTIONARY_DISCLAIMER)


class TestAssertNe:
	extends BaseTestClass

	func test_passes_with_integers_not_equal():
		gr.test.assert_ne(1, 2)
		assert_pass(gr.test)

	func test_fails_with_integers_equal():
		gr.test.assert_ne(1, 1, "Should fail")
		assert_fail(gr.test, 1, '1 = 1')

	func test_passes_with_floats_not_equal():
		gr.test.assert_ne(0.9, .009)
		assert_pass(gr.test)

	func test_passes_with_strings_not_equal():
		gr.test.assert_ne("one", "two", "Should Pass")
		assert_pass(gr.test)

	func test_fails_with_strings_equal():
		gr.test.assert_ne("one", "one", "Should Fail")
		assert_fail(gr.test)

	var array_vals = [
		[[1, 2, 3], ['1', '2', '3'], true],
		[[1, 2, 3], [1, 2, 3], false],
		[[1, 2.0, 3], [1.0, 2, 3.0], true]]
	func test_with_array(p = use_parameters(array_vals)):
		gr.test.assert_ne(p[0], p[1])
		if(p[2]):
			assert_pass(gr.test)
		else:
			assert_fail(gr.test)

	func test_with_dictionary_references():
		var d = {}
		var d_pointer = d
		gr.test.assert_ne(d, d_pointer)
		assert_fail(gr.test)
		assert_string_contains(gr.test._fail_pass_text[0], _compare.DICTIONARY_DISCLAIMER)

	func test_dictionary_not_compared_by_value():
		var d  = {'a':1}
		var d2 = {'a':1}
		gr.test.assert_ne(d, d2)
		assert_pass(gr.test)
		assert_string_contains(gr.test._fail_pass_text[0], _compare.DICTIONARY_DISCLAIMER)

class TestAssertAlmostEq:
	extends BaseTestClass

	func test_passes_with_integers_equal():
		gr.test.assert_almost_eq(2, 2, 0, "Should pass, 2 == 2 +/- 0")
		assert_pass(gr.test)

	func test_passes_with_integers_almost_within_range():
		gr.test.assert_almost_eq(1, 2, 1, "Should pass, 1 == 2 +/- 1")
		gr.test.assert_almost_eq(3, 2, 1, "Should pass, 3 == 2 +/- 1")
		assert_pass(gr.test, 2)

	func test_fails_with_integers_outside_range():
		gr.test.assert_almost_eq(0, 2, 1, "Should fail, 0 != 2 +/- 1")
		gr.test.assert_almost_eq(4, 2, 1, "Should fail, 4 != 2 +/- 1")
		assert_fail(gr.test, 2)

	func test_passes_with_floats_within_range():
		gr.test.assert_almost_eq(1.000, 1.000, 0.001, "Should pass, 1.000 == 1.000 +/- 0.001")
		gr.test.assert_almost_eq(1.001, 1.000, 0.001, "Should pass, 1.001 == 1.000 +/- 0.001")
		gr.test.assert_almost_eq(.999, 1.000, 0.001, "Should pass, .999 == 1.000 +/- 0.001")
		assert_pass(gr.test, 3)

	func test_fails_with_floats_outside_range():
		gr.test.assert_almost_eq(2.002, 2.000, 0.001, "Should fail, 2.002 == 2.000 +/- 0.001")
		gr.test.assert_almost_eq(1.998, 2.000, 0.001, "Should fail, 1.998 == 2.000 +/- 0.001")
		assert_fail(gr.test, 2)

	func test_passes_with_integers_within_float_range():
		gr.test.assert_almost_eq(2, 1.9, .5, 'Should pass, 1.5 < 2 < 2.4')
		assert_pass(gr.test)

	func test_passes_with_float_within_integer_range():
		gr.test.assert_almost_eq(2.5, 2, 1, 'Should pass, 1 < 2.5 < 3')
		assert_pass(gr.test)

	func test_passes_with_vector2s_eq():
		gr.test.assert_almost_eq(Vector2(1.0, 1.0), Vector2(1.0, 1.0), Vector2(0.0, 0.0), "Should pass, Vector2(1.0, 1.0) == Vector2(1.0, 1.0) +/- Vector2(0.0, 0.0)")
		assert_pass(gr.test)

	func test_fails_with_vector2s_ne():
		gr.test.assert_almost_eq(Vector2(1.0, 1.0), Vector2(2.0, 2.0), Vector2(0.0, 0.0), "Should fail, Vector2(1.0, 1.0) == Vector2(2.0, 2.0) +/- Vector2(0.0, 0.0)")
		assert_fail(gr.test)

	func test_passes_with_vector2s_almost_eq():
		gr.test.assert_almost_eq(Vector2(1.0, 1.0), Vector2(2.0, 2.0), Vector2(1.0, 1.0), "Should pass, Vector2(1.0, 1.0) == Vector2(2.0, 2.0) +/- Vector2(1.0, 1.0)")
		assert_pass(gr.test)

class TestAssertAlmostNe:
	extends BaseTestClass

	func test_pass_with_integers_not_equal():
		gr.test.assert_almost_ne(1, 2, 0, "Should pass, 1 != 2 +/- 0")
		assert_pass(gr.test)

	func test_fails_with_integers_equal():
		gr.test.assert_almost_ne(2, 2, 0, "Should fail, 2 == 2 +/- 0")
		assert_fail(gr.test)

	func test_passes_with_integers_outside_range():
		gr.test.assert_almost_ne(1, 3, 1, "Should pass, 1 != 3 +/- 1")
		assert_pass(gr.test)

	func test_fails_with_integers_within_range():
		gr.test.assert_almost_ne(2, 3, 1, "Should fail, 2 == 3 +/- 1")
		assert_fail(gr.test)

	func test_passes_with_floats_outside_range():
		gr.test.assert_almost_ne(1.000, 2.000, 0.001, "Should pass, 1.000 != 2.000 +/- 0.001")
		assert_pass(gr.test)

	func test_fails_with_floats_eq():
		gr.test.assert_almost_ne(1.000, 1.000, 0.001, "Should fail, 1.000 == 1.000 +/- 0.001")
		assert_fail(gr.test)

	func test_fails_with_floats_within_range():
		gr.test.assert_almost_ne(1.000, 2.000, 1.000, "Should fail, 1.000 == 2.000 +/- 1.000")
		assert_fail(gr.test)

	func test_passes_with_vector2s_outside_range():
		gr.test.assert_almost_ne(Vector2(1.0, 1.0), Vector2(2.0, 2.0), Vector2(0.0, 0.0), "Should pass, Vector2(1.0, 1.0) != Vector2(2.0, 2.0) +/- Vector2(0.0, 0.0)")
		assert_pass(gr.test)

	func test_fails_with_vector2s_eq():
		gr.test.assert_almost_ne(Vector2(1.0, 1.0), Vector2(1.0, 1.0), Vector2(0.0, 0.0), "Should fail, Vector2(1.0, 1.0) == Vector2(1.0, 1.0) +/- Vector2(0.0, 0.0)")
		assert_fail(gr.test)

	func test_passes_with_vector2s_almost_outside_range():
		gr.test.assert_almost_ne(Vector2(1.0, 1.0), Vector2(2.0, 2.0), Vector2(0.9, 0.9), "Should pass, Vector2(1.0, 1.0) == Vector2(2.0, 2.0) +/- Vector2(0.9, 0.9)")
		assert_pass(gr.test)

class TestAssertGt:
	extends BaseTestClass

	func test_passes_with_greater_integer():
		gr.test.assert_gt(2, 1, "Should Pass")
		assert_pass(gr.test, 1, '2 > 1')

	func test_fails_with_less_than_integer():
		gr.test.assert_gt(1, 2, "Should fail")
		assert_fail(gr.test, 1, '1 < 2')

	func test_passes_with_greater_string():
		gr.test.assert_gt("b", "a", "Should Pass")
		assert_pass(gr.test)

	func test_fails_with_less_than_string():
		gr.test.assert_gt("a", "b", "Should Fail")
		assert_fail(gr.test)

class TestAssertLt:
	extends BaseTestClass

	func test_number_with_lt():
		gr.test.assert_lt(1, 2, "Should Pass")
		assert_pass(gr.test, 1, '1 < 2')

	func test_number_with_gt():
		gr.test.assert_lt(2, 1, "Should fail")
		assert_fail(gr.test, 1, '2 > 1')

	func test_string_with_lt():
		gr.test.assert_lt("a", "b", "Should Pass")
		assert_pass(gr.test)

	func test_string_with_gt():
		gr.test.assert_lt("b", "a", "Should Fail")
		assert_fail(gr.test)

# TODO rename tests since they are now in an inner class.  See NOTE at top about naming.
class TestAssertBetween:
	extends BaseTestClass

	func test_between_with_number_between():
		gr.test.assert_between(2, 1, 3, "Should pass, 2 between 1 and 3")
		assert_pass(gr.test, 1, "Should pass, 2 between 1 and 3")

	func test_between_with_number_lt():
		gr.test.assert_between(0, 1, 3, "Should fail")
		assert_fail(gr.test, 1, '0 not between 1 and 3')

	func test_between_with_number_gt():
		gr.test.assert_between(4, 1, 3, "Should fail")
		assert_fail(gr.test, 1, '4 not between 1 and 3')

	func test_between_with_number_at_high_end():
		gr.test.assert_between(3, 1, 3, "Should pass")
		assert_pass(gr.test, 1, '3 is between 1 and 3')

	func test_between_with_number_at_low_end():
		gr.test.assert_between(1, 1, 3, "Should pass")
		assert_pass(gr.test, 1, '1 between 1 and 3')

	func test_between_with_invalid_number_range():
		gr.test.assert_between(4, 8, 0, "Should fail")
		assert_fail(gr.test, 1, '8 is starting number and is not less than 0')

	func test_between_with_string_between():
		gr.test.assert_between('b', 'a', 'c', "Should pass, 2 between 1 and 3")
		assert_pass(gr.test)

	func test_between_with_string_lt():
		gr.test.assert_between('a', 'b', 'd', "Should fail")
		assert_fail(gr.test)

	func test_between_with_string_gt():
		gr.test.assert_between('z', 'a', 'c', "Should fail")
		assert_fail(gr.test)

	func test_between_with_string_at_high_end():
		gr.test.assert_between('c', 'a', 'c', "Should pass")
		assert_pass(gr.test)

	func test_between_with_string_at_low_end():
		gr.test.assert_between('a', 'a', 'c', "Should pass")
		assert_pass(gr.test)

	func test_between_with_invalid_string_range():
		gr.test.assert_between('q', 'z', 'a', "Should fail")
		assert_fail(gr.test)


class TestAssertNotBetween:
	extends BaseTestClass

	func test_with_number_lt():
		gr.test.assert_not_between(1, 2, 3, "Should pass, 1 not between 2 and 3")
		assert_pass(gr.test)

	func test_with_number_gt():
		gr.test.assert_not_between(4, 1, 3, "Should pass, 4 not between 1 and 3")
		assert_pass(gr.test, 1, '4 not between 1 and 3')

	func test_with_number_at_low_end():
		gr.test.assert_not_between(1, 1, 3, "Should pass: exclusive not between")
		assert_pass(gr.test, 1, '1 not between 1 and 3, exclusively')

	func test_with_number_at_high_end():
		gr.test.assert_not_between(3, 1, 3, "Should pass: exclusive not between")
		assert_pass(gr.test, 1, '3 not between 1 and 3, exclusively')

	func test_with_invalid_number_range():
		gr.test.assert_not_between(4, 8, 0, "Should fail")
		assert_fail(gr.test, 1, '8 is starting number and is not less than 0')

	func test_with_string_between():
		gr.test.assert_not_between('b', 'a', 'c', "Should fail, b is between a and c")
		assert_fail(gr.test)

	func test_with_string_lt():
		gr.test.assert_not_between('a', 'b', 'd', "Should pass")
		assert_pass(gr.test)

	func test_with_string_gt():
		gr.test.assert_not_between('z', 'a', 'c', "Should pass")
		assert_pass(gr.test)

	func test_with_string_at_high_end():
		gr.test.assert_not_between('c', 'a', 'c', "Should pass: exclusive not between")
		assert_pass(gr.test)

	func test_with_string_at_low_end():
		gr.test.assert_not_between('a', 'a', 'c', "Should pass: exclusive not between")
		assert_pass(gr.test)

	func test_with_invalid_string_range():
		gr.test.assert_not_between('q', 'z', 'a', "Should fail: Invalid range")
		assert_fail(gr.test)

class TestAssertTrue:
	extends BaseTestClass

	func test_passes_with_true():
		gr.test.assert_true(true, "Should pass, true is true")
		assert_pass(gr.test)

	func test_fails_with_false():
		gr.test.assert_true(false, "Should fail")
		assert_fail(gr.test)

	func test_text_is_optional():
		gr.test.assert_true(true)
		assert_pass(gr.test)

	func test_fails_with_non_bools():
		gr.test.assert_true('asdf')
		gr.test.assert_true(1)
		assert_fail(gr.test, 2)


class TestAssertFalse:
	extends BaseTestClass

	func test_text_is_optional():
		gr.test.assert_false(false)
		assert_pass(gr.test)

	func test_fails_with_true():
		gr.test.assert_false(true, "Should fail")
		assert_fail(gr.test)

	func test_passes_with_false():
		gr.test.assert_false(false, "Should pass")
		assert_pass(gr.test)

	func test_fails_with_non_bools():
		gr.test.assert_false(null)
		gr.test.assert_false(0)
		assert_fail(gr.test, 2)

class TestAssertHas:
	extends BaseTestClass

	func test_passes_when_array_has_element():
		var array = [0]
		gr.test.assert_has(array, 0, 'It should have zero')
		assert_pass(gr.test)

	func test_fails_when_it_does_not_have_element():
		var array = [0]
		gr.test.assert_has(array, 1, 'Should not have it')
		assert_fail(gr.test)

	func test_assert_not_have_passes_when_not_in_there():
		var array = [0, 3, 5]
		gr.test.assert_does_not_have(array, 2, 'Should not have it.')
		assert_pass(gr.test)

	func test_assert_not_have_fails_when_in_there():
		var array = [1, 10, 20]
		gr.test.assert_does_not_have(array, 20, 'Should not have it.')
		assert_fail(gr.test)


class TestFailingDatatypeChecks:
	extends BaseTestClass

	func test_dt_string_number_eq():
		gr.test.assert_eq('1', 1)
		assert_fail(gr.test)

	func test_dt_string_number_ne():
		gr.test.assert_ne('2', 1)
		assert_fail(gr.test)

	func test_dt_string_number_assert_gt():
		gr.test.assert_gt('3', 1)
		assert_fail(gr.test)

	func test_dt_string_number_func_assert_lt():
		gr.test.assert_lt('1', 3)
		assert_fail(gr.test)

	func test_dt_string_number_func_assert_between():
		gr.test.assert_between('a', 5, 6)
		gr.test.assert_between(1, 2, 'c')
		assert_fail(gr.test, 2)

	func test_dt_can_compare_to_null():
		gr.test.assert_ne(Node2D.new(), null)
		gr.test.assert_ne(null, Node2D.new())
		assert_pass(gr.test, 2)


class TestPending:
	extends BaseTestClass

	func test_pending_increments_pending_count():
		gr.test.pending()
		assert_eq(gr.test.get_pending_count(), 1, 'One test should have been marked as pending')

	func test_pending_accepts_text():
		pending("This is a pending test.  You should see this text in the results.")

	func test_pending_does_not_increment_passed():
		gr.test.pending()
		assert_eq(gr.test.get_pass_count(), 0)


class TestAssertHasMethod:
	extends BaseTestClass

	class NoWantedMethod:
		func irrelevant_method():
			pass

	class HasWantedMethod:
		func wanted_method():
			pass

	func test_fail_if_is_lacking_method():
		var obj = NoWantedMethod.new()
		gr.test.assert_has_method(obj, 'wanted_method')
		assert_fail(gr.test)

	func test_pass_if_has_correct_method():
		var obj = HasWantedMethod.new()
		gr.test.assert_has_method(obj, 'wanted_method')
		assert_pass(gr.test)

class TestGetSetAsserts:
	extends BaseTestClass

	class NoGetNoSet:
		var _thing = 'nothing'

	class HasGetNotSet:
		func get_thing():
			pass

	class HasGetAndSetThatDontWork:
		func get_thing():
			pass
		func set_thing(new_thing):
			pass

	class HasGetSetThatWorks:
		var _thing = 'something'

		func get_thing():
			return _thing
		func set_thing(new_thing):
			_thing = new_thing

	func test_fail_if_get_set_not_defined():
		var obj = NoGetNoSet.new()
		gr.test.assert_accessors(obj, 'thing', 'something', 'another thing')
		assert_fail(gr.test, 2)

	func test_fail_if_has_get_and_not_set():
		var obj = HasGetNotSet.new()
		gr.test.assert_accessors(obj, 'thing', 'something', 'another thing')
		assert_fail_pass(gr.test, 1, 1)

	func test_fail_if_default_wrong_and_get_dont_work():
		var obj = HasGetAndSetThatDontWork.new()
		gr.test.assert_accessors(obj, 'thing', 'something', 'another thing')
		assert_fail_pass(gr.test, 2, 2)

	func test_fail_if_default_wrong():
		var obj = HasGetSetThatWorks.new()
		gr.test.assert_accessors(obj, 'thing', 'not the right default', 'another thing')
		assert_fail_pass(gr.test, 1, 3)

	func test_pass_if_all_get_sets_are_aligned():
		var obj = HasGetSetThatWorks.new()
		gr.test.assert_accessors(obj, 'thing', 'something', 'another thing')
		assert_pass(gr.test, 4)

class TestAssertExports:
	extends BaseTestClass

	class NoProperty:
		func _unused():
			pass

	class NotEditorProperty:
		var some_property = 1

	class HasCorrectEditorPropertyAndExplicitType:
		export(int) var int_property

	class HasCorrectEditorPropertyAndImplicitType:
		export var vec2_property = Vector2(0.0, 0.0)

	class HasCorrectEditorPropertyNotType:
		export(bool) var bool_property

	class HasObjectDerivedPropertyType:
		export(PackedScene) var scene_property

	func test_fail_if_property_not_found():
		var obj = NoProperty.new()
		gr.test.assert_exports(obj, "some_property", TYPE_BOOL)
		assert_fail(gr.test)

	func test_fail_if_not_editor_property():
		var obj = NotEditorProperty.new()
		gr.test.assert_exports(obj, "some_property", TYPE_INT)
		assert_fail(gr.test)

	func test_pass_if_editor_property_present_with_correct_explicit_type():
		var obj = HasCorrectEditorPropertyAndExplicitType.new()
		gr.test.assert_exports(obj, "int_property", TYPE_INT)
		assert_pass(gr.test)

	func test_pass_if_editor_property_present_with_correct_implicit_type():
		var obj = HasCorrectEditorPropertyAndImplicitType.new()
		gr.test.assert_exports(obj, "vec2_property", TYPE_VECTOR2)
		assert_pass(gr.test)

	func test_fail_if_editor_property_present_with_incorrect_type():
		var obj = HasCorrectEditorPropertyNotType.new()
		gr.test.assert_exports(obj, "bool_property", TYPE_REAL)
		assert_fail(gr.test)

	func test__object_derived_type__exported_as_object_type():
		var obj = HasObjectDerivedPropertyType.new()
		gr.test.assert_exports(obj, "scene_property", TYPE_OBJECT)
		assert_pass(gr.test)

# TODO rename tests since they are now in an inner class.  See NOTE at top about naming.
class TestAssertFileExists:
	extends BaseTestClass

	func test__assert_file_exists__with_file_dne():
		gr.test_with_gut.assert_file_exists('user://file_dne.txt')
		assert_fail(gr.test_with_gut)

	func test__assert_file_exists__with_file_exists():
		var path = 'user://gut_test_file.txt'
		var f = File.new()
		f.open(path, f.WRITE)
		f.close()
		gr.test_with_gut.assert_file_exists(path)
		assert_pass(gr.test_with_gut)

# TODO rename tests since they are now in an inner class.  See NOTE at top about naming.
class TestAssertFileDne:
	extends BaseTestClass

	func test__assert_file_dne__with_file_dne():
		gr.test_with_gut.assert_file_does_not_exist('user://file_dne.txt')
		assert_pass(gr.test_with_gut)

	func test__assert_file_dne__with_file_exists():
		var path = 'user://gut_test_file2.txt'
		var f = File.new()
		f.open(path, f.WRITE)
		f.close()
		gr.test_with_gut.assert_file_does_not_exist(path)
		assert_fail(gr.test_with_gut)

# TODO rename tests since they are now in an inner class.  See NOTE at top about naming.
class TestAssertFileEmpty:
	extends BaseTestClass

	func test__assert_file_empty__with_empty_file():
		var path = 'user://gut_test_empty.txt'
		var f = File.new()
		f.open(path, f.WRITE)
		f.close()
		gr.test_with_gut.assert_file_empty(path)
		assert_pass(gr.test_with_gut)

	func test__assert_file_empty__with_not_empty_file():
		var path = 'user://gut_test_empty2.txt'
		var f = File.new()
		f.open(path, f.WRITE)
		f.store_8(1)
		f.close()
		gr.test_with_gut.assert_file_empty(path)
		assert_fail(gr.test_with_gut)

	func test__assert_file_empty__fails_when_file_dne():
		var path = 'user://file_dne.txt'
		gr.test_with_gut.assert_file_empty(path)
		assert_fail(gr.test_with_gut)

# TODO rename tests since they are now in an inner class.  See NOTE at top about naming.
class TestAssertFileNotEmpty:
	extends BaseTestClass

	func test__assert_file_not_empty__with_empty_file():
		var path = 'user://gut_test_empty3.txt'
		var f = File.new()
		f.open(path, f.WRITE)
		f.close()
		gr.test_with_gut.assert_file_not_empty(path)
		assert_fail(gr.test_with_gut)

	func test__assert_file_not_empty__with_populated_file():
		var path = 'user://gut_test_empty4.txt'
		var f = File.new()
		f.open(path, f.WRITE)
		f.store_8(1)
		f.close()
		gr.test_with_gut.assert_file_not_empty(path)
		assert_pass(gr.test_with_gut)

	func test__assert_file_not_empty__fails_when_file_dne():
		var path = 'user://file_dne.txt'
		gr.test_with_gut.assert_file_not_empty(path)
		assert_fail(gr.test_with_gut)

# TODO rename tests since they are now in an inner class.  See NOTE at top about naming.
class TestSignalAsserts:
	extends BaseTestClass

	# Constants for all the signals created in SignalObject so I don't get false
	# pass/fail from typos
	const SIGNALS = {
		NO_PARAMETERS = 'no_parameters',
		ONE_PARAMETER = 'one_parameter',
		TWO_PARAMETERS = 'two_parameters',
		SOME_SIGNAL = 'some_signal',
		SCRIPT_SIGNAL = 'script_signal'
	}

	# ####################
	# A class that can emit all the signals in SIGNALS
	# ####################
	class SignalObject:
		signal script_signal
		func _init():
			add_user_signal(SIGNALS.NO_PARAMETERS)
			add_user_signal(SIGNALS.ONE_PARAMETER, [
				{'name':'something', 'type':TYPE_INT}
			])
			add_user_signal(SIGNALS.TWO_PARAMETERS, [
				{'name':'num', 'type':TYPE_INT},
				{'name':'letters', 'type':TYPE_STRING}
			])
			add_user_signal(SIGNALS.SOME_SIGNAL)

	func before_each():
		.before_each()
		gr.signal_object = SignalObject.new()

	func after_each():
		.after_each()
		gr.signal_object = null

	func test_when_object_not_being_watched__assert_signal_emitted__fails():
		gr.test.assert_signal_emitted(gr.signal_object, SIGNALS.SOME_SIGNAL)
		assert_fail(gr.test)

	func test_when_signal_emitted__assert_signal_emitted__passes():
		gr.test.watch_signals(gr.signal_object)
		gr.signal_object.emit_signal(SIGNALS.SOME_SIGNAL)
		gr.test.assert_signal_emitted(gr.signal_object, SIGNALS.SOME_SIGNAL)
		assert_pass(gr.test)

	func test_when_signal_not_emitted__assert_signal_emitted__fails():
		gr.test.watch_signals(gr.signal_object)
		gr.test.assert_signal_emitted(gr.signal_object, SIGNALS.SOME_SIGNAL)
		assert_fail(gr.test)

	func test_when_object_does_not_have_signal__assert_signal_emitted__fails():
		gr.test.watch_signals(gr.signal_object)
		gr.test.assert_signal_emitted(gr.signal_object, 'signal_does_not_exist')
		assert_fail(gr.test, 1, 'Only the failure that it does not have signal should fire.')

	func test_when_signal_emitted__assert_signal_not_emitted__fails():
		gr.test.watch_signals(gr.signal_object)
		gr.signal_object.emit_signal(SIGNALS.SOME_SIGNAL)
		gr.test.assert_signal_not_emitted(gr.signal_object, SIGNALS.SOME_SIGNAL)
		assert_fail(gr.test)

	func test_when_signal_not_emitted__assert_signal_not_emitted__fails():
		gr.test.watch_signals(gr.signal_object)
		gr.test.assert_signal_not_emitted(gr.signal_object, SIGNALS.SOME_SIGNAL)
		assert_pass(gr.test)

	func test_when_object_does_not_have_signal__assert_signal_not_emitted__fails():
		gr.test.watch_signals(gr.signal_object)
		gr.test.assert_signal_not_emitted(gr.signal_object, 'signal_does_not_exist')
		assert_fail(gr.test, 1, 'Only the failure that it does not have signal should fire.')

	func test_when_signal_emitted_once__assert_signal_emit_count__passes_with_1():
		gr.test.watch_signals(gr.signal_object)
		gr.signal_object.emit_signal(SIGNALS.SOME_SIGNAL)
		gr.test.assert_signal_emit_count(gr.signal_object, SIGNALS.SOME_SIGNAL, 1)
		assert_pass(gr.test)

	func test_when_signal_emitted_twice__assert_signal_emit_count__fails_with_1():
		gr.test.watch_signals(gr.signal_object)
		gr.signal_object.emit_signal(SIGNALS.SOME_SIGNAL)
		gr.signal_object.emit_signal(SIGNALS.SOME_SIGNAL)
		gr.test.assert_signal_emit_count(gr.signal_object, SIGNALS.SOME_SIGNAL, 1)
		assert_fail(gr.test)

	func test_when_object_does_not_have_signal__assert_signal_emit_count__fails():
		gr.test.watch_signals(gr.signal_object)
		gr.test.assert_signal_emit_count(gr.signal_object, 'signal_does_not_exist', 0)
		assert_fail(gr.test)

	func test__assert_has_signal__passes_when_it_has_the_signal():
		gr.test.assert_has_signal(gr.signal_object, SIGNALS.NO_PARAMETERS)
		assert_pass(gr.test)

	func test__assert_has_signal__fails_when_it_does_not_have_the_signal():
		gr.test.assert_has_signal(gr.signal_object, 'signal does not exist')
		assert_fail(gr.test)

	func test_can_get_signal_emit_counts():
		gr.test.watch_signals(gr.signal_object)
		gr.signal_object.emit_signal(SIGNALS.SOME_SIGNAL)
		gr.signal_object.emit_signal(SIGNALS.SOME_SIGNAL)
		assert_eq(gr.test.get_signal_emit_count(gr.signal_object, SIGNALS.SOME_SIGNAL), 2)

	func test__assert_signal_emitted_with_parameters__fails_when_object_not_watched():
		gr.test.assert_signal_emitted_with_parameters(gr.signal_object, SIGNALS.SOME_SIGNAL, [])
		assert_fail(gr.test)

	func test__assert_signal_emitted_with_parameters__passes_when_parameters_match():
		gr.test.watch_signals(gr.signal_object)
		gr.signal_object.emit_signal(SIGNALS.SOME_SIGNAL, 1)
		gr.test.assert_signal_emitted_with_parameters(gr.signal_object, SIGNALS.SOME_SIGNAL, [1])
		assert_pass(gr.test)

	func test__assert_signal_emitted_with_parameters__passes_when_all_parameters_match():
		gr.test.watch_signals(gr.signal_object)
		gr.signal_object.emit_signal(SIGNALS.SOME_SIGNAL, 1, 2, 3)
		gr.test.assert_signal_emitted_with_parameters(gr.signal_object, SIGNALS.SOME_SIGNAL, [1, 2, 3])
		assert_pass(gr.test)

	func test__assert_signal_emitted_with_parameters__fails_when_signal_not_emitted():
		gr.test.watch_signals(gr.signal_object)
		gr.test.assert_signal_emitted_with_parameters(gr.signal_object, SIGNALS.SOME_SIGNAL, [2])
		assert_fail(gr.test)

	func test__assert_signal_emitted_with_parameters__fails_when_parameters_dont_match():
		gr.test.watch_signals(gr.signal_object)
		gr.signal_object.emit_signal(SIGNALS.SOME_SIGNAL, 1)
		gr.test.assert_signal_emitted_with_parameters(gr.signal_object, SIGNALS.SOME_SIGNAL, [2])
		assert_fail(gr.test)

	func test__assert_signal_emitted_with_parameters__fails_when_not_all_parameters_match():
		gr.test.watch_signals(gr.signal_object)
		gr.signal_object.emit_signal(SIGNALS.SOME_SIGNAL, 1, 2, 3)
		gr.test.assert_signal_emitted_with_parameters(gr.signal_object, SIGNALS.SOME_SIGNAL, [1, 0, 3])
		assert_fail(gr.test)

	func test__assert_signal_emitted_with_parameters__can_check_multiple_emission():
		gr.test.watch_signals(gr.signal_object)
		gr.signal_object.emit_signal(SIGNALS.SOME_SIGNAL, 1)
		gr.signal_object.emit_signal(SIGNALS.SOME_SIGNAL, 2)
		gr.test.assert_signal_emitted_with_parameters(gr.signal_object, SIGNALS.SOME_SIGNAL, [1], 0)
		gr.test.assert_signal_emitted_with_parameters(gr.signal_object, SIGNALS.SOME_SIGNAL, [2], 1)
		assert_pass(gr.test, 2)

	func test__get_signal_emit_count__returns_neg_1_when_not_watched():
		assert_eq(gr.test.get_signal_emit_count(gr.signal_object, SIGNALS.SOME_SIGNAL), -1)

	func test_can_get_signal_parameters():
		gr.test.watch_signals(gr.signal_object)
		gr.signal_object.emit_signal(SIGNALS.SOME_SIGNAL, 1, 2, 3)
		assert_eq(gr.test.get_signal_parameters(gr.signal_object, SIGNALS.SOME_SIGNAL, 0), [1, 2, 3])

	func test__assert_signal_emitted__passes_with_script_signals():
		gr.test.watch_signals(gr.signal_object)
		gr.signal_object.emit_signal(SIGNALS.SCRIPT_SIGNAL)
		gr.test.assert_signal_emitted(gr.signal_object, SIGNALS.SCRIPT_SIGNAL)
		assert_pass(gr.test)

	func test__assert_has_signal__works_with_script_signals():
		gr.test.assert_has_signal(gr.signal_object, SIGNALS.SCRIPT_SIGNAL)
		assert_pass(gr.test)

	func test_when_signal_emitted_fails_emitted_signals_are_listed():
		gr.test.watch_signals(gr.signal_object)
		gr.signal_object.emit_signal(SIGNALS.NO_PARAMETERS)
		gr.signal_object.emit_signal(SIGNALS.SOME_SIGNAL)
		gr.test.assert_signal_emitted(gr.signal_object, SIGNALS.SCRIPT_SIGNAL)
		var text = gr.test._fail_pass_text[0]
		assert_string_contains(text, SIGNALS.NO_PARAMETERS)
		assert_string_contains(text, SIGNALS.SOME_SIGNAL)

	func test_when_signal_count_fails_then_emitted_signals_are_listed():
		gr.test.watch_signals(gr.signal_object)
		gr.signal_object.emit_signal(SIGNALS.NO_PARAMETERS)
		gr.signal_object.emit_signal(SIGNALS.SCRIPT_SIGNAL)
		gr.signal_object.emit_signal(SIGNALS.SOME_SIGNAL)
		gr.test.assert_signal_emit_count(gr.signal_object, SIGNALS.SCRIPT_SIGNAL, 2)
		var text = gr.test._fail_pass_text[0]
		assert_string_contains(text, SIGNALS.NO_PARAMETERS)
		assert_string_contains(text, SIGNALS.SOME_SIGNAL)

	func test_when_signal_emit_with_parameters_fails_because_signal_was_not_emitted_then_signals_are_listed():
		gr.test.watch_signals(gr.signal_object)
		gr.signal_object.emit_signal(SIGNALS.NO_PARAMETERS)
		gr.signal_object.emit_signal(SIGNALS.SOME_SIGNAL)
		gr.test.assert_signal_emitted_with_parameters(gr.signal_object, SIGNALS.SCRIPT_SIGNAL, [0])
		var text = gr.test._fail_pass_text[0]
		assert_string_contains(text, SIGNALS.NO_PARAMETERS)
		assert_string_contains(text, SIGNALS.SOME_SIGNAL)

	func test_issue_152():
		gr.test.watch_signals(gr.signal_object)
		gr.signal_object.emit_signal(SIGNALS.SOME_SIGNAL, 1.0, 2, 3.0)
		gr.test.assert_signal_emitted_with_parameters(gr.signal_object, SIGNALS.SOME_SIGNAL, [1, 2.0, 3])
		assert_fail(gr.test)


class TestExtendAsserts:
	extends BaseTestClass

	class BaseClass:
		extends Node2D

	class ExtendsBaseClass:
		extends BaseClass

	class HasSubclass1:
		class SubClass:
			var a = 1

	class HasSubclass2:
		class SubClass:
			var a = 2

	func test_passes_when_class_extends_parent():
		var node2d = Node2D.new()
		gr.test.assert_is(node2d, Node2D)
		assert_pass(gr.test)

	func test_fails_when_class_does_not_extend_parent():
		var lbl = Label.new()
		gr.test.assert_is(lbl, TextEdit)
		assert_fail(gr.test)

	func test_fails_with_primitves_and_classes():
		gr.test.assert_is([], Node2D)
		assert_fail(gr.test)

	func test_fails_when_compareing_object_to_primitives():
		gr.test.assert_is(Node2D.new(), [])
		gr.test.assert_is(TextEdit.new(), {})
		assert_fail(gr.test, 2)

	func test_fails_with_another_instance():
		var node1 = Node2D.new()
		var node2 = Node2D.new()
		gr.test.assert_is(node1, node2)
		assert_fail(gr.test)

	func test_passes_with_deeper_inheritance():
		var eb = ExtendsBaseClass.new()
		gr.test.assert_is(eb, Node2D)
		assert_pass(gr.test)

	func test_fails_when_class_names_match_but_inheritance_does_not():
		var a = HasSubclass1.SubClass.new()
		var b = HasSubclass2.SubClass.new()
		gr.test.assert_is(a, b)
		assert_fail(gr.test)

	func test_fails_when_class_names_match_but_inheritance_does_not__with_class():
		var a = HasSubclass1.SubClass.new()
		gr.test.assert_is(a, HasSubclass2.SubClass)
		# created bug https://github.com/godotengine/godot/issues/27111 for 3.1
		# TODO remove comment after awhile, this appears fixed in 3.2
		assert_fail(gr.test, 1, 'Fails in 3.1, bug has been created.')

class TestAssertTypeOf:
	extends BaseTestClass
	func before_all():
		_print_all_subtests  =  true

	func test_passes_when_object_is_of_type():
		var c = Color(1, 1, 1, 1)
		gr.test.assert_typeof(c, TYPE_COLOR)
		assert_pass(gr.test)

	func test_fails_when_it_is_not():
		var c = Color(1, 1, 1, 1)
		gr.test.assert_typeof(c, TYPE_INT)
		assert_fail(gr.test)

	func test_not_fails_when_object_is_of_type():
		var c = Color(1, 1, 1, 1)
		gr.test.assert_not_typeof(c, TYPE_COLOR)
		assert_fail(gr.test)

	func test_not_passes_when_it_is_not():
		var c = Color(1, 1, 1, 1)
		gr.test.assert_not_typeof(c, TYPE_INT)
		assert_pass(gr.test)

# TODO rename tests since they are now in an inner class.  See NOTE at top about naming.
class TestStringContains:
	extends BaseTestClass

	func test__assert_string_contains__fails_when_text_is_empty():
		gr.test.assert_string_contains('', 'walrus')
		assert_fail(gr.test)

	func test__assert_string_contains__fails_when_search_string_is_empty():
		gr.test.assert_string_contains('This is a test.', '')
		assert_fail(gr.test)

	func test__assert_string_contains__fails_when_case_sensitive_search_not_found():
		gr.test.assert_string_contains('This is a test.', 'TeSt', true)
		assert_fail(gr.test)

	func test__assert_string_contains__fails_when_case_insensitive_search_not_found():
		gr.test.assert_string_contains('This is a test.', 'penguin', false)
		assert_fail(gr.test)

	func test__assert_string_contains__passes_when_case_sensitive_search_is_found():
		gr.test.assert_string_contains('This is a test.', 'is a ', true)
		assert_pass(gr.test)

	func test__assert_string_contains__passes_when_case_insensitive_search_is_found():
		gr.test.assert_string_contains('This is a test.', 'this ', false)
		assert_pass(gr.test)

# TODO rename tests since they are now in an inner class.  See NOTE at top about naming.
class TestStringStartsWith:
	extends BaseTestClass

	func test__assert_string_starts_with__fails_when_text_is_empty():
		gr.test.assert_string_starts_with('', 'The')
		assert_fail(gr.test)

	func test__assert_string_starts_with__fails_when_search_string_is_empty():
		gr.test.assert_string_starts_with('This is a test.', '')
		assert_fail(gr.test)

	func test__assert_string_starts_with__fails_when_case_sensitive_search_not_at_start():
		gr.test.assert_string_starts_with('This is a test.', 'thi', true)
		assert_fail(gr.test)

	func test__assert_string_starts_with__fails_when_case_insensitive_search_not_at_start():
		gr.test.assert_string_starts_with('This is a test.', 'puffin', false)
		assert_fail(gr.test)

	func test__assert_string_starts_with__passes_when_case_sensitive_search_at_start():
		gr.test.assert_string_starts_with('This is a test.', 'This ', true)
		assert_pass(gr.test)

	func test__assert_string_starts_with__passes_when_case_insensitive_search_at_start():
		gr.test.assert_string_starts_with('This is a test.', 'tHI', false)
		assert_pass(gr.test)

# TODO rename tests since they are now in an inner class.  See NOTE at top about naming.
class TestStringEndsWith:
	extends BaseTestClass

	func test__assert_string_ends_with__fails_when_text_is_empty():
		gr.test.assert_string_ends_with('', 'seal')
		assert_fail(gr.test)

	func test__assert_string_ends_with__fails_when_search_string_is_empty():
		gr.test.assert_string_ends_with('This is a test.', '')
		assert_fail(gr.test)

	func test__assert_string_ends_with__fails_when_case_sensitive_search_not_at_end():
		gr.test.assert_string_ends_with('This is a test.', 'TEST.', true)
		assert_fail(gr.test)

	func test__assert_string_ends_with__fails_when_case_insensitive_search_not_at_end():
		gr.test.assert_string_ends_with('This is a test.', 'orca', false)
		assert_fail(gr.test)

	func test__assert_string_ends_with__passes_when_case_sensitive_search_at_end():
		gr.test.assert_string_ends_with('This is a test.', 'est.', true)
		assert_pass(gr.test)

	func test__assert_string_ends_with__passes_when_case_insensitive_search_at_end():
		gr.test.assert_string_ends_with('This is a test.', 'A teSt.', false)
		assert_pass(gr.test)

# TODO rename tests since they are now in an inner class.  See NOTE at top about naming.
class TestAssertCalled:
	extends BaseTestClass

	#const DOUBLE_ME_PATH = 'res://test/resources/doubler_test_objects/double_me.gd'

	func test_assert_called_fails_with_message_if_non_doubled_passed():
		var obj = GDScript.new()
		gr.test_with_gut.gut.get_spy().add_call(obj, 'method')
		gr.test_with_gut.assert_called(obj, 'method1')
		gut.p('!! Check output !!')
		assert_fail(gr.test_with_gut)

	func test_assert_called_passes_when_call_occurred():
		var doubled = gr.test_with_gut.double(DOUBLE_ME_PATH).new()
		doubled.get_value()
		gr.test_with_gut.assert_called(doubled, 'get_value')
		assert_pass(gr.test_with_gut)

	func test_assert_called_passes_with_parameters():
		var doubled = gr.test_with_gut.double(DOUBLE_ME_PATH).new()
		doubled.set_value(5)
		gr.test_with_gut.assert_called(doubled, 'set_value', [5])
		assert_pass(gr.test_with_gut)

	func test_fails_when_parameters_do_not_match():
		var doubled = gr.test_with_gut.double(DOUBLE_ME_PATH).new()
		doubled.set_value('a')
		gr.test_with_gut.assert_called(doubled, 'set_value', [5])
		assert_fail(gr.test_with_gut)

	func test_assert_called_works_with_defaults():
		var doubled = gr.test_with_gut.double(DOUBLE_ME_PATH).new()
		doubled.has_two_params_one_default(10)
		gr.test_with_gut.assert_called(doubled, 'has_two_params_one_default', [10, null])
		assert_pass(gr.test_with_gut)

	func test_assert_called_generates_error_if_third_parameter_not_an_array():
		var doubled = gr.test_with_gut.double(DOUBLE_ME_PATH).new()
		doubled.set_value(5)
		gr.test_with_gut.assert_called(doubled, 'set_value', 5)
		assert_fail(gr.test_with_gut)
		assert_eq(gr.test_with_gut.get_logger().get_errors().size(), 1, 'Generates error')



class TestAssertNotCalled:
	extends BaseTestClass


	func test_passes_when_no_calls_have_been_made():
		var doubled = gr.test_with_gut.double(DOUBLE_ME_PATH).new()
		gr.test_with_gut.assert_not_called(doubled, 'get_value')
		assert_pass(gr.test_with_gut)

	func test_fails_when_a_call_has_been_made():
		var doubled = gr.test_with_gut.double(DOUBLE_ME_PATH).new()
		doubled.get_value()
		gr.test_with_gut.assert_not_called(doubled, 'get_value')
		assert_fail(gr.test_with_gut)

	func test_fails_when_passed_a_non_doubled_instance():
		gr.test_with_gut.assert_not_called(GDScript.new(), 'method')
		assert_fail(gr.test_with_gut)

	func test_passes_if_parameters_do_not_match():
		var doubled = gr.test_with_gut.double(DOUBLE_ME_PATH).new()
		doubled.set_value(4)
		gr.test_with_gut.assert_not_called(doubled, 'set_value', [5])
		assert_pass(gr.test_with_gut)

	func test_fails_if_parameters_do_match():
		var doubled = gr.test_with_gut.double(DOUBLE_ME_PATH).new()
		doubled.set_value('a')
		gr.test_with_gut.assert_not_called(doubled, 'set_value', ['a'])
		assert_fail(gr.test_with_gut)

	func test_fails_if_no_params_specified_and_a_call_was_made():
		var doubled = gr.test_with_gut.double(DOUBLE_ME_PATH).new()
		doubled.set_value('a')
		gr.test_with_gut.assert_not_called(doubled, 'set_value')
		assert_fail(gr.test_with_gut)

class TestAssertCallCount:
	extends BaseTestClass

	#const DOUBLE_ME_PATH = 'res://test/resources/doubler_test_objects/double_me.gd'

	func test_passes_when_nothing_called_and_expected_count_zero():
		var doubled = gr.test_with_gut.double(DOUBLE_ME_PATH).new()
		gr.test_with_gut.assert_call_count(doubled, 'set_value', 0)
		assert_pass(gr.test_with_gut)

	func test_fails_when_count_does_not_match():
		var doubled = gr.test_with_gut.double(DOUBLE_ME_PATH).new()
		doubled.set_value(5)
		doubled.set_value(10)
		gr.test_with_gut.assert_call_count(doubled, 'set_value', 1)
		assert_fail(gr.test_with_gut)

	func test_fails_if_object_is_not_a_double():
		var obj = GDScript.new()
		gr.test_with_gut.gut.get_spy().add_call(obj, '_init')
		gr.test_with_gut.assert_call_count(obj, '_init', 1)
		assert_fail(gr.test_with_gut)

	func test_fails_if_parameters_do_not_match():
		var doubled = gr.test_with_gut.double(DOUBLE_ME_PATH).new()
		doubled.set_value(5)
		doubled.set_value(10)
		gr.test_with_gut.assert_call_count(doubled, 'set_value', 2, [5])
		assert_fail(gr.test_with_gut)

	func test_it_passes_if_parameters_do_match():
		var doubled = gr.test_with_gut.double(DOUBLE_ME_PATH).new()
		doubled.set_value(5)
		doubled.set_value(10)
		doubled.set_value(5)
		doubled.set_value(5)
		gr.test_with_gut.assert_call_count(doubled, 'set_value', 3, [5])
		assert_pass(gr.test_with_gut)

	func test_when_parameters_not_sent_all_calls_count():
		var doubled = gr.test_with_gut.double(DOUBLE_ME_PATH).new()
		doubled.set_value(5)
		doubled.set_value(10)
		doubled.set_value(6)
		doubled.set_value(12)
		gr.test_with_gut.assert_call_count(doubled, 'set_value', 4)
		assert_pass(gr.test_with_gut)

class TestGetCallParameters:
	extends BaseTestClass

	func test_it_works():
		var doubled = gr.test_with_gut.double(DOUBLE_ME_PATH).new()
		doubled.set_value(5)
		assert_eq(gr.test_with_gut.get_call_parameters(doubled, 'set_value'), [5])
		gr.test_with_gut.assert_called(doubled, 'set_value')
		assert_pass(gr.test_with_gut)

	func test_generates_error_if_you_do_not_pass_a_doubled_object():
		var thing = Node2D.new()
		var _p = gr.test_with_gut.get_call_parameters(thing, 'something')
		assert_eq(gr.test_with_gut.get_logger().get_errors().size(), 1)


class TestAssertNull:
	extends BaseTestClass

	func test_when_null_assert_passes():
		gr.test.assert_null(null)
		assert_pass(gr.test)

	func test_when_not_null_assert_fails():
		gr.test.assert_null('a')
		assert_fail(gr.test)

	func test_accepts_text():
		gr.test.assert_null('a', 'a is not null')
		assert_fail(gr.test)

	func test_does_not_blow_up_on_different_kinds_of_input():
		gr.test.assert_null(Node2D.new())
		gr.test.assert_null(1)
		gr.test.assert_null([])
		gr.test.assert_null({})
		gr.test.assert_null(Color(1,1,1,1))
		assert_fail(gr.test, 5)

class TestAssertNotNull:
	extends BaseTestClass

	func test_when_null_assert_fails():
		gr.test.assert_not_null(null)
		assert_fail(gr.test)

	func test_when_not_null_assert_passes():
		gr.test.assert_not_null('a')
		assert_pass(gr.test)

	func test_accepts_text():
		gr.test.assert_not_null('a', 'a is not null')
		assert_pass(gr.test)

	func test_does_not_blow_up_on_different_kinds_of_input():
		gr.test.assert_not_null(Node2D.new())
		gr.test.assert_not_null(1)
		gr.test.assert_not_null([])
		gr.test.assert_not_null({})
		gr.test.assert_not_null(Color(1,1,1,1))
		assert_pass(gr.test, 5)

class TestReplaceNode:
	extends BaseTestClass

	# The get methods in this scene use paths and $ to get to various resources
	# in the scene and return them.
	var Arena = load('res://test/resources/replace_node_scenes/Arena.tscn')
	var _arena = null

	func before_each():
		.before_each()
		_arena = Arena.instance()

	func after_each():
		.after_each()
		_arena.queue_free()

	func test_can_replace_node():
		var replacement = Node2D.new()
		gr.test.replace_node(_arena, 'Player1/Sword', replacement)
		assert_eq(_arena.get_sword(), replacement)

	func test_when_node_does_not_exist_error_is_generated():
		var replacement = Node2D.new()
		gr.test.replace_node(_arena, 'DoesNotExist', replacement)
		assert_errored(gr.test)

	func test_replacement_works_with_dollar_sign_references():
		var replacement = Node2D.new()
		gr.test.replace_node(_arena, 'Player1', replacement)
		assert_eq(_arena.get_player1_ds(), replacement)

	func test_replacement_works_with_dollar_sign_references_2():
		var replacement = Node2D.new()
		gr.test.replace_node(_arena, 'Player1/Sword', replacement)
		assert_eq(_arena.get_sword_ds(), replacement)

	func test_replaced_node_is_freed():
		var replacement = Node2D.new()
		var old = _arena.get_sword()
		gr.test.replace_node(_arena, 'Player1/Sword', replacement)
		# object is freed using queue_free, so we have to wait for it to go away
		yield(yield_for(0.5), YIELD)
		assert_true(_utils.is_freed(old))

	func test_replaced_node_retains_groups():
		var replacement = Node2D.new()
		var old = _arena.get_sword()
		old.add_to_group('Swords')
		gr.test.replace_node(_arena, 'Player1/Sword', replacement)
		assert_true(replacement.is_in_group('Swords'))

	func test_works_with_node_and_not_path():
		var replacement = Node2D.new()
		var old = _arena.get_sword_ds()
		gr.test.replace_node(_arena, old, replacement)
		assert_eq(_arena.get_sword(), replacement)

	func test_generates_error_if_base_node_does_not_have_node_to_replace():
		var replacement = Node2D.new()
		var old = Node2D.new()
		gr.test.replace_node(_arena, old, replacement)
		assert_errored(gr.test)

class TestAssertIsFreed:
	extends BaseTestClass

	func test_object_is_freed_should_pass():
		var obj = Node.new()
		obj.free()
		gr.test.assert_freed(obj, "Object1")
		assert_pass(gr.test)

	func test_object_is_freed_should_fail():
		var obj = Node.new()
		gr.test.assert_freed(obj, "Object2")
		# free after test
		obj.queue_free()
		assert_fail(gr.test)

	func test_object_is_not_freed_should_pass():
		var obj = Node.new()
		gr.test.assert_not_freed(obj, "Object3")
		# free after test
		obj.queue_free()
		assert_pass(gr.test)

	func test_object_is_not_freed_should_fail():
		var obj = Node.new()
		obj.free()
		gr.test.assert_not_freed(obj, "Object4")
		assert_fail(gr.test)

	func test_queued_free_is_not_freed():
		var obj = Node.new()
		add_child(obj)
		obj.queue_free()
		gr.test.assert_not_freed(obj, "Object4")
		assert_pass(gr.test)

class TestConnectionAsserts:
	extends BaseTestClass

	const SIGNAL_NAME = 'test_signal'
	const METHOD_NAME = 'test_signal_connector'

	class Signaler:
		signal test_signal

	class ConnectTo:
		func test_signal_connector():
			pass

	func test_when_target_connected_to_source_connected_passes_with_method_name():
		var s = Signaler.new()
		var c = ConnectTo.new()
		s.connect(SIGNAL_NAME, c, METHOD_NAME)
		gr.test.assert_connected(s, c, SIGNAL_NAME, METHOD_NAME)
		assert_pass(gr.test)

	func test_when_target_connected_to_source_connected_passes_without_method_name():
		var s = Signaler.new()
		var c = ConnectTo.new()
		s.connect(SIGNAL_NAME, c, METHOD_NAME)
		gr.test.assert_connected(s, c, SIGNAL_NAME)
		assert_pass(gr.test)

	func test_when_target_not_connected_to_source_connected_fails_with_method_name():
		var s = Signaler.new()
		var c = ConnectTo.new()
		gr.test.assert_connected(s, c, SIGNAL_NAME, METHOD_NAME)
		assert_fail(gr.test)

	func test_when_target_not_connected_to_source_connected_fails_without_method_name():
		var s = Signaler.new()
		var c = ConnectTo.new()
		gr.test.assert_connected(s, c, SIGNAL_NAME)
		assert_fail(gr.test)

	func test_when_target_connected_to_source_not_connected_fails_with_method_name():
		var s = Signaler.new()
		var c = ConnectTo.new()
		s.connect(SIGNAL_NAME, c, METHOD_NAME)
		gr.test.assert_not_connected(s, c, SIGNAL_NAME, METHOD_NAME)
		assert_fail(gr.test)

	func test_when_target_connected_to_source_not_connected_fails_without_method_name():
		var s = Signaler.new()
		var c = ConnectTo.new()
		s.connect(SIGNAL_NAME, c, METHOD_NAME)
		gr.test.assert_not_connected(s, c, SIGNAL_NAME)
		assert_fail(gr.test)

	func test_when_target_not_connected_to_source_not_connected_passes_with_method_name():
		var s = Signaler.new()
		var c = ConnectTo.new()
		gr.test.assert_not_connected(s, c, SIGNAL_NAME, METHOD_NAME)
		assert_pass(gr.test)

	func test_when_target_not_connected_to_source_not_connected_passes_without_method_name():
		var s = Signaler.new()
		var c = ConnectTo.new()
		gr.test.assert_not_connected(s, c, SIGNAL_NAME)
		assert_pass(gr.test)


class TestParameterizedTests:
	extends BaseTestClass

	func test_first_call_to_use_parameters_returns_first_index_of_params():
		var result = gr.test_with_gut.use_parameters([1, 2, 3])
		assert_eq(result, 1)

	func test_when_use_parameters_is_called_it_populates_guts_parameter_handler():
		gr.test_with_gut.use_parameters(['a'])
		assert_not_null(gr.test_with_gut.gut.get_parameter_handler())

	func test_prameter_handler_has_logger_set_to_guts_logger():
		gr.test_with_gut.use_parameters(['a'])
		var ph = gr.test_with_gut.gut.get_parameter_handler()
		assert_eq(ph.get_logger(), gr.test_with_gut.gut.get_logger())

	func test_when_gut_already_has_parameter_handler_it_does_not_make_a_new_one():
		gr.test_with_gut.use_parameters(['a', 'b', 'c', 'd'])
		var ph = gr.test_with_gut.gut.get_parameter_handler()
		gr.test_with_gut.use_parameters(['a', 'b', 'c', 'd'])
		assert_eq(gr.test_with_gut.gut.get_parameter_handler(), ph)

class TestMemoryMgmt:
	extends 'res://addons/gut/test.gd'

	func test_passes_when_no_orphans_introduced():
		assert_no_new_orphans()
		assert_true(gut._current_test.passed, 'test should be passing')

	func test_failing_orphan_assert_marks_test_as_failing():
		var n2d = Node2D.new()
		assert_no_new_orphans('this should fail')
		assert_true(is_failing(), 'test should be failing')
		n2d.free()

	func test_passes_when_orphans_released():
		var n2d = Node2D.new()
		n2d.free()
		assert_no_new_orphans()
		assert_true(gut._current_test.passed, 'this should be passing')

	func test_passes_with_queue_free():
		var n2d = Node2D.new()
		n2d.queue_free()
		yield(yield_for(.5, 'must yield for queue_free to take hold'), YIELD)
		assert_no_new_orphans()
		assert_true(gut._current_test.passed, 'this should be passing')

	func test_autofree_children():
		var n = Node.new()
		add_child_autofree(n)
		assert_eq(n.get_parent(), self, 'added as child')
		gut.get_autofree().free_all()
		assert_freed(n, 'node')
		assert_no_new_orphans()

	func test_autoqfree_children():
		var n = Node.new()
		add_child_autoqfree(n)
		assert_eq(n.get_parent(), self, 'added as child')
		gut.get_autofree().free_all()
		assert_not_freed(n, 'node') # should not be freed until yield
		yield(yield_for(.5), YIELD)
		assert_freed(n, 'node')
		assert_no_new_orphans()

	func test_children_warning():
		var TestClass = load('res://addons/gut/test.gd')
		for i in range(3):
			var extra_test = TestClass.new()
			add_child(extra_test)


class TestTestStateChecking:
	extends 'res://addons/gut/test.gd'

	var _gut = null

	func before_each():
		.before_each()
		_gut = _utils.Gut.new()
		add_child_autoqfree(_gut)
		_gut.add_script('res://test/resources/state_check_tests.gd')

	func _same_name():
		return gut.get_current_test_object().name

	func _run_test(inner_class, name=_same_name()):
		_gut.set_inner_class_name(inner_class)
		_gut.set_unit_test_name(name)
		_gut.test_scripts()

	func _assert_pass_fail_count(passing, failing):
		assert_eq(_gut.get_pass_count(), passing, 'Pass count does not match')
		assert_eq(_gut.get_fail_count(), failing, 'Failing count does not match')

	func test_is_passing_returns_true_when_test_is_passing():
		_run_test('TestIsPassing')
		_assert_pass_fail_count(2, 0)

	func test_is_passing_returns_false_when_test_is_failing():
		_run_test('TestIsPassing')
		_assert_pass_fail_count(1, 1)

	func test_is_passing_false_by_default():
		_run_test('TestIsPassing')
		_assert_pass_fail_count(1, 0)

	func  test_is_passing_returns_true_before_test_fails():
		_run_test('TestIsPassing')
		_assert_pass_fail_count(2, 1)

	func test_is_failing_returns_true_when_failing():
		_run_test('TestIsFailing')
		_assert_pass_fail_count(1, 1)

	func test_is_failing_returns_false_when_passing():
		_run_test('TestIsFailing')
		_assert_pass_fail_count(2, 0)

	func test_is_failing_returns_false_by_default():
		_run_test('TestIsFailing')
		_assert_pass_fail_count(1, 0)

	func test_is_failing_returns_false_before_test_passes():
		_run_test('TestIsFailing')
		_assert_pass_fail_count(2, 0)

	func test_error_generated_when_using_is_passing_in_before_all():
		_run_test('TestUseIsPassingInBeforeAll', 'test_nothing')
		assert_eq(_gut.get_logger().get_errors().size(), 1)

	func test_error_generated_when_using_is_passing_in_after_all():
		_run_test('TestUseIsPassingInAfterAll', 'test_nothing')
		assert_eq(_gut.get_logger().get_errors().size(), 1)

	func test_error_generated_when_using_is_failing_in_before_all():
		_run_test('TestUseIsFailingInBeforeAll', 'test_nothing')
		assert_eq(_gut.get_logger().get_errors().size(), 1)

	func test_error_generated_when_using_is_failing_in_after_all():
		_run_test('TestUseIsFailingInAfterAll', 'test_nothing')
		assert_eq(_gut.get_logger().get_errors().size(), 1)

class TestPassFailTestMethods:
	extends BaseTestClass

	func test_pass_test_passes_ups_pass_count():
		gr.test_with_gut.pass_test('pass this')
		assert_eq(gr.test_with_gut.get_pass_count(), 1, 'test count')

	func test_fail_test_ups_fail_count():
		gr.test_with_gut.fail_test('fail this')
		assert_eq(gr.test_with_gut.get_fail_count(), 1, 'test count')


class TestCompareDeepShallow:
	extends BaseTestClass

	func test_compare_shallow_uses_compare():
		var d_compare = double(_utils.Comparator).new()
		gr.test._compare = d_compare
		var result = gr.test.compare_shallow([], [])
		assert_called(d_compare, 'shallow')

	func test_compare_shallow_sets_max_differences():
		var result = gr.test.compare_shallow([], [], 10)
		assert_eq(result.max_differences, 10)

	func test_compare_deep_uses_compare():
		var d_compare = double(_utils.Comparator).new()
		gr.test._compare = d_compare
		var result = gr.test.compare_deep([], [])
		assert_called(d_compare, 'deep')

	func test_compare_deep_sets_max_differences():
		var result = gr.test.compare_deep([], [], 10)
		assert_eq(result.max_differences, 10)

	func test_assert_eq_deep_pass_with_same():
		gr.test.assert_eq_deep({'a':1}, {'a':1})
		assert_pass(gr.test)

	func test_assert_eq_deep_fails_with_different():
		gr.test.assert_eq_deep({'a':12}, {'a':1})
		assert_fail(gr.test)

	func test_assert_ne_deep_passes_with_different():
		gr.test.assert_ne_deep({'a':12}, {'a':1})
		assert_pass(gr.test)

	func test_assert_ne_deep_fails_with_same():
		gr.test.assert_ne_deep({'a':1}, {'a':1})
		assert_fail(gr.test)

	func test_assert_eq_shallow_pass_with_same():
		gr.test.assert_eq_shallow({'a':1}, {'a':1})
		assert_pass(gr.test)

	func test_assert_eq_shallow_fails_with_different():
		gr.test.assert_eq_shallow({'a':12}, {'a':1})
		assert_fail(gr.test)

	func test_assert_ne_shallow_passes_with_different():
		gr.test.assert_ne_shallow({'a':12}, {'a':1})
		assert_pass(gr.test)

	func test_assert_ne_shallow_fails_with_same():
		gr.test.assert_ne_shallow({'a':1}, {'a':1})
		assert_fail(gr.test)

class TestAssertSetgetCalled:
	extends BaseTestClass


	const TestNode = preload("res://test/resources/test_assert_setget_test_objects/test_node.gd")
	const TestScene = preload("res://test/resources/test_assert_setget_test_objects/TestScene.tscn")


	var bad_input = [
		# Passing instance instead of classe
		[TestNode.new(), "has_both", "set_has_both", "get_has_both"],
		# passing int instead of instance
		[5, "has_both", "set_has_both", "get_has_both"],
		# missing prop with existing setter/gettter
		[TestNode, "wrong_field_name", "set_both", "get_has_both"],
		# wrong setter
		[TestNode, "has_both", "wrong_setter_name", "get_has_both"],
		# wrong getter
		[TestNode, "has_both", "set_has_both", "wrong_getter_name"],
		# not passing setter/getter names
		[TestNode, "has_both", "", ""],
		# passing ints instead of strings
		[TestNode, "has_both", 1, 1],
		# passing nullsfor setter/getter names
		[TestNode, "has_both", null, null],
	]
	func test_fails_with_bad_input_params(params=use_parameters(bad_input)):
		var old_failed_count = gr.test_with_gut.get_fail_count() # issue parameterized tests
		gr.test_with_gut._assert_setget_called(params[0],params[1], params[2], params[3])
		assert_fail(gr.test_with_gut, old_failed_count + 1)
		if params[0] is TestNode:
			params[0].free()


	func test_fails_with_no_setter_and_getter_names():
		gr.test_with_gut._assert_setget_called(TestNode, "has_both")
		assert_fail(gr.test_with_gut)


	func test_fails_if_given_setter_is_not_called():
		gr.test_with_gut._assert_setget_called(TestNode, "has_both_dnu_setget", "set_has_both_dnu_setget")
		assert_fail(gr.test_with_gut)


	func test_fails_if_given_getter_is_not_called():
		gr.test_with_gut._assert_setget_called(TestNode, "has_both_dnu_setget", "", "get_has_both_dnu_setget")
		assert_fail(gr.test_with_gut)


	func test_passes_if_given_type_is_packed_scene():
		gr.test_with_gut._assert_setget_called(TestScene, "node_with_setter_getter", "set_node_with_setter_getter", "get_node_with_setter_getter")
		assert_pass(gr.test_with_gut)


	func test_passes_if_given_setter_and_getter_is_called():
		gr.test_with_gut._assert_setget_called(TestNode, "has_both", "set_has_both", "get_has_both")
		assert_pass(gr.test_with_gut)


	func test_passes_if_given_setter_is_called():
		gr.test_with_gut._assert_setget_called(TestNode, "has_both", "set_has_both")
		assert_pass(gr.test_with_gut)


	func test_passes_if_given_getter_is_called():
		gr.test_with_gut._assert_setget_called(TestNode, "has_both", "", "get_has_both")
		assert_pass(gr.test_with_gut)


	func test_fails_if_given_type_is_already_doubled():
		var doubled_type = double(TestNode)
		gr.test_with_gut._assert_setget_called(doubled_type, "has_both", "set_has_both", "get_has_both")
		assert_fail(gr.test_with_gut)


	func test_passes_if_given_setter_is_typed():
		gr.test_with_gut._assert_setget_called(TestNode, "typed_setter", "set_typed_setter")
		assert_pass(gr.test_with_gut)


class TestAssertProperty:
	extends BaseTestClass


	const TestNode = preload("res://test/resources/test_assert_setget_test_objects/test_node.gd")
	const TestScene = preload("res://test/resources/test_assert_setget_test_objects/TestScene.tscn")


	func test_passes_has_assert_setget_method():
		assert_has_method(gr.test, "assert_property")


	func test_passes_if_given_input_is_valid():
		gr.test_with_gut.assert_property(TestNode, "has_both", 4, 0)
		assert_pass(gr.test_with_gut, 6)


	func test_passes_if_instance_is_script():
		gr.test_with_gut.assert_property(TestNode, "has_both", 4, 0)
		assert_pass(gr.test_with_gut, 6)


	func test_passes_if_instance_is_packed_scene():
		var new_node_child_mock = TestNode.new()
		add_child_autofree(new_node_child_mock)
		gr.test_with_gut.assert_property(TestScene, "node_with_setter_getter", null, new_node_child_mock)
		assert_pass(gr.test_with_gut, 6)


	func test_passes_if_instance_is_obj_from_script():
		var node_child_mock = TestNode.new()
		add_child_autofree(node_child_mock)
		gr.test_with_gut.assert_property(node_child_mock, "has_both", 4, 5)
		assert_pass(gr.test_with_gut, 6)


	func test_passes_if_instance_is_obj_from_packed_scene():
		var scene_mock = TestScene.instance()
		add_child_autoqfree(scene_mock)
		var dflt_node_with_setter = scene_mock.get_node_with_setter_getter()
		var new_node_child_mock = TestNode.new()
		add_child_autofree(new_node_child_mock)
		gr.test_with_gut.assert_property(scene_mock, "node_with_setter_getter", dflt_node_with_setter, new_node_child_mock)
		assert_pass(gr.test_with_gut, 6)


	func test_fails_if_getter_does_not_exist():
		var test_node = TestNode.new()
		gr.test_with_gut.assert_property(test_node, 'has_setter', 2, 0)
		assert_fail_pass(gr.test_with_gut, 3, 1)

	func test_fails_if_obj_is_something_unexpected():
		var instance = Directory.new()
		gr.test_with_gut.assert_property(instance, "current_dir", "", "new_dir")
		assert_fail_pass(gr.test_with_gut, 3, 1)

	func test_other_fails_do_not_cause_false_negatrive():
		gr.test_with_gut.fail_test('fail')
		gr.test_with_gut.assert_property(TestNode, "has_both", 4, 0)
		assert_fail_pass(gr.test_with_gut, 1, 6)


class TestAssertSetGet:
	extends BaseTestClass

	const TestNode = preload("res://test/resources/test_assert_setget_test_objects/test_node.gd")

	func test_can_use_with_getter_only_name():
		gr.test_with_gut.assert_setget(TestNode, 'non_default_getter', null, '__get_non_default_getter')
		assert_pass(gr.test_with_gut)

	func test_can_use_with_setter_only_name():
		gr.test_with_gut.assert_setget(TestNode, 'non_default_setter', '__set_non_default_setter')
		assert_pass(gr.test_with_gut)

	func test_can_use_with_setter_only():
		gr.test_with_gut.assert_setget(TestNode, 'has_setter', SETTER_ONLY)
		assert_pass(gr.test_with_gut)

	func test_can_use_with_getter_only():
		gr.test_with_gut.assert_setget(TestNode, 'has_getter', GETTER_ONLY)
		assert_pass(gr.test_with_gut)

	func test_works_with_defaults():
		gr.test_with_gut.assert_setget(TestNode, 'has_both')
		assert_pass(gr.test_with_gut)

	func test_works_with_non_default_accessors_for_both():
		gr.test_with_gut.assert_setget(TestNode, 'non_default_both', '__set_default_both', '__get_default_both')
		assert_pass(gr.test_with_gut)

	func test_fails_with_defaults_and_no_getter():
		gr.test_with_gut.assert_setget(TestNode, 'has_setter')
		assert_fail(gr.test_with_gut)

	func test_fails_with_defaults_and_no_setter():
		gr.test_with_gut.assert_setget(TestNode, 'has_getter')
		assert_fail(gr.test_with_gut)

	func test_fails_with_no_setter_getter():
		gr.test_with_gut.assert_setget(TestNode, 'no_setget')
		assert_fail(gr.test_with_gut)

	func test_fails_when_property_does_not_exist():
		gr.test_with_gut.assert_setget(TestNode, '__dne__')
		assert_fail(gr.test_with_gut)

	func test_fails_when_all_exist_but_setget_not_used():
		gr.test_with_gut.assert_setget(TestNode, 'has_both_dnu_setget')
		assert_fail(gr.test_with_gut)
