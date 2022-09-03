# Script to demo this failing test:
#
# func test_doubled_instances_extend_the_inner_class():
# 	var inst = doubler.double_inner(INNER_CLASSES_PATH, 'InnerA').new()
# 	assert_is(inst, InnerClasses.InnerA)
extends SceneTree

# Currently not demoing anything wrong.
func _init():
	var script_source = '' + \
	"extends Node2D\n" + \
	"func hello_world():\n" + \
	"\tprint('--- hello world ---')"

	print(script_source)

	var DynScript = GDScript.new()
	DynScript.source_code = script_source
	DynScript.reload()

	var inst = DynScript.new()
	if(inst is Node2D):
		print('yes it is')
	else:
		print('unfortunately it is not')

	inst.free()
	quit()
