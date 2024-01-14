extends GutTest

# https://github.com/bitwes/Gut/issues/436

# This script for this scene has an export variable that has been set in the
# editor.  The position was also changed to (10, 10)
var TestScene = load('res://test/resources/TestIssue436.tscn')

func test_illustrate_scene_instance_gets_value():
	var scene = autofree(TestScene.instance())
	assert_eq(scene.test_export_value, 2)


func test_partial_double_gets_export_value_set_in_editor():
	var scene = partial_double(TestScene).instance()
	assert_eq(scene.test_export_value, 2)


func test_double_gets_export_value_set_in_editor():
	var scene = double(TestScene).instance()
	assert_eq(scene.test_export_value, 2)


func test_partial_double_gets_other_node_properties_that_were_set_in_editor():
	var scene = partial_double(TestScene).instance()
	assert_eq(scene.position, Vector2(10.0, 10.0))
