extends "res://addons/gut/test.gd"

var Doubler = load('res://addons/gut/doubler.gd')
const TEMP_FILES = 'user://test_doubler_temp_file'

const DOUBLE_ME_PATH = 'res://gut_tests_and_examples/test/doubler_test_objects/double_me.gd'
var gr = {
    doubler = null
}

func setup():
    gr.doubler = Doubler.new()
    gr.doubler.set_output_dir(TEMP_FILES)

func test_get_set_output_dir():
    assert_get_set_methods(Doubler.new(), 'output_dir', null, 'somewhere')

func test_get_set_stubber():
    assert_get_set_methods(Doubler.new(), 'stubber', null, GDScript.new())

func test_setting_output_dir_creates_directory_if_it_does_not_exist():
    var d = Doubler.new()
    d.set_output_dir('user://doubler_temp_files/')
    var dir = Directory.new()
    assert_true(dir.dir_exists('user://doubler_temp_files/'))

func test_doubling_object_creates_temp_file():
    gr.doubler.double(DOUBLE_ME_PATH)
    assert_file_exists(TEMP_FILES + '/double_me.gd')

func test_doubling_object_includes_methods():
    gr.doubler.double(DOUBLE_ME_PATH)
    var text = gut.get_file_as_text(TEMP_FILES.plus_file('double_me.gd'))
    assert_true(text.match('*func get_value(*:\n*'), 'should have get method')
    assert_true(text.match('*func set_value(*:\n*'), 'should have set method')

func test_doubling_methods_have_parameters_1():
    gr.doubler.double(DOUBLE_ME_PATH)
    var text = gut.get_file_as_text(TEMP_FILES.plus_file('double_me.gd'))
    assert_true(text.match('*param(arg0*:*'))

# Don't see a way to see which have defaults and which do not, so we default
# everything.
func test_all_parameters_are_defaulted_to_null():
    gr.doubler.double(DOUBLE_ME_PATH)
    var text = gut.get_file_as_text(TEMP_FILES.plus_file('double_me.gd'))
    assert_true(text.match('*one_default(arg0 = null, arg1 = null)*'))

func test_doubled_thing_includes_stubber_metadata():
    var doubled = gr.doubler.double(DOUBLE_ME_PATH).new()
    assert_ne(doubled.get('__gut_metadata_'), null)

func test_doubled_thing_has_original_path_in_metadata():
    var doubled = gr.doubler.double(DOUBLE_ME_PATH).new()
    assert_eq(doubled.__gut_metadata_.path, DOUBLE_ME_PATH)














# Keep this last so other tests fail before instantiation fails
func test_returns_class_that_can_be_instanced():
    var Doubled = gr.doubler.double(DOUBLE_ME_PATH)
    var doubled = Doubled.new()
    assert_ne(doubled, null)
