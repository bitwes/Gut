extends SceneTree

const DOUBLE_ME_PATH = 'res://test/resources/doubler_test_objects/double_me.gd'
var DoubleMe = GutUtils.WarningsManager.load_script_ignoring_all_warnings(DOUBLE_ME_PATH)
var ObjectInspector = load("res://scratch/object_inspector.gd")


var insp = ObjectInspector.new()

@abstract
class AbstractClass:
	@abstract
	func abstract_method() -> int

	func returns_int() -> int:
		return 7

	func returns_gut_test() -> GutTest:
		return GutTest.new()


class ExtendsAbstract:
	extends AbstractClass

	func abstract_method() -> int:
		return 10


class DifferentReturnTypes:
	func return_int() -> int:
		return 7

	func inferred_return_int():
		return 7

	func just_return():
		return

	func just_pass():
		pass

	func no_return():
		var a = 'foo'

	func void_return() -> void:
		var foo = 'a'


class ExtendsDifferentReturnTypes:
	extends DifferentReturnTypes

	func no_return():
		return "I'll return if I want"


class Example:
	func explicit_void() -> void:
		pass

	func inferred_void():
		pass


func print_methods(klass):

	for method in (klass as Variant).get_script_method_list():
		print("-----------")
		insp.print_method_signature(method)
		GutUtils.pretty_print(method)



func _init() -> void:

	# print_methods(AbstractClass)
	# print("\n____________________________________________________________\n")
	# print_methods(ExtendsAbstract)

	# var inst = DifferentReturnTypes.new()
	# for method in inst.get_method_list():
	# 	print("-----------")
	# 	insp.print_method_signature(method)
	# 	GutUtils.pretty_print(method)

	print_methods(ExtendsAbstract)
	# print(inst.no_return())
	quit()