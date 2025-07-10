extends GutTest

var Doubler = load('res://addons/gut/doubler.gd')

func test_can_make_a_double_of_node():
	var doubler = Doubler.new()
	doubler.print_source = true
	var d = doubler.double_gdnative(Node)
	assert_not_null(d)

func test_this_fails_until_varargs_are_included():
	var doubler = Doubler.new()
	var d = doubler.double_gdnative(Node)
	var source = d.get_source_code()
	assert_string_contains(source, "func rpc(")
