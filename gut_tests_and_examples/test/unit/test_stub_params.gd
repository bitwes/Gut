extends "res://addons/gut/test.gd"

var StubParams = load('res://addons/gut/stub_params.gd')

var gr = {
	stub_params = null
}

func setup():
	gr.stub_params = StubParams.new()

func test_to_return_sets_return_value():
    gr.stub_params.to_return(7)
    assert_eq(gr.stub_params.return_val, 7)

func test_to_return_returns_self():
    var thing = gr.stub_params.to_return(7)
    assert_eq(thing, gr.stub_params)

func test_init_sets_stub_target():
    var s = StubParams.new('thing')
    assert_eq(s.stub_target, 'thing')

func test_when_passed_sets_parameters():
    gr.stub_params.when_passed(1)
    assert_eq(gr.stub_params.parameters, 1)

func test_when_passed_returns_self():
    var thing = gr.stub_params.when_passed(7)
    assert_eq(thing, gr.stub_params)
