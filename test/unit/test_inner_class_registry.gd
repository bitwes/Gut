extends GutTest

const INNER_CLASSES_PATH = 'res://test/resources/doubler_test_objects/inner_classes.gd'
var InnerClasses = load(INNER_CLASSES_PATH)

func test_can_make_one():
	var reg = _utils.InnerClassRegistry.new()
	assert_not_null(reg)

func test_when_inner_not_registered_null_is_returned():
	var reg = _utils.InnerClassRegistry.new()
	assert_null(reg.get_extends_path(InnerClasses.InnerA))

func test_has_level_1_inner_classes():
	var reg = _utils.InnerClassRegistry.new()
	reg.add_inner_classes(InnerClasses)
	var ext_txt = reg.get_extends_path(InnerClasses.InnerA)
	assert_eq(ext_txt, str("'", INNER_CLASSES_PATH, "'.InnerA" ))

func test_has_level_2_inner_classes():
	var reg = _utils.InnerClassRegistry.new()
	reg.add_inner_classes(InnerClasses)
	var ext_txt = reg.get_extends_path(InnerClasses.InnerB.InnerB1)
	assert_eq(ext_txt, str("'", INNER_CLASSES_PATH, "'.InnerB.InnerB1" ))

func test_get_AnotherA_back_for_AnotherA():
	var reg = _utils.InnerClassRegistry.new()
	reg.add_inner_classes(InnerClasses)
	var ext_txt = reg.get_extends_path(InnerClasses.AnotherInnerA)
	assert_eq(ext_txt, str("'", INNER_CLASSES_PATH, "'.AnotherInnerA" ))
