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
	assert_ne(source.find("func rpc("), -1, "Found func decleration text")
	var inst = d.new()
	assert_ne(inst.__gutdbl_values.doubled_methods.find("rpc"), -1, 'Found rpc in list of doubled method')
	assert_ne(inst.__gutdbl_values.doubled_methods.find("call_deferred"), -1, "found call_deferred in list of doubled methods")
