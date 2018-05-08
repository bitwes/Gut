extends 'res://addons/gut/test.gd'



class TestSpy:
	extends 'res://addons/gut/test.gd'

	var Spy = load('res://addons/gut/spy.gd')
	var Simple = load('res://test/spy_test_objects/simple.gd')

	var _spy = null

	func setup():
		_spy = Spy.new()

	func test_can_add_call_to_method_on_path():
		_spy.add_call('nothing', 'method_name')

	func test_can_add_call_to_method_on_instance():
		var simple = Simple.new()
		_spy.add_call(simple, 'method_name')

	func test_was_called_returns_true_if_path_and_method_were_called():
		var simple = Simple.new()
		_spy.add_call(simple, 'method_name')
		assert_true(_spy.was_called(simple, 'method_name'))

	func test_can_check_if_instance_method_called():
		var simple = Simple.new()
		_spy.add_call(simple, 'method_name')
		assert_true(_spy.was_called(simple, 'method_name'))

	func test_if_method_was_not_called_then_was_called_returns_false():
		assert_false(_spy.was_called(Simple.new(), 'method_name'))

	func test_adding_second_call_does_not_overwrite_first():
		var simple = Simple.new()
		_spy.add_call(simple, 'method1')
		_spy.add_call(simple, 'method2')
		assert_true(_spy.was_called(simple, 'method1'))

	func test_was_called_with_no_parameters_returns_true_for_parameterized_calls():
		var simple = Simple.new()
		_spy.add_call(simple, 'method1', [1])
		_spy.add_call(simple, 'method1', [2])
		_spy.add_call(simple, 'method1', [3])
		assert_true(_spy.was_called(simple, 'method1'))

class TestAddingCallsWithParameters:
	extends 'res://addons/gut/test.gd'

	var Spy = load('res://addons/gut/spy.gd')
	var Simple = load('res://test/spy_test_objects/simple.gd')

	var _spy = null

	func setup():
		_spy = Spy.new()

	func test_can_add_call_with_parameters():
		_spy.add_call(Simple.new(), 'method1', [1])

	func test_can_check_for_calls_with_parameters():
		var simple = Simple.new()
		_spy.add_call(simple, 'method1', [1])
		assert_true(_spy.was_called(simple, 'method1', [1]))

	func test_when_params_dont_match_was_called_is_false():
		var simple = Simple.new()
		_spy.add_call(simple, 'method1', [1])
		assert_false(_spy.was_called(simple, 'method1', [2]))

class TestGetCallCount:
	extends 'res://addons/gut/test.gd'

	var Spy = load('res://addons/gut/spy.gd')
	var Simple = load('res://test/spy_test_objects/simple.gd')
	var _spy = null

	func setup():
		_spy = Spy.new()

	func test_when_no_calls_found_call_count_returns_0():
		var count = _spy.call_count(Simple.new(), 'method1')
		assert_eq(count, 0)

	func test_when_has_been_called_one_returned():
		var simple = Simple.new()
		_spy.add_call(simple, 'method1')
		assert_eq(_spy.call_count(simple, 'method1'), 1)

	func test_when_called_multiple_times_the_right_count_is_returned():
		var simple = Simple.new()
		for i in range(10):
			_spy.add_call(simple, 'method1')
		assert_eq(_spy.call_count(simple, 'method1'), 10)

	func test_can_get_count_called_with_parameters():
		var simple = Simple.new()
		_spy.add_call(simple, 'method1', [1])
		_spy.add_call(simple, 'method1', [1])
		_spy.add_call(simple, 'method1', [2])
		assert_eq(_spy.call_count(simple, 'method1', [1]), 2)

	func test_when_no_parameters_match_0_returned():
		var simple = Simple.new()
		_spy.add_call(simple, 'method1', [1])
		_spy.add_call(simple, 'method1', [2])
		assert_eq(_spy.call_count(simple, 'method1', [3]), 0)
