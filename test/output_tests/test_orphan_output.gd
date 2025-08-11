extends GutTest

var script_orphan = new_node("script_level")


func new_node(node_name):
	var n = Node.new()
	n.name = node_name
	return n


func before_all():
	new_node('before_all')


func after_all():
	new_node("after_all")


func test_this_makes_one_orphan():
	new_node("test_one_one")
	pass_test('passing')


func test_this_makes_two_orphans():
	new_node("test_two_one")
	new_node("test_two_two")
	pass_test('passing')


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
		new_node("after_all")


	func test_this_makes_one_orphan():
		new_node("test_one_one")
		pass_test('passing')


	func test_this_makes_two_orphans():
		new_node("test_two_one")
		new_node("test_two_two")
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
		new_node("after_all")


	func test_failing():
		new_node("test_one_one")
		assert_no_new_orphans()


	func test_passing():
		var n = new_node("test_two_one")
		n.free()
		assert_no_new_orphans()
