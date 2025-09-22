class_name AbstractClassStandalone
extends SceneTree


"""-----------------------------------------------------------------------------
After all this thinking, I think `stub_abstract_method` and detecting the
parser error to provide more info is the right approach.  `stub_abstract` would
add a stub that would not call super, could be stubbed to call super, and
errors when being called for a non-abstract method.

Also, the workaround of locally extending the abstact class and providing
and implmentation for abstract methods should be added to the documentation.
-----------------------------------------------------------------------------"""


var ObjIns = load("res://scratch/object_inspector.gd")


# ------------------------------------------------------------------------------
class JustSomeClass:

	func normal_function():
		pass


# ------------------------------------------------------------------------------
@abstract
class JustAbstract:
	extends Object


# ------------------------------------------------------------------------------
class ExtendsJustAbstract:
	extends JustAbstract


# ------------------------------------------------------------------------------
@abstract
class AbstractClass:
	extends Object

	@abstract
	func abstract_method()

	func real_method():
		pass


# ------------------------------------------------------------------------------
class Extends_Abstract:
	extends AbstractClass

	func abstract_method():
		pass


# ------------------------------------------------------------------------------
@abstract
class Extends_Abstract_IsAbstract:
	extends AbstractClass

	func abstract_method():
		pass

	@abstract
	func another_abstract_method()


# ------------------------------------------------------------------------------
class Extends_AbstractAndIsAbstract_IsNotAbstract:
	extends Extends_Abstract_IsAbstract

	func abstract_method():
		pass

	func another_abstract_method():
		pass


const CONSTANT_VALUE = 7



func evaluate_abstractness(klass):
	print(klass)
	if(typeof(klass) == TYPE_STRING):
		klass = get_script().get_script_constant_map()[klass]

	var counted = {}
	var abstract_methods = {}
	for method in klass.get_script_method_list():
		if(method.flags & METHOD_FLAG_VIRTUAL_REQUIRED):
			abstract_methods[method.name] = method

		counted[method.name] = counted.get_or_add(method.name, 0) + 1

	for key in counted:
		# Extends_AbstractAndIsAbstract_IsNotAbstract.abstract_method has a
		# count of 3
		if(counted[key] > 1):
			if(abstract_methods.has(key)):
				print("* [implemented] ", key , ' (', counted[key], ')')
			else:
				print("* [UNKNOWN] ", key)
		elif(counted[key] == 1):
			if(abstract_methods.has(key)):
				print("* [abstract] ", key)
			else:
				print("* [normal] ", key)
		else:
			print("[REALLY UNKOWN] ", key)
			print("    count = ", counted[key])




# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
func _init() -> void:
	var inspector = ObjIns.new()
	inspector.include_method_flags = true
	inspector.include_property_usage = true
	# inspector.include_meta = true
	# inspector.pretty_meta = true
	# inspector.include_native = true


	# evaluate_abstractness("JustSomeClass")
	evaluate_abstractness("AbstractClass")
	evaluate_abstractness("Extends_Abstract")
	evaluate_abstractness("Extends_Abstract_IsAbstract")
	evaluate_abstractness("Extends_AbstractAndIsAbstract_IsNotAbstract")

	inspector.print_script(Extends_AbstractAndIsAbstract_IsNotAbstract, "Extends_AbstractAndIsAbstract_IsNotAbstract")

	# inspector.print_script(get_script(), "this script")
	# inspector.print_script(AbstractClass, 'Abstract')
	# inspector.print_script(ExtendsAbstractClass, 'ExtendsAbstractClass')
	# inspector.print_script(ExtendsAbstractAndIsAbstract, 'ExtendsAbstractAndIsAbstract')
	# inspector.print_script(ExtendsAbstractAndIsAbstract_IsNotAbstract, 'ExtendsAbstractAndIsAbstract_IsNotAbstract')
	# inspector.print_script(JustSomeClass, 'JustSomeClass')
	# inspector.print_script(JustAbstract, 'JustAbstract')
	# inspector.print_script(ExtendsJustAbstract, 'ExtendsJustAbstract')

	quit()