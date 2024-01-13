extends SceneTree

var GutRunner = load('res://addons/gut/gui/GutRunner.tscn')
var GutScene = load('res://addons/gut/GutScene.tscn')



func _init():
	# var gs = GutScene.instantiate()
	# get_root().add_child(gs)

	var gr = GutRunner.instantiate()
	gr.set_cmdln_mode(true)
	get_root().add_child(gr)
	get_root().remove_child(gr)

	quit()