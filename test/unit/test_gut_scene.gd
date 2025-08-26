extends GutInternalTester

func test_free_no_orphans():
	var gs = GutUtils.GutScene.instantiate()
	gs.free()
	assert_no_new_orphans()


func test_in_tree_free_no_orphans():
	var gs = GutUtils.GutScene.instantiate()
	add_child(gs)
	gs.free()
	assert_no_new_orphans()
