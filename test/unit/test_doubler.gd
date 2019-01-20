extends "res://addons/gut/test.gd"

class BaseTest:
	extends "res://addons/gut/test.gd"

	#var Doubler = load('res://addons/gut/doubler.gd')
	const TEMP_FILES = 'user://test_doubler_temp_file'

	const DOUBLE_ME_PATH = 'res://test/doubler_test_objects/double_me.gd'
	const DOUBLE_ME_SCENE_PATH = 'res://test/doubler_test_objects/double_me_scene.tscn'
	const DOUBLE_EXTENDS_NODE2D = 'res://test/doubler_test_objects/double_extends_node2d.gd'
	const DOUBLE_EXTENDS_WINDOW_DIALOG = 'res://test/doubler_test_objects/double_extends_window_dialog.gd'
	var Doubler = load('res://addons/gut/doubler.gd')

	func _get_temp_file_as_text(filename):
		return gut.get_file_as_text(TEMP_FILES.plus_file(filename))

class TestTheBasics:
	extends BaseTest

	var gr = {
		doubler = null
	}

	func before_each():
		gr.doubler = Doubler.new()
		gr.doubler.set_use_unique_names(false)
		gr.doubler.set_output_dir(TEMP_FILES)

	func after_each():
		gr.doubler.clear_output_directory()

	func test_get_set_output_dir():
		assert_accessors(Doubler.new(), 'output_dir', null, 'somewhere')

	func test_get_set_stubber():
		assert_accessors(Doubler.new(), 'stubber', null, GDScript.new())

	func test_can_get_set_spy():
		assert_accessors(Doubler.new(), 'spy', null, GDScript.new())

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
		assert_true(text.match('*param(p_arg0*:*'), text)

	# Don't see a way to see which have defaults and which do not, so we default
	# everything.
	func test_all_parameters_are_defaulted_to_null():
		gr.doubler.double(DOUBLE_ME_PATH)
		var text = gut.get_file_as_text(TEMP_FILES.plus_file('double_me.gd'))
		assert_true(text.match('*one_default(p_arg0 = null, p_arg1 = null)*'))

	func test_doubled_thing_includes_stubber_metadata():
		var doubled = gr.doubler.double(DOUBLE_ME_PATH).new()
		assert_ne(doubled.get('__gut_metadata_'), null)

	func test_doubled_thing_has_original_path_in_metadata():
		var doubled = gr.doubler.double(DOUBLE_ME_PATH).new()
		assert_eq(doubled.__gut_metadata_.path, DOUBLE_ME_PATH)

	func test_keeps_extends():
		var doubled = gr.doubler.double(DOUBLE_EXTENDS_NODE2D).new()
		assert_is(doubled, Node2D)

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
		#print(gr.doubler.get_spy().get_call_list_as_string(inst))

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

	func test_get_set_logger():
		assert_ne(gr.doubler.get_logger(), null)
		var l = load('res://addons/gut/logger.gd').new()
		gr.doubler.set_logger(l)
		assert_eq(gr.doubler.get_logger(), l)



class TestBuiltInOverloading:
	extends BaseTest

	var _dbl_win_dia_text = ''

	func _hide_call_back():
		pass

	var doubler = null
	func before_each():
		doubler = Doubler.new()
		doubler.set_use_unique_names(false)
		doubler.set_output_dir(TEMP_FILES)

		doubler.double(DOUBLE_EXTENDS_WINDOW_DIALOG)
		_dbl_win_dia_text = _get_temp_file_as_text('double_extends_window_dialog.gd')


	func after_all():
		pass
		#doubler.clear_output_directory()

	func test_when_everything_included_you_can_still_make_an_a_new_object():
		var inst = doubler.double(DOUBLE_ME_PATH).new()
		assert_ne(inst, null)

	func test_when_everything_included_you_can_still_make_a_new_node2d():
		var inst = doubler.double(DOUBLE_EXTENDS_NODE2D).new()
		assert_ne(inst, null)

	func test_when_everything_included_you_can_still_double_a_scene():
		var inst = doubler.double_scene(DOUBLE_ME_SCENE_PATH).instance()
		add_child(inst)
		assert_ne(inst, null, "instance is not null")
		assert_ne(inst.label, null, "Can get to a label on the instance")
		# pause so _process gets called
		yield(yield_for(3), YIELD)
		end_test()

	func test_double_includes_methods_in_super():
		assert_string_contains(_dbl_win_dia_text, 'connect(')

	func test_can_call_a_built_in_that_has_default_parameters():
		var inst = doubler.double(DOUBLE_EXTENDS_WINDOW_DIALOG).new()
		inst.connect('hide', self, '_hide_call_back')

	func test_all_types_supported():
		assert_string_contains(_dbl_win_dia_text, 'popup_centered(p_size = Vector2(0, 0)):', 'Vector2')
		assert_string_contains(_dbl_win_dia_text, 'bounds = Rect2(0, 0, 0, 0)', 'Rect2')

# Since defaults are only available for built-in methods these tests verify
# specific method parameters that were found to cause a problem.
class TestDefaultParameters:
	extends BaseTest

	var doubler = null
# True and False
#func set_anchor(p_margin = null, p_anchor = null, p_keep_margin = False, p_push_opposite_anchor = True):
# Vector2 (i think)
#func popup_centered(p_size = (0, 0)):
# Transform?
#func popup(p_bounds = (0, 0, 0, 0)):
# Null and Color
#func draw_texture(p_texture = null, p_position = null, p_modulate = Color(1,1,1,1), p_normal_map = Null):
# True, False, Null, Color
#func draw_texture_rect_region(p_texture = null, p_rect = null, p_src_rect = null, p_modulate = Color(1,1,1,1), p_transpose = False, p_normal_map = Null, p_clip_uv = True):
	func before_each():
		doubler = Doubler.new()
		doubler.set_use_unique_names(false)
		doubler.set_output_dir(TEMP_FILES)

	func test_parameters_are_doubled_for_connect():
		var inst = doubler.double_scene(DOUBLE_ME_SCENE_PATH).instance()
		var text = _get_temp_file_as_text('double_me_scene.gd')
		var sig = 'func connect(p_signal = null, p_target = null, p_method = null, p_binds = [], p_flags = 0):'
		assert_string_contains(text, sig)

	func test_parameters_are_doubled_for_draw_char():
		var inst = doubler.double_scene(DOUBLE_ME_SCENE_PATH).instance()
		var text = _get_temp_file_as_text('double_me_scene.gd')
		var sig = 'func draw_char(p_font = null, p_position = null, p_char = null, p_next = null, p_modulate = Color(1,1,1,1)):'
		assert_string_contains(text, sig)
