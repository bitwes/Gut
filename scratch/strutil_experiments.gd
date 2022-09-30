extends SceneTree

func create_script_from_source(source):
	var r_path = 'res://some_fake_script.gd'

	var DynamicScript = GDScript.new()
	DynamicScript.source_code = source
	DynamicScript.resource_path = r_path
	var result = DynamicScript.reload()

	return DynamicScript


func something():
	var s = create_script_from_source("extends Node2D\nvar a = 1").new()
	print('s.a = ', s.a)
	var d = inst_to_dict(s)
	print(d)

func print_class(thing):
	print(thing.get_class())

func _init():
	var n = Node
	# print(Node.get_class())
	print_class(n)
	quit()