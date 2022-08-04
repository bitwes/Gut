extends GutTest

class DoubleThis:
	func get_someting():
		return 'someting';

func test_assert_true():
	assert_true(true, 'this is true')

func test_simple_double():
	var ThisDouble = double(DoubleThis)
	var dthis = ThisDouble.new()
	stub(dthis, 'something').to_return('poop')
	assert_eq(dthis.something(), 'poop')
