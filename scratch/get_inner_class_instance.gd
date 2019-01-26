extends SceneTree
# ##############################################################################
# Proof of concept of loading an inner class given the name of the file where
# the class is and the name of the class in the file.
# ##############################################################################

class TestClass:
	func test_context1_one():
		pass
	func test_context1_two():
		pass
	func print_something(and_this=''):
		print('hello world ', and_this)

class Inner1:
	class Inner2:
		func print_something():
			print('inner 2')

	func print_something():
		print('inner 1')

func _do_stuff():
	var t = load('res://test/doubler_test_objects/inner_classes.gd')
	var IA = t.get('InnerA')
	var IB1 = t.get('InnerB').get('InnerB1')
	var i = IB1.new()

	print('----')
	print(t.get_property_list())
	print(t.get_method_list())
	print(IB1.get_method_list())
	print('----')
	print(t.new().get_property_list())
	print(t.new().get_method_list())
	print('----')
	print(to_json(t))
	print(to_json(i))
	print(i.get_b1())
	print(inst2dict(i))
	print(inst2dict(i)['@path'])
	print(inst2dict(t.new()))


func _init():

	_do_stuff()
	quit()
