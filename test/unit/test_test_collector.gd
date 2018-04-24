extends "res://addons/gut/test.gd"

var TestCollector = load('res://addons/gut/test_collector.gd')
var SCRIPTS_ROOT = 'res://test/parsing_and_loading_samples/'

var gr = {
	tc = null
}
func setup():
	gr.tc = TestCollector.new()

func test_has_test_one():
	gr.tc.add_script(SCRIPTS_ROOT + 'parse_samples.gd')
	assert_eq(gr.tc.scripts[0].tests[0].name, 'test_one')

func test_does_not_have_not_prefixed():
	gr.tc.add_script(SCRIPTS_ROOT + 'parse_samples.gd')
	for i in range(gr.tc.scripts[0].tests.size()):
		assert_ne(gr.tc.scripts[0].tests[i].name, 'not_prefixed')

func test_get_set_test_prefix():
	assert_get_set_methods(gr.tc, 'test_prefix', 'test_', 'soemthing')

func test_can_change_test_prefix():
	gr.tc.set_test_prefix('diff_prefix_')
	gr.tc.add_script(SCRIPTS_ROOT + 'parse_samples.gd')
	assert_eq(gr.tc.scripts[0].tests[0].name, 'diff_prefix_something')

func test_get_set_test_class_prefix():
	assert_get_set_methods(gr.tc, 'test_class_prefix', 'Test', 'Something')

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
