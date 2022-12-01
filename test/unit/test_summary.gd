extends "res://addons/gut/test.gd"

var Summary = load('res://addons/gut/summary.gd')

var gr = {
	summary = null
}


func before_each():
	gr.summary = Summary.new()

func test_can_add_script():
	gr.summary.add_script('script1')
	pass_test('no error')

func test_can_get_scripts():
	gr.summary.add_script('script1')
	gr.summary.add_script('script2')
	assert_eq(gr.summary.get_scripts().size(), 2)

func test_get_current_script_returns_the_most_recent_script():
	gr.summary.add_script('script1')
	gr.summary.add_script('script2')
	assert_eq(gr.summary.get_current_script().name, 'script2')

func test_adding_a_new_script_changes_current():
	gr.summary.add_script('script1')
	gr.summary.add_script('script2')
	gr.summary.add_script('script3')
	assert_eq(gr.summary.get_current_script().name, 'script3')

func test_can_add_pass():
	gr.summary.add_script('script1')
	gr.summary.add_pass('test_name')
	assert_eq(gr.summary.get_current_script().get_pass_count(), 1)

func test_can_add_fail():
	gr.summary.add_script('script1')
	gr.summary.add_fail('test_name', 'reason')
	assert_eq(gr.summary.get_current_script().get_fail_count(), 1)

func test_can_get_failure_reason():
	gr.summary.add_script('script1')
	gr.summary.add_fail('test_name', 'reason')
	assert_ne(gr.summary.get_test_text('test_name').find('reason'), -1)

func test_can_add_pending():
	gr.summary.add_script('script66')
	gr.summary.add_pending('test_name', 'reason')
	assert_eq(gr.summary.get_current_script().get_pending_count(), 1)
	assert_ne(gr.summary.get_test_text('test_name').find('reason'), -1)

func test_get_test_text_returns_test_name():
	gr.summary.add_script('script1')
	gr.summary.add_pass('test_name', 'reason')
	assert_ne(gr.summary.get_test_text('test_name').find('test_name'), -1)

func test_get_non_inner_claas_script_count_excludes_inner_classes():
	gr.summary.add_script('res://script.gd.InnerClass')
	gr.summary.add_script('res://script.gd.Other_inner')
	assert_eq(gr.summary.get_non_inner_class_script_count(), 1)

func test_get_non_inner_claas_script_count_includes_other_scripts():
	gr.summary.add_script('res://one.gd')
	gr.summary.add_script('res://two.gd')
	assert_eq(gr.summary.get_non_inner_class_script_count(), 2)

func test_get_non_inner_claas_script_count_handles_mixed_scripts():
	gr.summary.add_script('res://script.gd.InnerClass')
	gr.summary.add_script('res://script.gd.InnerClass2')
	gr.summary.add_script('res://one.gd')
	gr.summary.add_script('res://two.gd')
	assert_eq(gr.summary.get_non_inner_class_script_count(), 3)

func test_test_that_do_not_assert_do_not_count_as_passing():
	gr.summary.add_script('res://script.gd')
	gr.summary.add_test('foo')

	var total = gr.summary.get_totals()
	assert_eq(total.passing_tests, 0, 'pass count')

func test_tests_that_do_not_assert_count_as_tests():
	gr.summary.add_script('res://script.gd')
	gr.summary.add_test('foo')

	var total = gr.summary.get_totals()
	assert_eq(total.tests, 1, 'test count')

func test_test_that_do_not_assert_are_not_pending():
	gr.summary.add_script('res://script.gd')
	gr.summary.add_test('foo')

	var total = gr.summary.get_totals()
	assert_eq(total.pending, 0)

func test_test_that_do_not_assert_are_not_failing():
	gr.summary.add_script('res://script.gd')
	gr.summary.add_test('foo')

	var total = gr.summary.get_totals()
	assert_eq(total.failing, 0)

func test_test_that_do_not_assert_are_risky():
	gr.summary.add_script('res://script.gd')
	gr.summary.add_test('foo')

	var total = gr.summary.get_totals()
	assert_eq(total.risky, 1)


# func test_printed_summary_uses_non_inncer_class_as_script_count():
# 	gr.summary.add_script('res://script.gd.InnerClass')
# 	gr.summary.add_script('res://script.gd.InnerClass2')
# 	gr.summary.add_script('res://one.gd')
# 	gr.summary.add_script('res://two.gd')
# 	var correct_count_check = gr.summary.get_summary_text().find('Scripts:          3')
# 	assert_true(correct_count_check != -1)


func test_check_out_this_summary():
	gr.summary.add_script('script_all_pass')
	gr.summary.add_pass('test_pass1')
	gr.summary.add_pass('test_pass2')

	gr.summary.add_script('script_with_pending')
	gr.summary.add_pass('test_pass1')
	gr.summary.add_pending('test_pending', 'b/c I said so')

	gr.summary.add_script('script_with_failure')
	gr.summary.add_fail('test_fail', 'it is wrong')

	gr.summary.add_script('script_complex')
	gr.summary.add_fail('pending_fail', 'fail')
	gr.summary.add_pending('pending_fail', 'pending')

	gr.summary.add_script('no_tests')

	gr.summary.add_script('no_asserts')
	gr.summary.add_test('does_nothing')

	gut.p("---------------------------------------")
	gut.p("- Start Summary Output")
	gut.p("---------------------------------------")
	gr.summary.log_summary_text(gut.logger)
	gut.p("---------------------------------------")
	gut.p("- End Summary Output")
	gut.p("---------------------------------------")
	pass_test('Must be visually checked')


func test_adding_bunch_of_names():
	var func_names = [
	'test_can_make_one',
	'test_can_parse_a_script',
	'test_parsing_same_thing_does_not_add_to_scripts',
	'test_parse_returns_script_parser',
	'test_parse_returns_cached_version_on_2nd_parse',
	'test_can_get_instance_parse_result_from_gdscript',
	'test_parsing_more_adds_more_scripts',
	'test_can_parse_path_string',
	'test_when_passed_an_invalid_path_null_is_returned',
	'test_inner_class_sets_subpath',
	'test_inner_class_sets_script_path',
	'test_can_make_one_from_gdscript',
	'test_can_make_one_from_instance',
	'test_instance_and_gdscript_have_same_methods',
	'test_new_from_gdscript_sets_path',
	'test_new_from_inst_sets_path',
	'test_can_get_method_by_name',
	'test_can_get_super_method_by_name',
	'test_non_super_methods_are_not_in_get_super_method_by_name',
	'test_can_get_local_method_by_name',
	'test_can_super_methods_not_included_in_local_method_by_name',
	'test_overloaded_local_methods_are_local',
	'test_get_local_method_names_excludes_supers',
	'test_get_super_method_names_excludes_locals',
	'test_is_blacklisted_returns_true_for_blacklisted_methods',
	'test_is_black_listed_returns_false_for_non_blacklisted_methods',
	'test_is_black_listed_returns_null_for_methods_that_DNE',
	'test_subpath_is_null_by_default',
	'test_cannot_set_subpath',
	'test_subpath_set_when_passing_inner_and_parent',
	'test_subpath_set_for_deeper_inner_classes',
	'test_resource_is_loaded_script',
	'test_resource_is_loaded_inner',
	'test_extends_text_has_path_for_scripts',
	'test_extends_text_uses_class_name_for_natives',
	'test_extends_text_adds_inner_classes_to_end',
	'test_parsing_native_does_not_generate_orphans',
	]
	gr.summary.add_script('res://something.gd')
	for fn in func_names:
		var result = gr.summary.add_test(fn)
		assert_not_null(result, fn)