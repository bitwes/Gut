extends SceneTree

func create_script_from_source(source):
	var r_path = 'res://some_fake_script.gd'

	var DynamicScript = GDScript.new()
	DynamicScript.source_code = source
	DynamicScript.resource_path = r_path
	var result = DynamicScript.reload()

	return DynamicScript


func _init():
	var s = create_script_from_source("extends Node2D\nvar a = 1").new()
	print('s.a = ', s.a)
	var d = inst_to_dict(s)
	print(d)

	quit()