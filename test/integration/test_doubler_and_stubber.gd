# NOTE about set_use_unique_names
#   Since a new doubler is made for each test, this cannot use the unique names
#   or things do not load properly.  This also means that everything is
#   essentially using the same doubles.  Since the body of the doubles isn't
#   changing over the course of this test script, that is ok.
extends "res://addons/gut/test.gd"

var Stubber = load('res://addons/gut/stubber.gd')
var Doubler = load('res://addons/gut/doubler.gd')

const DOUBLE_ME_PATH = 'res://test/doubler_test_objects/double_me.gd'
const DOUBLE_ME_SCENE_PATH = 'res://test/doubler_test_objects/double_me_scene.tscn'
const DOUBLE_EXTENDS_NODE2D = 'res://test/doubler_test_objects/double_extends_node2d.gd'
const TEMP_FILES = 'user://test_doubler_temp_file'

var gr = {
	doubler = null,
	stubber = null
}

func before_each():
	gr.doubler = Doubler.new()
	gr.doubler.set_output_dir(TEMP_FILES)
	gr.stubber = Stubber.new()
	gr.doubler.clear_output_directory()

func test_doubled_has_null_stubber_by_default():
	var d = gr.doubler.double(DOUBLE_ME_PATH).new()
	assert_eq(d.__gut_metadata_.stubber, null)

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
