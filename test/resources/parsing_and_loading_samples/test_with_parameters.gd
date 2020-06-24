extends "res://addons/gut/test.gd"

func test_has_one_defaulted_parameter(p=use_parameters(['a'])):
	assert_true(true, 'this one passes')

func test_has_two_parameters(p1=null, p2=null):
	assert_true(false, 'Should not see this.  This should not be run.')

func test_no_parameters():
	assert_true(true, 'this one passes')

func test_has_three_values_for_parameters(p=use_parameters([['a', 'a'], ['b', 'b'], ['c', 'c']])):
	assert_eq(p[0], p[1])

func test_does_not_use_use_parameters(p=null):
	assert_true(true, 'this passes but should never be called more than once.')

func test_three_values_and_a_yield(p=use_parameters([['a', 'a'], ['b', 'b'], ['c', 'c']])):
	yield(yield_for(.2), YIELD)
	assert_eq(p[0], p[1])


class TestInnerClass:
	extends "res://addons/gut/test.gd"
	func test_inner_has_one_defaulted_parameter(p=null):
		assert_true(true, 'this one passes')

	func test_inner_has_two_parameters(p1=null, p2=null):
		assert_true(false, 'Should not see this.  This should not be run.')

	func test_inner_no_parameters():
		assert_true(true, 'this one passes')
