extends GutTest

const INNER_CLASSES_PATH = 'res://test/resources/doubler_test_objects/inner_classes.gd'
var InnerClasses = load(INNER_CLASSES_PATH)

func _print_registry(reg):
	print("---------------------------------------")
	print(reg.to_s())
	print("---------------------------------------")


func test_can_make_one():
	var reg = GutUtils.InnerClassRegistry.new()
	assert_not_null(reg)

func test_when_inner_not_registered_null_is_returned():
	var reg = GutUtils.InnerClassRegistry.new()
	assert_null(reg.get_extends_path(InnerClasses.InnerA))

func test_has_level_1_inner_classes():
	var reg = GutUtils.InnerClassRegistry.new()
	reg.register(InnerClasses)
	var ext_txt = reg.get_extends_path(InnerClasses.InnerA)
	assert_eq(ext_txt, str("'", INNER_CLASSES_PATH, "'.InnerA" ))

func test_has_level_2_inner_classes():
	var reg = GutUtils.InnerClassRegistry.new()
	reg.register(InnerClasses)
	var ext_txt = reg.get_extends_path(InnerClasses.InnerB.InnerB1)
	assert_eq(ext_txt, str("'", INNER_CLASSES_PATH, "'.InnerB.InnerB1" ))

func test_get_AnotherA_back_for_AnotherA():
	var reg = GutUtils.InnerClassRegistry.new()
	reg.register(InnerClasses)
	var ext_txt = reg.get_extends_path(InnerClasses.AnotherInnerA)
	assert_eq(ext_txt, str("'", INNER_CLASSES_PATH, "'.AnotherInnerA" ))

func test_can_get_subpath_for_registered():
	var reg = GutUtils.InnerClassRegistry.new()
	reg.register(InnerClasses)
	var subpath = reg.get_subpath(InnerClasses.InnerB.InnerB1)
	assert_eq(subpath, ".InnerB.InnerB1" )

func test_subpath_is_empty_string_when_not_registered():
	var reg = GutUtils.InnerClassRegistry.new()
	var subpath = reg.get_subpath(InnerClasses.InnerB.InnerB1)
	assert_eq(subpath, "" )

func test_base_path_is_the_path_to_the_script():
	var reg = GutUtils.InnerClassRegistry.new()
	reg.register(InnerClasses)
	var base_path = reg.get_base_path(InnerClasses.InnerCA)
	assert_eq(base_path, INNER_CLASSES_PATH)

func test_can_get_base_resource_for_inner_class():
	var reg = GutUtils.InnerClassRegistry.new()
	reg.register(InnerClasses)
	var resource = reg.get_base_resource(InnerClasses.InnerCA)
	assert_eq(resource, InnerClasses)

func test_get_base_resource_returns_null_when_not_registered():
	var reg = GutUtils.InnerClassRegistry.new()
	var resource = reg.get_base_resource(InnerClasses.InnerCA)
	assert_eq(resource, null)

func test_get_full_path_with_script_name():
	var reg = GutUtils.InnerClassRegistry.new()
	reg.register(InnerClasses)
	var inst = InnerClasses.InnerB.InnerB1.new()
	var result = reg.do_the_thing_i_want_it_to_do(inst)
	assert_string_ends_with(result, '.gd/InnerB/InnerB1')


func test_get_the_full_path_with_script_name_works_with_class_ref():
	var reg = GutUtils.InnerClassRegistry.new()
	reg.register(InnerClasses)
	var result = reg.do_the_thing_i_want_it_to_do(InnerClasses.InnerB.InnerB1)
	assert_string_ends_with(result, '.gd/InnerB/InnerB1')


var ConstantMapExamples = load('res://test/resources/constant_map_examples.gd')
func test_using_constant_map_examples():
	var reg = GutUtils.InnerClassRegistry.new()
	reg.register(ConstantMapExamples)
	pending()


func test_name_clashes():
	var reg = GutUtils.InnerClassRegistry.new()
	reg.register(ConstantMapExamples)

	var src = ConstantMapExamples.source_code
	src = src.replace('TestResourceConstantMapExamples', 'TestResourceConstantMapExamplesDupe')
	var DupeClass = GutUtils.create_script_from_source(src)
	reg.register(DupeClass)

	assert_ne(
		reg.get_extends_path(ConstantMapExamples.InnerClassTwo.InnerClassTwo_One),
		reg.get_extends_path(DupeClass.InnerClassTwo.InnerClassTwo_One)
	)


func test_when_given_an_inner_class_it_does_not_error_and_does_not_register_anything():
	var reg = GutUtils.InnerClassRegistry.new()
	reg.register(ConstantMapExamples.InnerClassTwo.InnerClassTwo_One)
	assert_true(reg.get_registry_data().is_empty(), 'No inners reg')
	assert_true(reg.is_script_registered(ConstantMapExamples.InnerClassTwo.InnerClassTwo_One), 'script counts as registered')


# This knows more than it should but I'm not sure how to verify this any other way.
func test_skips_registration_for_known_scripts():
	var reg = partial_double(GutUtils.InnerClassRegistry).new()
	reg.register(ConstantMapExamples)
	var after_one_called_count = get_call_count(reg._register_inners)
	reg.register(ConstantMapExamples)
	assert_called_count(reg._register_inners, after_one_called_count)


func test_this_fails_until_the_notes_for_what_needs_to_be_done_is_removed():
	assert_file_does_not_exist('res://inst_to_dict_todo.md')
	fail_test('This is a dumb failsafe that this branch does not get merged.')