extends GutTest

class BaseTest:
	extends GutTest

	const DOUBLE_ME_PATH = 'res://test/resources/doubler_test_objects/double_me.gd'
	const DOUBLE_ME_SCENE_PATH = 'res://test/resources/doubler_test_objects/double_me_scene.tscn'
	const DOUBLE_EXTENDS_NODE2D = 'res://test/resources/doubler_test_objects/double_extends_node2d.gd'
	const DOUBLE_EXTENDS_WINDOW_DIALOG = 'res://test/resources/doubler_test_objects/double_extends_window_dialog.gd'
	const DOUBLE_WITH_STATIC = 'res://test/resources/doubler_test_objects/has_static_method.gd'

	var DoubleMe = load(DOUBLE_ME_PATH)
	var DoubleExtendsNode2D = load(DOUBLE_EXTENDS_NODE2D)
	var DoubleExtendsWindowDialog = load(DOUBLE_EXTENDS_WINDOW_DIALOG)
	var DoubleWithStatic = load(DOUBLE_WITH_STATIC)
	var DoubleMeScene = load(DOUBLE_ME_SCENE_PATH)

	var Doubler = load('res://addons/gut/new_doubler.gd')
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



class TestTheBasics:
	extends BaseTest

	var _doubler = null

	var stubber = _utils.Stubber.new()
	func before_each():
		stubber.clear()
		_doubler = Doubler.new()
		_doubler.set_stubber(stubber)
		_doubler.set_gut(gut)
		_doubler.print_source = false

	func test_get_set_stubber():
		var dblr = Doubler.new()
		var default_stubber = dblr.get_stubber()
		assert_accessors(dblr, 'stubber', default_stubber, GDScript.new())

	func test_can_get_set_spy():
		assert_accessors(Doubler.new(), 'spy', null, GDScript.new())

	func test_get_set_gut():
		assert_accessors(Doubler.new(), 'gut', null, GDScript.new())

	func test_get_set_logger():
		assert_ne(_doubler.get_logger(), null)
		var l = load('res://addons/gut/logger.gd').new()
		_doubler.set_logger(l)
		assert_eq(_doubler.get_logger(), l)

	func test_doubler_sets_logger_of_method_maker():
		assert_eq(_doubler.get_logger(), _doubler._method_maker.get_logger())

	func test_setting_logger_sets_it_on_method_maker():
		var l = load('res://addons/gut/logger.gd').new()
		_doubler.set_logger(l)
		assert_eq(_doubler.get_logger(), _doubler._method_maker.get_logger())

	func test_get_set_strategy():
		assert_accessors(_doubler, 'strategy', _utils.DOUBLE_STRATEGY.SCRIPT_ONLY,  _utils.DOUBLE_STRATEGY.INCLUDE_SUPER)

	func test_can_set_strategy_in_constructor():
		var d = Doubler.new(_utils.DOUBLE_STRATEGY.INCLUDE_SUPER)
		assert_eq(d.get_strategy(), _utils.DOUBLE_STRATEGY.INCLUDE_SUPER)


class TestDoublingScripts:
	extends BaseTest

	var _doubler = null

	var stubber = _utils.Stubber.new()
	func before_each():
		stubber.clear()
		_doubler = Doubler.new()
		_doubler.set_stubber(stubber)
		_doubler.set_gut(gut)
		_doubler.print_source = false


	func test_doubling_object_includes_methods():
		var inst = _doubler.double(DoubleMe).new()
		assert_source_contains(inst, 'func get_value(')
		assert_source_contains(inst, 'func set_value(')

	func test_doubling_methods_have_parameters_1():
		var inst = _doubler.double(DoubleMe).new()
		assert_source_contains(inst, 'has_one_param(p_one=', 'first parameter for one param method is defined')

	# Don't see a way to see which have defaults and which do not, so we default
	# everything.
	func test_all_parameters_are_defaulted_to_null():
		var inst = _doubler.double(DoubleMe).new()
		assert_source_contains(inst,
			'has_two_params_one_default(' +
			'p_one=__gutdbl.default_val("has_two_params_one_default",0), '+
			'p_two=__gutdbl.default_val("has_two_params_one_default",1))')
		# assert_true(text.match('*has_two_params_one_default(p_arg0=__gut_default_val("has_two_params_one_default",0), p_arg1=__gut_default_val("has_two_params_one_default",1))*'))

	func test_doubled_thing_includes_stubber_metadata():
		var doubled = _doubler.double(DoubleMe).new()
		assert_ne(doubled.get('__gutdbl'), null)

	func test_doubled_thing_has_original_path_in_metadata():
		var doubled = _doubler.double(DoubleMe).new()
		assert_eq(doubled.__gutdbl.thepath, DOUBLE_ME_PATH)

	func test_doublecd_thing_has_gut_metadata():
		var doubled = _doubler.double(DoubleMe).new()
		assert_eq(doubled.__gutdbl.gut, gut)

	func test_keeps_extends():
		pending('Crashes hard in 4.0 a16 on assert_is')
		var doubled = _doubler.double(DoubleExtendsNode2D).new()
		# assert_is(doubled, Node2D)

	func test_does_not_add_duplicate_methods():
		var TheClass = load('res://test/resources/parsing_and_loading_samples/extends_another_thing.gd')
		_doubler.double(TheClass)
		assert_true(true, 'If we get here then the duplicates were removed.')


	func test_returns_class_that_can_be_instanced():
		var Doubled = _doubler.double(DoubleMe)
		var doubled = Doubled.new()
		assert_ne(doubled, null)

	func test_doubles_retain_signals():
		var d = _doubler.double(DOUBLE_ME_PATH).new()
		assert_has_signal(d, 'signal_signal')


class TestAddingIgnoredMethods:
	extends BaseTest
	var _doubler = null

	var stubber = _utils.Stubber.new()
	func before_each():
		stubber.clear()
		_doubler = Doubler.new()
		_doubler.set_stubber(stubber)
		_doubler.set_gut(gut)
		_doubler.print_source = false

	func test_can_add_to_ignore_list():
		assert_eq(_doubler.get_ignored_methods().size(), 0, 'initial size')
		_doubler.add_ignored_method(DoubleWithStatic, 'some_method')
		assert_eq(_doubler.get_ignored_methods().size(), 1, 'after add')

	func test_when_ignored_methods_are_a_local_method_mthey_are_not_present_in_double_code():
		_doubler.add_ignored_method(DoubleMe, 'has_one_param')
		var c = _doubler.double(DoubleMe)
		assert_source_not_contains(c.new(), 'has_one_param')

	func test_when_ignored_methods_are_a_super_method_they_are_not_present_in_double_code():
		_doubler.add_ignored_method(DoubleMe, 'is_connected')
		var c = _doubler.double(DoubleMe, _utils.DOUBLE_STRATEGY.INCLUDE_SUPER)
		assert_source_not_contains(c.new(), 'is_connected')

	func test_can_double_classes_with_static_methods():
		_doubler.add_ignored_method(DoubleWithStatic, 'this_is_a_static_method')
		var d = _doubler.double(DoubleWithStatic).new()
		assert_null(d.this_is_not_static())


class TestDoubleScene:
	extends BaseTest
	var _doubler = null

	var stubber = _utils.Stubber.new()
	func before_each():
		stubber.clear()
		_doubler = Doubler.new()
		_doubler.set_stubber(stubber)
		_doubler.set_gut(gut)
		_doubler.print_source = false

	func test_can_double_scene():
		var obj = _doubler.double_scene(DoubleMeScene)
		var inst = obj.instantiate()
		assert_eq(inst.return_hello(), null)

	func test_can_add_doubled_scene_to_tree():
		var inst = _doubler.double_scene(DoubleMeScene).instantiate()
		add_child(inst)
		assert_ne(inst.label, null)
		remove_child(inst)

	func test_metadata_for_scenes_script_points_to_scene_not_script():
		var inst = _doubler.double_scene(DoubleMeScene).instantiate()
		assert_eq(inst.__gutdbl.thepath, DOUBLE_ME_SCENE_PATH)

	func test_can_override_strategy_when_doubling_scene():
		_doubler.set_strategy(_utils.DOUBLE_STRATEGY.SCRIPT_ONLY)
		var inst = autofree(_doubler.double_scene(DoubleMeScene, _utils.DOUBLE_STRATEGY.INCLUDE_SUPER).instantiate())
		assert_source_contains(inst, 'func is_blocking_signals')

	func test_full_start_has_block_signals():
		_doubler.set_strategy(_utils.DOUBLE_STRATEGY.INCLUDE_SUPER)
		var inst = autofree(_doubler.double_scene(DoubleMeScene).instantiate())
		assert_source_contains(inst, 'func is_blocking_signals')


class TestDoubleStrategyIncludeSuper:
	extends BaseTest


	func _hide_call_back():
		pass

	var doubler = null
	var stubber = _utils.Stubber.new()

	func before_all():
		var d = Doubler.new(_utils.DOUBLE_STRATEGY.INCLUDE_SUPER)


	func before_each():
		stubber.clear()
		doubler = Doubler.new(_utils.DOUBLE_STRATEGY.INCLUDE_SUPER)
		doubler.set_stubber(stubber)


	func test_built_in_overloading_ony_happens_on_full_strategy():
		doubler.set_strategy(_utils.DOUBLE_STRATEGY.SCRIPT_ONLY)
		var inst = doubler.double(DoubleMe).new()
		var txt = get_source(inst)
		assert_false(txt == '', "text is not empty")
		assert_source_not_contains(inst, 'func is_blocking_signals', 'does not have non-overloaded methods')

	func test_can_override_strategy_when_doubling_script():
		doubler.set_strategy(_utils.DOUBLE_STRATEGY.SCRIPT_ONLY)
		var inst = doubler.double(DoubleMe, _utils.DOUBLE_STRATEGY.INCLUDE_SUPER).new()
		assert_source_contains(inst, 'func is_blocking_signals')

	func test_when_everything_included_you_can_still_make_an_a_new_object():
		var inst = doubler.double(DoubleMe).new()
		assert_ne(inst, null)

	func test_when_everything_included_you_can_still_make_a_new_node2d():
		var inst = autofree(doubler.double(DoubleExtendsNode2D).new())
		assert_ne(inst, null)

	func test_when_everything_included_you_can_still_double_a_scene():
		pending('YIELD')
		return

		var inst = autofree(doubler.double_scene(DOUBLE_ME_SCENE_PATH).instantiate())
		add_child(inst)
		assert_ne(inst, null, "instantiate is not null")
		assert_ne(inst.label, null, "Can get to a label on the instantiate")
		# pause so _process gets called
		await yield_for(3).YIELD

	func test_double_includes_methods_in_super():
		var inst = doubler.double(DoubleExtendsWindowDialog).new()
		assert_source_contains(inst, 'connect(')

	func test_can_call_a_built_in_that_has_default_parameters():
		pending('have to rework defaults')
		return

		var inst = autofree(doubler.double(DoubleExtendsWindowDialog).new())
		inst.connect('hide', self._hide_call_back)
		pass_test("if we got here, it worked")


	func test_doubled_builtins_call_super():
		var inst = autofree(doubler.double(DoubleExtendsWindowDialog).new())
		# Make sure the function is in the doubled class definition
		assert_source_contains(inst, 'func add_user_signal(p_signal')
		# Make sure that when called it retains old functionality.
		inst.add_user_signal('new_one', [])
		inst.add_user_signal('new_two', ['a', 'b'])
		assert_has_signal(inst, 'new_one')
		assert_has_signal(inst, 'new_two')

	func test_doubled_builtins_are_added_as_stubs_to_call_super():
		var inst = autofree(doubler.double(DoubleExtendsWindowDialog).new())
		assert_true(doubler.get_stubber().should_call_super(inst, 'add_user_signal'))
