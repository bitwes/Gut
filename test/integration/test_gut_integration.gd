extends GutTest

class CoupledScriptTest:
	extends GutInternalTester

	var _gut = null

	func before_each():
		_gut = new_gut(verbose)
		_gut._should_print_versions = false
		_gut._should_print_summary = false
		add_child_autofree(_gut)

	func _same_name():
		return gut.get_current_test_object().name

	func _run_tests(script_path, inner_class, test_name):
		_gut.add_script(script_path)

		if(inner_class != null):
			_gut.inner_class_name = inner_class

		if(test_name != null):
			_gut.unit_test_name = test_name

		_gut.wait_log_delay = wait_log_delay
		_gut.test_scripts()


	func _assert_pass_fail_count(passing, failing):
		assert_eq(_gut.get_pass_count(), passing, 'Pass count does not match')
		assert_eq(_gut.get_fail_count(), failing, 'Failing count does not match')


class TestYieldInBeforeAfterMethods:
	extends CoupledScriptTest

	const SCRIPT_PATH = 'res://test/resources/yield_in_before_after_methods.gd'

	func test_gut_waits_for_yield_in_before_all():
		_run_tests(SCRIPT_PATH, 'TestYieldInBeforeAll', null)
		await wait_for_signal(_gut.end_run, 10)
		_assert_pass_fail_count(1, 0)

	func test_gut_waits_for_yield_in_after_all():
		var start_time = Time.get_ticks_msec()
		_run_tests(SCRIPT_PATH, 'TestYieldInAfterAll', null)
		await wait_for_signal(_gut.end_run, 10)
		assert_gt(Time.get_ticks_msec() - start_time, 1000)

	func test_gut_waits_for_yield_in_after_each():
		_run_tests(SCRIPT_PATH, 'TestYieldInAfterEach', null)
		await wait_for_signal(_gut.end_run, 10)
		_assert_pass_fail_count(1, 1)

	func test_gut_waits_for_yield_in_before_each():
		_run_tests(SCRIPT_PATH, 'TestYieldInBeforeEach', null)
		await wait_for_signal(_gut.end_run, 10)
		_assert_pass_fail_count(1, 0)
