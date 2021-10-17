extends "res://addons/gut/test.gd"

# test.gd has a StubParams variable already so this has to have a
# different name.  I thought it was too vague to just use the one
# that test.gd has
var StubParamsClass = load('res://addons/gut/stub_params.gd')

var gr = {
	stub_params = null
}

func before_each():
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

func test_init_sets_subpath():
	var s = StubParamsClass.new('thing', 'method', 'inner1/inner2')
	assert_eq(s.target_subpath, 'inner1/inner2')

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

func test_can_set_to_call_super():
	gr.stub_params.to_call_super()
	assert_eq(gr.stub_params.call_super, true)

func test_to_call_super_returns_self():
	var val = gr.stub_params.to_call_super()
	assert_eq(val, gr.stub_params)

func test_param_count_returns_null():
	var val = gr.stub_params.param_count(3)
	assert_null(val);

func test_param_count_sets_param_count():
	var val = gr.stub_params.param_count(3)
	assert_eq(gr.stub_params.parameter_count, 3)

func test_param_count_default_value():
	assert_eq(gr.stub_params.parameter_count, -1)

func test_param_defaults_returns_null():
	var val = gr.stub_params.param_defaults([])
	assert_null(val)

func test_param_defaults_sets_parameter_count():
	gr.stub_params.param_defaults([1, 2, 3])
	assert_eq(gr.stub_params.parameter_count, 3)

func test_parameter_defaults_is_null_by_default():
	assert_null(gr.stub_params.parameter_defaults)

func test_param_defaults_set_parameter_defaults():
	gr.stub_params.param_defaults([1, 2, 3])
	assert_eq(gr.stub_params.parameter_defaults, [1, 2, 3])

func test_has_param_override_is_false_by_default():
	assert_false(gr.stub_params.has_param_override())

func test_when_param_count_set_has_param_override_is_true():
	gr.stub_params.param_count(3)
	assert_true(gr.stub_params.has_param_override())