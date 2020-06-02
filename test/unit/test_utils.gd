extends 'res://addons/gut/test.gd'

var Utils = load('res://addons/gut/utils.gd')

func test_can_make_one():
	assert_not_null(Utils.new())

func test_is_double_returns_false_for_non_doubles():
	var utils = Utils.new()
	assert_false(utils.is_double(Node.new()))

func test_is_double_returns_true_for_doubles():
	var utils = Utils.new()
	var d = double(Node).new()
	assert_true(utils.is_double(d))

func test_is_double_returns_false_for_primitives():
	var utils = Utils.new()
	assert_false(utils.is_double('hello'), 'string')
	assert_false(utils.is_double(1), 'int')
	assert_false(utils.is_double(1.0), 'float')
	assert_false(utils.is_double([]), 'array')
	assert_false(utils.is_double({}), 'dictionary')
	# that's probably enough spot checking


