extends 'res://addons/gut/test.gd'

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

class TestVersionCheck:
	extends 'res://addons/gut/test.gd'

	var Utils = load('res://addons/gut/utils.gd')

	func _fake_engine_version(version):
		var parsed = version.split('.')
		return{'major':parsed[0], 'minor':parsed[1], 'patch':parsed[2]}

	var test_versions = ParameterFactory.named_parameters(
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
	func test_is_version_ok(p=use_parameters(test_versions)):
		var utils = autofree(Utils.new())
		var engine_info = _fake_engine_version(p.engine_version)
		var req_version = p.req_version.split('.')
		assert_eq(utils.is_version_ok(engine_info, req_version), p.expected_result,
			str(p.engine_version, ' >= ', p.req_version))
