extends GutInternalTester

var DoubleTools = load("res://addons/gut/double_tools.gd")
var Stubber = load("res://addons/gut/stubber.gd")
var StubParams = load("res://addons/gut/stub_params.gd")

class FakeBase:
	var foo = 'foo'

	func set_foo(val):
		foo = val


class FakeDouble:
	extends FakeBase





var call_this_was_called = false
func call_this(value):
	call_this_was_called = value

func before_each():
	call_this_was_called = false


func test_can_make_one():
	assert_not_null(DoubleTools.new())

func test_get_method_to_call_returns_null_when_not_stubbed():
	var fd = FakeDouble.new()
	var stbr = Stubber.new()

	var dt = DoubleTools.new()
	dt.stubber = stbr
	dt.double = fd

	assert_null(dt.get_method_to_call('set_foo', [1]))


func test_get_method_to_call_returns_the_stubbed_method():
	var fd = FakeDouble.new()

	var sp = StubParams.new(fd.set_foo)
	sp.to_call(call_this)

	var stbr = Stubber.new()
	stbr.add_stub(sp)

	var dt = DoubleTools.new()
	dt.stubber = stbr
	dt.double = fd

	var result = dt.get_method_to_call('set_foo', [1])
	assert_eq(result.get_object(), self, "object")
	assert_eq(result.get_method(), "call_this", "method")


func test_calling_the_method_uses_parameters_passed():
	var fd = FakeDouble.new()

	var sp = StubParams.new(fd.set_foo)
	sp.to_call(call_this)

	var stbr = Stubber.new()
	stbr.add_stub(sp)

	var dt = DoubleTools.new()
	dt.stubber = stbr
	dt.double = fd

	var result = dt.get_method_to_call('set_foo', [1])
	result.call()
	assert_eq(call_this_was_called, 1)


# func test_print_source():
# 	gut.get_doubler().print_source = true
# 	var d = double(DoubleMe).new()
# 	gut.get_doubler().print_source = false
