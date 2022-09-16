extends "res://addons/gut/test.gd"

class BaseTest:
	extends GutTest
	var Stubber = load('res://addons/gut/stubber.gd')
	var Doubler = load('res://addons/gut/doubler.gd')
	var StubParams = load('res://addons/gut/stub_params.gd')


	const DOUBLE_ME_PATH = 'res://test/resources/doubler_test_objects/double_me.gd'
	const DOUBLE_ME_SCENE_PATH = 'res://test/resources/doubler_test_objects/double_me_scene.tscn'
	const DOUBLE_EXTENDS_NODE2D = 'res://test/resources/doubler_test_objects/double_extends_node2d.gd'
	const DOUBLE_EXTENDS_WINDOW_DIALOG = 'res://test/resources/doubler_test_objects/double_extends_window_dialog.gd'
	const TO_STUB_PATH = 'res://test/resources/stub_test_objects/to_stub.gd'
	const DOUBLE_WITH_STATIC = 'res://test/resources/doubler_test_objects/has_static_method.gd'
	const INIT_PARAMETERS = 'res://test/resources/stub_test_objects/init_parameters.gd'
	const INNER_CLASSES_PATH = 'res://test/resources/doubler_test_objects/inner_classes.gd'

	var DoubleMe = load(DOUBLE_ME_PATH)
	var DoubleExtendsNode2D = load(DOUBLE_EXTENDS_NODE2D)
	var DoubleExtendsWindowDialog = load(DOUBLE_EXTENDS_WINDOW_DIALOG)
	var DoubleWithStatic = load(DOUBLE_WITH_STATIC)
	var DoubleMeScene = load(DOUBLE_ME_SCENE_PATH)
	var InnerClasses = load(INNER_CLASSES_PATH)


	var print_source_when_failing = true

	func get_source(thing):
		var to_return = null
		if(_utils.is_instance(thing)):
			to_return = thing.get_script().get_source_code()
		else:
			to_return = thing.source_code
		return to_return

	func _pdflt(method, idx):
		return str('__gut_default_val("', method, '",', idx, ')')


	func _sig_gen(method, no_defaults):
		var to_return = ''
		for i in range(no_defaults.size()):
			to_return += str(no_defaults[i], '=', _pdflt(method, i), ', ')
		return to_return

	func assert_source_contains(thing, look_for, text=''):
		var source = get_source(thing)
		var msg = str('Expected source for ', _strutils.type2str(thing), ' to contain "', look_for, '":  ', text)
		if(source == null || source.find(look_for) == -1):
			fail_test(msg)
			if(print_source_when_failing):
				var header = str('------ Source for ', _strutils.type2str(thing), ' ------')
				gut.p(header)
				gut.p(_utils.add_line_numbers(source))

		else:
			pass_test(msg)

	func assert_source_not_contains(thing, look_for, text=''):
		var source = get_source(thing)
		var msg = str('Expected source for ', _strutils.type2str(thing), ' to not contain "', look_for, '":  ', text)
		if(source == null || source.find(look_for) == -1):
			pass_test(msg)
		else:
			fail_test(msg)
			if(print_source_when_failing):
				var header = str('------ Source for ', _strutils.type2str(thing), ' ------')
				gut.p(header)
				gut.p(_utils.add_line_numbers(source))

class TestTheBasics:
	extends BaseTest

	var gr = {
		doubler = null,
		stubber = null
	}

	func before_each():
		gr.doubler = Doubler.new()
		gr.stubber = Stubber.new()
		gr.doubler.set_stubber(gr.stubber)


		var d = gr.doubler.double(DoubleMe).new()
		assert_eq(d.__gutdbl.stubber, gr.stubber)

	func test_stubbing_method_returns_expected_value():
		var D = gr.doubler.double(DoubleMe)
		var sp = StubParams.new(DOUBLE_ME_PATH, 'get_value').to_return(7)
		gr.stubber.add_stub(sp)
		assert_eq(D.new().get_value(), 7)

	func test_can_stub_non_local_methods():
		var D = gr.doubler.double(DoubleMe)
		var sp = StubParams.new(DOUBLE_ME_PATH, 'get_position').to_return(Vector2(11, 11))
		gr.stubber.add_stub(sp)
		assert_eq(D.new().get_position(), Vector2(11, 11))

	func test_when_non_local_methods_not_stubbed_super_is_returned():
		var D = gr.doubler.double(DoubleMe)
		var d = autofree(D.new())
		assert_eq(d.get_child_count(), 0)

	func test_can_stub_doubled_instance_values():
		var D = gr.doubler.double(DoubleMe)
		var d1 = D.new()
		var d2 = D.new()

		var sp1 = StubParams.new(DOUBLE_ME_PATH, 'get_value').to_return(5)
		gr.stubber.add_stub(sp1)
		var sp2 = StubParams.new(d1, 'get_value').to_return(10)
		gr.stubber.add_stub(sp2)

		assert_eq(d1.get_value(), 10, 'instantiate gets right value')
		assert_eq(d2.get_value(), 5, 'other instantiate gets class value')

	func test_stubbed_methods_send_parameters_in_callback():
		var sp = StubParams.new(DOUBLE_ME_PATH, 'has_one_param')
		sp.to_return(10).when_passed(1)
		gr.stubber.add_stub(sp)
		var d = gr.doubler.double(DoubleMe).new()
		assert_eq(d.has_one_param(1), 10)
		assert_eq(d.has_one_param('asdf'), null)

	func test_stub_with_nothing_works_with_parameters():
		var sp1 = StubParams.new(DOUBLE_ME_PATH, 'has_one_param').to_return(5)
		var sp2 = StubParams.new(DOUBLE_ME_PATH, 'has_one_param')
		sp2.to_return(10).when_passed(1)
		gr.stubber.add_stub(sp1)
		gr.stubber.add_stub(sp2)

		var d = gr.doubler.double(DoubleMe).new()
		assert_eq(d.has_one_param(), 5)

	func test_can_stub_doubled_scenes():
		var sp = StubParams.new(DOUBLE_ME_SCENE_PATH, 'return_hello')
		sp.to_return('world')
		gr.stubber.add_stub(sp)
		var inst = autofree(gr.doubler.double_scene(DoubleMeScene).instantiate())
		assert_eq(inst.return_hello(), 'world')

	func test_when_stubbed_to_call_super_then_super_is_called():
		var doubled = gr.doubler.double(DoubleMe).new()
		var params = _utils.StubParams.new(doubled, 'set_value').to_call_super()
		gr.stubber.add_stub(params)
		doubled.set_value(99)
		assert_eq(doubled._value, 99)

	func test_can_stub_native_methods():
		pending('pending in 4.0')
		return
		var d_node2d = autofree(gr.doubler.double_gdnative(Node2D).new())
		var params = _utils.StubParams.new(d_node2d, 'get_position').to_return(-1)
		gr.stubber.add_stub(params)
		assert_eq(d_node2d.get_position(), -1)

	func test_partial_double_of_Node2D_returns_super_values():
		pending('pending in 4.0')
		return

		var pd_node_2d  = autofree(gr.doubler.partial_double_gdnative(Node2D).new())
		#pd_node_2d  = gr.doubler.partial_double_gdnative(Node2D).new()
		assert_eq(pd_node_2d.is_blocking_signals(), false)

	func test_can_stub_all_Node2D_doubles():
		pending('pending in 4.0')
		return

		var d_node2d = autofree(gr.doubler.double_gdnative(Node2D).new())
		var params = _utils.StubParams.new(Node2D, 'get_position').to_return(-1)
		gr.stubber.add_stub(params)
		assert_eq(d_node2d.get_position(), -1)

	func test_init_is_never_stubbed_to_call_super():
		var inst =  gr.doubler.partial_double(DoubleMe).new()
		assert_false(gr.stubber.should_call_super(inst, '_init', []))

	func test_ready_is_never_stubbed_to_call_super():
		var inst =  gr.doubler.partial_double(DoubleMe).new()
		assert_false(gr.stubber.should_call_super(inst, '_ready', []))

	func test_stubbing_init_to_call_super_generates_error():
		var err_count = gr.stubber.get_logger().get_errors().size()

		var inst =  gr.doubler.partial_double(DoubleMe).new()
		var params = _utils.StubParams.new(inst, '_init')
		gr.stubber.add_stub(params)
		params.to_call_super()
		assert_eq(gr.stubber.get_logger().get_errors().size(), err_count + 1)

	func test_stubbing_init_to_call_super_does_not_generate_stub():
		var inst =  gr.doubler.partial_double(DoubleMe).new()
		var params = _utils.StubParams.new(inst, '_init').to_call_super()
		gr.stubber.add_stub(params)
		assert_false(gr.stubber.should_call_super(inst, '_init'))

	func  test_you_cannot_stub_init_to_do_nothing():
		var err_count = gr.stubber.get_logger().get_errors().size()
		var inst =  gr.doubler.partial_double(DoubleMe).new()
		var params = _utils.StubParams.new(inst, '_init')
		gr.stubber.add_stub(params)
		params.to_do_nothing()
		assert_false(gr.stubber.should_call_super(inst, '_init'), 'stub not created')
		assert_eq(gr.stubber.get_logger().get_errors().size(), err_count + 1, 'error generated')

	func test_stubbing_return_value_of_init_results_in_error():
		var err_count = gr.stubber.get_logger().get_errors().size()
		var inst =  gr.doubler.partial_double(DoubleMe).new()
		var params = _utils.StubParams.new(inst, '_init')
		gr.stubber.add_stub(params)
		params.to_return('abc')
		assert_eq(gr.stubber.get_return(inst, '_init'), null, 'return value')
		assert_eq(gr.stubber.get_logger().get_errors().size(), err_count + 1, 'error generated')

	func test_double_can_have_default_param_values_stubbed():
		pending('pending in 4.0')
		return

		var params = _utils.StubParams.new(INIT_PARAMETERS, '_init')
		params.param_defaults(["override_default"])
		gr.stubber.add_stub(params)
		var inst = gr.doubler.double(INIT_PARAMETERS).new()
		assert_eq(inst.value, 'override_default')



# Since defaults are only available for built-in methods these tests verify
# specific method parameters that were found to cause a problem.
class TestDefaultParameters:
	extends BaseTest
	var skip_script = 'Pending in 4.0'

	var doubler = null

	func before_each():
		doubler = Doubler.new(_utils.DOUBLE_STRATEGY.FULL)
		doubler.set_stubber(_utils.Stubber.new())

	func test_all_types_supported():
		var dbl = doubler.double(DoubleExtendsWindowDialog).new()
		assert_source_contains(dbl, 'popup_centered(p_size=Vector2(0, 0)):', 'Vector2')
		assert_source_contains(dbl, 'bounds=Rect2(0, 0, 0, 0)', 'Rect2')


	func test_parameters_are_doubled_for_connect():
		pending('Has changed in Godot 4')
		# var inst = autofree(doubler.double_scene(DOUBLE_ME_SCENE_PATH).instantiate())
		# var no_defaults = _sig_gen('connect', ['p_signal', 'p_target', 'p_method'])
		# var sig = str('func connect(',Callable(no_defaults,'p_binds=[]),p_flags=0):'))

		# assert_source_contains(inst, sig)

	func test_parameters_are_doubled_for_draw_char():
		var inst = autofree(doubler.double_scene(DOUBLE_ME_SCENE_PATH).instantiate())
		var no_defaults = _sig_gen('draw_char', ['p_font', 'p_position', 'p_char', 'p_next'])
		var sig = 'func draw_char(' + no_defaults + 'p_modulate=Color(1,1,1,1)):'

		assert_source_contains(inst, sig)

	func test_parameters_are_doubled_for_draw_multimesh():
		var inst = autofree(doubler.double(DOUBLE_EXTENDS_WINDOW_DIALOG).new())
		var no_defaults = _sig_gen('draw_multimesh', ['p_multimesh', 'p_texture'])
		var sig = str('func draw_multimesh()(',
			no_defaults,
			'p_normal_map=null):')

		assert_source_contains(inst, sig)

	var singletons = [
		"PhysicsServer2D",	# TYPE_TRANSFORM2D, TYPE_RID
		"PhysicsServer3D",	# TYPE_TRANSFORM3D
		"RenderingServer"		# TYPE_PACKED_FLOAT32_ARRAY, TYPE_PACKED_INT32_ARRAY
	]
	func test_various_singletons_that_introduced_new_default_types(singleton = use_parameters(singletons)):
		pending('Broke in 4.0'); return

		var inst = doubler.double_singleton(singleton).new()
		assert_not_null(inst)