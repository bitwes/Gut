extends GutInternalTester

var Stubs = GutUtils.Stubs
var StubParams = GutUtils.StubParams

func test_can_make_one():
	var s = Stubs.new()
	assert_not_null(s)


"""
var dbl = doubler.double_singleton(Input).new()
var method = 'is_action_just_pressed'
assert_eq(stubber.get_default_value(dbl, method, 0), null)
assert_eq(stubber.get_default_value(dbl, method, 1), false)
"""

func test_that_one_thing():
	var s = Stubs.new()
	var sp = StubParams.new(Input, GutUtils.find_method_meta(Input.get_method_list(), 'is_action_just_pressed'))
	s.add_stub(sp)
	var matches = s.get_all_stubs(Input, 'is_action_just_pressed')
	assert_eq(matches.size(), 1)
	if(is_failing()):
		print(s.to_s())

