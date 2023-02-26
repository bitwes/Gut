extends GutTest

var ResultTree = load('res://addons/gut/gui/ResultsTree.tscn')

func test_assert_can_create_one():
	var rt = autofree(ResultTree.instantiate())
	assert_not_null(rt);

func test_has_show_orphans_property():
	var rt = autofree(ResultTree.instantiate())
	assert_property(rt, 'show_orphans', true, false)

func test_has_hide_passing_property():
	var rt = autofree(ResultTree.instantiate())
	assert_property(rt, 'hide_passing', true, false)

func test_test_load_some_shit():
	var rt = add_child_autofree(ResultTree.instantiate())
	rt.load_json_file('res://test/resources/gut_full_run.json')
	pause_before_teardown()

