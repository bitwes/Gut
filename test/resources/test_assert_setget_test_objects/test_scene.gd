extends Node2D


@onready var node_with_setter_getter = $NodeChildMock :
	get:
		return node_with_setter_getter # TODOConverter40 Copy here content of get_node_with_setter_getter
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of set_node_with_setter_getter


func set_node_with_setter_getter(node):
	if node_with_setter_getter != null:
		node_with_setter_getter.queue_free()
	node_with_setter_getter = node


func get_node_with_setter_getter() :
	return node_with_setter_getter
