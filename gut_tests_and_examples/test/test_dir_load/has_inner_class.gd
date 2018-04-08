extends "res://addons/gut/test.gd"
func test_soemthing():
	pass

func test_nothing():
	pass

class TestClass1:
	extends "res://addons/gut/test.gd"
	func test_context1_one():
		pass
	func test_context1_two():
		pass
	func print_something():
		print('hello world')

class NotTestClass:
	func test_something():
		pass
	func not_a_test():
		pass
