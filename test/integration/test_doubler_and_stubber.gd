extends "res://addons/gut/test.gd"

var Stubber = load('res://addons/gut/stubber.gd')
var Doubler = load('res://addons/gut/doubler.gd')

const DOUBLE_ME_PATH = 'res://test/resources/doubler_test_objects/double_me.gd'
const DOUBLE_ME_SCENE_PATH = 'res://test/resources/doubler_test_objects/double_me_scene.tscn'
const DOUBLE_EXTENDS_NODE2D = 'res://test/resources/doubler_test_objects/double_extends_node2d.gd'
const TEMP_FILES = 'user://test_doubler_temp_file'
const TO_STUB_PATH = 'res://test/resources/stub_test_objects/to_stub.gd'

var gr = {
	doubler = null,
	stubber = null
}

func before_each():
	gr.doubler = Doubler.new()
	gr.doubler.set_output_dir(TEMP_FILES)
	gr.doubler.clear_output_directory()

	gr.stubber = Stubber.new()

func after_all():
	gut.file_delete(TEMP_FILES)

# func after_each():
# 	gr.doubler.clear_output_directory()

func test_doubled_have_ref_to_stubber():
	gr.doubler.set_stubber(gr.stubber)
	var d = gr.doubler.double(DOUBLE_ME_PATH).new()
	assert_eq(d.__gut_metadata_.stubber, gr.stubber)

func test_stubbing_method_returns_expected_value():
	gr.doubler.set_stubber(gr.stubber)
	var D = gr.doubler.double(DOUBLE_ME_PATH)
	gr.stubber.set_return(DOUBLE_ME_PATH, 'get_value', 7)
	assert_eq(D.new().get_value(), 7)

func test_can_stub_non_local_methods():
	gr.doubler.set_stubber(gr.stubber)
	var D = gr.doubler.double(DOUBLE_ME_PATH)
	gr.stubber.set_return(DOUBLE_ME_PATH, 'get_position', Vector2(11, 11))
	assert_eq(D.new().get_position(), Vector2(11, 11))

func test_when_non_local_methods_not_stubbed_super_is_returned():
	gr.doubler.set_stubber(gr.stubber)
	var D = gr.doubler.double(DOUBLE_EXTENDS_NODE2D)
	var d = D.new()
	assert_eq(d.get_rotation(), 0.0)

func test_can_stub_doubled_instance_values():
	gr.doubler.set_stubber(gr.stubber)
	var D = gr.doubler.double(DOUBLE_ME_PATH)
	var d1 = D.new()
	var d2 = D.new()
	gr.stubber.set_return(DOUBLE_ME_PATH, 'get_value', 5)
	gr.stubber.set_return(d1, 'get_value', 10)
	assert_eq(d1.get_value(), 10, 'instance gets right value')
	assert_eq(d2.get_value(), 5, 'other instance gets class value')

func test_stubbed_methods_send_parameters_in_callback():
	gr.doubler.set_stubber(gr.stubber)
	gr.stubber.set_return(DOUBLE_ME_PATH, 'has_one_param', 10, [1])
	var d = gr.doubler.double(DOUBLE_ME_PATH).new()
	assert_eq(d.has_one_param(1), 10)
	assert_eq(d.has_one_param('asdf'), null)

func test_stub_with_nothing_works_with_parameters():
	gr.doubler.set_stubber(gr.stubber)
	gr.stubber.set_return(DOUBLE_ME_PATH, 'has_one_param', 5)
	gr.stubber.set_return(DOUBLE_ME_PATH, 'has_one_param', 10, [1])
	var d = gr.doubler.double(DOUBLE_ME_PATH).new()
	assert_eq(d.has_one_param(), 5)

func test_can_stub_doubled_scenes():
	gr.doubler.set_stubber(gr.stubber)
	gr.stubber.set_return(DOUBLE_ME_SCENE_PATH, 'return_hello', 'world')
	var inst = gr.doubler.double_scene(DOUBLE_ME_SCENE_PATH).instance()
	assert_eq(inst.return_hello(), 'world')

func test_when_stubbed_to_call_super_then_super_is_called():
	gr.doubler.set_stubber(gr.stubber)
	var doubled = gr.doubler.double(DOUBLE_ME_PATH).new()
	var params = _utils.StubParams.new(doubled, 'set_value').to_call_super()
	gr.stubber.add_stub(params)
	doubled.set_value(99)
	assert_eq(doubled._value, 99)

func test_can_stub_native_methods():
	gr.doubler.set_stubber(gr.stubber)
	var d_node2d = gr.doubler.double_gdnative(Node2D).new()
	print(d_node2d.__gut_metadata_.stubber)
	var params = _utils.StubParams.new(d_node2d, 'get_position').to_return(-1)
	gr.stubber.add_stub(params)
	assert_eq(d_node2d.get_position(), -1)

func test_partial_double_of_Node2D_returns_super_values():
	gr.doubler.set_stubber(gr.stubber)
	var pd_node_2d  = gr.doubler.partial_double_gdnative(Node2D).new()
	# see big ass comment in next test.
	pd_node_2d  = gr.doubler.partial_double_gdnative(Node2D).new()
	assert_eq(pd_node_2d.is_blocking_signals(), false)

func test_can_stub_all_Node2D_doubles():
	gr.doubler.set_stubber(gr.stubber)
	var d_node2d = gr.doubler.double_gdnative(Node2D).new()
	# !!!!!!!!!!!!!!!
	# TODO figure this mystery out.  Probably has something to do with the
	# comment at the top of this file.
	#
	# I don't know why this does not work if we don't do it twice.  If it isn't
	# done twice then it  will fail w/ a null stubber.  If you swap this method
	# with the previous one, then that one will fail and this will pass w/o
	# having to do it twice.  If  you run this test by itself it passes w/o
	# doing it twice.  I'm not sure what is going on.
	#
	# The stubber instances match up (via  print statements) but d_node2d always
	# has a null stubber after the first call and the real one after the 2nd.
	# !!!!!!!!!!!!!!!
	d_node2d = gr.doubler.double_gdnative(Node2D).new()
	d_node2d = gr.doubler.double_gdnative(Node2D).new()
	print(d_node2d.__gut_metadata_.stubber)
	var params = _utils.StubParams.new(Node2D, 'get_position').to_return(-1)
	gr.stubber.add_stub(params)
	assert_eq(d_node2d.get_position(), -1)

func test_init_is_never_stubbed_to_all_super():
	gr.doubler.set_stubber(gr.stubber)
	var inst =  gr.doubler.partial_double(DOUBLE_ME_PATH).new()
	assert_false(gr.stubber.should_call_super(inst, '_init', []))

func test_ready_is_never_stubbed_to_all_super():
	gr.doubler.set_stubber(gr.stubber)
	var inst =  gr.doubler.partial_double(DOUBLE_ME_PATH).new()
	assert_false(gr.stubber.should_call_super(inst, '_ready', []))
