extends GutInternalTester

var GutControl = load('res://addons/gut/gui/GutControl.tscn')

func test_free_no_orphans():
	var gc = GutControl.instantiate()
	gc.free()
	assert_no_new_orphans()


func test_in_tree_free_no_orphans():
	var gc = GutControl.instantiate()
	add_child(gc)
	gc.free()
	assert_no_new_orphans()
