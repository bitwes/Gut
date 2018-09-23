# ------------------------------------------------------------------------------
# Tests test.gd.  test.gd contains all the asserts is the class that all
# test scripts inherit from.
#
# NOTE on naming tests.  Most of these tests were made before Inner Test Classes
# were supported.  To that end a lot of tests should be renamed.  All new tests
# should be in an Inner Test Class and follow a convention similar to:
#   * test_passes_when...
#   * test_passes_if...
#   * test_fails_when...
#   * etc
# ------------------------------------------------------------------------------
extends "res://addons/gut/test.gd"

class BaseTestClass:
	extends "res://addons/gut/test.gd"

	var Gut = load('res://addons/gut/gut.gd')
	var Test = load('res://addons/gut/test.gd')
	# !! Use this for debugging to see the results of all the subtests that
	# are run using assert_fail_pass, assert_fail and assert_pass that are
	# built into this class
	var _print_all_subtests = false

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

	# convinience method to assert the number of failures on the gr.test_gut object.
	func assert_fail(t, count=1, msg=''):
		var self_fail_count = get_fail_count()
		assert_eq(t.get_fail_count(), count, 'Bad FAIL COUNT:  ' + msg)
		if(t.get_pass_count() > 0 and count != t.get_assert_count()):
			assert_eq(t.get_pass_count(), 0, 'When checking for failures there should be no passing')
		if(get_fail_count() != self_fail_count or _print_all_subtests):
			print_fail_pass_text(t)

	# convinience method to assert the number of passes on the gr.test_gut object.
	func assert_pass(t, count=1, msg=''):
		var self_fail_count = get_fail_count()
		assert_eq(t.get_pass_count(), count, 'Bad PASS COUNT:  ' + msg)
		if(t.get_fail_count() != 0 and count != t.get_assert_count()):
			assert_eq(t.get_fail_count(), 0, 'When checking for passes there should be no failures.')
		if(get_fail_count() != self_fail_count or _print_all_subtests):
			print_fail_pass_text(t)

	# #############
	# Seutp/Teardown
	# #############
	func setup():
		gr.test = Test.new()
		gr.test_with_gut = Test.new()
		gr.test_with_gut.gut = Gut.new()

	func teardown():
		gr.test_with_gut.gut.get_doubler().clear_output_directory()
		gr.test_with_gut.gut.get_spy().clear()

		gr.test.free()
		gr.test = null
		gr.test_with_gut.free()

class TestMiscTests:
	extends BaseTestClass

	func test_script_object_added_to_tree():
		gr.test.assert_ne(get_tree(), null, "The tree should not be null if we are added to it")
		assert_pass(gr.test)

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

	func test_passes_when_cast_char_to_float():
		gr.test.assert_eq(float('0.92'), 0.92)
		assert_pass(gr.test, 1, 'I suspect this is failing due to an engine bug.')

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
		gr.test.assert_gt("a", "b", "Sould Fail")
		assert_fail(gr.test)

# TODO rename tests since they are now in an inner class.  See NOTE at top about naming.
class TestAssertLt:
	extends BaseTestClass

	func test_assert_lt_number_with_lt():
		gr.test.assert_lt(1, 2, "Should Pass")
		assert_pass(gr.test, 1, '1 < 2')

	func test_assert_lt_number_with_gt():
		gr.test.assert_lt(2, 1, "Should fail")
		assert_fail(gr.test, 1, '2 > 1')

	func test_assert_lt_string_with_lt():
		gr.test.assert_lt("a", "b", "Should Pass")
		assert_pass(gr.test)

	func test_assert_lt_string_with_gt():
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

# TODO rename tests since they are now in an inner class.  See NOTE at top about naming.
class TestAssertTrue:
	extends BaseTestClass

	func test_assert_true_with_true():
		gr.test.assert_true(true, "Should pass, true is true")
		assert_pass(gr.test)

	func test_assert_true_with_false():
		gr.test.assert_true(false, "Should fail")
		assert_fail(gr.test)

	func test_can_call_true_without_text():
		gr.test.assert_true(true)
		assert_pass(gr.test)

# TODO rename tests since they are now in an inner class.  See NOTE at top about naming.
class TestAssertFalse:
	extends BaseTestClass

	func test_can_call_false_without_text():
		gr.test.assert_false(false)
		assert_pass(gr.test)

	func test_assert_flase_with_true():
		gr.test.assert_false(true, "Should fail")
		assert_fail(gr.test)

	func test_assert_false_with_false():
		gr.test.assert_false(false, "Should pass")
		assert_pass(gr.test)

# TODO rename tests since they are now in an inner class.  See NOTE at top about naming.
class TestAssertHas:
	extends BaseTestClass

	func test_assert_has_passes_when_array_has_element():
		var array = [0]
		gr.test.assert_has(array, 0, 'It should have zero')
		assert_pass(gr.test)

	func test_assert_has_fails_when_it_does_not_have_element():
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

# TODO rename tests since they are now in an inner class.  See NOTE at top about naming.
class testFailingDatatypeChecks:
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

# TODO rename tests since they are now in an inner class.  See NOTE at top about naming.
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

	func setup():
		.setup()
		gr.signal_object = SignalObject.new()

	func teardown():
		.teardown()
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

	func test__assert_signal_emitted_with_paramters__fails_when_object_not_watched():
		gr.test.assert_signal_emitted_with_parameters(gr.signal_object, SIGNALS.SOME_SIGNAL, [])
		assert_fail(gr.test)

	func test__assert_signal_emitted_with_parameters__passes_when_paramters_match():
		gr.test.watch_signals(gr.signal_object)
		gr.signal_object.emit_signal(SIGNALS.SOME_SIGNAL, 1)
		gr.test.assert_signal_emitted_with_parameters(gr.signal_object, SIGNALS.SOME_SIGNAL, [1])
		assert_pass(gr.test)

	func test__assert_signal_emitted_with_parameters__passes_when_all_paramters_match():
		gr.test.watch_signals(gr.signal_object)
		gr.signal_object.emit_signal(SIGNALS.SOME_SIGNAL, 1, 2, 3)
		gr.test.assert_signal_emitted_with_parameters(gr.signal_object, SIGNALS.SOME_SIGNAL, [1, 2, 3])
		assert_pass(gr.test)

	func test__assert_signal_emitted_with_parameters__fails_when_signal_not_emitted():
		gr.test.watch_signals(gr.signal_object)
		gr.test.assert_signal_emitted_with_parameters(gr.signal_object, SIGNALS.SOME_SIGNAL, [2])
		assert_fail(gr.test)

	func test__assert_signal_emitted_with_parameters__fails_when_paramters_dont_match():
		gr.test.watch_signals(gr.signal_object)
		gr.signal_object.emit_signal(SIGNALS.SOME_SIGNAL, 1)
		gr.test.assert_signal_emitted_with_parameters(gr.signal_object, SIGNALS.SOME_SIGNAL, [2])
		assert_fail(gr.test)

	func test__assert_signal_emitted_with_parameters__fails_when_not_all_paramters_match():
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

# TODO rename tests since they are now in an inner class.  See NOTE at top about naming.
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

	func test__assert_extends__passes_when_class_extends_parent():
		var node2d = Node2D.new()
		gr.test.assert_extends(node2d, Node2D)
		assert_pass(gr.test)

	func test__assert_extends__fails_when_class_does_not_extend_parent():
		var lbl = Label.new()
		gr.test.assert_extends(lbl, TextEdit)
		assert_fail(gr.test)

	func test__assert_extends__fails_with_primitves_and_classes():
		gr.test.assert_extends([], Node2D)
		assert_fail(gr.test)

	func test__assert_extends__fails_when_compareing_object_to_primitives():
		gr.test.assert_extends(Node2D.new(), [])
		gr.test.assert_extends(TextEdit.new(), {})
		assert_fail(gr.test, 2)

	func test__assert_extends__fails_with_another_instance():
		var node1 = Node2D.new()
		var node2 = Node2D.new()
		gr.test.assert_extends(node1, node2)
		assert_fail(gr.test)

	func test__assert_extends__passes_with_deeper_inheritance():
		var eb = ExtendsBaseClass.new()
		gr.test.assert_extends(eb, Node2D)
		assert_pass(gr.test)

	func test__assert_extends__fails_when_class_names_match_but_inheritance_does_not():
		var a = HasSubclass1.SubClass.new()
		var b = HasSubclass2.SubClass.new()
		gr.test.assert_extends(a, b)
		assert_fail(gr.test)

	func test__assert_extends__fails_when_class_names_match_but_inheritance_does_not__with_class():
		var a = HasSubclass1.SubClass.new()
		gr.test.assert_extends(a, HasSubclass2.SubClass)
		assert_fail(gr.test)

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

	func test__assert_string_contains__passes_when_case_insensitve_search_is_found():
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

	const DOUBLE_ME_PATH = 'res://test/doubler_test_objects/double_me.gd'

	func test_assert_called_fails_with_message_if_non_doubled_passed():
		var obj = GDScript.new()
		gr.test_with_gut.gut.get_spy().add_call(obj, 'method')
		gr.test_with_gut.assert_called(obj, 'method1')
		gut.p('!! Check output !!')
		assert_fail(gr.test_with_gut)

	func test_assert_called_passes_when_call_occured():
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

class TestAssertNotCalled:
	extends BaseTestClass

	const DOUBLE_ME_PATH = 'res://test/doubler_test_objects/double_me.gd'

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

	const DOUBLE_ME_PATH = 'res://test/doubler_test_objects/double_me.gd'

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
