extends GutTest


var GutRunner = load('res://addons/gut/gui/GutRunner.tscn')

func test_can_make_one():
	var gr = autofree(GutRunner.instantiate())
	assert_not_null(gr)

