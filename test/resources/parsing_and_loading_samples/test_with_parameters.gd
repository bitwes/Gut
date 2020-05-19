extends "res://addons/gut/test.gd"

func test_has_one_defaulted_parameter(p=null):
	assert_true(true, 'this one passes')

func test_has_two_parameters(p1=null, p2=null):
	assert_true(false, 'this one fails and shoul never be run')

func test_no_parameters():
	assert_true(true, 'this one passes')

class TestInnerClass:
	extends "res://addons/gut/test.gd"
	func test_inner_has_one_defaulted_parameter(p=null):
		assert_true(true, 'this one passes')

	func test_inner_has_two_parameters(p1=null, p2=null):
		assert_true(false, 'this one fails and shoul never be run')

	func test_inner_no_parameters():
		assert_true(true, 'this one passes')
