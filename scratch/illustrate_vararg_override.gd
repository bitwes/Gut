extends SceneTree


func _init():
	var DynamicScript = GDScript.new()
	var source = """
extends Node

func rpc(s1: StringName ='', p2='', p3='', p4='')-> Error:
	pass
	"""
	DynamicScript.source_code = source
	DynamicScript.resource_path = "res://illustrate_the_issue.gd"
	var result = DynamicScript.reload()
	print(result)

	quit()

