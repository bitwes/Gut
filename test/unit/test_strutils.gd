extends 'res://test/gut_test.gd'

class TestInternalStr:
	extends 'res://test/gut_test.gd'

	var Strutils = load('res://addons/gut/strutils.gd')

	func _str(thing):
		return Strutils.new().type2str(thing)

	class ExtendsControl:
		extends Control

		func do_something():
			pass # does nothing, heh

	class ExtendsNothing:
		var foo = 'bar'

	func test_string():
		assert_eq(_str('this'), 'this')

	func test_int():
		assert_eq(_str(1234), '1234')

	func test_float():
		assert_eq(_str(1.234), '1.234')

	func test_script():
		assert_eq(_str(self), str(self, '(test_strutils.gd/TestInternalStr)'))

	func test_script_2():
		var dm = autofree(DoubleMe.new())
		assert_eq(_str(dm), str(dm) + '(double_me.gd)')

	func test_scene():
		var scene = autofree(DoubleMeScene.instance())
		assert_eq(_str(scene),  str(scene, '(double_me_scene.gd)'))

	func test_file_instance():
		var f = File.new()
		assert_eq(_str(f), str(f))

	func test_vector2():
		var v2 = Vector2(20, 30)
		assert_eq(_str(v2), 'Vector2(20, 30)')

	func test_null():
		assert_eq(_str(null), str(null))

	func test_boolean():
		assert_eq(_str(true), str(true))
		assert_eq(_str(false), str(false))

	func test_color():
		var c  = Color(.1, .2, .3)
		assert_eq(_str(c), 'Color(0.1,0.2,0.3,1)')

	func test_gdnative():
		assert_eq(_str(Node2D), 'Node2D')

	func test_loaded_scene():
		assert_eq(_str(DoubleMeScene), str(DoubleMeScene) + '(double_me_scene.tscn)')

	func test_doubles():
		var d = double(DOUBLE_ME_PATH).new()
		assert_eq(_str(d), str(d) + '(double of double_me.gd)')

	func test_another_double():
		var d = double(DOUBLE_EXTENDS_NODE2D).new()
		assert_eq(_str(d), str(d) + '(double of double_extends_node2d.gd)')

	func test_double_inner():
		var d = double(InnerClasses, 'InnerA').new()
		assert_eq(_str(d), str(d) + '(double of inner_classes.gd/InnerA)')

	func test_assert_null():
		assert_eq(_str(null), str(null))

	func test_object_null():
		var scene = autofree(load(DOUBLE_ME_SCENE_PATH).instance())
		assert_eq(_str(scene.get_parent()), 'Null')

	# currently does not print the inner class, maybe later.
	func test_inner_class():
		var ec = autofree(ExtendsControl.new())
		assert_eq(_str(ec), str(ec) + '(test_strutils.gd/TestInternalStr/ExtendsControl)')

	func test_simple_class():
		var en = autofree(ExtendsNothing.new())
		assert_eq(_str(en), str(en) + '(test_strutils.gd/TestInternalStr/ExtendsNothing)')

	func test_returns_null_for_just_freed_objects():
		var n = autofree(Node.new())
		n.free()
		assert_eq(_str(n), '[Deleted Object]', 'sometimes fails based on timing.')
