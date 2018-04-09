extends "res://addons/gut/test.gd"

var Gut = load('res://addons/gut/gut.gd')
var Test = load('res://addons/gut/test.gd')

const TEMP_FILES = 'user://test_doubler_temp_file'

const DOUBLE_ME_PATH = 'res://gut_tests_and_examples/test/doubler_test_objects/double_me.gd'

var gr = {
    gut = null,
    test = null
}

func setup():
    gr.gut = Gut.new()
    gr.test = Test.new()
    gr.test.gut = gr.gut

func test_double_returns_a_class():
    var D = gr.test.double(DOUBLE_ME_PATH)
    assert_ne(D.new(), null)

func test_double_sets_stubber_for_doubled_class():
    var d = gr.test.double(DOUBLE_ME_PATH).new()
    assert_eq(d.__gut_metadata_.stubber, gr.gut.get_stubber())

func test_basic_double_and_stub():
    var d = gr.test.double(DOUBLE_ME_PATH).new()
    gr.test.stub(DOUBLE_ME_PATH, 'get_value').to_return(10)
    assert_eq(d.get_value(), 10)
