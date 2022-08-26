# ------------------------------------------------------------------------------
# Test the Gut object.
# ------------------------------------------------------------------------------
extends GutTest


class TestProperties:
	extends GutTest
	var Gut = load('res://addons/gut/gut.gd')
	var Test = load('res://addons/gut/test.gd')

	var _gut = null

	func before_each():
		_gut = autofree(Gut.new())

	var _backed_properties = ParameterFactory.named_parameters(
		['property_name', 'default', 'new_value'],
		[
			['disable_strict_datatype_checks', false, true],
			['log_level', 1, 3],
			['disable_strict_datatype_checks', false, true],
			['include_subdirectories', false, true],
			['double_strategy', 1, 2],
			['pre_run_script', '', 'res://something.gd'],
			['post_run_script', '', 'res://something_else.gd'],
			['color_output', false, true],
			['junit_xml_file', '', 'user://somewhere.json'],
			['junit_xml_timestamp', false, true],
			['export_path', '', 'res://somewhere/cool'],
			['color_output', false, true]
		])

	func test_check_backed_properties(p=use_parameters(_backed_properties)):
		assert_property_with_backing_variable(_gut, p.property_name, p.default, p.new_value)

	var _basic_properties = ParameterFactory.named_parameters(
		['property_name', 'default', 'new_value'],
		[
			['paint_after', .2, 1.5]
		])

	func test_basic_properties(p = use_parameters(_basic_properties)):
		assert_property(_gut, p.property_name, p.default, p.new_value)

	func test_add_children_to_backed_property():
		assert_property_with_backing_variable(_gut, 'add_children_to', _gut, self)

	func test_get_set_ingore_pauses():
		assert_accessors(_gut, 'ignore_pause_before_teardown', false, true)

	func test_get_current_script_object_returns_null_by_default():
		assert_eq(_gut.get_current_script_object(), null)
		# I don't know how to test this in other situations

	func test_get_set_temp_directory():
		assert_accessors(_gut, 'temp_directory', 'user://gut_temp_directory', 'user://blahblah')

	func test_get_set_parameter_handler():
		assert_accessors(_gut, 'parameter_handler', null, _utils.ParameterHandler.new([]))

	func test_get_set_junit_xml_file():
		assert_accessors(_gut, 'junit_xml_file', '', 'user://xml_file.xml')

	func test_get_set_junit_xml_timestamp():
		assert_accessors(_gut, 'junit_xml_timestamp', false, true)



class TestEverythingElse:
	extends GutTest

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
		g.log_level = g.LOG_LEVEL_ALL_ASSERTS
		return g

	# Prints out gr.test_gut assert results, used by assert_fail and assert_pass
	func print_test_gut_info():
		var text_array = gr.test_gut._log_text.split("\n")
		gut.p('Results of gr.test_gut asserts')
		gut.p('------------------------------')
		for i in range(text_array.size()):
			gut.p(text_array[i])

	# convenience method to assert the number of failures on the gr.test_gut object.
	func assert_fail(count=1, msg=''):
		assert_eq(gr.test.get_fail_count(), count, 'failures:  ' + msg)
		if(gr.test.get_fail_count() != count):
			print_test_gut_info()

	# convenience method to assert the number of passes on the gr.test_gut object.
	func assert_pass(count=1, msg=''):
		assert_eq(gr.test.get_pass_count(), count, 'passes:  ' + msg)
		if(gr.test.get_pass_count() != count):
			print_test_gut_info()

	# ------------------------------
	# Setup/Teardown
	# ------------------------------
	func before_all():
		_utils._test_mode = true
		starting_counts.setup_count = gut.get_test_count()
		starting_counts.teardown_count = gut.get_test_count()
		counts.prerun_setup_count += 1

	func before_each():
		counts.setup_count += 1
		gr.test_finished_called = false
		gr.test_gut = get_a_gut()
		add_child_autoqfree(gr.test_gut)
		gr.test = Test.new()
		gr.test.gut = gr.test_gut

	func after_each():
		counts.teardown_count += 1

	func after_all():
		counts.postrun_teardown_count += 1
		# can't verify that this ran, so do an assert.
		# Asserts in any of the setup/teardown methods
		# is a bad idea in general.
		assert_true(true, 'POSTTEARDOWN RAN')
		gut.directory_delete_files('user://')


	# ------------------------------
	# Doubler
	# ------------------------------
	func test_get_set_double_strategy():
		assert_accessors(gr.test_gut, 'double_strategy', 1, 2)

	func test_when_test_overrides_strategy_it_is_reset_after_test_finishes():
		gr.test_gut.set_double_strategy(_utils.DOUBLE_STRATEGY.PARTIAL)
		gr.test_gut.add_script('res://test/samples/test_before_after.gd')
		gr.test_gut.get_doubler().set_strategy(_utils.DOUBLE_STRATEGY.FULL)
		gr.test_gut.test_scripts()
		assert_eq(gr.test_gut.get_double_strategy(), _utils.DOUBLE_STRATEGY.PARTIAL)

	func test_clears_ignored_methods_between_tests():
		gr.test_gut.get_doubler().add_ignored_method('ignore_script', 'ignore_method')
		gr.test_gut.add_script('res://test/samples/test_sample_one.gd')
		gr.test_gut._tests_like = 'test_assert_eq_number_not_equal'
		gr.test_gut.test_scripts()
		assert_eq(gr.test_gut.get_doubler().get_ignored_methods().size(), 0)
		pause_before_teardown()


	# ------------------------------
	# disable strict datatype comparisons
	# ------------------------------
	func test_when_strict_enabled_you_can_compare_int_and_float():
		gr.test.assert_eq(1.0, 1)
		assert_pass()

	func test_when_strict_disabled_can_compare_int_and_float():
		gr.test_gut.disable_strict_datatype_checks = true
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
		var result = d.open('user://')
		if(result ==  OK):
			d.make_dir('gut_dir_tests')
			gr.test_gut.file_touch(path + '/helloworld.txt')
			gr.test_gut.file_touch(path + '/file2.txt')
			gr.test_gut.directory_delete_files(path)
			gr.test.assert_file_does_not_exist(path + '/helloworld.txt')
			gr.test.assert_file_does_not_exist(path + '/file2.txt')
			gut.directory_delete_files('user://gut_dir_tests')
			gut.file_delete('user://gut_dir_tests')

		assert_pass(2, 'both files should not exist')

	# ------------------------------
	# Misc tests
	# ------------------------------
	func test_gut_sets_self_on_logger():
		assert_eq(gr.test_gut.get_logger().get_gut(), gr.test_gut)

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
	# No Assert Warning
	# ------------------------------
	func test_when_a_test_has_no_asserts_a_warning_is_generated():
		gr.test_gut.add_script('res://test/resources/per_test_assert_tracking.gd')
		gr.test_gut.set_unit_test_name('test_no_asserts')
		gr.test_gut.test_scripts()
		assert_eq(gr.test_gut.get_logger().get_warnings().size(), 1)

	func test_with_passing_assert_no_assert_warning_is_not_generated():
		gr.test_gut.add_script('res://test/resources/per_test_assert_tracking.gd')
		gr.test_gut.set_unit_test_name('test_passing_assert')
		gr.test_gut.test_scripts()
		assert_eq(gr.test_gut.get_logger().get_warnings().size(), 0)

	func test_with_failing_assert_no_assert_warning_is_not_generated():
		gr.test_gut.add_script('res://test/resources/per_test_assert_tracking.gd')
		gr.test_gut.set_unit_test_name('test_failing_assert')
		gr.test_gut.test_scripts()
		assert_eq(gr.test_gut.get_logger().get_warnings().size(), 0)

	func test_with_pass_test_call_no_assert_warning_is_not_generated():
		gr.test_gut.add_script('res://test/resources/per_test_assert_tracking.gd')
		gr.test_gut.set_unit_test_name('test_use_pass_test')
		gr.test_gut.test_scripts()
		assert_eq(gr.test_gut.get_logger().get_warnings().size(), 0)

	func test_with_fail_test_call_no_assert_warning_is_not_generated():
		gr.test_gut.add_script('res://test/resources/per_test_assert_tracking.gd')
		gr.test_gut.set_unit_test_name('test_use_fail_test')
		gr.test_gut.test_scripts()
		assert_eq(gr.test_gut.get_logger().get_warnings().size(), 0)

	func test_with_pending_call_no_assert_warning_is_no_generated():
		gr.test_gut.add_script('res://test/resources/per_test_assert_tracking.gd')
		gr.test_gut.set_unit_test_name('test_use_pending')
		gr.test_gut.test_scripts()
		assert_eq(gr.test_gut.get_logger().get_warnings().size(), 0)


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
		pending('pending in 4.0')
		# gr.test_gut.add_script('res://test/unit/verify_signal_watches_are_cleared.gd')
		# gr.test_gut.test_scripts()
		# assert_eq(gr.test_gut.get_pass_count(), 1, 'One test should have passed.')
		# assert_eq(gr.test_gut.get_fail_count(), 1, 'One failure for not watching anymore.')

	# ------------------------------
	# Inner Class
	# ------------------------------
	func test_can_get_set_inner_class_name():
		assert_accessors(gr.test_gut, 'inner_class_name', '', 'something')

	func test_when_set_only_inner_class_tests_run():
		gr.test_gut.set_inner_class_name('TestClass1')
		gr.test_gut.add_script('res://test/resources/parsing_and_loading_samples/has_inner_class.gd')
		gr.test_gut.test_scripts()
		# count should be 4, 2 from TestClass1 and 2 from TestExtendsTestClass1
		# which extends TestClass1 so it gets its two tests as well.
		assert_eq(gr.test_gut.get_summary().get_totals().tests, 4)

	func test_when_script_has_const_that_starts_with_Test_it_ignores_it():
		gr.test_gut.add_script('res://test/resources/parsing_and_loading_samples/const_object.gd')
		pass_test('we got here')

	# ------------------------------
	# Setup/before and teardown/after
	# ------------------------------
	func test_after_running_script_everything_checks_out():
		gr.test_gut.add_script('res://test/samples/test_before_after.gd')
		gr.test_gut.test_scripts()
		var instantiate = gr.test_gut.get_current_script_object()
		assert_eq(instantiate.counts.before_all, 1, 'before_all')
		assert_eq(instantiate.counts.before_each, 3, 'before_each')
		assert_eq(instantiate.counts.after_all, 1, 'after_all')
		assert_eq(instantiate.counts.after_each, 3, 'after_each')

		assert_eq(instantiate.counts.prerun_setup, 1, 'prerun_setup')
		assert_eq(instantiate.counts.setup, 3, 'setup')
		assert_eq(instantiate.counts.postrun_teardown, 1, 'postrun_teardown')
		assert_eq(instantiate.counts.teardown, 3, 'teardown')

	func test_when_inner_class_skipped_none_of_the_before_after_are_called():
		pending('pending in 4.0')
		# gut.p('these tests sometimes fail.  Will have to add inner class names to test objects to make sure it passes.  GUT no longer guarantees the order in which the inner test classes are run so sometimes it works and sometimes it doesnt.')
		# gr.test_gut.add_script('res://test/resources/parsing_and_loading_samples/inner_classes_check_before_after.gd')
		# gr.test_gut.set_inner_class_name('Inner1')
		# gr.test_gut.test_scripts()
		# var instances = gr.test_gut._test_script_objects

		# var inner1_inst = null
		# var inner2_inst = null

		# # order in which the inner classes will be run is unknown  so  we
		# # have to go looking for them.
		# for i in range(instances.size()):
		# 	var dict = inst2dict(instances[i])
		# 	print('subpath  = ', dict['@subpath'])
		# 	if(dict['@subpath'] == 'TestInner1'):
		# 		inner1_inst = instances[i]
		# 	elif(dict['@subpath'] == 'TestInner2'):
		# 		inner2_inst = instances[i]

		# assert_eq(inner1_inst.before_all_calls, 1, 'TestInner1 before_all calls')
		# assert_eq(inner1_inst.after_all_calls, 1, 'TestInner1 after_all calls')
		# assert_eq(inner1_inst.before_each_calls, 1, 'TestInner1 before_each_calls')
		# assert_eq(inner1_inst.after_each_calls, 1, 'TestInner1 after_each calls')

		# assert_eq(inner2_inst.before_all_calls, 0, 'TestInner2 before_all calls')
		# assert_eq(inner2_inst.after_all_calls, 0, 'TestInner2 after_all calls')
		# assert_eq(inner2_inst.before_each_calls, 0, 'TestInner2 before_each_calls')
		# assert_eq(inner2_inst.after_each_calls, 0, 'TestInner2 after_each calls')

	# ------------------------------
	# Pre and post hook tests
	# ------------------------------
	func test_when_pre_hook_set_script_instance_is_is_retrievable():
		var  PreRunScript = load('res://test/resources/pre_run_script.gd')
		gr.test_gut.pre_run_script = 'res://test/resources/pre_run_script.gd'
		gr.test_gut.add_script(SAMPLES_DIR + 'test_sample_all_passed.gd')
		gr.test_gut.test_scripts()
		assert_is(gr.test_gut.get_pre_run_script_instance(), PreRunScript)

	func test_when_pre_hook_set_run_method_is_called():
		var  PreRunScript = load('res://test/resources/pre_run_script.gd')
		gr.test_gut.pre_run_script = 'res://test/resources/pre_run_script.gd'
		gr.test_gut.add_script(SAMPLES_DIR + 'test_sample_all_passed.gd')
		gr.test_gut.test_scripts()
		assert_true(gr.test_gut.get_pre_run_script_instance().run_called)

	func test_when_pre_hook_set_to_invalid_script_no_tests_are_ran():
		gr.test_gut.pre_run_script = 'res://does_not_exist.gd'
		gr.test_gut.add_script(SAMPLES_DIR + 'test_sample_all_passed.gd')
		gr.test_gut.test_scripts()
		assert_eq(gr.test_gut.get_summary().get_totals().tests, 0, 'test should not be run')
		assert_gt(gr.test_gut.get_logger().get_errors().size(), 0, 'there should be errors')

	func test_pre_hook_sets_gut_instance():
		gr.test_gut.pre_run_script = 'res://test/resources/pre_run_script.gd'
		gr.test_gut.add_script(SAMPLES_DIR + 'test_sample_all_passed.gd')
		gr.test_gut.test_scripts()
		assert_eq(gr.test_gut.get_pre_run_script_instance().gut, gr.test_gut)

	func test_pre_hook_does_not_accept_non_hook_scripts():
		gr.test_gut.pre_run_script = 'res://test/resources/non_hook_script.gd'
		gr.test_gut.add_script(SAMPLES_DIR + 'test_sample_all_passed.gd')
		gr.test_gut.test_scripts()
		assert_eq(gr.test_gut.get_summary().get_totals().tests, 0, 'test should not be run')
		assert_gt(gr.test_gut.get_logger().get_errors().size(), 0, 'there should be errors')

	func test_post_hook_is_run_after_tests():
		pending('pending in 4.0 yield')
		# var PostRunScript = load('res://test/resources/post_run_script.gd')
		# gr.test_gut.post_run_script = 'res://test/resources/post_run_script.gd'
		# gr.test_gut.add_script(SAMPLES_DIR + 'test_sample_all_passed.gd')
		# gr.test_gut.test_scripts()
		# await yield_for(1).YIELD
		# assert_is(gr.test_gut._post_run_script_instance, PostRunScript, 'Instance is set')
		# assert_true(gr.test_gut._post_run_script_instance.run_called, 'run was called')

	func test_when_post_hook_set_to_invalid_script_no_tests_are_ran():
		pending('pending in 4.0')
		# watch_signals(gr.test_gut)
		# gr.test_gut.post_run_script = 'res://does_not_exist.gd'
		# gr.test_gut.add_script(SAMPLES_DIR + 'test_sample_all_passed.gd')
		# gr.test_gut.test_scripts()
		# assert_eq(gr.test_gut.get_summary().get_totals().tests, 0, 'test should not be run')
		# assert_gt(gr.test_gut.get_logger().get_errors().size(), 0, 'there should be errors')

	# ------------------------------
	# Parameterized Test Tests
	# ------------------------------
	const TEST_WITH_PARAMETERS = 'res://test/resources/parsing_and_loading_samples/test_with_parameters.gd'
	func _get_test_script_object_of_type(the_gut, the_type):
		var objs = gr.test_gut._test_script_objects
		var obj = null
		for i in range(objs.size()):
			if(objs[i] is the_type):
				obj = objs[i]
			print('- ', _str(objs[i]))
		return obj

	func test_can_run_tests_with_parameters():
		gr.test_gut.add_script(TEST_WITH_PARAMETERS)
		gr.test_gut.set_unit_test_name('test_has_one_defaulted_parameter')
		gr.test_gut.test_scripts()
		var totals = gr.test_gut.get_summary().get_totals()
		assert_eq(totals.passing, 1, 'pass count')
		assert_eq(totals.tests, 1, 'test count')

	func test_too_many_parameters_generates_an_error():
		gr.test_gut.add_script(TEST_WITH_PARAMETERS)
		gr.test_gut.set_unit_test_name('test_has_two_parameters')
		gr.test_gut.test_scripts()
		assert_eq(gr.test_gut.get_logger().get_errors().size(), 1, 'error size')
		assert_eq(gr.test_gut.get_summary().get_totals().tests, 0, 'test count')

	func test_parameterized_tests_are_called_multiple_times():
		gr.test_gut.add_script(TEST_WITH_PARAMETERS)
		gr.test_gut.set_unit_test_name('test_has_three_values_for_parameters')
		gr.test_gut.test_scripts()
		assert_eq(gr.test_gut.get_pass_count(), 3)

	func test_when_use_parameters_is_not_called_then_error_is_generated():
		gr.test_gut.add_script(TEST_WITH_PARAMETERS)
		gr.test_gut.set_unit_test_name('test_does_not_use_use_parameters')
		gr.test_gut.test_scripts()
		assert_eq(gr.test_gut.get_logger().get_errors().size(), 1, 'error size')
		assert_eq(gr.test_gut.get_fail_count(), 1)

	# if you really think about this, it is a very very inception like test.
	func test_parameterized_test_that_yield_are_called_correctly():
		pending('pending in 4.0 yield')
		# gr.test_gut.add_script(TEST_WITH_PARAMETERS)
		# gr.test_gut.set_unit_test_name('test_three_values_and_a_yield')
		# gr.test_gut.test_scripts()
		# await yield_to(gr.test_gut, 'test_finished', 10).YIELD
		# assert_eq(gr.test_gut.get_pass_count(), 3)

	func test_parameterized_test_calls_before_each_before_each_test():
		gr.test_gut.add_script(TEST_WITH_PARAMETERS)
		gr.test_gut.set_inner_class_name('TestWithBeforeEach')
		gr.test_gut.test_scripts()
		assert_eq(gr.test_gut.get_pass_count(), 3)
		var obj = _get_test_script_object_of_type(gr.test_gut, load(TEST_WITH_PARAMETERS).TestWithBeforeEach)
		assert_eq(obj.before_count, 3, 'test class:  before_count')

	func test_parameterized_test_calls_after_each_after_each_test():
		gr.test_gut.add_script(TEST_WITH_PARAMETERS)
		gr.test_gut.set_inner_class_name('TestWithAfterEach')
		gr.test_gut.test_scripts()
		assert_eq(gr.test_gut.get_pass_count(), 3)
		var obj = _get_test_script_object_of_type(gr.test_gut, load(TEST_WITH_PARAMETERS).TestWithAfterEach)
		assert_eq(obj.after_count, 3, 'test class:  after_count')


	# ------------------------------
	# Asserting in before_all and after_all
	# ------------------------------
	func test_passing_asserts_made_in_before_all_are_counted():
		gr.test_gut.add_script('res://test/resources/has_asserts_in_beforeall_and_afterall.gd')
		gr.test_gut.set_inner_class_name('TestPassingBeforeAllAssertNoOtherTests')
		gr.test_gut.test_scripts()
		assert_eq(gr.test_gut.get_assert_count(), 1, 'assert count')
		assert_eq(gr.test_gut.get_pass_count(), 1, 'pass count')

	func test_passing_asserts_made_in_after_all_are_counted():
		gr.test_gut.add_script('res://test/resources/has_asserts_in_beforeall_and_afterall.gd')
		gr.test_gut.set_inner_class_name('TestPassingAfterAllAssertNoOtherTests')
		gr.test_gut.test_scripts()
		assert_eq(gr.test_gut.get_assert_count(), 1, 'assert count')
		assert_eq(gr.test_gut.get_pass_count(), 1, 'pass count')

	func test_failing_asserts_made_in_before_all_are_counted():
		gr.test_gut.add_script('res://test/resources/has_asserts_in_beforeall_and_afterall.gd')
		gr.test_gut.set_inner_class_name('TestFailingBeforeAllAssertNoOtherTests')
		gr.test_gut.test_scripts()
		assert_eq(gr.test_gut.get_assert_count(), 1, 'assert count')
		assert_eq(gr.test_gut.get_fail_count(), 1, 'fail count')

	func test_failing_asserts_made_in_after_all_are_counted():
		gr.test_gut.add_script('res://test/resources/has_asserts_in_beforeall_and_afterall.gd')
		gr.test_gut.set_inner_class_name('TestFailingAfterAllAssertNoOtherTests')
		gr.test_gut.test_scripts()
		assert_eq(gr.test_gut.get_assert_count(), 1, 'assert count')
		assert_eq(gr.test_gut.get_fail_count(), 1, 'fail count')

	func test_before_all_after_all_printing():
		gr.test_gut.add_script('res://test/resources/has_asserts_in_beforeall_and_afterall.gd')
		gr.test_gut.set_inner_class_name('TestHasBeforeAllAfterAllAndSomeTests')
		gr.test_gut.test_scripts()
		assert_eq(gr.test_gut.get_pass_count(), 4, 'pass count')
		assert_eq(gr.test_gut.get_fail_count(), 4, 'fail count')
		assert_eq(gr.test_gut.get_assert_count(), 8, 'assert count`')

	func test_before_all_after_all_printing_all_classes_in_script():
		gr.test_gut.add_script('res://test/resources/has_asserts_in_beforeall_and_afterall.gd')
		gr.test_gut.test_scripts()
		assert_eq(gr.test_gut.get_pass_count(), 11, 'pass count')
		assert_eq(gr.test_gut.get_fail_count(), 11, 'fail count')
		assert_eq(gr.test_gut.get_assert_count(), 22, 'assert count`')


	# ------------------------------------------------------------------------------
	#
	#
	# This must be the LAST test (but i don't think it always will be anymore)
	# TODO Is this still valid and is it always the last test?  It will not be.
	#
	# ------------------------------------------------------------------------------
	func test_verify_results():
		gut.p("/*THESE SHOULD ALL PASS, IF NOT THEN SOMETHING IS BROKEN*/")
		gut.p("/*These counts will be off if another script was run before this one.*/")
		assert_eq(1, counts.prerun_setup_count, "Prerun setup should have been called once")
		assert_eq(gut.get_test_count() - starting_counts.setup_count, counts.setup_count, "Setup should have been called once for each test")
		# teardown for this test hasn't been run yet.
		assert_eq(gut.get_test_count() -1 - starting_counts.teardown_count, counts.teardown_count, "Teardown should have been called one less time.")
