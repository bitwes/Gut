extends GutTest


class TestScriptCollector:
	extends GutTest

	const DOUBLE_ME_PATH = 'res://test/resources/doubler_test_objects/double_me.gd'
	var DoubleMe = load(DOUBLE_ME_PATH)
	var ExtendsNode = load('res://test/resources/doubler_test_objects/double_extends_node2d.gd')


	var ScriptCollector = load('res://addons/gut/script_parser.gd')

	func test_can_make_one():
		assert_not_null(ScriptCollector.new())

	func test_can_parse_a_script():
		var collector = ScriptCollector.new()
		collector.parse(DoubleMe)
		assert_eq(collector.scripts.size(), 1)

	func test_parsing_same_thing_does_not_add_to_scripts():
		var collector = ScriptCollector.new()
		collector.parse(DoubleMe)
		collector.parse(DoubleMe)
		assert_eq(collector.scripts.size(), 1)

	func test_parse_returns_script_parser():
		var collector = ScriptCollector.new()
		var result = collector.parse(DoubleMe)
		assert_is(result, ScriptCollector.ScriptParser)

	func test_parse_returns_cached_version_on_2nd_parse():
		var collector = ScriptCollector.new()
		collector.parse(DoubleMe)
		var result = collector.parse(DoubleMe)
		assert_is(result, ScriptCollector.ScriptParser)

	func test_can_parse_instances():
		var collector = ScriptCollector.new()
		collector.parse(autofree(DoubleMe.new()))
		assert_eq(collector.scripts.size(), 1)

	func test_can_get_instance_parse_result_from_gdscript():
		var collector = ScriptCollector.new()
		collector.parse(autofree(DoubleMe.new()))
		var result = collector.parse(DoubleMe)
		assert_is(result, ScriptCollector.ScriptParser)
		assert_eq(collector.scripts.size(), 1)

	func test_parsing_more_adds_more_scripts():
		var collector = ScriptCollector.new()
		collector.parse(DoubleMe)
		collector.parse(ExtendsNode)
		assert_eq(collector.scripts.size(), 2)

	func test_can_parse_path_string():
		var collector = ScriptCollector.new()
		collector.parse(DOUBLE_ME_PATH)
		assert_eq(collector.scripts.size(), 1)

	func test_when_passed_an_invalid_path_null_is_returned():
		var collector = ScriptCollector.new()
		var result = collector.parse('res://foo.bar')
		assert_null(result)


class TestScriptParser:
	extends GutTest

	const DOUBLE_ME_PATH = 'res://test/resources/doubler_test_objects/double_me.gd'
	var ScriptParser = load('res://addons/gut/script_parser.gd').ScriptParser
	var DoubleMe = load(DOUBLE_ME_PATH)

	func test_can_make_one_from_gdscript():
		assert_not_null(ScriptParser.new(DoubleMe))

	func test_can_make_one_from_instance():
		var inst = autofree(DoubleMe.new())
		assert_not_null(ScriptParser.new(inst))

	func test_instance_and_gdscript_have_same_methods():
		var gd_parser = ScriptParser.new(DoubleMe)
		var inst = autofree(DoubleMe.new())
		var inst_parser = ScriptParser.new(inst)

		assert_eq(gd_parser.get_sorted_method_names(), inst_parser.get_sorted_method_names())

	func test_new_from_gdscript_sets_path():
		var parser = ScriptParser.new(DoubleMe)
		assert_eq(parser.script_path, DOUBLE_ME_PATH)

	func test_new_from_inst_sets_path():
		var inst = autofree(DoubleMe.new())
		var parser = ScriptParser.new(inst)
		assert_eq(parser.script_path, DOUBLE_ME_PATH)

	func test_can_get_method_by_name():
		var parser = ScriptParser.new(DoubleMe)
		assert_not_null(parser.get_method('_get'))

	func test_can_get_super_method_by_name():
		var parser = ScriptParser.new(DoubleMe)
		assert_not_null(parser.get_super_method('_get'))

	func test_non_super_methods_are_not_in_get_super_method_by_name():
		var parser = ScriptParser.new(DoubleMe)
		assert_null(parser.get_super_method('has_string_and_array_defaults'))

	func test_can_get_local_method_by_name():
		var parser = ScriptParser.new(DoubleMe)
		assert_not_null(parser.get_local_method('has_string_and_array_defaults'))

	func test_can_super_methods_not_included_in_local_method_by_name():
		var parser = ScriptParser.new(DoubleMe)
		assert_null(parser.get_local_method('_get'))

	func test_overloaded_local_methods_are_local():
		var parser = ScriptParser.new(DoubleMe)
		assert_not_null(parser.get_local_method('_init'))

	func test_get_local_method_names_excludes_supers():
		var parser = ScriptParser.new(DoubleMe)
		var names = parser.get_local_method_names()
		assert_does_not_have(names, '_get')

	func test_get_super_method_names_excludes_locals():
		var parser = ScriptParser.new(DoubleMe)
		var names = parser.get_super_method_names()
		assert_does_not_have(names, 'has_string_and_array_defaults')
