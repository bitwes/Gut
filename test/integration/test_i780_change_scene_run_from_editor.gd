extends GutTest

var scene_path = "res://test/resources/simple_scene.tscn"
var Scene  = load(scene_path)

func test_with_change_scene_to_file():
	get_tree().change_scene_to_file(scene_path)
	await get_tree().scene_changed
	autofree(get_tree().current_scene)
	pass_test('passing')

func test_with_change_scene_to_packed():
	get_tree().change_scene_to_packed(Scene)
	await get_tree().scene_changed
	autofree(get_tree().current_scene)
	pass_test('passing')
