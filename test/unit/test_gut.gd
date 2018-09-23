# ------------------------------------------------------------------------------
# Test the Gut object.
# ------------------------------------------------------------------------------
extends "res://addons/gut/test.gd"

var Gut = load('res://addons/gut/gut.gd')
var Test = load('res://addons/gut/test.gd')

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
class HasPhysicsProcessMethod:
	extends Node
	var physics_process_called_count = 0
	var delta_sum = 0.0

	func _physics_process(delta):
		physics_process_called_count += 1
		delta_sum += delta

#------------------------------
# Utility methods/variables
#------------------------------
# When these tests are ran in the context of other tests then the setup and
# teardown counts can get out of whack which causes the last test in here
# to fail.  These counts are used to adjust the values tested against.
var starting_counts = {
	setup_count = 0,
	teardown_count = 0
}

var counts = {
	setup_count = 0,
	teardown_count = 0,
	prerun_setup_count = 0,
	postrun_teardown_count = 0
}

# GlobalReset(gr) variables to be used by tests.
# The values of these are reset in the setup or
# teardown methods.
var gr = {
	test_gut = null,
	test_finished_called = false,
	signal_object = null,
	test = null
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
	assert_eq(gr.test.get_fail_count(), count, 'failures:  ' + msg)
	if(gr.test.get_fail_count() != count):
		print_test_gut_info()

# convinience method to assert the number of passes on the gr.test_gut object.
func assert_pass(count=1, msg=''):
	assert_eq(gr.test.get_pass_count(), count, 'passes:  ' + msg)
	if(gr.test.get_pass_count() != count):
		print_test_gut_info()


# ------------------------------
# Setup/Teardown
# ------------------------------
func prerun_setup():
	starting_counts.setup_count = gut.get_test_count()
	starting_counts.teardown_count = gut.get_test_count()
	counts.prerun_setup_count += 1

func setup():
	counts.setup_count += 1
	gr.test_finished_called = false
	gr.test_gut = get_a_gut()
	#gr.signal_object = SignalObject.new()
	gr.test = Test.new()
	gr.test.gut = gr.test_gut

func teardown():
	counts.teardown_count += 1
	gr.test_gut.queue_free()

func postrun_teardown():
	counts.postrun_teardown_count += 1
	#can't verify that this ran, so do an assert.
	#Asserts in any of the setup/teardown methods
	#is a bad idea in general.
	assert_true(true, 'POSTTEARDOWN RAN')
	gut.directory_delete_files('user://')

# ------------------------------
# Settings
# ------------------------------
func test_get_set_ingore_pauses():
	assert_accessors(gr.test_gut, 'ignore_pause_before_teardown', false, true)

func test_when_ignore_pauses_set_it_checks_checkbox():
	gr.test_gut.set_ignore_pause_before_teardown(true)
	assert_true(gr.test_gut._ctrls.ignore_continue_checkbox.is_pressed())

func test_when_ignore_pauses_unset_it_unchecks_checkbox():
	gr.test_gut.set_ignore_pause_before_teardown(true)
	gr.test_gut.set_ignore_pause_before_teardown(false)
	assert_false(gr.test_gut._ctrls.ignore_continue_checkbox.is_pressed())

func test_get_current_script_object_returns_null_by_default():
	assert_eq(gr.test_gut.get_current_script_object(), null)
	# I don't know how to test this in other situations

func test_get_set_temp_directory():
	assert_accessors(gr.test_gut, 'temp_directory', 'user://gut_temp_directory', 'user://blahblah')

# ------------------------------
# disable strict datatype comparisons
# ------------------------------
func test_when_strict_enabled_you_can_compare_int_and_float():
	gr.test.assert_eq(1.0, 1)
	assert_pass()

func test_when_strict_disabled_can_compare_int_and_float():
	gr.test_gut.disable_strict_datatype_checks(true)
	gr.test.assert_eq(1.0, 1)
	assert_pass()

# ------------------------------
# File utilities
# ------------------------------
func test_file_touch_creates_file():
	var path = 'user://gut_test_touch.txt'
	gut.file_touch(path)
	gr.test.assert_file_exists(path)
	assert_pass()

func test_file_delete_kills_file():
	var path = 'user://gut_test_file_delete.txt'
	gr.test_gut.file_touch(path)
	gr.test_gut.file_delete(path)
	gr.test.assert_file_does_not_exist(path)
	assert_pass()

func test_delete_all_files_in_a_directory():
	var path = 'user://gut_dir_tests'
	var d = Directory.new()
	d.open('user://')
	str(d.make_dir('gut_dir_tests'))

	gr.test_gut.file_touch(path + '/helloworld.txt')
	gr.test_gut.file_touch(path + '/file2.txt')
	gr.test_gut.directory_delete_files(path)
	gr.test.assert_file_does_not_exist(path + '/helloworld.txt')
	gr.test.assert_file_does_not_exist(path + '/file2.txt')

	assert_pass(2, 'both files should not exist')

# ------------------------------
# Misc tests
# ------------------------------
func test_simulate_calls_process():
	var obj = HasProcessMethod.new()
	gr.test_gut.simulate(obj, 10, .1)
	gr.test.assert_eq(obj.process_called_count, 10, "_process should have been called 10 times")
	#using just the numbers didn't work, nor using float.  str worked for some reason and
	#i'm not sure why.
	gr.test.assert_eq(str(obj.delta_sum), str(1), "The delta value should have been passed in and summed")
	assert_pass(2)

func test_simulate_calls_process_on_child_objects():
	var parent = HasProcessMethod.new()
	var child = HasProcessMethod.new()
	parent.add_child(child)
	gr.test_gut.simulate(parent, 10, .1)
	gr.test.assert_eq(child.process_called_count, 10, "_process should have been called on the child object too")
	assert_pass()

func test_simulate_calls_process_on_child_objects_of_child_objects():
	var objs = []
	for i in range(5):
		objs.append(HasProcessMethod.new())
		if(i > 0):
			objs[i - 1].add_child(objs[i])
	gr.test_gut.simulate(objs[0], 10, .1)

	for i in range(objs.size()):
		gr.test.assert_eq(objs[i].process_called_count, 10, "_process should have been called on object # " + str(i))

	assert_pass(objs.size())

func test_simulate_calls_physics_process():
	var obj = HasPhysicsProcessMethod.new()
	gr.test_gut.simulate(obj, 10, .1)
	gr.test.assert_eq(obj.physics_process_called_count, 10, "_process should have been called 10 times")
	#using just the numbers didn't work, nor using float.  str worked for some reason and
	#i'm not sure why.
	gr.test.assert_eq(str(obj.delta_sum), str(1), "The delta value should have been passed in and summed")
	assert_pass(2)


# ------------------------------
# Setting test to run
# ------------------------------
const SAMPLES_DIR = 'res://test/samples/'
func test_get_set_test_to_run():
	gr.test.assert_accessors(gr.test_gut, 'unit_test_name', '', 'hello')
	assert_pass(4)

func test_setting_name_will_run_only_matching_tests():
	gr.test_gut.add_script(SAMPLES_DIR + 'test_sample_all_passed.gd')
	gr.test_gut.set_unit_test_name('test_works')
	gr.test_gut.test_scripts()
	assert_eq(gr.test_gut.get_test_count(), 1)

func test_setting_name_matches_partial():
	gr.test_gut.add_script(SAMPLES_DIR + 'test_sample_all_passed.gd')
	gr.test_gut.set_unit_test_name('two')
	gr.test_gut.test_scripts()
	assert_eq(gr.test_gut.get_test_count(), 1)

# These should all pass, just making sure there aren't any syntax errors.
func test_asserts_on_test_object():
	pending('This really is not pending')
	assert_eq(1, 1, 'text')
	assert_ne(1, 2, 'text')
	assert_almost_eq(5, 5, 0, 'text')
	assert_almost_ne(5, 6, 0, 'text')
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

	path = 'user://gut_test_empty.txt'
	f = File.new()
	f.open(path, f.WRITE)
	f.close()
	assert_file_empty(path)

	path = 'user://gut_test_not_empty3.txt'
	f = File.new()
	f.open(path, f.WRITE)
	f.store_8(1)
	f.close()
	assert_file_not_empty(path)

func test_gut_clears_test_instances_between_runs():
	gr.test_gut.add_script(SAMPLES_DIR + 'test_sample_all_passed.gd')
	gr.test_gut.test_scripts()
	gr.test_gut.test_scripts()
	assert_eq(gr.test_gut._test_script_objects.size(), 1, 'The should only be one test script after a second run')


# ------------------------------
# Signal tests
# ------------------------------
func test_when_moving_to_next_test_watched_signals_are_cleared():
	gr.test_gut.add_script('res://test/unit/verify_signal_watches_are_cleared.gd')
	gr.test_gut.test_scripts()
	assert_eq(gr.test_gut.get_pass_count(), 1, 'One test should have passed.')
	assert_eq(gr.test_gut.get_fail_count(), 1, 'One failure for not watching anymore.')

# ------------------------------
# Inner Class
# ------------------------------
func test_can_get_set_inner_class_name():
	assert_accessors(gr.test_gut, 'inner_class_name', null, 'something')

func test_assert_exports_inner_class_name():
	assert_exports(gr.test_gut, '_inner_class_name', TYPE_STRING)

func test_when_set_only_inner_class_tests_run():
	gr.test_gut.set_inner_class_name('TestClass1')
	gr.test_gut.add_script('res://test/parsing_and_loading_samples/has_inner_class.gd')
	gr.test_gut.test_scripts()
	assert_eq(gr.test_gut.get_summary().get_totals().tests, 2)

# ------------------------------------------------------------------------------
#
#
# This must be the LAST test
#
#
# ------------------------------------------------------------------------------
func test_verify_results():
	gut.p("/*THESE SHOULD ALL PASS, IF NOT THEN SOMETHING IS BROKEN*/")
	gut.p("/*These counts will be off if another script was run before this one.*/")
	assert_eq(1, counts.prerun_setup_count, "Prerun setup should have been called once")
	assert_eq(gut.get_test_count() - starting_counts.setup_count, counts.setup_count, "Setup should have been called once for each test")
	# teardown for this test hasn't been run yet.
	assert_eq(gut.get_test_count() -1 - starting_counts.teardown_count, counts.teardown_count, "Teardown should have been called one less time.")
