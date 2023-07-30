extends GutInternalTester

class TestBasics:
	extends GutInternalTester
	const TEMP_FILES = 'user://test_doubler_temp_file'

	var gr = {
		gut = null,
		test = null
	}

	func before_each():
		gr.gut = Gut.new()
		gr.gut._should_print_versions = false

		gr.test = Test.new()
		gr.test.gut = gr.gut
		add_child_autofree(gr.gut)
		add_child_autofree(gr.test)

	func after_each():
		gr.gut.get_spy().clear()

	func test_double_returns_a_class():
		var D = gr.test.double(DoubleMe)
		assert_ne(D.new(), null)

	func test_double_sets_stubber_for_doubled_class():
		var d = gr.test.double(DoubleMe).new()
		assert_eq(d.__gutdbl.stubber, gr.gut.get_stubber())

	func test_basic_double_and_stub():
		var d = gr.test.double(DoubleMe).new()
		gr.test.stub(DOUBLE_ME_PATH, 'get_value').to_return(10)
		assert_eq(d.get_value(), 10)

	func test_get_set_double_strat():
		assert_accessors(gr.test, 'double_strategy', gr.test.DOUBLE_STRATEGY.SCRIPT_ONLY, gr.test.DOUBLE_STRATEGY.INCLUDE_NATIVE)

	func test_when_strategy_is_full_then_supers_are_spied():
		var doubled = gr.test.double(DoubleMe, gr.test.DOUBLE_STRATEGY.INCLUDE_NATIVE).new()
		doubled.is_blocking_signals()
		gr.test.assert_called(doubled, 'is_blocking_signals')
		assert_eq(gr.test.get_pass_count(), 1)

	func test_when_strategy_is_partial_then_spying_on_non_overloaded_fails():
		var doubled = gr.test.double(DoubleMe, gr.test.DOUBLE_STRATEGY.SCRIPT_ONLY).new()
		doubled.is_blocking_signals()
		gr.test.assert_not_called(doubled, 'is_blocking_signals')
		assert_eq(gr.test.get_fail_count(), 1)

	func test_can_override_strategy_when_doubling_scene():
		var doubled = gr.test.double(DoubleMeScene, gr.test.DOUBLE_STRATEGY.INCLUDE_NATIVE).instantiate()
		autofree(doubled)
		doubled.is_blocking_signals()
		gr.test.assert_called(doubled, 'is_blocking_signals')
		assert_eq(gr.test.get_pass_count(), 1)

	func test_when_strategy_is_partial_then_spying_on_non_overloaded_fails_with_scenes():
		var doubled = gr.test.double(DoubleMeScene, gr.test.DOUBLE_STRATEGY.SCRIPT_ONLY).instantiate()
		autofree(doubled)
		doubled.is_blocking_signals()
		gr.test.assert_not_called(doubled, 'is_blocking_signals')
		assert_eq(gr.test.get_fail_count(), 1)

	func test_can_stub_inner_class_methods():
		gr.gut.get_doubler().inner_class_registry.register(InnerClasses)
		var d = gr.gut.get_doubler().double(InnerClasses.InnerA).new()
		gr.test.stub(InnerClasses.InnerA, 'get_a').to_return(10)
		assert_eq(d.get_a(), 10)

	func test_can_stub_multiple_inner_classes():
		gr.gut.get_doubler().inner_class_registry.register(InnerClasses)
		var a = gr.gut.get_doubler().double(InnerClasses.InnerA).new()
		var anotherA = gr.gut.get_doubler().double(InnerClasses.AnotherInnerA).new()
		gr.test.stub(a, 'get_a').to_return(10)
		gr.test.stub(anotherA, 'get_a').to_return(20)
		assert_eq(a.get_a(), 10)
		assert_eq(anotherA.get_a(), 20)

	func test_can_stub_multiple_inners_using_class_path_and_inner_names():
		gr.test.register_inner_classes(InnerClasses)

		var inner_a = gr.gut.get_doubler().double(InnerClasses.InnerA).new()
		var another_a = gr.gut.get_doubler().double(InnerClasses.AnotherInnerA).new()
		gr.test.stub(InnerClasses.InnerA, 'get_a').to_return(10)
		assert_eq(inner_a.get_a(), 10, 'InnerA should be stubbed')
		assert_eq(another_a.get_a(), null, 'AnotherA should NOT be stubbed')
		if(is_failing()):
			gut.p(gr.gut.get_stubber().to_s())

	func test_when_stub_passed_a_non_doubled_instance_it_generates_an_error():
		var n = autofree(Node.new())
		gr.test.stub(n, 'something').to_return(3)
		assert_errored(gr.test, 1)

	func test_when_stub_passed_singleton_it_generates_error():
		gr.test.stub(Input, "is_action_just_pressed").to_return(true)
		assert_errored(gr.test, 1)

	func test_can_stub_scenes():
		var dbl_scn = gr.test.double(DoubleMeScene).instantiate()
		gr.test.stub(dbl_scn, 'return_hello').to_return('world')
		assert_eq(dbl_scn.return_hello(), 'world')





class TestIgnoreMethodsWhenDoubling:
	extends GutInternalTester

	var _test_gut = null
	var _test = null

	func before_each():
		_test_gut = Gut.new()
		_test = Test.new()
		_test.gut = _test_gut

		add_child_autofree(_test_gut)
		add_child_autofree(_test)

	func test_sends_loaded_script_to_the_doubler():
		var m_doubler = double(_utils.Doubler).new()
		_test_gut._doubler = m_doubler
		_test.ignore_method_when_doubling(DoubleMe, 'two')
		assert_called(m_doubler, 'add_ignored_method', [DoubleMe, 'two'])

	func test_sends_loaded_scene_to_the_doubler():
		var m_doubler = double(_utils.Doubler).new()
		_test_gut._doubler = m_doubler
		_test.ignore_method_when_doubling(DoubleMeScene, 'two')
		assert_called(m_doubler, 'add_ignored_method',
			[GutUtils.get_scene_script_object(DoubleMeScene), 'two'])

	func test_when_ignoring_scene_methods_they_are_not_doubled():
		_test.ignore_method_when_doubling(DoubleMeScene, 'return_hello')
		var m_inst = _test.double(DoubleMeScene).instantiate()
		autofree(m_inst)
		m_inst.return_hello()
		# since it is ignored it should not have been caught by the stubber
		_test.assert_not_called(m_inst, 'return_hello')
		assert_eq(_test.get_fail_count(), 1)


class TestTestsSmartDoubleMethod:
	extends GutInternalTester

	var _test = null

	func before_all():
		_test = Test.new()
		_test.gut = gut

	func after_each():
		gut.get_stubber().clear()

	func test_when_passed_a_script_it_doubles_script():
		var inst = _test.double(DoubleMe).new()
		assert_eq(inst.__gutdbl.thepath, DOUBLE_ME_PATH)

	func test_when_passed_a_scene_it_doubles_a_scene():
		var inst = _test.double(DoubleMeScene).instantiate()
		assert_eq(inst.__gutdbl.thepath, DOUBLE_ME_SCENE_PATH)


	func test_doulbing_inners_with_objects():
		_test.register_inner_classes(InnerClasses)
		var inst = _test.double(InnerClasses.InnerA).new()
		assert_eq(inst.__gutdbl.thepath, INNER_CLASSES_PATH, 'check path')
		assert_eq(inst.__gutdbl.subpath, 'InnerA', 'check subpath')


	func test_include_native_strategy_used_for_scripts():
		var inst = _test.double(DoubleMe, DOUBLE_STRATEGY.INCLUDE_NATIVE).new()
		inst.get_instance_id()
		assert_called(inst, 'get_instance_id')

	func test_script_only_strategy_used_for_scripts():
		var inst = _test.double(DoubleMe, DOUBLE_STRATEGY.SCRIPT_ONLY).new()
		assert_does_not_have(inst.__gutdbl_values.doubled_methods, 'get_instance_id')

	func test_include_native_strategy_used_with_scenes():
		var inst = _test.double(DoubleMeScene, DOUBLE_STRATEGY.INCLUDE_NATIVE).instantiate()
		assert_has(inst.__gutdbl_values.doubled_methods, 'get_instance_id')

	func test_script_ony_strategy_used_with_scenes():
		var inst = _test.double(DoubleMeScene, DOUBLE_STRATEGY.SCRIPT_ONLY).instantiate()
		assert_does_not_have(inst.__gutdbl_values.doubled_methods, 'get_instance_id')

	func test_include_native_strategy_used_with_inners():
		_test.register_inner_classes(InnerClasses)
		var inst = _test.double(InnerClasses.InnerA, DOUBLE_STRATEGY.INCLUDE_NATIVE).new()
		assert_has(inst.__gutdbl_values.doubled_methods, 'get_instance_id')

	func test_script_only_strategy_used_with_inners():
		_test.register_inner_classes(InnerClasses)
		var inst = _test.double(InnerClasses.InnerA, DOUBLE_STRATEGY.SCRIPT_ONLY).new()
		assert_does_not_have(inst.__gutdbl_values.doubled_methods, 'get_instance_id')


	func test_when_passing_a_class_of_a_script_it_doubles_it():
		var inst = _test.double(DoubleMe).new()
		assert_eq(inst.__gutdbl.thepath, DOUBLE_ME_PATH)

	func test_when_passing_a_class_of_a_scene_it_doubles_it():
		var inst = _test.double(DoubleMeScene).instantiate()
		assert_eq(inst.__gutdbl.thepath, DOUBLE_ME_SCENE_PATH)


	func test_can_double_native_classes():
		var inst = _test.double(Node2D).new()
		assert_not_null(inst)

	func test_when_an_instance_is_passed_null_is_returned_and_an_error_is_generated():
		var inst = autofree(Node2D.new())
		var d = _test.double(inst)
		assert_null(d, 'double is null')
		assert_errored(_test, 1)


class TestPartialDoubleMethod:
	extends GutInternalTester

	var _gut = null
	var _test = null

	func before_all():
		_gut = Gut.new()
		_test = Test.new()
		_test.gut = _gut

		add_child(_gut)
		add_child(_test)

	func after_each():
		_gut.get_stubber().clear()

	func after_all():
		_gut.free()
		_test.free()

	func test_partial_double_script():
		var inst = _test.partial_double(DoubleMe).new()
		inst.set_value(10)
		assert_eq(inst.get_value(), 10)

	# TODO this test is tempramental.  It has something to do with the loading
	# of the doubles I think.  Should be fixed.
	func test_partial_double_scene():
		var inst = _test.partial_double(DoubleMeScene).instantiate()
		autofree(inst)
		assert_eq(inst.return_hello(), 'hello', 'sometimes fails, should be fixed.')


	func test_partial_double_inner():
		_test.register_inner_classes(InnerClasses)
		var inst = _test.partial_double(InnerClasses.InnerA).new()
		assert_eq(inst.get_a(), 'a')

	func test_double_script_not_a_partial():
		var inst = _test.double(DoubleMe).new()
		inst.set_value(10)
		assert_eq(inst.get_value(), null)

	func test_double_scene_not_a_partial():
		var inst = _test.double(DoubleMeScene).instantiate()
		autofree(inst)
		assert_eq(inst.return_hello(), null)

	func test_double_inner_not_a_partial():
		_test.register_inner_classes(InnerClasses)
		var inst = _test.double(InnerClasses.InnerA).new()
		assert_eq(inst.get_a(), null)

	func test_can_spy_on_partial_doubles():
		var pass_count = _test.get_pass_count()
		var inst = _test.partial_double(DoubleMe).new()
		inst.set_value(10)
		_test.assert_called(inst, 'set_value')
		_test.assert_called(inst, 'set_value', [10])
		assert_eq(_test.get_pass_count(), pass_count + 2)

	func test_can_stub_partial_doubled_native_class():
		var inst = _test.partial_double(Node2D).new()
		autofree(inst)
		_test.stub(inst, 'get_position').to_return(-1)
		assert_eq(inst.get_position(), -1)

	func test_can_spy_on_partial_doubled_native_class():
		var pass_count = _test.get_pass_count()
		var inst = autofree(_test.partial_double(Node2D).new())
		inst.set_position(Vector2(100, 100))
		_test.assert_called(inst, 'set_position', [Vector2(100, 100)])
		assert_eq(_test.get_pass_count(), pass_count + 1, 'tests have passed')


	func test_when_an_instance_is_passed_null_is_returned_and_an_error_is_generated():
		var inst = autofree(Node2D.new())
		var d = _test.partial_double(inst)
		assert_null(d, 'double is null')
		assert_errored(_test, 1)


class TestOverridingParameters:
	extends GutInternalTester

	var _gut = null
	var _test = null

	func before_all():
		_gut = Gut.new()
		_test = Test.new()
		_test.gut = _gut

		add_child(_gut)
		add_child(_test)

	func after_each():
		_gut.get_stubber().clear()

	func after_all():
		_gut.free()
		_test.free()

	const INIT_PARAMETERS = 'res://test/resources/stub_test_objects/init_parameters.gd'
	const DEFAULT_PARAMS_PATH = 'res://test/resources/doubler_test_objects/double_default_parameters.gd'
	var DefaultParams = load(DEFAULT_PARAMS_PATH)
	# -------------------
	# Default parameters and override parameter count
	func test_can_stub_default_values():
		var TestClass = load(DEFAULT_PARAMS_PATH)
		var s = _test.stub(TestClass, 'return_passed').to_call_super()
		s.param_defaults(['1', '2'])

		var inst =  _test.double(DefaultParams).new()
		var ret_val = inst.return_passed()
		assert_eq(ret_val, '12')


	func test_issue_246_rpc_id_varargs():
		_test.stub(Node, 'rpc_id').to_do_nothing().param_count(5)
		_test.stub(Node, '_ready').to_do_nothing()

		var inst =  _test.double(Node).new()
		add_child_autofree(inst)

		var ret_val = inst.rpc_id(1, 'foo', '3', '4', '5')
		_test.assert_called(inst, 'rpc_id', [1, 'foo', '3', '4', '5'])
		assert_eq(_test.get_pass_count(), 1)


	func test_issue_246_rpc_id_varargs2():
		stub(Node, 'rpc_id').to_do_nothing().param_count(5)

		var inst = double(Node).new()
		add_child_autofree(inst)
		inst.rpc_id(1, 'foo', '3', '4', '5')
		assert_called(inst, 'rpc_id', [1, 'foo', '3', '4', '5'])

	func test_issue_246_rpc_id_varargs_with_defaults():
		stub(Node, 'rpc_id').to_do_nothing().param_defaults([null, null, 'a', 'b', 'c'])

		var inst = double(Node).new()
		add_child_autofree(inst)
		inst.rpc_id(1, 'foo', 'z')
		assert_called(inst, 'rpc_id', [1, 'foo', 'z', 'b', 'c'])

	func test_setting_less_parameters_does_not_affect_anything():
		var TestClass = load(DEFAULT_PARAMS_PATH)
		var s = _test.stub(TestClass, 'return_passed').param_count(0)

		var inst =  _test.partial_double(DefaultParams).new()
		var ret_val = inst.return_passed('a', 'b')
		assert_eq(ret_val, 'ab')

	func test_double_can_have_default_param_values_stubbed_using_class():
		var InitParams = load(INIT_PARAMETERS)
		_test.stub(InitParams, '_init').param_defaults(["override_default"])
		var inst = _test.double(InitParams).new()
		assert_eq(inst.value, 'override_default')

class TestStub:
	extends GutInternalTester

	var _gut = null
	var _test = null

	func before_all():
		_gut = Gut.new()
		_gut.logger = _utils.Logger.new()
		_test = Test.new()
		_test.gut = _gut

		add_child(_gut)
		add_child(_test)

	func after_each():
		_gut.get_stubber().clear()

	func after_all():
		_gut.free()
		_test.free()

	func test_stub_of_valid_stuff_is_fine():
		var dbl = _test.double(DoubleMe).new()
		_test.stub(dbl, 'get_value').to_return(9)
		assert_errored(_test, 0)


	func test_stub_of_double_method_generates_error_when_method_does_not_exist():
		var dbl = _test.double(DoubleMe).new()
		_test.stub(dbl, 'foo').to_do_nothing()
		assert_errored(_test, 1)


# class TestSingletonDoubling:
# 	extends GutInternalTester

# 	var _test_gut = null
# 	var _test = null

# 	func before_each():
# 		_test_gut = Gut.new()
# 		_test_gut._should_print_versions = false
# 		_test = Test.new()
# 		_test.gut = _test_gut

# 		add_child_autofree(_test_gut)
# 		add_child_autofree(_test)

# 	func test_double_gives_double():
# 		var inst = _test.double_singleton("Input").new()
# 		assert_eq(inst.__gut_metadata_.from_singleton, "Input")

# 	func test_partial_gives_partial_double():
# 		var inst = _test.partial_double_singleton("Input").new()
# 		assert_true(inst.__gut_metadata_.is_partial)

# 	func test_double_errors_if_not_passed_a_string():
# 		var value = _test.double_singleton(Node2D)
# 		assert_errored(_test)
# 		assert_null(value, "null should be returned")

# 	func test_double_errors_if_class_name_does_not_exist():
# 		var value = _test.double_singleton("asdf")
# 		assert_errored(_test)
# 		assert_null(value, "null should be returned")

# 	func test_partial_double_errors_if_not_passed_a_string():
# 		var value = _test.partial_double_singleton(Node2D)
# 		assert_errored(_test)
# 		assert_null(value, "null should be returned")

# 	func test_partial_double_errors_if_class_name_does_not_exist():
# 		var value = _test.partial_double_singleton("asdf")
# 		assert_errored(_test)
# 		assert_null(value, "null should be returned")


# 	func test_can_stub_is_action_just_pressed_on_Input():
# 		var inst = _test.double_singleton("Input").new()
# 		_test.stub(inst, 'is_action_just_pressed').to_return(true)
# 		assert_true(inst.is_action_just_pressed('some_action'))

# 	func test_can_stub_get_processor_count_on_OS():
# 		var dbl_os = _test.partial_double_singleton('OS').new()
# 		_test.stub(dbl_os, 'get_processor_count').to_return(99)
# 		assert_eq(dbl_os.get_processor_count(), 99)


# 	var eligible_singletons = [
# 		"XRServer", "AudioServer", "CameraServer",
# 		"Engine", "Geometry2D", "Input",
# 		"InputMap", "IP", "JavaClassWrapper",
# 		"JavaScript", "JSON", "Marshalls",
# 		"OS", "Performance", "PhysicsServer2D",
# 		"PhysicsServer3D",
# 		"ProjectSettings", "ResourceLoader",
# 		"ResourceSaver", "TranslationServer", "VisualScriptEditor",
# 		"RenderingServer",
# 		# these two were missed by print_instanced_ClassDB_classes but were in
# 		# the global scope list.
# 		"ClassDB", "NavigationMeshGenerator"
# 	]
# 	func test_all_doubler_supported_singletons_are_supported_by_double_singleton_method(singleton = use_parameters(eligible_singletons)):
# 		# !! Keep eligible singletons in line with eligible_singletons in test_doubler
# 		assert_not_null(double_singleton(singleton), singleton)

# 	func test_all_doubler_supported_singles_are_supported_by_partial_double_singleton_method(singleton = use_parameters(eligible_singletons)):
# 		# !! Keep eligible singletons in line with eligible_singletons in test_doubler
# 		assert_not_null(partial_double_singleton(singleton), singleton)
