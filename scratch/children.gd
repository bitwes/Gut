extends SceneTree

var node1 = Node.new()
var node2 = Node.new()
var node3 = Node.new()

func _init():
	print('starting kids = ', get_root().get_children())
	print('stray nodes = ', node1.print_stray_nodes())

	print('created nodes = ', node1, node2, node3)
	get_root().add_child(node1)
	get_root().add_child(node2)
	get_root().add_child(node3)

	print('children = ', get_root().get_children())
	print('freeing ', node1)
	node1.free()
	print('children = ', get_root().get_children())

	quit()

