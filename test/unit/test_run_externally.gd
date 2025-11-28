extends GutInternalTester


func test_can_make_one():
	var inst = autofree(GutUtils.RunExternallyScene.instantiate())
	assert_not_null(inst)


func test_can_get_godot_help():
	var inst = add_child_autofree(GutUtils.RunExternallyScene.instantiate())
	var help_text = await inst.get_godot_help()
	assert_string_contains(help_text, "-h, --help")


func test_can_get_gut_help():
	var inst = add_child_autofree(GutUtils.RunExternallyScene.instantiate())
	var help_text = await inst.get_gut_help()
	assert_string_contains(help_text, "The default behavior for GUT is to load")
