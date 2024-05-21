extends GutTest

var WarningsManager = load('res://addons/gut/warnings_manager.gd')


func test_can_make_one():
	var wm = WarningsManager.new()
	assert_not_null(wm)
	wm.print_warnings_dictionary(WarningsManager.project_warnings)


func test_project_warnings_is_populated():
	assert_typeof(WarningsManager.project_warnings.exclude_addons, TYPE_BOOL)


func test_replace_warnings_value():
	var wm = WarningsManager.new()
	var d = wm.create_warnings_dictionary_from_project_settings()
	d.unused_signal = WarningsManager.WARN
	var d2 = wm.replace_warnings_values(d, 1, 0)
	assert_ne(d, d2)
	assert_eq(d2.unused_signal, 0)
	assert_eq(d.unused_signal, 1)