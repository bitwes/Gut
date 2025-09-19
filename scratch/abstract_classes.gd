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
class ExtendsAbstractClass:
	extends AbstractClass

	func abstract_method():
		pass


# ------------------------------------------------------------------------------
@abstract
class ExtendsAbstractAndIsAbstract:
	extends AbstractClass

	func abstract_method():
		pass

	@abstract
	func another_abstract_method()


# ------------------------------------------------------------------------------
class ExtendsAbstractAndIsAbstract_IsNotAbstract:
	extends ExtendsAbstractAndIsAbstract

	func abstract_method():
		pass

	func another_abstract_method():
		pass


const CONSTANT_VALUE = 7


# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
func _init() -> void:
	var inspector = ObjIns.new()
	inspector.include_method_flags = true
	inspector.include_property_usage = true
	# inspector.include_meta = true
	# inspector.pretty_meta = true
	# inspector.include_native = true

	inspector.print_script(get_script(), "this script")
	inspector.print_script(AbstractClass, 'Abstract')
	inspector.print_script(ExtendsAbstractClass, 'ExtendsAbstractClass')
	inspector.print_script(ExtendsAbstractAndIsAbstract, "ExtendsAbstractAndIsAbstract")
	# inspector.print_script(ExtendsAbstractAndIsAbstract, 'ExtendsAbstractAndIsAbstract')
	# inspector.print_script(ExtendsAbstractAndIsAbstract_IsNotAbstract, 'ExtendsAbstractAndIsAbstract_IsNotAbstract')
	# inspector.print_script(JustSomeClass, 'JustSomeClass')
	# inspector.print_script(JustAbstract, 'JustAbstract')
	# inspector.print_script(ExtendsJustAbstract, 'ExtendsJustAbstract')

	quit()