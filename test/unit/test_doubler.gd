extends "res://addons/gut/test.gd"

#var Doubler = load('res://addons/gut/doubler.gd')
const TEMP_FILES = 'user://test_doubler_temp_file'

const DOUBLE_ME_PATH = 'res://test/doubler_test_objects/double_me.gd'
const DOUBLE_ME_SCENE_PATH = 'res://test/doubler_test_objects/double_me_scene.tscn'
const DOUBLE_EXTENDS_NODE2D = 'res://test/doubler_test_objects/double_extends_node2d.gd'
var Doubler = load('res://addons/gut/doubler.gd')
var gr = {
	doubler = null
}

func setup():
	gr.doubler = Doubler.new()
	gr.doubler.set_use_unique_names(false)
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

func test_keeps_extends():
	var doubled = gr.doubler.double(DOUBLE_EXTENDS_NODE2D).new()
	assert_extends(doubled, Node2D)

func test_can_clear_output_directory():
	gr.doubler.double(DOUBLE_ME_PATH)
	gr.doubler.double(DOUBLE_EXTENDS_NODE2D)
	assert_file_exists(TEMP_FILES + '/double_me.gd')
	assert_file_exists(TEMP_FILES + '/double_extends_node2d.gd')
	gr.doubler.clear_output_directory()
	assert_file_does_not_exist(TEMP_FILES + '/double_me.gd')
	assert_file_does_not_exist(TEMP_FILES + '/double_extends_node2d.gd')

func test_can_delete_output_directory():
	var d = Directory.new()
	d.open('user://')
	gr.doubler.double(DOUBLE_ME_PATH)
	assert_true(d.dir_exists(TEMP_FILES))
	gr.doubler.delete_output_directory()
	assert_false(d.dir_exists(TEMP_FILES))

func test_can_double_scene():
	var obj = gr.doubler.double_scene(DOUBLE_ME_SCENE_PATH)
	var inst = obj.instance()
	assert_eq(inst.return_hello(), null)

func test_can_add_doubled_scene_to_tree():
	var inst = gr.doubler.double_scene(DOUBLE_ME_SCENE_PATH).instance()
	add_child(inst)
	assert_ne(inst.label, null)
	remove_child(inst)

func test_metadata_for_scenes_script_points_to_scene_not_script():
	var inst = gr.doubler.double_scene(DOUBLE_ME_SCENE_PATH).instance()
	assert_eq(inst.__gut_metadata_.path, DOUBLE_ME_SCENE_PATH)

func test_does_not_add_duplicate_methods():
	gr.doubler.double('res://test/parsing_and_loading_samples/extends_another_thing.gd')
	assert_true(true, 'If we get here then the duplicates were removed.')
	
# Keep this last so other tests fail before instantiation fails
func test_returns_class_that_can_be_instanced():
	var Doubled = gr.doubler.double(DOUBLE_ME_PATH)
	var doubled = Doubled.new()
	assert_ne(doubled, null)
