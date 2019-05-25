extends "res://test/gut_test.gd"

var Stubber = load('res://addons/gut/stubber.gd')
# test.gd has a StubParams variable already so this has to have a
# different name.  I thought it was too vague to just use the one
# that test.gd has
var StubParamsClass = load('res://addons/gut/stub_params.gd')

const TO_STUB_PATH = 'res://test/resources/stub_test_objects/to_stub.gd'
var ToStub = load(TO_STUB_PATH)

const HAS_STUB_METADATA_PATH = 'res://test/resources/stub_test_objects/has_stub_metadata.gd'
var HasStubMetadata = load(HAS_STUB_METADATA_PATH)

var gr = {
	stubber = null
}

func print_info(c):
	print('---------')
	for i in range(c.get_method_list().size()):
		print(i, '.  ', c.get_method_list()[i]['name'])
	for i in range(c.get_property_list().size()):
		print(i, '.  ', c.get_property_list()[i], ' = ', c.get(c.get_property_list()[i]['name']))
	print('path = ', c.resource_path)
	print('source = ', c.get_path())
	print('meta = ', c.get_meta_list())
	print('class = ', c.get_class())
	print('script of inst = ', c.new().get_script().get_path())

func before_each():
	gr.stubber = Stubber.new()

func test_has_logger():
	assert_has_logger(gr.stubber)

func test_can_set_return():
	gr.stubber.set_return('some_path', 'some_method', 7)

func test_can_get_return_value():
	gr.stubber.set_return('some_path', 'some_method', 7)
	var value = gr.stubber.get_return('some_path', 'some_method')
	assert_eq(value, 7)

func test_can_get_return_for_multiple_methods():
	gr.stubber.set_return('some_path', 'method1', 1)
	gr.stubber.set_return('some_path', 'method2', 2)
	assert_eq(gr.stubber.get_return('some_path', 'method1'), 1, 'method1 returns 1')
	assert_eq(gr.stubber.get_return('some_path', 'method2'), 2, 'method1 returns 2')

func test_can_set_return_with_class():
	gr.stubber.set_return(ToStub, 'get_value', 0)
	assert_eq(gr.stubber.get_return(ToStub, 'get_value'), 0)

func test_getting_return_for_thing_that_does_not_exist_returns_null():
	var value = gr.stubber.get_return('nothing', 'something')
	assert_eq(value, null)

func test_getting_return_for_thing_that_does_not_exist_generates_info():
	var value = gr.stubber.get_return('nothing', 'something')
	assert_eq(gr.stubber.get_logger().get_infos().size(), 1)

func test_can_get_return_value_for_class_using_path():
	gr.stubber.set_return(ToStub, 'get_value', 0)
	var value = gr.stubber.get_return(TO_STUB_PATH, 'get_value')
	assert_eq(value, 0)

func test_can_get_return_value_using_an_instance_of_class():
	gr.stubber.set_return(ToStub, 'get_value', 0)
	var inst = ToStub.new()
	var value = gr.stubber.get_return(inst, 'get_value')
	assert_eq(value, 0)

func test_instance_stub_takes_precedence_over_path_stub():
	gr.stubber.set_return(TO_STUB_PATH, 'get_value', 0)
	var inst = ToStub.new()
	gr.stubber.set_return(inst, 'get_value', 100)
	var value = gr.stubber.get_return(inst, 'get_value')
	assert_eq(value, 100)

func test_instance_stub_not_used_for_path_stub():
	gr.stubber.set_return(TO_STUB_PATH, 'get_value', 0)
	var inst = ToStub.new()
	gr.stubber.set_return(inst, 'get_value', 100)
	var value = gr.stubber.get_return(TO_STUB_PATH, 'get_value')
	assert_eq(value, 0)

func test_returns_can_be_layered():
	gr.stubber.set_return(TO_STUB_PATH, 'get_value', 0)
	var inst = ToStub.new()
	gr.stubber.set_return(inst, 'get_other', 100)
	assert_eq(gr.stubber.get_return(inst, 'get_value'), 0, 'unstubbed instance method should get class value')
	assert_eq(gr.stubber.get_return(inst, 'get_other'), 100, 'stubbed instance method should get inst value')
	assert_eq(gr.stubber.get_return(TO_STUB_PATH, 'get_value'), 0, 'stubbed path method should get path value')
	assert_eq(gr.stubber.get_return(TO_STUB_PATH ,'get_other'), null, 'unstubbed path method should get null')

func test_will_use_metadata_for_class_path():
	gr.stubber.set_return('some_path', 'some_method', 0)
	var inst = HasStubMetadata.new()
	inst.__gut_metadata_.path = 'some_path'
	var value = gr.stubber.get_return(inst, 'some_method')
	assert_eq(value, 0)

func test_will_use_instance_instead_of_metadata():
	gr.stubber.set_return('some_path', 'some_method', 0)
	var inst = HasStubMetadata.new()
	inst.__gut_metadata_.path = 'some_path'
	gr.stubber.set_return(inst, 'some_method', 100)
	assert_eq(gr.stubber.get_return(inst, 'some_method'), 100)

func test_can_stub_with_parameters():
	gr.stubber.set_return('some_path', 'some_method', 7, [1, 2])
	var val = gr.stubber.get_return('some_path', 'some_method', [1, 2])
	assert_eq(val, 7)

func test_parameter_stubs_return_different_values():
	gr.stubber.set_return('some_path', 'some_method', 5)
	gr.stubber.set_return('some_path', 'some_method', 10, [1, 2])
	var with_params = gr.stubber.get_return('some_path', 'some_method', [1, 2])
	var wo_params = gr.stubber.get_return('some_path', 'some_method')
	assert_eq(with_params, 10, 'With params should give correct value')
	assert_eq(wo_params, 5, 'Without params should give correct value')

func test_stub_with_nothing_works_with_no_parameters():
	gr.stubber.set_return('some_path', 'has_one_param', 5)
	gr.stubber.set_return('some_path', 'has_one_param', 10, [1])
	assert_eq(gr.stubber.get_return('some_path', 'has_one_param'), 5)

func test_withStubParams_can_set_return():
	var sp = StubParamsClass.new('thing', 'method').to_return(10)
	gr.stubber.add_stub(sp)
	assert_eq(gr.stubber.get_return('thing', 'method'), 10)

func test_withStubParams_can_get_return_based_on_parameters():
	var sp = StubParamsClass.new('thing', 'method').to_return(10).when_passed('a')
	gr.stubber.add_stub(sp)
	var with_params = gr.stubber.get_return('thing', 'method', ['a'])
	assert_eq(with_params, 10)

func test_withStubParams_can_get_return_based_on_complex_parameters():
	var sp = StubParamsClass.new('thing', 'method').to_return(10)
	sp.when_passed('a', 1, ['a', 1], sp)
	gr.stubber.add_stub(sp)
	var with_params = gr.stubber.get_return('thing', 'method', ['a', 1, ['a', 1], sp])
	assert_eq(with_params, 10)

func test_when_parameters_do_not_match_any_stub_then_warning_generated():
	var sp = StubParamsClass.new('thing', 'method').to_return(10).when_passed('a')
	gr.stubber.add_stub(sp)
	var result = gr.stubber.get_return('thing', 'method', ['b'])
	assert_eq(gr.stubber.get_logger().get_warnings().size(), 1)

func test_withStubParams_param_layering_works():
	var sp1 = StubParamsClass.new('thing', 'method').to_return(10).when_passed(10)
	var sp2 = StubParamsClass.new('thing', 'method').to_return(5).when_passed(5)
	var sp3 = StubParamsClass.new('thing', 'method').to_return('nothing')

	gr.stubber.add_stub(sp1)
	gr.stubber.add_stub(sp2)
	gr.stubber.add_stub(sp3)

	var sp1_r = gr.stubber.get_return('thing', 'method', [10])
	var sp2_r = gr.stubber.get_return('thing', 'method', [5])
	var sp3_r = gr.stubber.get_return('thing', 'method')

	assert_eq(sp1_r, 10, 'When passed 10 it gets 10')
	assert_eq(sp2_r, 5, 'When passed 5 it gets 5')
	assert_eq(sp3_r, 'nothing', 'When params do not match it sends default back.')

func test_should_call_super_returns_false_by_default():
	assert_false(gr.stubber.should_call_super('thing', 'method'))

func test_should_call_super_returns_true_when_stubbed_to_do_so():
	var sp = StubParamsClass.new('thing', 'method').to_call_super()
	gr.stubber.add_stub(sp)
	assert_true(gr.stubber.should_call_super('thing', 'method'))

func test_should_call_super_overriden_by_setting_return():
	var sp = StubParamsClass.new('thing', 'method').to_call_super()
	sp.to_return(null)
	gr.stubber.add_stub(sp)
	assert_false(gr.stubber.should_call_super('thing', 'method'))

func test_to_do_nothing_returns_self():
	var sp = StubParamsClass.new('thing', 'method')
	assert_eq(sp.to_do_nothing(), sp)
