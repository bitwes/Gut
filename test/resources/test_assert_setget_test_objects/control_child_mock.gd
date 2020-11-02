extends Control

const NodeChildMock = preload("res://test/resources/test_assert_setget_test_objects/node_child_mock.gd")
var node_with_setter: NodeChildMock = null setget set_node_with_setter

onready var progress_bar = $ProgressBar
onready var label = $Label


func set_node_with_setter(node):
	node_with_setter = node


func update():
	if node_with_setter != null:
		label.text = "%s / %s" %[node_with_setter.field_with_setter_getter, node_with_setter.field]
		progress_bar.max_value = node_with_setter.field
		progress_bar.value = node_with_setter.field_with_setter_getter
