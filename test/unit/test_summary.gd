extends "res://addons/gut/test.gd"

var Summary = load('res://addons/gut/summary.gd')

var gr = {
	summary = null
}


func before_each():
	gr.summary = Summary.new()

func test_can_add_script():
	gr.summary.add_script('script1')

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

func test_printed_summary_uses_non_inncer_class_as_script_count():
	gr.summary.add_script('res://script.gd.InnerClass')
	gr.summary.add_script('res://script.gd.InnerClass2')
	gr.summary.add_script('res://one.gd')
	gr.summary.add_script('res://two.gd')
	var correct_count_check = gr.summary.get_summary_text().find('Scripts:          3')
	assert_true(correct_count_check != -1)


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
	assert_true(true)
