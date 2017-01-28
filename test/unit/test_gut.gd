extends "res://addons/gut/test.gd"

var Gut = load('res://addons/Gut/gut.gd')
#--------------------------------------
#Used to test calling the _process method
#on an object through gut
#--------------------------------------
class HasProcessMethod:
	extends Node
	var process_called_count = 0
	var delta_sum = 0.0

	func _process(delta):
		process_called_count += 1
		delta_sum += delta

#--------------------------------------
#Used to test calling the _fixed_process
#method on an object through gut
#--------------------------------------
class HasFixedProcessMethod:
	extends Node
	var fixed_process_called_count = 0
	var delta_sum = 0.0

	func _fixed_process(delta):
		fixed_process_called_count += 1
		delta_sum += delta

#--------------------------------------
# Classes used to set get/set assert
#--------------------------------------
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


#------------------------------
# Utility methods/variables
#------------------------------
var counts = {
	setup_count = 0,
	teardown_count = 0,
	prerun_setup_count = 0,
	postrun_teardown_count = 0,
}

# GlobalReset(gr) variables to be used by tests.
# The values of these are reset in the setup or
# teardown methods.
var gr = {
	test_gut = null,
	test_finished_called = false
}

func callback_for_test_finished():
	gr.test_finished_called = true

# Returns a new gut object, all setup for testing.
func get_a_gut():
	var g = Gut.new()
	g.set_yield_between_tests(false)
	g.set_log_level(g.LOG_LEVEL_ALL_ASSERTS)
	add_child(g)
	return g

# Prints out gr.test_gut assert results, used by assert_fail and assert_pass
func print_test_gut_info():
	var text_array = gr.test_gut._log_text.split("\n")
	gut.p('Results of gr.test_gut asserts')
	gut.p('------------------------------')
	for i in range(text_array.size()):
		gut.p(text_array[i])

# convinience method to assert the number of failures on the gr.test_gut object.
func assert_fail(count=1, msg=''):
	gut.assert_eq(gr.test_gut.get_fail_count(), count, 'failures:  ' + msg)
	if(gr.test_gut.get_fail_count() != count):
		print_test_gut_info()

# convinience method to assert the number of passes on the gr.test_gut object.
func assert_pass(count=1, msg=''):
	gut.assert_eq(gr.test_gut.get_pass_count(), count, 'passes:  ' + msg)
	if(gr.test_gut.get_pass_count() != count):
		print_test_gut_info()

#------------------------------
# Setup/Teardown
#------------------------------
func setup():
	counts.setup_count += 1
	gr.test_finished_called = false
	gr.test_gut = get_a_gut()

func teardown():
	counts.teardown_count += 1
	gr.test_gut.queue_free()

func prerun_setup():
	counts.prerun_setup_count += 1

func postrun_teardown():
	counts.postrun_teardown_count += 1
	#can't verify that this ran, so do an assert.
	#Asserts in any of the setup/teardown methods
	#is a bad idea in general.
	gut.assert_true(true, 'POSTTEARDOWN RAN')
	gut.directory_delete_files('user://')

#------------------------------
# Settings
#------------------------------
func test_get_set_ingore_pauses():
	assert_get_set_methods(gr.test_gut, 'ignore_pause_before_teardown', false, true)

func test_when_ignore_pauses_set_it_checks_checkbox():
	gr.test_gut.set_ignore_pause_before_teardown(true)
	assert_true(gr.test_gut._ctrls.ignore_continue_checkbox.is_pressed())

func test_when_ignore_pauses_unset_it_unchecks_checkbox():
	gr.test_gut.set_ignore_pause_before_teardown(true)
	gr.test_gut.set_ignore_pause_before_teardown(false)
	assert_false(gr.test_gut._ctrls.ignore_continue_checkbox.is_pressed())

#------------------------------
#Number tests
#------------------------------

func test_assert_eq_number_not_equal():
	gr.test_gut.assert_eq(1, 2)
	assert_fail(1, "Should fail.  1 != 2")

func test_assert_eq_number_equal():
	gr.test_gut.assert_eq('asdf', 'asdf')
	assert_pass(1, "Should pass")

func test_assert_ne_number_not_equal():
	gr.test_gut.assert_ne(1, 2)
	assert_pass(1, "Should pass, 1 != 2")

func test_assert_ne_number_equal():
	gr.test_gut.assert_ne(1, 1, "Should fail")
	assert_fail(1, '1 = 1')

func test_assert_gt_number_with_gt():
	gr.test_gut.assert_gt(2, 1, "Should Pass")
	assert_pass(1, '2 > 1')

func test_assert_gt_number_with_lt():
	gr.test_gut.assert_gt(1, 2, "Should fail")
	assert_fail(1, '1 < 2')

func test_assert_lt_number_with_lt():
	gr.test_gut.assert_lt(1, 2, "Should Pass")
	assert_pass(1, '1 < 2')

func test_assert_lt_number_with_gt():
	gr.test_gut.assert_lt(2, 1, "Should fail")
	assert_fail(1, '2 > 1')

func test_between_with_number_between():
	gr.test_gut.assert_between(2, 1, 3, "Should pass, 2 between 1 and 3")
	assert_pass(1, "Should pass, 2 between 1 and 3")

func test_between_with_number_lt():
	gr.test_gut.assert_between(0, 1, 3, "Should fail")
	assert_fail(1, '0 not between 1 and 3')

func test_between_with_number_gt():
	gr.test_gut.assert_between(4, 1, 3, "Should fail")
	assert_fail(1, '4 not between 1 and 3')

func test_between_with_number_at_high_end():
	gr.test_gut.assert_between(3, 1, 3, "Should pass")
	assert_pass(1, '3 is between 1 and 3')

func test_between_with_number_at_low_end():
	gr.test_gut.assert_between(1, 1, 3, "Should pass")
	assert_pass(1, '1 between 1 and 3')

func test_between_with_invalid_number_range():
	gr.test_gut.assert_between(4, 8, 0, "Should fail")
	assert_fail(1, '8 is starting number and is not less than 0')

#------------------------------
# float tests
#------------------------------
func test_float_eq():
	gr.test_gut.assert_eq(1.0, 1.0)
	assert_pass(1)

func test_float_eq_fail():
	gr.test_gut.assert_eq(.19, 1.9)
	assert_fail(1)

func test_float_ne():
	gr.test_gut.assert_ne(0.9, .009)
	assert_pass(1)

func test_cast_float_eq_pass():
	gr.test_gut.assert_eq(float('0.92'), 0.92)
	assert_pass(1)

func test_fail_compare_float_cast_as_int():
	# int cast will make it 0
	gr.test_gut.assert_eq(int(0.5), 0.5)
	assert_fail(1)

func test_cast_int_math_eq_float():
	var i = 2
	gr.test_gut.assert_eq(5 / float(i), 2.5)
	assert_pass(1)

#------------------------------
#string tests
#------------------------------

func test_assert_eq_string_not_equal():
	gr.test_gut.assert_eq("one", "two", "Should Fail")
	assert_fail()

func test_assert_eq_string_equal():
	gr.test_gut.assert_eq("one", "one", "Should Pass")
	assert_pass()

func test_assert_ne_string_not_equal():
	gr.test_gut.assert_ne("one", "two", "Should Pass")
	assert_pass()

func test_assert_ne_string_equal():
	gr.test_gut.assert_ne("one", "one", "Should Fail")
	assert_fail()

func test_assert_gt_string_with_gt():
	gr.test_gut.assert_gt("b", "a", "Should Pass")
	assert_pass()

func test_assert_gt_string_with_lt():
	gr.test_gut.assert_gt("a", "b", "Sould Fail")
	assert_fail()

func test_assert_lt_string_with_lt():
	gr.test_gut.assert_lt("a", "b", "Should Pass")
	assert_pass()

func test_assert_lt_string_with_gt():
	gr.test_gut.assert_lt("b", "a", "Should Fail")
	assert_fail()

func test_between_with_string_between():
	gr.test_gut.assert_between('b', 'a', 'c', "Should pass, 2 between 1 and 3")
	assert_pass()

func test_between_with_string_lt():
	gr.test_gut.assert_between('a', 'b', 'd', "Should fail")
	assert_fail()

func test_between_with_string_gt():
	gr.test_gut.assert_between('z', 'a', 'c', "Should fail")
	assert_fail()

func test_between_with_string_at_high_end():
	gr.test_gut.assert_between('c', 'a', 'c', "Should pass")
	assert_pass()

func test_between_with_string_at_low_end():
	gr.test_gut.assert_between('a', 'a', 'c', "Should pass")
	assert_pass()

func test_between_with_invalid_string_range():
	gr.test_gut.assert_between('q', 'z', 'a', "Should fail")
	assert_fail()
#------------------------------
#boolean tests
#------------------------------
func test_assert_true_with_true():
	gr.test_gut.assert_true(true, "Should pass, true is true")
	assert_pass()

func test_assert_true_with_false():
	gr.test_gut.assert_true(false, "Should fail")
	assert_fail()

func test_assert_flase_with_true():
	gr.test_gut.assert_false(true, "Should fail")
	assert_fail()

func test_assert_false_with_false():
	gr.test_gut.assert_false(false, "Should pass")
	assert_pass()

#------------------------------
# disable strict datatype comparisons
#------------------------------
func test_when_strict_enabled_you_can_compare_int_and_float():
	gr.test_gut.assert_eq(1.0, 1)
	assert_pass()

func test_when_strict_disabled_can_compare_int_and_float():
	gr.test_gut.disable_strict_datatype_checks(true)
	gr.test_gut.assert_eq(1.0, 1)
	assert_pass()


#------------------------------
# File asserts
#------------------------------
func test_assert_file_exists_with_file_dne():
	gr.test_gut.assert_file_exists('user://file_dne.txt')
	assert_fail()

func test_assert_file_exists_with_file_exists():
	var path = 'user://gut_test_file.txt'
	var f = File.new()
	f.open(path, f.WRITE)
	f.close()
	gr.test_gut.assert_file_exists(path)
	assert_pass()

func test_assert_file_dne_with_file_dne():
	gr.test_gut.assert_file_does_not_exist('user://file_dne.txt')
	assert_pass()

func test_assert_file_dne_with_file_exists():
	var path = 'user://gut_test_file2.txt'
	var f = File.new()
	f.open(path, f.WRITE)
	f.close()
	gr.test_gut.assert_file_does_not_exist(path)
	assert_fail()

func test_assert_file_empty_with_empty_file():
	var path = 'user://gut_test_empty.txt'
	var f = File.new()
	f.open(path, f.WRITE)
	f.close()
	gr.test_gut.assert_file_empty(path)
	assert_pass()

func test_assert_file_empty_with_not_empty_file():
	var path = 'user://gut_test_empty2.txt'
	var f = File.new()
	f.open(path, f.WRITE)
	f.store_8(1)
	f.close()
	gr.test_gut.assert_file_empty(path)
	assert_fail()

func test_assert_file_empty_fails_when_file_dne():
	var path = 'user://file_dne.txt'
	gr.test_gut.assert_file_empty(path)
	assert_fail()

func test_assert_file_not_empty_with_empty_file():
	var path = 'user://gut_test_empty3.txt'
	var f = File.new()
	f.open(path, f.WRITE)
	f.close()
	gr.test_gut.assert_file_not_empty(path)
	assert_fail()

func test_assert_file_not_empty_with_populated_file():
	var path = 'user://gut_test_empty4.txt'
	var f = File.new()
	f.open(path, f.WRITE)
	f.store_8(1)
	f.close()
	gr.test_gut.assert_file_not_empty(path)
	assert_pass()

func test_assert_file_not_empty_fails_when_file_dne():
	var path = 'user://file_dne.txt'
	gr.test_gut.assert_file_not_empty(path)
	assert_fail()

#------------------------------
# File utilities
#------------------------------
func test_file_touch_creates_file():
	var path = 'user://gut_test_touch.txt'
	gut.file_touch(path)
	gr.test_gut.assert_file_exists(path)
	assert_pass()


func test_file_delete_kills_file():
	var path = 'user://gut_test_file_delete.txt'
	gr.test_gut.file_touch(path)
	gr.test_gut.file_delete(path)
	gr.test_gut.assert_file_does_not_exist(path)
	assert_pass()

func test_delete_all_files_in_a_directory():
	var path = 'user://gut_dir_tests'
	var d = Directory.new()
	d.open('user://')
	str(d.make_dir('gut_dir_tests'))

	gr.test_gut.file_touch(path + '/helloworld.txt')
	gr.test_gut.file_touch(path + '/file2.txt')
	gr.test_gut.directory_delete_files(path)
	gr.test_gut.assert_file_does_not_exist(path + '/helloworld.txt')
	gr.test_gut.assert_file_does_not_exist(path + '/file2.txt')

	assert_pass(2, 'both files should not exist')

#------------------------------
# Datatype comparison fail.
#------------------------------
func test_dt_string_number_eq():
	gr.test_gut.assert_eq('1', 1)
	assert_fail(1)

func test_dt_string_number_ne():
	gr.test_gut.assert_ne('2', 1)
	assert_fail(1)

func test_dt_string_number_assert_gt():
	gr.test_gut.assert_gt('3', 1)
	assert_fail(1)

func test_dt_string_number_func_assert_lt():
	gr.test_gut.assert_lt('1', 3)
	assert_fail(1)

func test_dt_string_number_func_assert_between():
	gr.test_gut.assert_between('a', 5, 6)
	gr.test_gut.assert_between(1, 2, 'c')
	assert_fail(2)

func test_dt_can_compare_to_null():
	gr.test_gut.assert_ne(HasFixedProcessMethod.new(), null)
	gr.test_gut.assert_ne(null, HasFixedProcessMethod.new())
	assert_pass(2)

#------------------------------
#Misc tests
#------------------------------
func test_can_call_eq_without_text():
	gr.test_gut.assert_eq(1, 1)
	assert_pass()

func test_can_call_ne_without_text():
	gr.test_gut.assert_ne(1, 2)
	assert_pass()

func test_can_call_true_without_text():
	gr.test_gut.assert_true(true)
	assert_pass()

func test_can_call_false_without_text():
	gr.test_gut.assert_false(false)
	assert_pass()

func test_script_object_added_to_tree():
	gr.test_gut.assert_ne(get_tree(), null, "The tree should not be null if we are added to it")
	assert_pass()

func test_pending_increments_pending_count():
	gr.test_gut.pending()
	gut.assert_eq(gr.test_gut.get_pending_count(), 1, 'One test should have been marked as pending')

func test_pending_accepts_text():
	gut.pending("This is a pending test.  You should see this text in the results.")

func test_simulate_calls_process():
	var obj = HasProcessMethod.new()
	gr.test_gut.simulate(obj, 10, .1)
	gr.test_gut.assert_eq(obj.process_called_count, 10, "_process should have been called 10 times")
	#using just the numbers didn't work, nor using float.  str worked for some reason and
	#i'm not sure why.
	gr.test_gut.assert_eq(str(obj.delta_sum), str(1), "The delta value should have been passed in and summed")
	assert_pass(2)

func test_simulate_calls_process_on_child_objects():
	var parent = HasProcessMethod.new()
	var child = HasProcessMethod.new()
	parent.add_child(child)
	gr.test_gut.simulate(parent, 10, .1)
	gr.test_gut.assert_eq(child.process_called_count, 10, "_process should have been called on the child object too")
	assert_pass()

func test_simulate_calls_process_on_child_objects_of_child_objects():
	var objs = []
	for i in range(5):
		objs.append(HasProcessMethod.new())
		if(i > 0):
			objs[i - 1].add_child(objs[i])
	gr.test_gut.simulate(objs[0], 10, .1)

	for i in range(objs.size()):
		gr.test_gut.assert_eq(objs[i].process_called_count, 10, "_process should have been called on object # " + str(i))

	assert_pass(objs.size())

func test_simulate_calls_fixed_process():
	var obj = HasFixedProcessMethod.new()
	gr.test_gut.simulate(obj, 10, .1)
	gr.test_gut.assert_eq(obj.fixed_process_called_count, 10, "_process should have been called 10 times")
	#using just the numbers didn't work, nor using float.  str worked for some reason and
	#i'm not sure why.
	gr.test_gut.assert_eq(str(obj.delta_sum), str(1), "The delta value should have been passed in and summed")
	assert_pass(2)
#------------------------------
# Get/Set Assert
#------------------------------
func test_fail_if_get_set_not_defined():
	var obj = NoGetNoSet.new()
	gr.test_gut.assert_get_set_methods(obj, 'thing', 'something', 'another thing')
	assert_fail(2)

func test_fail_if_has_get_and_not_set():
	var obj = HasGetNotSet.new()
	gr.test_gut.assert_get_set_methods(obj, 'thing', 'something', 'another thing')
	assert_fail()

func test_fail_if_default_wrong_and_get_dont_work():
	var obj = HasGetAndSetThatDontWork.new()
	gr.test_gut.assert_get_set_methods(obj, 'thing', 'something', 'another thing')
	assert_fail(2)

func test_fail_if_default_wrong():
	var obj = HasGetSetThatWorks.new()
	gr.test_gut.assert_get_set_methods(obj, 'thing', 'not the right default', 'another thing')
	assert_fail()

func test_pass_if_all_get_sets_are_aligned():
	var obj = HasGetSetThatWorks.new()
	gr.test_gut.assert_get_set_methods(obj, 'thing', 'something', 'another thing')
	assert_pass(4)
#------------------------------
# Setting test to run
#------------------------------
func test_get_set_test_to_run():
	gr.test_gut.assert_get_set_methods(gr.test_gut, 'unit_test_name', '', 'hello')
	assert_pass(4)

func test_setting_name_will_run_only_matching_tests():
	gr.test_gut.add_script('res://test/unit/test_sample_all_passed.gd')
	gr.test_gut.set_unit_test_name('test_works')
	gr.test_gut.test_scripts()
	gut.assert_eq(gr.test_gut.get_test_count(), 1)

func test_setting_name_matches_partial():
	gr.test_gut.add_script('res://test/unit/test_sample_all_passed.gd')
	gr.test_gut.set_unit_test_name('two')
	gr.test_gut.test_scripts()
	gut.assert_eq(gr.test_gut.get_test_count(), 1)

# These should all pass, just making sure there aren't any syntax errors.
func test_asserts_on_test_object():
	pending('This really is not pending')
	assert_eq(1, 1, 'text')
	assert_ne(1, 2, 'text')
	assert_gt(10, 5, 'text')
	assert_lt(1, 2, 'text')
	assert_true(true, 'text')
	assert_false(false, 'text')
	assert_between(5, 1, 10, 'text')
	assert_file_does_not_exist('res://doesnotexist')

	var path = 'user://gut_test_file.txt'
	var f = File.new()
	f.open(path, f.WRITE)
	f.close()
	assert_file_exists(path)


	var path = 'user://gut_test_empty.txt'
	var f = File.new()
	f.open(path, f.WRITE)
	f.close()
	assert_file_empty(path)

	var path = 'user://gut_test_not_empty3.txt'
	var f = File.new()
	f.open(path, f.WRITE)
	f.store_8(1)
	f.close()
	assert_file_not_empty(path)

	var obj = HasGetSetThatWorks.new()
	assert_get_set_methods(obj, 'thing', 'something', 'another thing')

#-------------------------------------------------------------------------------
#
#
# This must be LAST test
#
#
#-------------------------------------------------------------------------------
func test_verify_results():
	gut.p("/*THESE SHOULD ALL PASS, IF NOT THEN SOMETHING IS BROKEN*/")
	gut.p("/*These counts will be off if another script was run before this one.*/")
	gut.assert_eq(1, counts.prerun_setup_count, "Prerun setup should have been called once")
	gut.assert_eq(gut.get_test_count(), counts.setup_count, "Setup should have been called once for each test")
	# teardown for this test hasn't been run yet.
	gut.assert_eq(gut.get_test_count() -1, counts.teardown_count, "Teardown should have been called one less time.")
