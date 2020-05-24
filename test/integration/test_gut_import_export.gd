extends 'res://test/gut_test.gd'

var _test_gut = null
const EXPORT_FILE = 'res://test/exported_tests.cfg'

func before_each():
	_test_gut = Gut.new()
	add_child(_test_gut)

func after_each():
	gut.file_delete(EXPORT_FILE)
	remove_child(_test_gut)

func test_export_test_exports_tests():
	_test_gut.add_directory('res://test/resources/parsing_and_loading_samples')
	_test_gut.export_tests(EXPORT_FILE)
	assert_file_not_empty(EXPORT_FILE)

func test_export_uses_export_path_if_no_path_sent():
	_test_gut.add_directory('res://test/resources/parsing_and_loading_samples')
	_test_gut.set_export_path(EXPORT_FILE)
	_test_gut.export_tests()
	assert_file_not_empty(EXPORT_FILE)

func test_if_export_path_not_set_and_no_path_passed_error_is_generated():
	_test_gut.add_directory('res://test/resources/parsing_and_loading_samples')
	_test_gut.export_tests()
	assert_errored(_test_gut)

func test_importing_tests_populates_test_collector():
	_test_gut.add_directory('res://test/resources/parsing_and_loading_samples')
	_test_gut.export_tests(EXPORT_FILE)

	var _import_gut = Gut.new()
	add_child(_import_gut)
	_import_gut.import_tests(EXPORT_FILE)

	assert_eq(
	_import_gut.get_test_collector().scripts.size(),
	_test_gut.get_test_collector().scripts.size())
	remove_child(_import_gut)

func test_import_tests_uses_export_path_by_default():
	_test_gut.add_directory('res://test/resources/parsing_and_loading_samples')
	_test_gut.export_tests(EXPORT_FILE)

	var _import_gut = Gut.new()
	add_child(_import_gut)
	_import_gut.set_export_path(EXPORT_FILE)
	_import_gut.import_tests()

	assert_eq(
	_import_gut.get_test_collector().scripts.size(),
	_test_gut.get_test_collector().scripts.size())
	remove_child(_import_gut)

func test_import_errors_if_file_does_not_exist():
	_test_gut.import_tests('res://file_does_not_exist.txt')
	assert_errored(_test_gut)

func test_gut_runs_the_imported_tests():
	_test_gut.add_directory('res://test/resources/parsing_and_loading_samples')
	_test_gut.export_tests(EXPORT_FILE)

	var _import_gut = Gut.new()
	add_child(_import_gut)
	_import_gut.set_export_path(EXPORT_FILE)
	_import_gut.import_tests()
	_import_gut.test_scripts()
	remove_child(_import_gut)

	var totals = _import_gut.get_summary().get_totals()
	assert_eq(totals.scripts, 6)
	# picked some arbitrary number since these assert counts could change
	# over time.  Last run was 16 passing.  This is probably a sign that this
	# shouldn't be reusing parsing_and_loading_samples but the world isn't
	# perfect alright?  I'm trying here, but lay off a bit why dontcha.
	assert_gt(totals.passing, 10)
	pause_before_teardown()
