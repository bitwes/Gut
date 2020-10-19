extends 'res://addons/gut/test.gd'

var CompareResult = _utils.CompareResult

func test_can_make_one():
	var c  = CompareResult.new()
	assert_not_null(c)

func test_get_set_equal():
	var c = CompareResult.new()
	assert_accessors(c, 'are_equal', null, true)

func test_get_set_summary():
	var  c = CompareResult.new()
	assert_accessors(c, 'summary', null, 'asdf')

