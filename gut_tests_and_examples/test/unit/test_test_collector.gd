extends "res://addons/gut/test.gd"

var TestCollector = load('res://addons/gut/test_collector.gd')

var gr = {
	tc = null
}
func setup():
	gr.tc = TestCollector.new()

func test_doing_something():
	gr.tc.add_script('res://gut_tests_and_examples/test/samples/test_readme_examples.gd')
	print(gr.tc.to_s())

func test_another_thing():
	gr.tc.add_script('res://gut_tests_and_examples/test/samples/has_inner_class.gd')
	print(gr.tc.to_s())
