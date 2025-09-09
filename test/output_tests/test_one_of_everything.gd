extends GutTest


func test_failing():
	assert_false(true)

func test_passing():
	assert_true(true)

func test_pending():
	pending('This is pending')

func test_risky_no_assert():
	var _a = 'b'
	pass

func test_push_error():
	push_error('test error')
	assert_true(true)
	
func test_expected_push_error():
	push_error('test error')
	assert_push_error('test error')

func test_gut_warning():
	gut.get_logger().warn('test warning')
	assert_eq(1, 1)
	
func test_gut_error():
	gut.get_logger().error("test gut error")
	assert_between(2, 1, 3)

func test_makes_an_orphan():
	var _n = Node.new()
	assert_no_new_orphans()
