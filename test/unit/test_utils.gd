extends 'res://addons/gut/test.gd'

var Utils = load('res://addons/gut/utils.gd')

func test_can_make_one():
	assert_not_null(autofree(Utils.new()))

func test_is_double_returns_false_for_non_doubles():
	var utils = autofree(Utils.new())
	assert_false(utils.is_double(autofree(Node.new())))

func test_is_double_returns_true_for_doubles():
	var utils = autofree(Utils.new())
	var d = double(Node).new()
	assert_true(utils.is_double(d))

func test_is_double_returns_false_for_primitives():
	var utils = autofree(Utils.new())
	assert_false(utils.is_double('hello'), 'string')
	assert_false(utils.is_double(1), 'int')
	assert_false(utils.is_double(1.0), 'float')
	assert_false(utils.is_double([]), 'array')
	assert_false(utils.is_double({}), 'dictionary')
	# that's probably enough spot checking


class OverloadsGet:
	var a = []
	func get(index):
		return a[index]

func test_is_double_works_with_classes_that_overload_get():
	var og = autofree(OverloadsGet.new())
	var utils = autofree(Utils.new())
	assert_false(utils.is_double(og))

func test_is_instance_false_for_classes():
	var utils = autofree(Utils.new())
	assert_false(utils.is_instance(Node2D))

func test_is_instance_true_for_new():
	var utils = autofree(Utils.new())
	var n = Node.new()
	assert_true(utils.is_instance(n))

func test_is_instance_false_for_instanced_things():
	var utils = autofree(Utils.new())
	var i = load('res://test/resources/SceneNoScript.tscn')
	assert_false(utils.is_instance(i))
