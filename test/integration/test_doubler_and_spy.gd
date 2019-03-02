extends 'res://test/gut_test.gd'

const TEMP_FILES = 'user://test_doubler_and_spy'

#const DOUBLE_ME_PATH = 'res://test/resources/doubler_test_objects/double_me.gd'
#Aconst DOUBLE_ME_SCENE_PATH = 'res://test/resources/doubler_test_objects/double_me_scene.tscn'
#const DOUBLE_EXTENDS_NODE2D = 'res://test/resources/doubler_test_objects/double_extends_node2d.gd'

class TestBoth:
	extends 'res://addons/gut/test.gd'

	var Doubler = load('res://addons/gut/doubler.gd')
	var Spy = load('res://addons/gut/spy.gd')

	var _spy = null
	var _doubler = null

	func before_each():
		_spy = Spy.new()
		_doubler = Doubler.new()
		_doubler.set_output_dir(TEMP_FILES)
		_doubler.set_spy(_spy)

	func after_each():
		_doubler.clear_output_directory()
		_spy.clear()

	func test_spy_is_set_in_metadata():
		var inst = _doubler.double(DOUBLE_ME_PATH).new()
		assert_eq(inst.__gut_metadata_.spy, _spy)

	func test_when_doubled_method_called_spy_sees_it():
		var inst = _doubler.double(DOUBLE_ME_PATH).new()
		inst.set_value(5)
		assert_true(_spy.was_called(inst, 'set_value'))

	func test_when_doubled_method_called_it_sends_parameters():
		var inst = _doubler.double(DOUBLE_ME_PATH).new()
		inst.set_value(5)
		assert_true(_spy.was_called(inst, 'set_value', [5]))

	func test_it_works_with_two_parameters_too():
		var inst = _doubler.double(DOUBLE_ME_PATH).new()
		inst.has_two_params_one_default('a', 'b')
		assert_false(_spy.was_called(inst, 'has_two_params_one_default', ['c', 'd']), 'should not match')
		assert_true(_spy.was_called(inst, 'has_two_params_one_default', ['a', 'b']), 'should match')

	func test_can_spy_on_built_ins_when_doing_a_full_double():
		_doubler.set_strategy(DOUBLE_STRATEGY.FULL)
		var inst = _doubler.double(DOUBLE_ME_PATH).new()
		# add_user_signal is a function on Object that isn't in our subclass.
		inst.add_user_signal('new_signal')
		inst.add_user_signal('signal_with_params', ['a', 'b'])
		assert_true(_spy.was_called(inst, 'add_user_signal'), 'added first signal')
		assert_true(_spy.was_called(inst, 'add_user_signal', ['signal_with_params', ['a', 'b']]), 'second signal added')
