extends GutTest

var WarningsManager = load('res://addons/gut/warnings_manager.gd')

func after_each():
	WarningsManager.reset_warnings()


func test_warnings_manager_is_not_disabled_by_default():
	assert_false(WarningsManager.disabled)


func test_cannot_disable_warnings_manager():
	var value = WarningsManager.disabled
	WarningsManager.disabled = !value
	assert_eq(WarningsManager.disabled, value)


func test_replace_warnings_value():
	var wm = WarningsManager.new()
	var d = wm.create_warnings_dictionary_from_project_settings()
	d.unused_signal = WarningsManager.WARN
	var d2 = wm.replace_warnings_values(d, 1, 0)
	assert_ne(d, d2)
	assert_eq(d2.unused_signal, 0)
	assert_eq(d.unused_signal, 1)


func test_exclude_gut_sets_directory_rules_entry_to_exclude():
	WarningsManager.exclude_gut(true)
	var val = ProjectSettings.get(WarningsManager.DIRECTORY_RULES)
	assert_has(val, 'res://addons/gut')
	if(is_passing()):
		assert_eq(val['res://addons/gut'], WarningsManager.DIRECTORY_EXCLUDE)


func test_include_gut_sets_directory_rules_entry_to_include():
	WarningsManager.exclude_gut(false)
	var val = ProjectSettings.get(WarningsManager.DIRECTORY_RULES)
	assert_has(val, 'res://addons/gut')
	if(is_passing()):
		assert_eq(val['res://addons/gut'], WarningsManager.DIRECTORY_INCLUDE)


func test_exclude_gut_dynamic_files_sets_directory_rules():
	WarningsManager.exclude_dynamic_files()
	var val = ProjectSettings.get(WarningsManager.DIRECTORY_RULES)
	assert_has(val, WarningsManager.DYNAMIC_FILES_PATH)
	if(is_passing()):
		assert_eq(val[WarningsManager.DYNAMIC_FILES_PATH], WarningsManager.DIRECTORY_EXCLUDE)
