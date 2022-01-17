extends GutTest

func test_manual_error():
	gut.get_logger().error("This is a manual error")
	pass_test('we did it')

func test_manual_warning():
	gut.get_logger().warn("This is a manual warning")
	pass_test('we did it')