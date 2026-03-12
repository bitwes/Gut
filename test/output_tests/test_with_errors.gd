extends GutTest

func _generate_a_push_error():
	push_error("hello push_error")

func test_with_push_error():
	push_error('this is a push error')
	pass_test('has push_error')


func test_forced_engine_error() -> void:
	OS.delay_usec(-10)
	pass_test('has forced engine error')


func test_gut_error():
	gut.get_logger().error("manual error")
	pass_test('has a gut error')


func test_failing():
	assert_false(true)


func test_with_two_push_error():
	push_error('this is a push error')
	_generate_a_push_error()
	pass_test('has push_error')


func test_with_two_forced_engine_error() -> void:
	OS.delay_usec(-10)
	OS.delay_usec(-11)
	pass_test('has forced engine error')


func test_with_two_gut_error():
	gut.get_logger().error("manual error")
	gut.get_logger().error("error again")
	pass_test('has a gut error')



class TestInnerClassOutput:
	extends GutTest

	func test_with_push_error():
		push_error('this is a push error')
		pass_test('has push_error')


	func test_forced_engine_error() -> void:
		OS.delay_usec(-10)
		pass_test('has forced engine error')


	func test_gut_error():
		gut.get_logger().error("manual error")
		pass_test('has a gut error')


	func test_failing():
		assert_false(true)
