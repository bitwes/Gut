extends "res://addons/gut/test.gd"

var Stubber = load('res://addons/gut/stubber.gd')

const TO_STUB_PATH = 'res://gut_tests_and_examples/test/stub_test_objects/to_stub.gd'
var ToStub = load(TO_STUB_PATH)

const HAS_STUB_METADATA_PATH = 'res://gut_tests_and_examples/test/stub_test_objects/has_stub_metadata.gd'
var HasStubMetadata = load(HAS_STUB_METADATA_PATH)


class InnerClass:
	func return_seven():
		return 7


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

func setup():
	gr.stubber = Stubber.new()

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


func test_inners():
	# this only works with instances but we can get to the path and all the
	# neat stuff, this might be the path to stubbing inners
	var i = InnerClass.new()
	print(inst2dict(i))
