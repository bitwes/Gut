extends SceneTree

const DOUBLE_ME_PATH = 'res://test/resources/doubler_test_objects/double_me.gd'
var DoubleMe = GutUtils.WarningsManager.load_script_ignoring_all_warnings(DOUBLE_ME_PATH)
var ObjectInspector = load("res://scratch/object_inspector.gd")


var insp = ObjectInspector.new()



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

class Base:
	func foo():
		pass

	func bar() -> void:
		pass


func print_methods(klass):

	for method in (klass as Variant).get_script_method_list():
		print("-----------")
		insp.print_method_signature(method)
		GutUtils.pretty_print(method)


@abstract
class AbstractClass:
	@abstract
	func abstract_method() -> int


class ExtendsAbstract:
	extends AbstractClass

	func abstract_method() -> int:
		return 10


class ReturnTypeDefaults:
	func packed_byte_array()->PackedByteArray:
		return PackedByteArray()

	func packed_int32_array() -> PackedInt32Array:
		return PackedInt32Array()


func _init() -> void:
	# print("AbstractClass")
	# for method in (AbstractClass as Variant).get_script_method_list():
	# 	print(JSON.stringify(method, "    "))

	# print("\nExtendsAbstract")
	# for method in (ExtendsAbstract as Variant).get_script_method_list():
	# 	print(JSON.stringify(method, "    "))

	# print_methods(AbstractClass)
	# print("\n____________________________________________________________\n")
	# print_methods(ExtendsAbstract)

	# var inst = DifferentReturnTypes.new()
	# for method in inst.get_method_list():
	# 	print("-----------")
	# 	insp.print_method_signature(method)
	# 	GutUtils.pretty_print(method)

	# print_methods(Base)
	# print(inst.no_return())

	var inst = ReturnTypeDefaults.new()
	for method in (ReturnTypeDefaults as Variant).get_script_method_list():
		print('calling ', method.name)
		inst.call(method.name)
	quit()