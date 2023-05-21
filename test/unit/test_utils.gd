extends 'res://addons/gut/test.gd'

const INNER_CLASSES_PATH = 'res://test/resources/doubler_test_objects/inner_classes.gd'

var InnerClasses = load(INNER_CLASSES_PATH)
var Utils = load('res://addons/gut/utils.gd')


func test_can_make_one():
	assert_not_null(autofree(Utils.new()))

func test_is_double_returns_false_for_non_doubles():
	var utils = autofree(Utils.new())
	assert_false(utils.is_double(autofree(Node.new())))

func test_is_double_returns_true_for_doubles():
	var utils = autofree(Utils.new())
	var d = double(Node).new()
	assert_true(utils.is_double(d))

func test_is_double_returns_false_for_primitives():
	var utils = autofree(Utils.new())
	assert_false(utils.is_double('hello'), 'string')
	assert_false(utils.is_double(1), 'int')
	assert_false(utils.is_double(1.0), 'float')
	assert_false(utils.is_double([]), 'array')
	assert_false(utils.is_double({}), 'dictionary')
	# that's probably enough spot checking


class OverloadsGet:
	var a = []
	func get(index):
		return a[index]

func test_is_double_works_with_classes_that_overload_get():
	var og = autofree(OverloadsGet.new())
	var utils = autofree(Utils.new())
	assert_false(utils.is_double(og))

func test_is_instance_false_for_classes():
	var utils = autofree(Utils.new())
	assert_false(utils.is_instance(Node2D))

func test_is_instance_true_for_new():
	var utils = autofree(Utils.new())
	var n = Node.new()
	assert_true(utils.is_instance(n))

func test_is_instance_false_for_instanced_things():
	var utils = autofree(Utils.new())
	var i = load('res://test/resources/SceneNoScript.tscn')
	assert_false(utils.is_instance(i))


func test_get_native_class_name_does_not_generate_orphans():
	var utils = Utils.new()
	var n = utils.get_native_class_name(Node2D)
	utils.free()
	assert_no_new_orphans()

func test_get_native_class_name_does_not_free_references():
	var utils = autofree(Utils.new())
	var n = utils.get_native_class_name(InputEventKey)
	pass_test("we got here")

func test_is_native_class_returns_true_for_native_classes():
	var utils = autofree(Utils.new())
	assert_true(utils.is_native_class(Node))


func test_is_inner_class_true_for_inner_classes():
	var utils = autofree(Utils.new())
	assert_true(utils.is_inner_class(InnerClasses.InnerA))

func test_is_inner_class_false_for_base_scripts():
	var utils = autofree(Utils.new())
	assert_false(utils.is_inner_class(InnerClasses))

func test_is_inner_class_false_for_non_objs():
	var utils = autofree(Utils.new())
	assert_false(utils.is_inner_class('foo'))



class TestVersionCheck:
	extends 'res://addons/gut/test.gd'

	var Utils = load('res://addons/gut/utils.gd')

	func _fake_engine_version(version):
		var parsed = version.split('.')
		return{'major':parsed[0], 'minor':parsed[1], 'patch':parsed[2]}

	var test_ok_versions = ParameterFactory.named_parameters(
		['engine_version', 'req_version', 'expected_result'],
		[
			['1.2.3', '1.2.3', true],
			['2.0.0', '1.0.0', true],
			['1.0.1', '1.0.0', true],
			['1.1.0', '1.0.0', true],
			['1.1.1', '1.0.0', true],
			['1.2.5', '1.0.10', true],
			['3.3.0', '3.2.3', true],
			['4.0.0', '3.2.0', true],

			['3.0.0', '3.0.1', false],
			['1.2.3', '2.0.0', false],
			['1.2.1', '1.2.3', false],
			['1.2.3', '1.3.0', false],

		])
	func test_is_version_ok(p=use_parameters(test_ok_versions)):
		var utils = autofree(Utils.new())
		var engine_info = _fake_engine_version(p.engine_version)
		var req_version = p.req_version.split('.')
		assert_eq(utils.is_version_ok(engine_info, req_version), p.expected_result,
			str(p.engine_version, ' >= ', p.req_version))

	var test_is_versions = ParameterFactory.named_parameters(
		['engine_version', 'expected_version', 'expected_result'],
		[
			['1.2.3', '1.2.3', true],
			['1.2.3', '1.2', true],
			['1.2.3', '1', true],

			['1.2.4', '1.2.3', false],
			['1.3.3', '1.2.3', false],
			['2.2.3', '1.2.3', false],

			['1.2.3', '1.2.3.4', false]
		])

	func test_is_godot_version(p=use_parameters(test_is_versions)):
		var utils = autofree(Utils.new())
		var engine_info = _fake_engine_version(p.engine_version)
		assert_eq(utils.is_godot_version(p.expected_version, engine_info), p.expected_result,
			str(p.engine_version, ' is ', p.expected_version))


class TestGetEnumValue:
	extends GutTest

	enum TEST1{
		ZERO,
		ONE,
		TWO,
		THREE,
		TWENTY_ONE
	}


	func test_returns_index_when_given_index():
		var val = GutUtils.get_enum_value(0, TEST1)
		assert_eq(val, 0)

	func test_returns_null_when_invalid_index():
		var val = GutUtils.get_enum_value(99, TEST1)
		assert_eq(val, null)

	func test_returns_value_when_given_string():
		var val = GutUtils.get_enum_value('TWO', TEST1)
		assert_eq(val, 2)

	func test_returns_value_when_given_lowercase_string():
		var val = GutUtils.get_enum_value('three', TEST1)
		assert_eq(val, 3)

	func test_replaces_spaces_with_underscores():
		var val = GutUtils.get_enum_value('twenty ONE', TEST1)
		assert_eq(val, TEST1.TWENTY_ONE)

	func test_returns_null_if_string_not_a_key():
		var val = GutUtils.get_enum_value('not a key', TEST1)
		assert_null(val)

	func test_can_provide_default_value():
		var val = GutUtils.get_enum_value('not a key', TEST1, 'asdf')
		assert_eq(val, 'asdf')


