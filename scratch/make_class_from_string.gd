extends SceneTree

func make_class():
	var text = ""

	text = "class MadeIt:\n" + \
		  "\tvar something=\"hello\"\n" + \
		  "\tfunc do_something():\n" +\
		  "\t\treturn 'did it'"

	return text

func make_node():
	var text = "extends Node2D\n" + \
	           "func do_something():\n" + \
			   "\treturn 'did it'"
	return text


func get_script_for_text(text):
	var script = GDScript.new()
	script.set_source_code(text)
	script.reload()
	return script

func create_node2d():
	var n = Node2D.new()
	n.set_script(get_script_for_text(make_node()))
	print(n.do_something())
	n.free()

func create_instance():
	var obj = Reference.new()
	obj.set_script(get_script_for_text(make_class()))

	var inner_class = obj.MadeIt.new()
	print(inner_class.do_something())



func _init():
	print("hello world")
	create_node2d()
	quit()
