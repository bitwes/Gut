extends GutTest


class FailTestClass:
	extends Node

	var should_stop_waiting: bool = false


	func bool_await() -> bool:
		await get_tree().process_frame
		return true

	func test_no_return_type():
		pass

	func returns_node2d() -> Node2D:
		return Node2D.new()

	func returns_node2d_with_await() -> Node2D:
		await get_tree().process_frame
		return Node2D.new()


func before_all():
	register_inner_classes(get_script())


func test_it_1() -> void:
	var dbl: FailTestClass = partial_double(FailTestClass).new()
	assert_not_null(dbl)


func test_it_2():
	var dbl: FailTestClass = partial_double(FailTestClass).new()
	assert_not_null(dbl)


func test_all_returns():
	var Dbl = double(TestResourceAllReturnTypes)
	assert_false(typeof(Dbl) == TYPE_INT)
	var inst = Dbl.new()
	assert_not_null(inst)


func test_all_returns_again():
	var Dbl = double(TestResourceAllReturnTypes)
	assert_false(typeof(Dbl) == TYPE_INT)
	var inst = Dbl.new()
	assert_not_null(inst)


func test_all_returns_again_again():
	var Dbl = double(TestResourceAllReturnTypes)
	assert_false(typeof(Dbl) == TYPE_INT)
	var inst = Dbl.new()
	assert_not_null(inst)


func test_wait_parses_frames():
	var sender = double(InputSender).new()
	stub(sender, 'wait').to_call_super()
	sender.wait('3f')
	assert_called(sender, 'wait_frames', [3.0])


func test_wait_parses_seconds():
	var sender = double(InputSender).new()
	stub(sender, 'wait').to_call_super()
	sender.wait('2s')
	assert_called(sender, 'wait_secs', [2.0])
