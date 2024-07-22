extends GutInternalTester


var _src_base = """
extends GutTest
"""
var _src_passing_test = """
func test_is_passing():
	assert_true(true)
"""
var _src_failing_test = """
func test_is_failing():
	assert_eq(1, '1')
"""
var _src_skip_script_var_string_val = """
var skip_script = 'skip me, thanks'
"""
var _src_skip_script_var_null_val = """
var skip_script = null
"""
var _src_should_skip_script_method_ret_true = """
func should_skip_script():
	return true
"""
var _src_should_skip_script_method_ret_false = """
func should_skip_script():
	return false
"""
var _src_should_skip_script_method_ret_string = """
func should_skip_script():
	return 'skip me'
"""

var _gut = null

func before_all():
	verbose = true

func before_each():
	_gut = add_child_autofree(new_gut(verbose))


func _run_test_source(src):
	var g = new_gut(true)
	add_child_autofree(g)

	var dyn = GutUtils.create_script_from_source(src)
	g.get_test_collector().add_script(dyn.resource_path)
	g.run_tests()

	var s = GutUtils.Summary.new()
	return s.get_totals(g)


func test_can_compose_and_run_a_script():
	var src = _src_base +\
		_src_passing_test +\
		_src_failing_test
	var t = _run_test_source(src)

	assert_eq(t.tests, 2)


func test_using_skip_script_variable_is_deprecated():
	var src = _src_base + \
		_src_skip_script_var_string_val + \
		_src_passing_test
	var t = _run_test_source(src)
	assert_eq(t.deprecated, 1, 'Should be one deprecation.')

func test_using_skip_script_variable_is_deprecated_():
	var s = DynamicGutTest.new()
	s.add_source("var skip_script = 'skip me thanks'")
	s.add_source("func test_passing():assert_true(true)")
	var t = s.run_test_in_gut(_gut)
	assert_eq(t.deprecated, 1, 'Should be one deprecation.')


func test_when_skip_script_var_is_string_script_is_skipped():
	var src = _src_base + \
		_src_skip_script_var_string_val + \
		_src_passing_test
	var t = _run_test_source(src)

	assert_eq(t.tests, 0, 'no tests should be ran')
	assert_eq(t.risky, 1, 'Should be marked as risky due to skip')

func test_when_skip_script_var_is_string_script_is_skipped_():
	var src = _src_base + \
		_src_skip_script_var_string_val + \
		_src_passing_test
	var t = _run_test_source(src)

	assert_eq(t.tests, 0, 'no tests should be ran')
	assert_eq(t.risky, 1, 'Should be marked as risky due to skip')



func test_when_skip_script_var_is_null_the_script_is_ran():
	var src = _src_base + \
		_src_skip_script_var_null_val + \
		_src_passing_test
	var t = _run_test_source(src)

	assert_eq(t.tests, 1, 'the one test should be ran')
	assert_eq(t.risky, 0, 'not marked risky just for having var')

func test_should_skip_script_method_returns_false_by_default():
	var test = autofree(GutTest.new())
	assert_false(test.should_skip_script())


func test_when_should_skip_script_returns_false_script_is_run():
	var src = _src_base + \
		_src_should_skip_script_method_ret_false + \
		_src_passing_test
	var t = _run_test_source(src)

	assert_eq(t.tests, 1, 'no tests should be ran')
	assert_eq(t.risky, 0, 'Should be marked as risky due to skip')



func test_when_should_skip_script_returns_true_script_is_skipped():
	var src = _src_base + \
		_src_should_skip_script_method_ret_true + \
		_src_passing_test
	var t = _run_test_source(src)

	assert_eq(t.tests, 0, 'no tests should be ran')
	assert_eq(t.risky, 1, 'Should be marked as risky due to skip')


func test_when_should_skip_script_returns_string_script_is_skipped():
	var src = _src_base + \
		_src_should_skip_script_method_ret_string + \
		_src_passing_test
	var t = _run_test_source(src)

	assert_eq(t.tests, 0, 'no tests should be ran')
	assert_eq(t.risky, 1, 'Should be marked as risky due to skip')


func test_using_should_skip_script_method_is_not_deprecated():
	var src = _src_base + \
		_src_should_skip_script_method_ret_true + \
		_src_passing_test
	var t = _run_test_source(src)

	assert_eq(t.deprecated, 0, 'nothing is deprecated')

