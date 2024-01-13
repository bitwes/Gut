extends GutTest


var GutRunner = load('res://addons/gut/gui/GutRunner.tscn')

func test_nothing():
	pending()

func test_gut_runner_does_not_create_orphans():
	var gr = GutRunner.instantiate()
	gr.set_cmdln_mode(true)
	add_child(gr)
	gr.free()
	assert_no_new_orphans()


# func test_can_make_one():
# 	var gs = add_child_autofree(_utils.GutScene.instantiate())
# 	assert_not_null(gs)


# func test_freeing_simple_instance_does_not_make_orphans():
# 	var gs = _utils.GutScene.instantiate()
# 	assert_not_null(gs)
# 	gs.free()
# 	assert_no_new_orphans()


# func test_something():
# 	var gs = _utils.GutScene.instantiate()
# 	add_child(gs)
# 	gs.set_font('LobsterTwo')
# 	gs.set_font('AnonymousPro')
# 	# gs.set_font_size(5)
# 	gs.free()
# 	assert_no_new_orphans()


# func test_something_else():
# 	var theme = load('res://addons/gut/gui/GutSceneTheme.tres')
# 	assert_no_new_orphans()
