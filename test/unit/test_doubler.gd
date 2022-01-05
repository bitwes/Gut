extends "res://addons/gut/test.gd"

class BaseTest:
	extends "res://addons/gut/test.gd"

	const TEMP_FILES = 'user://test_doubler_temp_file'

	const DOUBLE_ME_PATH = 'res://test/resources/doubler_test_objects/double_me.gd'
	const DOUBLE_ME_SCENE_PATH = 'res://test/resources/doubler_test_objects/double_me_scene.tscn'
	const DOUBLE_EXTENDS_NODE2D = 'res://test/resources/doubler_test_objects/double_extends_node2d.gd'
	const DOUBLE_EXTENDS_WINDOW_DIALOG = 'res://test/resources/doubler_test_objects/double_extends_window_dialog.gd'
	const DOUBLE_WITH_STATIC = 'res://test/resources/doubler_test_objects/has_static_method.gd'

	var Doubler = load('res://addons/gut/doubler.gd')

	func get_instance_source(thing):
		var to_return = null
		if(_utils.is_instance(thing)):
			to_return = thing.get_script().get_source_code()
		return to_return

	func _pdflt(method, idx):
		return str('__gut_default_val("', method, '",', idx, ')')


	func _sig_gen(method, no_defaults):
		var to_return = ''
		for i in range(no_defaults.size()):
			to_return += str(no_defaults[i], '=', _pdflt(method, i), ', ')
		return to_return



class TestTheBasics:
	extends BaseTest

	var gr = {
		doubler = null
	}

	var stubber = _utils.Stubber.new()
	func before_each():
		stubber.clear()
		gr.doubler = Doubler.new()
		gr.doubler.set_stubber(stubber)
		gr.doubler.set_output_dir(TEMP_FILES)
		gr.doubler.set_gut(gut)

	func after_each():
		gr.doubler.clear_output_directory()

	func test_get_set_output_dir():
		assert_accessors(Doubler.new(), 'output_dir', 'user://gut_temp_directory', 'user://somewhere')
		gut.file_delete('user://somewhere')

	func test_get_set_stubber():
		var dblr = Doubler.new()
		var default_stubber = dblr.get_stubber()
		assert_accessors(dblr, 'stubber', default_stubber, GDScript.new())

	func test_can_get_set_spy():
		assert_accessors(Doubler.new(), 'spy', null, GDScript.new())

	func test_get_set_make_files():
		assert_accessors(Doubler.new(), 'make_files', false, true)

	func test_get_set_gut():
		assert_accessors(Doubler.new(), 'gut', null, GDScript.new())

	func test_setting_output_dir_creates_directory_if_it_does_not_exist():
		var d = Doubler.new()
		d.set_make_files(true)
		var path = 'user://doubler_temp_files/'
		d.set_output_dir(path)
		var dir = Directory.new()
		assert_true(dir.dir_exists(path))
		gut.file_delete(path)

	func test_doubling_object_includes_methods():
		var inst = gr.doubler.double(DOUBLE_ME_PATH).new()
		var text = get_instance_source(inst)
		assert_true(text.match('*func get_value(*:\n*'), 'should have get method')
		assert_true(text.match('*func set_value(*:\n*'), 'should have set method')

	func test_doubling_methods_have_parameters_1():
		var inst = gr.doubler.double(DOUBLE_ME_PATH).new()
		var text = get_instance_source(inst)
		assert_true(text.match('*param(p_arg0*:*'), text)

	# Don't see a way to see which have defaults and which do not, so we default
	# everything.
	func test_all_parameters_are_defaulted_to_null():
		var inst = gr.doubler.double(DOUBLE_ME_PATH).new()
		var text = get_instance_source(inst)
		assert_true(text.match('*has_two_params_one_default(p_arg0=__gut_default_val("has_two_params_one_default",0), p_arg1=__gut_default_val("has_two_params_one_default",1))*'))

	func test_doubled_thing_includes_stubber_metadata():
		var doubled = gr.doubler.double(DOUBLE_ME_PATH).new()
		assert_ne(doubled.get('__gut_metadata_'), null)

	func test_doubled_thing_has_original_path_in_metadata():
		var doubled = gr.doubler.double(DOUBLE_ME_PATH).new()
		assert_eq(doubled.__gut_metadata_.path, DOUBLE_ME_PATH)

	func test_doublecd_thing_has_gut_metadata():
		var doubled = gr.doubler.double(DOUBLE_ME_PATH).new()
		assert_eq(doubled.__gut_metadata_.gut, gut)

	func test_keeps_extends():
		var doubled = gr.doubler.double(DOUBLE_EXTENDS_NODE2D).new()
		assert_is(doubled, Node2D)

	func test_can_clear_output_directory():
		gr.doubler.set_make_files(true)
		gut.file_touch(TEMP_FILES  + '/test_file.txt')
		gr.doubler.clear_output_directory()
		assert_file_does_not_exist(TEMP_FILES  + '/test_file.txt')

	func test_can_delete_output_directory():
		var d = Directory.new()
		d.open('user://')
		gr.doubler.set_make_files(true)
		gr.doubler.double(DOUBLE_ME_PATH)
		assert_true(d.dir_exists(TEMP_FILES))
		gr.doubler.delete_output_directory()
		assert_false(d.dir_exists(TEMP_FILES))

	func test_can_double_scene():
		var obj = gr.doubler.double_scene(DOUBLE_ME_SCENE_PATH)
		var inst = obj.instance()
		assert_eq(inst.return_hello(), null)

	func test_can_add_doubled_scene_to_tree():
		var inst = gr.doubler.double_scene(DOUBLE_ME_SCENE_PATH).instance()
		add_child(inst)
		assert_ne(inst.label, null)
		remove_child(inst)

	func test_metadata_for_scenes_script_points_to_scene_not_script():
		var inst = gr.doubler.double_scene(DOUBLE_ME_SCENE_PATH).instance()
		assert_eq(inst.__gut_metadata_.path, DOUBLE_ME_SCENE_PATH)

	func test_does_not_add_duplicate_methods():
		gr.doubler.double('res://test/resources/parsing_and_loading_samples/extends_another_thing.gd')
		assert_true(true, 'If we get here then the duplicates were removed.')

	# Keep this last so other tests fail before instantiation fails
	func test_returns_class_that_can_be_instanced():
		var Doubled = gr.doubler.double(DOUBLE_ME_PATH)
		var doubled = Doubled.new()
		assert_ne(doubled, null)

	func test_get_set_logger():
		assert_ne(gr.doubler.get_logger(), null)
		var l = load('res://addons/gut/logger.gd').new()
		gr.doubler.set_logger(l)
		assert_eq(gr.doubler.get_logger(), l)

	func test_doubler_sets_logger_of_method_maker():
		assert_eq(gr.doubler.get_logger(), gr.doubler._method_maker.get_logger())

	func test_setting_logger_sets_it_on_method_maker():
		var l = load('res://addons/gut/logger.gd').new()
		gr.doubler.set_logger(l)
		assert_eq(gr.doubler.get_logger(), gr.doubler._method_maker.get_logger())

	func test_get_set_strategy():
		assert_accessors(gr.doubler, 'strategy', _utils.DOUBLE_STRATEGY.PARTIAL,  _utils.DOUBLE_STRATEGY.FULL)

	func test_can_set_strategy_in_constructor():
		var d = Doubler.new(_utils.DOUBLE_STRATEGY.FULL)
		assert_eq(d.get_strategy(), _utils.DOUBLE_STRATEGY.FULL)

	func test_doubles_retain_signals():
		var d = gr.doubler.double(DOUBLE_ME_PATH).new()
		assert_has_signal(d, 'signal_signal')
		assert_has_signal(d, 'user_signal')

	func test_can_add_to_ignore_list():
		assert_eq(gr.doubler.get_ignored_methods().size(), 0, 'initial size')
		gr.doubler.add_ignored_method(DOUBLE_WITH_STATIC, 'some_method')
		assert_eq(gr.doubler.get_ignored_methods().size(), 1, 'after add')

	func test_when_ignored_methods_are_a_local_method_mthey_are_not_present_in_double_code():
		gr.doubler.add_ignored_method(DOUBLE_ME_PATH, 'has_one_param')
		var c = gr.doubler.double(DOUBLE_ME_PATH)
		var text = get_instance_source(c.new())
		assert_ne(text, '', "text is not empty")
		assert_eq(text.find('has_one_param'), -1)

	func test_when_ignored_methods_are_a_super_method_mthey_are_not_present_in_double_code():
		gr.doubler.add_ignored_method(DOUBLE_ME_PATH, 'is_connected')
		var c = gr.doubler.double(DOUBLE_ME_PATH, _utils.DOUBLE_STRATEGY.FULL)
		var text = get_instance_source(c.new())
		assert_ne(text, '', "text is not empty")
		assert_eq(text.find('is_connected'), -1)

	func test_can_double_classes_with_static_methods():
		gr.doubler.add_ignored_method(DOUBLE_WITH_STATIC, 'this_is_a_static_method')
		var d = gr.doubler.double(DOUBLE_WITH_STATIC).new()
		assert_null(d.this_is_not_static())


class TestBuiltInOverloading:
	extends BaseTest

	var _dbl_win_dia_text = ''
	var _dbl_win_dia = null

	func _hide_call_back():
		pass

	var doubler = null
	var stubber = _utils.Stubber.new()


	func before_all():
		# WindowDialog has A LOT of the edge cases we need to check so it is used
		# as the default.
		var d = Doubler.new(_utils.DOUBLE_STRATEGY.FULL)
		_dbl_win_dia = d.double(DOUBLE_EXTENDS_WINDOW_DIALOG)
		var inst = _dbl_win_dia.new()
		_dbl_win_dia_text = get_instance_source(inst)
		inst.free()


	func before_each():
		stubber.clear()
		doubler = Doubler.new(_utils.DOUBLE_STRATEGY.FULL)
		doubler.set_stubber(stubber)
		doubler.set_output_dir(TEMP_FILES)



	func after_all():
		if(doubler):
			doubler.clear_output_directory()

	func test_built_in_overloading_ony_happens_on_full_strategy():
		doubler.set_strategy(_utils.DOUBLE_STRATEGY.PARTIAL)
		var txt = get_instance_source(doubler.double(DOUBLE_ME_PATH).new())
		assert_ne(txt, '', "text is not empty")
		assert_eq(txt.find('func is_blocking_signals'), -1, 'does not have non-overloaded methods')

	func test_can_override_strategy_when_doubling_script():
		doubler.set_strategy(_utils.DOUBLE_STRATEGY.PARTIAL)
		var inst = doubler.double(DOUBLE_ME_PATH, DOUBLE_STRATEGY.FULL).new()
		var txt = get_instance_source(inst)
		assert_ne(txt, '', "text is not empty")
		assert_ne(txt.find('func is_blocking_signals'), -1, 'HAS non-overloaded methods')

	func test_can_override_strategy_when_doubling_scene():
		doubler.set_strategy(_utils.DOUBLE_STRATEGY.PARTIAL)
		var inst = autofree(doubler.double_scene(DOUBLE_ME_SCENE_PATH, DOUBLE_STRATEGY.FULL).instance())
		var txt = get_instance_source(inst)
		assert_ne(txt, '', "text is not empty")
		assert_ne(txt.find('func is_blocking_signals'), -1, 'HAS non-overloaded methods')

	func test_when_everything_included_you_can_still_make_an_a_new_object():
		var inst = doubler.double(DOUBLE_ME_PATH).new()
		assert_ne(inst, null)

	func test_when_everything_included_you_can_still_make_a_new_node2d():
		var inst = autofree(doubler.double(DOUBLE_EXTENDS_NODE2D).new())
		assert_ne(inst, null)

	func test_when_everything_included_you_can_still_double_a_scene():
		var inst = autofree(doubler.double_scene(DOUBLE_ME_SCENE_PATH).instance())
		add_child(inst)
		assert_ne(inst, null, "instance is not null")
		assert_ne(inst.label, null, "Can get to a label on the instance")
		# pause so _process gets called
		yield(yield_for(3), YIELD)
		end_test()

	func test_double_includes_methods_in_super():
		assert_string_contains(_dbl_win_dia_text, 'connect(')

	func test_can_call_a_built_in_that_has_default_parameters():
		var inst = autofree(doubler.double(DOUBLE_EXTENDS_WINDOW_DIALOG).new())
		inst.connect('hide', self, '_hide_call_back')

	func test_all_types_supported():
		assert_string_contains(_dbl_win_dia_text, 'popup_centered(p_size=Vector2(0, 0)):', 'Vector2')
		assert_string_contains(_dbl_win_dia_text, 'bounds=Rect2(0, 0, 0, 0)', 'Rect2')

	func test_doubled_builtins_call_super():
		var inst = autofree(doubler.double(DOUBLE_EXTENDS_WINDOW_DIALOG).new())
		# Make sure the function is in the doubled class definition
		assert_string_contains(get_instance_source(inst), 'func add_user_signal(p_signal')
		# Make sure that when called it retains old functionality.
		inst.add_user_signal('new_one')
		inst.add_user_signal('new_two', ['a', 'b'])
		assert_has_signal(inst, 'new_one')
		assert_has_signal(inst, 'new_two')

	func test_doubled_builtins_are_added_as_stubs_to_call_super():
		#doubler.set_stubber(_utils.Stubber.new())
		var inst = autofree(doubler.double(DOUBLE_EXTENDS_WINDOW_DIALOG).new())
		assert_true(doubler.get_stubber().should_call_super(inst, 'add_user_signal'))




# Since defaults are only available for built-in methods these tests verify
# specific method parameters that were found to cause a problem.
class TestDefaultParameters:
	extends BaseTest

	var doubler = null

	func before_each():
		doubler = Doubler.new(_utils.DOUBLE_STRATEGY.FULL)
		doubler.set_stubber(_utils.Stubber.new())
		doubler.set_output_dir(TEMP_FILES)

	func test_parameters_are_doubled_for_connect():
		var inst = autofree(doubler.double_scene(DOUBLE_ME_SCENE_PATH).instance())
		var text = get_instance_source(inst)
		var no_defaults = _sig_gen('connect', ['p_signal', 'p_target', 'p_method'])
		var sig = str('func connect(', no_defaults, 'p_binds=[], p_flags=0):')

		assert_string_contains(text, sig)

	func test_parameters_are_doubled_for_draw_char():
		var inst = autofree(doubler.double_scene(DOUBLE_ME_SCENE_PATH).instance())
		var text = get_instance_source(inst)
		var no_defaults = _sig_gen('draw_char', ['p_font', 'p_position', 'p_char', 'p_next'])
		var sig = 'func draw_char(' + no_defaults + 'p_modulate=Color(1,1,1,1)):'

		assert_string_contains(text, sig)

	func test_parameters_are_doubled_for_draw_multimesh():
		var inst = autofree(doubler.double(DOUBLE_EXTENDS_WINDOW_DIALOG).new())
		var no_defaults = _sig_gen('draw_multimesh', ['p_multimesh', 'p_texture'])
		var sig = str('func draw_multimesh(',
			no_defaults,
			'p_normal_map=null):')

		assert_string_contains(get_instance_source(inst), sig)

	var singletons = [
		"Physics2DServer",	# TYPE_TRANSFORM2D, TYPE_RID
		"PhysicsServer",	# TYPE_TRANSFORM
		"VisualServer"		# TYPE_REAL_ARRAY, TYPE_INT_ARRAY
	]
	func test_various_singletons_that_introduced_new_default_types(singleton = use_parameters(singletons)):
		var inst = doubler.double_singleton(singleton).new()
		assert_not_null(inst)


class TestDoubleInnerClasses:
	extends BaseTest

	var doubler = null
	const INNER_CLASSES_PATH = 'res://test/resources/doubler_test_objects/inner_classes.gd'
	var InnerClasses = load(INNER_CLASSES_PATH)

	func before_each():
		doubler = Doubler.new()
		doubler.set_stubber(_utils.Stubber.new())
		doubler.set_output_dir(TEMP_FILES)

	func test_can_instantiate_inner_double():
		var Doubled = doubler.double_inner(INNER_CLASSES_PATH, 'InnerB/InnerB1')
		assert_has_method(Doubled.new(), 'get_b1')

	func test_doubled_instance_returns_null_for_get_b1():
		var dbld = doubler.double_inner(INNER_CLASSES_PATH, 'InnerB/InnerB1').new()
		assert_null(dbld.get_b1())

	func test_doubled_instances_extend_the_inner_class():
		var inst = doubler.double_inner(INNER_CLASSES_PATH, 'InnerA').new()
		assert_extends(inst, InnerClasses.InnerA)

	func test_doubled_inners_that_extend_inners_get_full_inheritance():
		var inst = doubler.double_inner(INNER_CLASSES_PATH, 'InnerCA').new()
		assert_has_method(inst, 'get_a')
		assert_has_method(inst, 'get_ca')

	func test_doubled_inners_have_subpath_set_in_metadata():
		var inst = doubler.double_inner(INNER_CLASSES_PATH, 'InnerCA').new()
		assert_eq(inst.__gut_metadata_.subpath, 'InnerCA')

	func test_non_inners_have_empty_subpath():
		var inst = doubler.double(INNER_CLASSES_PATH).new()
		assert_eq(inst.__gut_metadata_.subpath, '')

	func test_can_override_strategy_when_doubling():
		#doubler.set_strategy(DOUBLE_STRATEGY.FULL)
		var d = doubler.double_inner(INNER_CLASSES_PATH, 'InnerA', DOUBLE_STRATEGY.FULL)
		# make sure it has something from Object that isn't implemented
		var text = get_instance_source(d.new())
		assert_string_contains(text , 'func disconnect(p_signal')
		assert_eq(doubler.get_strategy(), DOUBLE_STRATEGY.PARTIAL, 'strategy should have been reset')

	func test_doubled_inners_retain_signals():
		var inst = doubler.double_inner(INNER_CLASSES_PATH, 'InnerWithSignals').new()
		assert_has_signal(inst, 'signal_signal')
		assert_has_signal(inst, 'user_signal')


class TestPartialDoubles:
	extends BaseTest

	const INNER_CLASSES_PATH = 'res://test/resources/doubler_test_objects/inner_classes.gd'

	var doubler = null
	var stubber = _utils.Stubber.new()

	func before_each():
		stubber.clear()
		doubler = Doubler.new()
		doubler.set_output_dir(TEMP_FILES)
		doubler.set_stubber(stubber)

	func after_each():
		doubler.clear_output_directory()

	func test_can_make_partial_of_script():
		var inst = doubler.partial_double(DOUBLE_ME_PATH).new()
		inst.set_value(10)
		assert_eq(inst.get_value(), 10)

	func test_double_script_does_not_make_partials():
		var inst = doubler.double(DOUBLE_ME_PATH).new()
		assert_eq(inst.get_value(), null)

	func test_can_make_partial_of_inner_script():
		var inst = doubler.partial_double_inner(INNER_CLASSES_PATH, 'InnerA').new()
		assert_eq(inst.get_a(), 'a')

	func test_double_inner_does_not_call_supers():
		var inst = doubler.double_inner(INNER_CLASSES_PATH, 'InnerA').new()
		assert_eq(inst.get_a(), null)

	func test_can_make_partial_of_scene():
		var inst = autofree(doubler.partial_double_scene(DOUBLE_ME_SCENE_PATH).instance())
		assert_eq(inst.return_hello(), 'hello')

	func test_double_scene_does_not_call_supers():
		var inst = autofree(doubler.double_scene(DOUBLE_ME_SCENE_PATH).instance())
		assert_eq(inst.return_hello(), null)
		pause_before_teardown()

	func test_init_is_not_stubbed_to_call_super():
		var inst = doubler.partial_double(DOUBLE_ME_PATH).new()
		var text = get_instance_source(inst)
		assert_false(text.match("*__gut_should_call_super('_init'*"), 'should not call super _init')

	func test_can_partial_and_normal_double_in_same_test():
		var double = doubler.double(DOUBLE_ME_PATH).new()
		var p_double = doubler.partial_double(DOUBLE_ME_PATH).new()

		assert_null(double.get_value(), 'double get_value')
		assert_eq(p_double.get_value(), 0, 'partial get_value')
		print(doubler.get_stubber().to_s())


class TestDoubleGDNaviteClasses:
	extends BaseTest

	var _doubler = null
	var _stubber = _utils.Stubber.new()

	func before_each():
		_stubber.clear()
		_doubler = Doubler.new()
		_doubler.set_output_dir(TEMP_FILES)
		_doubler.set_stubber(_stubber)

	func after_each():
		_doubler.clear_output_directory()

	func test_can_double_Node2D():
		var d_node_2d = _doubler.double_gdnative(Node2D)
		assert_not_null(d_node_2d)

	func test_can_partial_double_Node2D():
		var pd_node_2d  = _doubler.partial_double_gdnative(Node2D)
		assert_not_null(pd_node_2d)


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

	func test_double_default_init_params():
		var doubled = double('res://test/unit/test_doubler.gd', 'TestAutofree/InitHasDefaultParams').new()
		assert_eq(doubled.a, 'asdf')

	func test_partial_double_default_init_params():
		var doubled = partial_double('res://test/unit/test_doubler.gd', 'TestAutofree/InitHasDefaultParams').new()
		assert_eq(doubled.a, 'asdf')


class TestDoubleSingleton:
	extends BaseTest

	var _doubler = null
	var _stubber = _utils.Stubber.new()

	func before_each():
		_stubber.clear()
		_doubler = Doubler.new()
		_doubler.set_output_dir(TEMP_FILES)
		_doubler.set_stubber(_stubber)
		_doubler._print_source = false

	func test_can_make_double_of_input():
		var Doubled = _doubler.double_singleton("Input")
		assert_not_null(Doubled)

	func test_can_make_instance_of_double():
		var doubled = _doubler.double_singleton("Input").new()
		assert_not_null(doubled)

	func test_double_gets_methods_from_input():
		var doubled = _doubler.double_singleton("Input").new()
		assert_true(doubled.has_method("action_press"))

	func test_normal_double_of_input_does_not_have_implementations():
		var doubled = _doubler.double_singleton("Input").new()
		assert_null(doubled.is_action_just_pressed())

	func test_partial_double_gets_implementation():
		var doubled = _doubler.partial_double_singleton("Input").new()
		assert_false(doubled.is_action_just_pressed("foobar"))

	func test_double_gets_constants():
		var doubled = _doubler.double_singleton("Input").new()
		assert_eq(doubled.CURSOR_VSPLIT, Input.CURSOR_VSPLIT)

	func test_partial_double_gets_wired_properties():
		var doubled = _doubler.partial_double_singleton("ARVRServer").new()
		assert_eq(doubled.world_scale, 1.0, "property")
		assert_eq(doubled.get_world_scale(), 1.0, "accessor")

	func test_partial_double_setters_are_wired_to_set_source_property():
		var doubled = _doubler.partial_double_singleton("ARVRServer").new()
		doubled.world_scale = 0.5
		assert_eq(ARVRServer.get_world_scale(), 0.5, "accessor")
		# make sure to put it back to what it was, who knows what it does.
		ARVRServer.world_scale = 1.0

	func test_double_gets_unwired_properties_by_default():
		var doubled = _doubler.double_singleton("ARVRServer").new()
		assert_null(doubled.world_scale)

	# These singletons were found using print_instanced_ClassDB_classes in
	# scratch/get_info.gd and are most likely the only singletons that
	# should be doubled as of now.
	var eligible_singletons = [
		"ARVRServer", "AudioServer", "CameraServer",
		"Engine", "Geometry", "Input",
		"InputMap", "IP", "JavaClassWrapper",
		"JavaScript", "JSON", "Marshalls",
		"OS", "Performance", "Physics2DServer",
		"PhysicsServer",
		"ProjectSettings", "ResourceLoader",
		"ResourceSaver", "TranslationServer", "VisualScriptEditor",
		"VisualServer",
		# these two were missed by print_instanced_ClassDB_classes but were in
		# the global scope list.
		"ClassDB", "EditorNavigationMeshGenerator"
	]
	func test_can_make_doubles_of_eligible_singletons(singleton = use_parameters(eligible_singletons)):
		assert_not_null(_doubler.double_singleton(singleton), singleton)

	# Note that setters aren't tested b/c picking valid values automatically is
	# an unreasonable approach and I didn't want to maintain a list.  If a setter
	# or getter method is not found when trying to make the double then an
	# error should be printed.  It seems safe to assume if the getters are wired
	# and there aren't any error messages when this test runs then the setters
	# are also wired.  A specific setter is tested in a previous test, just
	# not on all properties of all the eligible singletons.
	func test_property_getters_wired_for_partials_of_eligible_singletons(singleton = use_parameters(eligible_singletons)):
		var props = ClassDB.class_get_property_list(singleton)
		for prop in props:
			var double = partial_double_singleton(singleton).new()
			var parent_inst = _utils.get_singleton_by_name(singleton)
			assert_eq(double.get(prop["name"]), parent_inst.get(prop["name"]),
				str(singleton, ".", prop["name"]))

