extends Node2D


onready var node_with_setter_getter = $NodeChildMock setget set_node_with_setter_getter, get_node_with_setter_getter


func set_node_with_setter_getter(node):
	if node_with_setter_getter != null:
		node_with_setter_getter.queue_free()
	node_with_setter_getter = node


func get_node_with_setter_getter() :
	return node_with_setter_getter
