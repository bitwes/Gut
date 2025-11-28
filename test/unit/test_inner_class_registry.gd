extends GutTest

const INNER_CLASSES_PATH = 'res://test/resources/doubler_test_objects/inner_classes.gd'
var InnerClasses = load(INNER_CLASSES_PATH)
var CyclicRefA = load('res://test/resources/parsing_and_loading_samples/cyclic_ref_class_a.gd')

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

func tet_subpath_is_empty_string_when_not_registered():
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

func test_does_not_spin_out_of_control_with_const_cyclic_refs():
	var reg = GutUtils.InnerClassRegistry.new()
	reg.register(CyclicRefA)
	pass_test('we got here')

func test_does_not_contain_a_ref_to_external_classes():
	var reg = GutUtils.InnerClassRegistry.new()
	reg.register(CyclicRefA)
	var result = reg.get_base_path(CyclicRefA.b_ref)
	assert_null(result)
