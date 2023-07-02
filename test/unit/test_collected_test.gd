extends GutTest

var CollectedTest = load('res://addons/gut/collected_test.gd')



func test_add_fail_results_in_is_failing_to_true():
    var t = CollectedTest.new()
    t.add_fail('fail text')
    assert_true(t.is_failing())


func test_add_pending_results_in_is_pending():
    var t = CollectedTest.new()
    t.add_pending('pending text')
    assert_true(t.is_pending())

func test_adding_pending_and_fail_still_results_in_pending_false():
    var t = CollectedTest.new()
    t.add_pending('pending text')
    t.add_fail('fail text')
    assert_false(t.is_pending())

func test_add_pass_results_in_is_passing_true():
    var t= CollectedTest.new()
    t.add_pass('pass text')
    assert_true(t.is_passing())

func test_add_pass_and_fail_results_in_passing_false():
    var t = CollectedTest.new()
    t.add_pass('pass text')
    t.add_fail('fail text')
    assert_false(t.is_passing())

func test_add_pass_and_pending_results_in_passing_false():
    var t = CollectedTest.new()
    t.add_pass('pass text')
    t.add_pending('pending text')
    assert_false(t.is_passing())


func test_get_status_text_is_no_asserts_when_nothing_happened():
    var t = CollectedTest.new()
    assert_eq(t.get_status_text(), 'no asserts')

func test_when_one_pass_added_status_is_pass():
    var t = CollectedTest.new()
    t.add_pass('pass')
    assert_eq(t.get_status_text(), 'pass')

func test_when_one_failed_status_is_fail():
    var t = CollectedTest.new()
    t.add_fail('fail')
    assert_eq(t.get_status_text(), 'fail')

func test_when_one_pending_status_is_pending():
    var t = CollectedTest.new()
    t.add_pending('pending')
    assert_eq(t.get_status_text(), 'pending')

func test_when_should_skip_true_status_is_risky():
    var t = CollectedTest.new()
    t.should_skip = true
    assert_eq(t.get_status_text(), 'skipped')

func test_when_nothing_added_test_is_risky():
    var t = CollectedTest.new()
    assert_true(t.is_risky())

func test_when_has_pass_test_is_not_risky():
    var t = CollectedTest.new()
    t.add_pass('pass')
    assert_false(t.is_risky())

func test_when_has_pending_test_is_not_risky():
    var t = CollectedTest.new()
    t.add_pending('text')
    assert_false(t.is_risky())

func test_when_has_failure_test_is_not_risky():
    var t = CollectedTest.new()
    t.add_fail('text')
    assert_false(t.is_risky())

func test_when_should_skip_test_is_risky():
    var t = CollectedTest.new()
    t.should_skip = true
    assert_true(t.is_risky())

func test_assert_count_zero_by_default():
    var t = CollectedTest.new()
    assert_eq(t.assert_count, 0)


func test_assert_count_reflects_pass_and_failures():
    var t = CollectedTest.new()
    t.add_pass('pass')
    t.add_pass('pass')
    t.add_fail('fail')
    assert_eq(t.assert_count, 3)


# func test_test_that_do_not_assert_are_not_pending():
# 	gr.summary.add_script('res://script.gd')
# 	gr.summary.add_test('foo')

# 	var total = gr.summary.get_totals()
# 	assert_eq(total.pending, 0)

# func test_test_that_do_not_assert_are_not_failing():
# 	gr.summary.add_script('res://script.gd')
# 	gr.summary.add_test('foo')

# 	var total = gr.summary.get_totals()
# 	assert_eq(total.failing, 0)

# func test_test_that_do_not_assert_are_risky():
# 	gr.summary.add_script('res://script.gd')
# 	gr.summary.add_test('foo')

# 	var total = gr.summary.get_totals()
# 	assert_eq(total.risky, 1)
