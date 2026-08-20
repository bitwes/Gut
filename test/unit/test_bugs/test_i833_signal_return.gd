extends GutInternalTester


class ReturnsSignal:
	signal finished

	func get_finished() -> Signal:
		return finished


func before_all():
	register_inner_classes(get_script())


func test_typed_signal_return_is_not_wrapped():
	var doubled = partial_double(ReturnsSignal).new()
	assert_tracked_gut_error_text(gut,
		"Cannot double method 'get_finished' because it returns a Signal.")
	assert_does_not_have(doubled.__gutdbl_values.doubled_methods, 'get_finished')
	assert_typeof(doubled.get_finished(), TYPE_SIGNAL)


func test_typed_signal_return_can_be_explicitly_ignored():
	ignore_method_when_doubling(ReturnsSignal, 'get_finished')
	var doubled = partial_double(ReturnsSignal).new()
	assert_tracked_gut_error(gut, 0)
	assert_does_not_have(doubled.__gutdbl_values.doubled_methods, 'get_finished')
	assert_typeof(doubled.get_finished(), TYPE_SIGNAL)
