extends "res://test/resources/test_assert_setget_test_objects/scene_mock.gd"


func set_node_with_setter_getter(node):
	.set_node_with_setter_getter(node)
	_add_random_value_to_field_and_fied_with_setter_getter()


func _add_random_value_to_field_and_fied_with_setter_getter():
	var bonus = randi() % 10
	node_with_setter_getter.field += bonus
	node_with_setter_getter.fied_with_setter_getter += bonus
