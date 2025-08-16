extends GutTest

class CyclicRefClass:
	extends Object

	var other_thing = null

var script_orphan = new_node("script_level")
var MainScene = load('res://scenes/main.tscn')

func new_node(node_name):
	var n = Node.new()
	n.name = node_name
	return n


func before_all():
	new_node('before_all')


func after_all():
	new_node("script_level_after_all")


func test_this_makes_one_orphan():
	new_node("test_one_one")
	pass_test('passing')


func test_this_makes_two_orphans():
	new_node("test_two_one")
	new_node("test_two_two")
	pass_test('passing')


var _script_cyclic_ref = CyclicRefClass.new()
func test_cyclic_ref():
	var test_cyclic_ref_var = CyclicRefClass.new()
	test_cyclic_ref_var.other_thing = _script_cyclic_ref
	_script_cyclic_ref.other_thing = test_cyclic_ref_var
	pass_test('passing')

func test_cyclic_ref_local():
	var cyclic_ref_a = CyclicRefClass.new()
	var cyclic_ref_b = CyclicRefClass.new()
	cyclic_ref_a.other_thing = cyclic_ref_b
	cyclic_ref_b.other_thing = cyclic_ref_a
	pass_test('passing')


func test_with_a_scene_orphan():
	var main_scene = MainScene.instantiate()
	pass_test('passing')


func test_with_a_scene_orphan_assert():
	var main_scene = autoqfree(MainScene.instantiate())
	assert_no_orphans()


func test_with_an_autofreed_node():
	var new_node = autofree(Node.new())
	assert_no_orphans("will fail, but will not list orphan because by then it is freed.")


func test_with_some_nodes_with_children():
	var parent_a = new_node("parent_a")
	var child_a_1 = new_node("child_a_1")
	var child_a_2 = new_node("child_a_2")

	parent_a.add_child(child_a_1)
	parent_a.add_child(child_a_2)
	pass_test("passing")


func test_with_some_nodes_with_children_2():
	var parent_a = new_node("parent_a")
	var child_a_1 = new_node("child_a_1")
	var child_a_2 = new_node("child_a_2")

	var sub_parent_b = new_node("sub_parent_b")
	var child_b_1 = new_node("child_b_1")
	var child_b_2 = new_node("child_b_2")

	parent_a.add_child(child_a_1)
	parent_a.add_child(child_a_2)
	parent_a.add_child(sub_parent_b)

	sub_parent_b.add_child(child_b_1)
	sub_parent_b.add_child(child_b_2)
	pass_test("passing")


func test_with_some_nodes_with_children_3():
	var parent_a = new_node("parent_one")
	var child_a_1 = new_node("child_a_1")
	var child_a_2 = new_node("child_a_2")

	var sub_parent_b = new_node("sub_parent_b")
	var child_b_1 = new_node("child_b_1")
	var child_b_2 = new_node("child_b_2")

	parent_a.add_child(child_a_1)
	parent_a.add_child(child_a_2)
	parent_a.add_child(sub_parent_b)

	sub_parent_b.add_child(child_b_1)
	sub_parent_b.add_child(child_b_2)

	test_with_some_nodes_with_children()
	pass_test("passing")


class TestDupeOne:
	extends GutTest
	var script_orphan = new_node("script_level")


	func new_node(node_name):
		var n = Node.new()
		n.name = node_name
		return n


	func before_all():
		new_node('before_all')


	func after_all():
		new_node("TestDupeOne_after_all")


	func test_this_makes_one_orphan():
		new_node("test_one_one")
		pass_test('passing')


	func test_this_makes_two_orphans():
		new_node("test_two_one")
		new_node("test_two_two")
		pass_test('passing')


	func test_is_an_object_an_orphan():
		var o = Object.new()
		pass_test('passing')


class TestWithAsserts:
	extends GutTest
	var script_orphan = new_node("script_level")


	func new_node(node_name):
		var n = Node.new()
		n.name = node_name
		return n


	func before_all():
		new_node('before_all')


	func after_all():
		new_node("TestWithAsserts_after_all")


	func test_failing():
		new_node("test_one_one")
		assert_no_new_orphans()


	func test_passing():
		var n = new_node("test_two_one")
		n.free()
		assert_no_new_orphans()


	func test_pending():
		var n = new_node("test_pending")
		pending("sure")


	func test_risky():
		var n = new_node("test_risky")
