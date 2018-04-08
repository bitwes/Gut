extends "res://addons/gut/test.gd"
func prerun_setup():
	gut.p('script:  pre-run')
func setup():
	gut.p('script:  setup')
func teardown():
	gut.p('script:  teardown')
func postrun_teardown():
	gut.p('script:  post-run')

func test_soemthing():
	assert_true(true)

func test_nothing():
	assert_true(false)

class TestClass1:
	extends "res://addons/gut/test.gd"
	func prerun_setup():
		gut.p('TestClass1:  pre-run')
	func setup():
		gut.p('TestClass1:  setup')
	func teardown():
		gut.p('TestClass1:  teardown')
	func postrun_teardown():
		gut.p('TestClass1:  post-run')

	func test_context1_one():
		assert_true(true)
	func test_context1_two():
		pending()
	func test_failing():
		assert_eq(2, 1)
	func print_something():
		print('hello world')

class NotTestClass:
	func test_something():
		assert_true(true)
	func not_a_test():
		pass
