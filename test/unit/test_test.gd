# ------------------------------------------------------------------------------
# Contains tests that are not directly related to asserts.  All assert tests
# go in res://test/unit/test_test_asserts.gd
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

	# #############
	# Seutp/Teardown
	# #############
	func before_each():
		gr.test = Test.new()
		gr.test_with_gut = Test.new()
		gr.test_with_gut.gut = autofree(Gut.new())

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

	func test_fails_when_orphans_introduced():
		var n2d = Node2D.new()
		assert_no_new_orphans('this should fail')
		assert_false(gut._current_test.passed, 'test should be failing')
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


