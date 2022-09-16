extends GutTest

class BaseTest:
	extends GutTest

	const DOUBLE_ME_PATH = 'res://test/resources/doubler_test_objects/double_me.gd'
	const DOUBLE_ME_SCENE_PATH = 'res://test/resources/doubler_test_objects/double_me_scene.tscn'
	const DOUBLE_EXTENDS_NODE2D = 'res://test/resources/doubler_test_objects/double_extends_node2d.gd'
	const DOUBLE_EXTENDS_WINDOW_DIALOG = 'res://test/resources/doubler_test_objects/double_extends_window_dialog.gd'
	const DOUBLE_WITH_STATIC = 'res://test/resources/doubler_test_objects/has_static_method.gd'

	var DoubleMe = load(DOUBLE_ME_PATH)

	var Doubler = load('res://addons/gut/doubler.gd')
	var print_source_when_failing = true

	func get_source(thing):
		var to_return = null
		if(_utils.is_instance(thing)):
			to_return = thing.get_script().get_source_code()
		else:
			to_return = thing.source_code
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

	func print_source(thing):
		var source = get_source(thing)
		gut.p(_utils.add_line_numbers(source))




class TestDoubleInnerClasses:
	extends BaseTest
	var skip_script = 'Cannot extend inner classes godotengine #65666'

	var doubler = null
	const INNER_CLASSES_PATH = 'res://test/resources/doubler_test_objects/inner_classes.gd'
	var InnerClasses = load(INNER_CLASSES_PATH)

	func before_each():
		doubler = Doubler.new()
		doubler.set_stubber(_utils.Stubber.new())

	func test_can_instantiate_inner_double():
		var Doubled = doubler.double_inner(INNER_CLASSES_PATH, 'InnerB/InnerB1')
		assert_has_method(Doubled.new(), 'get_b1')

	func test_doubled_instance_returns_null_for_get_b1():
		var dbld = doubler.double_inner(INNER_CLASSES_PATH, 'InnerB/InnerB1').new()
		assert_null(dbld.get_b1())

	func test_doubled_instances_extend_the_inner_class():
		var inst = doubler.double_inner(INNER_CLASSES_PATH, 'InnerA').new()
		assert_true(inst is InnerClasses.InnerA, 'instance should be an InnerA')
		if(is_failing()):
			print_source(inst)

	func test_doubled_inners_that_extend_inners_get_full_inheritance():
		var inst = doubler.double_inner(INNER_CLASSES_PATH, 'InnerCA').new()
		assert_has_method(inst, 'get_a')
		assert_has_method(inst, 'get_ca')

	func test_doubled_inners_have_subpath_set_in_metadata():
		var inst = doubler.double_inner(INNER_CLASSES_PATH, 'InnerCA').new()
		assert_eq(inst.__gutdbl.subpath, 'InnerCA')

	func test_non_inners_have_empty_subpath():
		var inst = doubler.double(INNER_CLASSES_PATH).new()
		assert_eq(inst.__gutdbl.subpath, '')

	func test_can_override_strategy_when_doubling():
		#doubler.set_strategy(DOUBLE_STRATEGY.FULL)
		var d = doubler.double_inner(INNER_CLASSES_PATH, 'InnerA', DOUBLE_STRATEGY.FULL)
		# make sure it has something from Object that isn't implemented
		assert_source_contains(d.new() , 'func disconnect(p_signal')
		assert_eq(doubler.get_strategy(), DOUBLE_STRATEGY.PARTIAL, 'strategy should have been reset')

	func test_doubled_inners_retain_signals():
		var inst = doubler.double_inner(INNER_CLASSES_PATH, 'InnerWithSignals').new()
		assert_has_signal(inst, 'signal_signal')

	func test_double_inner_does_not_call_supers():
		var inst = doubler.double_inner(INNER_CLASSES_PATH, 'InnerA').new()
		assert_eq(inst.get_a(), null)






class TestDoubleGDNaviteClasses:
	extends BaseTest

	var _doubler = null
	var _stubber = _utils.Stubber.new()

	func before_each():
		_stubber.clear()
		_doubler = Doubler.new()
		_doubler.set_stubber(_stubber)

	func test_can_double_Node2D():
		var d_node_2d = _doubler.double_gdnative(Node2D)
		assert_not_null(d_node_2d)

	func test_can_partial_double_Node2D():
		var pd_node_2d  = _doubler.partial_double_gdnative(Node2D)
		assert_not_null(pd_node_2d)

	func test_can_make_instances_of_native_doubles():
		var crect_double_inst = _doubler.double_gdnative(ColorRect).new()
		assert_not_null(crect_double_inst)


class TestAutofree:
	extends BaseTest

	class InitHasDefaultParams:
		var a = 'b'

		func _init(value='asdf'):
			a = value

	func test_doubles_are_autofreed():
		var doubled = double(DOUBLE_EXTENDS_NODE2D).new()
		gut.get_autofree().free_all()
		assert_no_new_orphans()

	func test_partial_doubles_are_autofreed():
		var doubled = partial_double(DOUBLE_EXTENDS_NODE2D).new()
		gut.get_autofree().free_all()
		assert_no_new_orphans()


class TestInitParameters:
	extends BaseTest
	var skip_script = 'Not ready for 4.0 (before_all broken)'

	class InitDefaultParameters:
		var value = 'start_value'

		func _init(p_arg0='default_value'):
			value = p_arg0

	var DoubledClass = null
	var PartialDoubledClass = null

	func before_all():
		gut.get_doubler()._print_source = false

	func before_each():
		DoubledClass = double(
			'res://test/unit/test_doubler.gd',
			'TestInitParameters/InitDefaultParameters')
		PartialDoubledClass = partial_double(
			'res://test/unit/test_doubler.gd',
			'TestInitParameters/InitDefaultParameters')

	# This is due to the gut defaulting mechanism since the
	# default value cannot be known
	func test_double_gets_null_for_default_value():
		var doubled = DoubledClass.new()
		assert_null(doubled.value)

	func test_double_gets_passed_value():
		var doubled = DoubledClass.new('test')
		assert_eq(doubled.value, 'test')

	func test_partial_double_gets_passed_value():
		var doubled = PartialDoubledClass.new('test')
		assert_eq(doubled.value, 'test')

	func test_partial_double_gets_null_for_default_value():
		var doubled = PartialDoubledClass.new()
		assert_null(doubled.value)



# class TestDoubleSingleton:
# 	extends BaseTest

# 	var _doubler = null
# 	var _stubber = _utils.Stubber.new()

# 	func before_each():
# 		_stubber.clear()
# 		_doubler = Doubler.new()
# 		_doubler.set_output_dir(TEMP_FILES)
# 		_doubler.set_stubber(_stubber)
# 		_doubler._print_source = false

# 	func test_can_make_double_of_input():
# 		var Doubled = _doubler.double_singleton("Input")
# 		assert_not_null(Doubled)

# 	func test_can_make_instance_of_double():
# 		var doubled = _doubler.double_singleton("Input").new()
# 		assert_not_null(doubled)

# 	func test_double_gets_methods_from_input():
# 		var doubled = _doubler.double_singleton("Input").new()
# 		assert_true(doubled.has_method("action_press"))

# 	func test_normal_double_of_input_does_not_have_implementations():
# 		var doubled = _doubler.double_singleton("Input").new()
# 		assert_null(doubled.is_action_just_pressed())

# 	func test_partial_double_gets_implementation():
# 		var doubled = _doubler.partial_double_singleton("Input").new()
# 		assert_false(doubled.is_action_just_pressed("foobar"))

# 	func test_double_gets_constants():
# 		var doubled = _doubler.double_singleton("Input").new()
# 		assert_eq(doubled.CURSOR_VSPLIT, Input.CURSOR_VSPLIT)

# 	func test_partial_double_gets_wired_properties():
# 		var doubled = _doubler.partial_double_singleton("XRServer").new()
# 		assert_eq(doubled.world_scale, 1.0, "property")
# 		assert_eq(doubled.get_world_scale(), 1.0, "accessor")

# 	func test_partial_double_setters_are_wired_to_set_source_property():
# 		var doubled = _doubler.partial_double_singleton("XRServer").new()
# 		doubled.world_scale = 0.5
# 		assert_eq(XRServer.get_world_scale(), 0.5, "accessor")
# 		# make sure to put it back to what it was, who knows what it does.
# 		XRServer.world_scale = 1.0

# 	func test_double_gets_unwired_properties_by_default():
# 		var doubled = _doubler.double_singleton("XRServer").new()
# 		assert_null(doubled.world_scale)

# 	# These singletons were found using print_instanced_ClassDB_classes in
# 	# scratch/get_info.gd and are most likely the only singletons that
# 	# should be doubled as of now.
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
# 	func test_can_make_doubles_of_eligible_singletons(singleton = use_parameters(eligible_singletons)):
# 		# !! Keep eligible singletons in line with eligible_singletons in test_test_stubber_doubler
# 		assert_not_null(_doubler.double_singleton(singleton), singleton)

# 	# Note that setters aren't tested b/c picking valid values automatically is
# 	# an unreasonable approach and I didn't want to maintain a list.  If a setter
# 	# or getter method is not found when trying to make the double then an
# 	# error should be printed.  It seems safe to assume if the getters are wired
# 	# and there aren't any error messages when this test runs then the setters
# 	# are also wired.  A specific setter is tested in a previous test, just
# 	# not on all properties of all the eligible singletons.
# 	func test_property_getters_wired_for_partials_of_eligible_singletons(singleton = use_parameters(eligible_singletons)):
# 		var props = ClassDB.class_get_property_list(singleton)
# 		for prop in props:
# 			var double = partial_double_singleton(singleton).new()
# 			var parent_inst = _utils.get_singleton_by_name(singleton)
# 			assert_eq(double.get(prop["name"]), parent_inst.get(prop["name"]),
# 				str(singleton, ".", prop["name"]))

# 	var os_method_names = ['get_processor_count']
# 	func test_OS_methods(method_name = use_parameters(os_method_names)):
# 		var dbl_os = _doubler.partial_double_singleton('OS').new()
# 		assert_eq(dbl_os.has_method(method_name), OS.has_method(method_name), 'has ' + method_name)

# 	var input_method_names = ['something']
# 	func test_Input_methods(method_name = use_parameters(input_method_names)):
# 		var dbl_input = _doubler.partial_double_singleton('Input')
# 		assert_eq(dbl_input.has_method(method_name), Input.has_method(method_name), 'has ' + method_name)
