extends GutInternalTester


class FailTestClass:
	extends Node

	var should_stop_waiting: bool = false


	func returns_bool_with_await() -> bool:
		await get_tree().process_frame
		return true

	func test_no_return_type():
		pass

	func returns_node2d() -> Node2D:
		return Node2D.new()

	func returns_node2d_with_await() -> Node2D:
		await get_tree().process_frame
		return Node2D.new()

	func returns_variant_with_await() -> Variant:
		await get_tree().process_frame
		return 4

	func returns_ref_counted_with_await() -> RefCounted:
		await get_tree().process_frame
		return RefCounted.new()

	func returns_object_with_await() -> Object:
		await get_tree().process_frame
		return RefCounted.new()

	func returns_FailTestClass() -> FailTestClass:
		return FailTestClass.new()

	func returns_FailTestClass_with_await() -> FailTestClass:
		await get_tree().process_frame
		return FailTestClass.new()



func before_all():
	register_inner_classes(get_script())


func after_each():
	pass
	# gut.get_doubler()._method_return_types.clear()

func after_all():
	gut.get_doubler().print_source = false


func test_it() -> void:
	var dbl: FailTestClass = partial_double(FailTestClass).new()
	assert_not_null(dbl)


func test_it_with_setting_returns():
	var dbl: FailTestClass = double(FailTestClass).new()
	assert_not_null(dbl)


func test_it_again_since_this_was_failing_occassionally():
	var dbl: FailTestClass = partial_double(FailTestClass).new()
	assert_not_null(dbl)


func test_it_with_setting_return():
	var dbl: FailTestClass = double(FailTestClass).new()
	assert_not_null(dbl)


func test_all_returns():
	var Dbl = double(TestResourceAllReturnTypes)
	assert_false(typeof(Dbl) == TYPE_INT)
	var inst = Dbl.new()
	assert_not_null(inst)


func test_double_of_InputSender_wait_parses_frames():
	var sender = double(InputSender).new()
	stub(sender, 'wait').to_call_super()
	sender.wait('3f')
	assert_called(sender, 'wait_frames', [3.0])


func test_double_GutTest():
	var Dbl = double(GutTest)
	assert_not_null(Dbl)
