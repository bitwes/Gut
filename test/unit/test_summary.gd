extends "res://test/gut_test.gd"

var Summary = load('res://addons/gut/test_collector.gd')
const PARSING_AND_LOADING = 'res://test/resources/parsing_and_loading_samples'
const SUMMARY_SCRIPTS = 'res://test/resources/summary_test_scripts'

func _make_a_gut():
    var test_gut = add_child_autofree(new_gut())
    test_gut.logger.disable_printer("terminal", false)
    test_gut._should_print_summary = true
    return test_gut

func _run_test_gut_tests(test_gut):
    test_gut.p(" ------------------ start test output ------------------")
    watch_signals(test_gut)
    test_gut.run_tests()
    if(get_signal_emit_count(test_gut, 'end_run') == 0):
        await wait_for_signal(test_gut.end_run, 60, 'waiting for tests to finish')
    test_gut.p(" ------------------ end test output ------------------")

    gut.p("\n\n\n\n\n\n\n")


func test_can_make_one():
    var s = Summary.new()
    assert_not_null(s)

func test_can_make_one_with_a_test_colletor():
    var s = Summary.new(_make_a_gut())
    assert_not_null(s)

func test_output_1():
    var test_gut = _make_a_gut()
    test_gut.add_directory(PARSING_AND_LOADING)

    await _run_test_gut_tests(test_gut)
    pass_test("Look at the output, or don't if you aren't interested.")

func test_output_with_unit_and_script_set():
    var test_gut = _make_a_gut()
    test_gut.add_directory(PARSING_AND_LOADING)

    test_gut.select_script('sample')
    test_gut.unit_test_name = 'number'

    await _run_test_gut_tests(test_gut)
    pass_test("Look at the output, or don't if you aren't interested.")

func test_output_with_scripts_that_have_issues():
    var test_gut = _make_a_gut()
    test_gut.add_directory(SUMMARY_SCRIPTS)

    test_gut.log_level = 99
    test_gut.select_script('issues')

    await _run_test_gut_tests(test_gut)
    pass_test("Look at the output, or don't if you aren't interested.")

