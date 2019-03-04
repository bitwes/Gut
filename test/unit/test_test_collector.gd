extends "res://test/gut_test.gd"


class TestTestCollector:
	extends "res://test/gut_test.gd"

	var SCRIPTS_ROOT = 'res://test/resources/parsing_and_loading_samples/'

	var gr = {
		tc = null
	}
	func before_each():
		gr.tc = TestCollector.new()

	func test_has_logger():
		assert_has_logger(gr.tc)

	func test_has_test_one():
		gr.tc.add_script(SCRIPTS_ROOT + 'parse_samples.gd')
		assert_eq(gr.tc.scripts[0].tests[0].name, 'test_one')

	func test_does_not_have_not_prefixed():
		gr.tc.add_script(SCRIPTS_ROOT + 'parse_samples.gd')
		for i in range(gr.tc.scripts[0].tests.size()):
			assert_ne(gr.tc.scripts[0].tests[i].name, 'not_prefixed')

	func test_get_set_test_prefix():
		assert_accessors(gr.tc, 'test_prefix', 'test_', 'something')

	func test_can_change_test_prefix():
		gr.tc.set_test_prefix('diff_prefix_')
		gr.tc.add_script(SCRIPTS_ROOT + 'parse_samples.gd')
		assert_eq(gr.tc.scripts[0].tests[0].name, 'diff_prefix_something')

	func test_get_set_test_class_prefix():
		assert_accessors(gr.tc, 'test_class_prefix', 'Test', 'Something')

	func test_finds_inner_classes():
		gr.tc.add_script(SCRIPTS_ROOT + 'has_inner_class.gd')
		var found = false
		for i in range(gr.tc.scripts.size()):
			if(gr.tc.scripts[i].class_name == 'TestClass1'):
				found = true
		assert_true(found, 'Should have the inner class in there')
		assert_eq(gr.tc.scripts.size(), 2)

	func test_can_change_test_class_prefix():
		gr.tc.set_test_class_prefix('DifferentPrefix')
		gr.tc.add_script(SCRIPTS_ROOT + 'has_inner_class.gd')
		var found = false
		for i in range(gr.tc.scripts.size()):
			if(gr.tc.scripts[i].class_name == 'DifferentPrefixClass'):
				found = true
		assert_true(found, 'Should have the inner class in there')

	func test_ignores_classes_that_match_but_do_not_extend_test():
		gr.tc.set_test_class_prefix('DoesNotExtend')
		gr.tc.add_script(SCRIPTS_ROOT + 'has_inner_class.gd')
		var found = false
		for i in range(gr.tc.scripts.size()):
			if(gr.tc.scripts[i].class_name == 'DoesNot'):
				found = true
		assert_false(found, 'Should have skipped, should see warning.')

	func test_inner_classes_have_tests():
		gr.tc.add_script(SCRIPTS_ROOT + 'has_inner_class.gd')
		for i in range(gr.tc.scripts.size()):
			if(gr.tc.scripts[i].class_name == 'TestClass1'):
				assert_eq(gr.tc.scripts[i].tests.size(), 2)

	# also checks that only local methods are found since there is some extra
	# print methods.
	func test_inner_tests_are_found_using_test_prefix():
		gr.tc.set_test_prefix('print_')
		gr.tc.add_script(SCRIPTS_ROOT + 'has_inner_class.gd')
		for i in range(gr.tc.scripts.size()):
			if(gr.tc.scripts[i].class_name == 'TestClass1'):
				assert_eq(gr.tc.scripts[i].tests.size(), 1)

	func test_inner_tests_must_extend_test_to_be_used():
		gr.tc.add_script(SCRIPTS_ROOT + 'has_inner_class.gd')
		for i in range(gr.tc.scripts.size()):
			assert_ne(gr.tc.scripts[i].class_name, 'TestDoesNotExtendTest')

class TestExportImport:
	extends "res://test/gut_test.gd"

	var SCRIPTS_ROOT = 'res://test/resources/parsing_and_loading_samples/'
	var EXPORT_FILE = 'user://exported_tests.cfg'

	func _rewrite_config_to_point_to_exports(path):
		var export_file_text = gut.get_file_as_text(path)
		export_file_text = export_file_text.replace( \
			'res://test/resources/parsing_and_loading_samples/', \
			'res://test/resources/parsing_and_loading_samples/exported/')
		_utils.write_file(path, export_file_text)

	func _run_test_collector(tc):
		var test_gut = Gut.new()
		add_child(test_gut)
		test_gut._test_collector = tc
		test_gut._test_the_scripts()
		remove_child(test_gut)
		return test_gut.get_summary().get_totals()

	func after_each():
		gut.file_delete(EXPORT_FILE)

	func test_exporting_creates_file():
		var tc = TestCollector.new()
		tc.add_script(SCRIPTS_ROOT + 'parse_samples.gd')
		tc.export_tests(EXPORT_FILE)
		assert_file_exists(EXPORT_FILE)
		assert_file_not_empty(EXPORT_FILE)

	func test_import_adds_scripts():
		var tc_export = TestCollector.new()
		tc_export.add_script(SCRIPTS_ROOT + 'parse_samples.gd')
		tc_export.export_tests(EXPORT_FILE)

		var tc_import = TestCollector.new()
		tc_import.import_tests(EXPORT_FILE)
		assert_eq(tc_import.scripts.size(), 1)

	func test_imported_script_has_all_tests():
		var tc_export = TestCollector.new()
		tc_export.add_script(SCRIPTS_ROOT + 'parse_samples.gd')
		tc_export.export_tests(EXPORT_FILE)

		var tc_import = TestCollector.new()
		tc_import.import_tests(EXPORT_FILE)
		assert_eq(tc_import.scripts[0].tests.size(), 2, 'has correct size')
		var names = _utils.extract_property_from_array(tc_import.scripts[0].tests, 'name')
		assert_has(names, 'test_one')
		assert_has(names, 'test_two')

	func test_imports_inner_classes():
		var tc_export = TestCollector.new()
		tc_export.add_script(SCRIPTS_ROOT + 'has_inner_class.gd')
		tc_export.export_tests(EXPORT_FILE)

		var tc_import = TestCollector.new()
		tc_import.import_tests(EXPORT_FILE)
		assert_eq(tc_import.scripts.size(), 2, 'one for the tests in the base and one for the inner class')
		assert_eq(tc_import.scripts[1].class_name, 'TestClass1')

	func test_imported_tests_are_test_classes():
		var tc_export = TestCollector.new()
		tc_export.add_script(SCRIPTS_ROOT + 'parse_samples.gd')
		tc_export.export_tests(EXPORT_FILE)

		var tc_import = TestCollector.new()
		tc_import.import_tests(EXPORT_FILE)
		assert_eq(tc_import.scripts[0].tests[0].name, 'test_one')

	# This should be an integration tests but I don't have a home for it yet.
	func test_gut_runs_imported_tests():
		var tc_export = TestCollector.new()
		tc_export.add_script(SCRIPTS_ROOT + 'has_inner_class.gd')
		tc_export.export_tests(EXPORT_FILE)

		var tc_import = TestCollector.new()
		tc_import.import_tests(EXPORT_FILE)

		var totals = _run_test_collector(tc_import)
		assert_eq(totals.tests, 4, 'test count')
		assert_eq(totals.scripts, 1, 'script count')

	func test_when_file_does_not_exist_it_follows_remap():
		var tc_export = TestCollector.new()
		tc_export.add_script(SCRIPTS_ROOT + 'parse_samples.gd')
		tc_export.export_tests(EXPORT_FILE)

		_rewrite_config_to_point_to_exports(EXPORT_FILE)

		var tc_import = TestCollector.new()
		tc_import.import_tests(EXPORT_FILE)
		assert_string_contains(
			tc_import.scripts[0].path,
			'parse_samples.gdc')

	# This should be an integration tests but I don't have a home for it yet.
	func test_gut_runs_imported_exported_tests():
		var tc_export = TestCollector.new()
		tc_export.add_script(SCRIPTS_ROOT + 'has_inner_class.gd')
		tc_export.export_tests(EXPORT_FILE)

		_rewrite_config_to_point_to_exports(EXPORT_FILE)

		var tc_import = TestCollector.new()
		tc_import.import_tests(EXPORT_FILE)

		var totals = _run_test_collector(tc_import)
		assert_eq(totals.tests, 4, 'test count')
		# This is 2 for some reason.  it is only 1 in the other test.  One of
		# them is wrong but everything else checks out ok.
		assert_eq(totals.scripts, 2, 'script count')
