extends 'res://test/gut_test.gd'

const TEMP_FILES = 'user://test_doubler_and_spy'

class TestBoth:
	extends 'res://test/gut_test.gd'

	var Doubler = load('res://addons/gut/doubler.gd')

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

	func test_can_spy_on_native_doubles():
		var inst  = _doubler.partial_double_gdnative(Node2D).new()
		inst.set_position(Vector2(20, 20))
		assert_true(_spy.was_called(inst, 'set_position'))
		assert_true(_spy.was_called(inst, 'set_position', [Vector2(20, 20)]))

	func test_can_spy_on_overidden_parameters():
		# this is required or gut won't find the rpc_id method
		_doubler.set_strategy(DOUBLE_STRATEGY.FULL)
		var path = 'res://test/resources/doubler_test_objects/double_extends_node2d.gd'
		_doubler.get_method_maker().add_parameter_override(
			path, 'rpc_id', 3)
		var inst = _doubler.double(path).new()
		# This part shouldn't be in this script b/c we shouldn't be doing
		# anything with the stubber, but for some reason DOUBLE_STRATEGY.FULL
		# calls super by default for these built-in methods.
		var sp = _utils.StubParams.new(path, 'rpc_id')
		sp.to_do_nothing()
		_doubler.get_stubber().add_stub(sp)
		add_child(inst)
		inst.rpc_id(1, 'b', 'c')
		assert_true(_spy.was_called(inst, 'rpc_id', [1, 'b', 'c']))
