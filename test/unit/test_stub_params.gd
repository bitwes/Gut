extends "res://addons/gut/test.gd"

# test.gd has a StubParams variable already so this has to have a
# different name.  I thought it was too vague to just use the one
# that test.gd has
var StubParamsClass = load('res://addons/gut/stub_params.gd')

var gr = {
	stub_params = null
}

func setup():
	gr.stub_params = StubParamsClass.new()

func test_to_return_sets_return_value():
    gr.stub_params.to_return(7)
    assert_eq(gr.stub_params.return_val, 7)

func test_to_return_returns_self():
    var thing = gr.stub_params.to_return(7)
    assert_eq(thing, gr.stub_params)

func test_init_sets_stub_target():
    var s = StubParamsClass.new('thing')
    assert_eq(s.stub_target, 'thing')

func test_init_sets_method():
	var s = StubParamsClass.new('thing', 'method')
	assert_eq(s.stub_method, 'method')

func test_when_passed_returns_self():
    var thing = gr.stub_params.when_passed(7)
    assert_eq(thing, gr.stub_params)

func test_when_passed_sets_parameters():
    gr.stub_params.when_passed(1)
    assert_eq(gr.stub_params.parameters, [1])

func test_parameters_turn_values_into_array():
	gr.stub_params.when_passed(1,2,3)
	assert_eq(gr.stub_params.parameters, [1,2,3])

func test_can_take_up_to_10_parameters():
	gr.stub_params.when_passed(1,2,3,4,5,6,7,8,9,10)
	assert_eq(gr.stub_params.parameters.size(), 10)
