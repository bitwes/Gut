extends "res://addons/gut/test.gd"

func test_object_is_freed_should_pass():
	var obj = Node.new()
	obj.free()
	assert_freed(obj, "Object1")
	
func test_object_is_freed_should_fail():
	var obj = Node.new()
	assert_freed(obj, "Object2")
	# free after test
	obj.queue_free()
	
func test_object_is_not_freed_should_pass():
	var obj = Node.new()
	assert_not_freed(obj, "Object3")
	# free after test
	obj.queue_free()
	
func test_object_is_not_freed_should_fail():
	var obj = Node.new()
	obj.free()
	assert_not_freed(obj, "Object4")