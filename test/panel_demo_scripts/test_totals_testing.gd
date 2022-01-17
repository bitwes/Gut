extends GutTest

func test_passing_test():
	pass_test('did it!')
	
func test_failing_test():
	fail_test('did not do it!')

func test_generates_error():
	gut.get_logger().error('This is a manual error')
	pass_test('passing')
	
func test_generates_warning():
	gut.get_logger().warn("This is a manual warning")
	
func test_multiple_passing_asserts():
	assert_eq(1, 1)
	assert_eq(2, 2)
	assert_eq('a', 'a')
	
func test_makes_orphan():
	var orphan = Node2D.new()
	assert_true(true)
	
func test_pending():
	pending("this is pending")
	

