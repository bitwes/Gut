extends GutTest


var GutRunner = load('res://addons/gut/gui/GutRunner.tscn')


func before_all():
	register_inner_classes(get_script())


func test_can_make_one():
	var gr = autofree(GutRunner.instantiate())
	assert_not_null(gr)


class TestQuit:
	extends GutInternalTester

	class PostRunHook:
		extends GutHookScript

		var use_this_exit_code = 0

		func run():
			set_exit_code(use_this_exit_code)

	# func should_skip_script():
	# 	return "Skipping until all the stupid globals are worked out."


	var GutRunner = load('res://addons/gut/gui/GutRunner.tscn')
	var PDblRunner = null

	# Added .5s to end of GUT run so this had to be introduced and bumped up.
	const MIN_FRAMES_TO_RUN_TESTS = 50
	var _created_runners = []


	func before_all():
		verbose = true
		PDblRunner = partial_double(GutRunner)


	func after_each():
		for r in _created_runners:
			if(r.error_tracker != GutUtils.get_error_tracker()):
				GutErrorTracker.deregister_logger(r.error_tracker)
		_created_runners.clear()


	func _create_runner():
		verbose = true
		var gr = PDblRunner.instantiate()
		gr.lgr = GutLogger.new()
		gr.error_tracker = GutErrorTracker.new()
		gr.gut_config = GutUtils.GutConfig.new()
		gr.gut_config.options.dirs = ['res://not_real']

		stub(gr, 'quit').to_do_nothing()

		gr.gut = new_partial_double_gut(verbose)
		# Use this script's error tracker so errors in tests actually
		# cause failures.
		gr.gut.error_tracker = gut.error_tracker
		stub(gr.gut.add_directory).to_do_nothing()
		_created_runners.append(gr)

		return gr


	func test_does_not_quit_when_gut_config_does_not_say_to():
		if(GutUtils.is_headless()):
			pending("cannot be tested when run headless.")
			return

		var gr = _create_runner()
		add_child_autofree(gr)

		gr.run_tests()
		await wait_physics_frames(MIN_FRAMES_TO_RUN_TESTS)
		assert_not_called(gr, 'quit')


	func test_quits_with_exit_code_0_when_should_exit_and_everything_ok():
		var gr = _create_runner()
		gr.gut_config.options.should_exit = true
		add_child_autofree(gr)

		gr.run_tests()
		await wait_physics_frames(MIN_FRAMES_TO_RUN_TESTS)
		assert_called(gr, 'quit', [0])


	func test_quits_with_exit_code_0_when_exit_on_success_and_everything_ok():
		var gr = _create_runner()
		gr.gut_config.options.should_exit_on_success = true
		add_child_autofree(gr)

		gr.run_tests()
		await wait_physics_frames(MIN_FRAMES_TO_RUN_TESTS)
		assert_called(gr, 'quit', [0])


	func test_sets_exit_code_from_post_run_hook():
		var hook_inst = PostRunHook.new()
		hook_inst.use_this_exit_code = 456

		var gr = _create_runner()
		gr.gut_config.options.should_exit = true
		stub(gr.gut, 'get_post_run_script_instance').to_return(hook_inst)
		add_child_autofree(gr)

		gr.run_tests()
		await wait_physics_frames(MIN_FRAMES_TO_RUN_TESTS)
		assert_called(gr, 'quit', [456])


	func test_exit_code_is_1_when_any_test_fails():
		var gr = _create_runner()
		gr.gut_config.options.should_exit = true
		stub(gr.gut, 'get_fail_count').to_return(1)
		add_child_autofree(gr)

		gr.run_tests()
		await wait_physics_frames(MIN_FRAMES_TO_RUN_TESTS)
		assert_called(gr, 'quit', [1])


	func test_hook_script_overrides_fail_count_exit_code():
		var hook_inst = PostRunHook.new()
		hook_inst.use_this_exit_code = 456

		var gr = _create_runner()
		gr.gut_config.options.should_exit = true
		stub(gr.gut, 'get_post_run_script_instance').to_return(hook_inst)
		stub(gr.gut, 'get_fail_count').to_return(99)
		add_child_autofree(gr)

		gr.run_tests()
		await wait_physics_frames(MIN_FRAMES_TO_RUN_TESTS)
		assert_called(gr, 'quit', [456])


	func test_does_not_quit_when_exit_on_success_but_has_failing_tests():
		if(GutUtils.is_headless()):
			pending("cannot be tested when run headless.")
			return

		var gr = _create_runner()
		gr.gut_config.options.should_exit_on_success = true
		stub(gr.gut, 'get_fail_count').to_return(1)
		add_child_autofree(gr)

		gr.run_tests()
		await wait_physics_frames(MIN_FRAMES_TO_RUN_TESTS)
		assert_not_called(gr, 'quit')


	func test_quits_when_exit_on_success_and_has_risky_tests():
		var gr = _create_runner()
		gr.gut_config.options.should_exit_on_success = true
		stub(gr.gut, 'get_pending_count').to_return(1)
		add_child_autofree(gr)

		gr.run_tests()
		await wait_physics_frames(MIN_FRAMES_TO_RUN_TESTS)
		assert_called(gr, 'quit', [0])


	func test_quits_with_exit_code_1_when_no_directories_are_configured():
		var gr = _create_runner()
		gr.gut_config.options.should_exit = true
		gr.gut_config.options.dirs = []
		add_child_autofree(gr)

		gr.run_tests()
		await wait_physics_frames(MIN_FRAMES_TO_RUN_TESTS)

		assert_logger_errored(gr.lgr)
		assert_push_error("directories configured,")

		assert_called(gr, 'quit', [1])

