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

@abstract
class Extends_Abstract_DoesNotImplement:
	extends AbstractClass

	@abstract
	func abstract_method()

	func my_normal_method():
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


class Extends_BaseButton:
	extends BaseButton

	func normal_method():
		pass

const CONSTANT_VALUE = 7

func parse_methods(klass):
	var normal_methods = {}
	var abstract_methods = {}
	for method in klass.get_script_method_list():
		if(method.flags & METHOD_FLAG_VIRTUAL_REQUIRED):
			abstract_methods[method.name] = method
		else:
			normal_methods[method.name] = method

	# Adds an "implmeted" field to the meta.  I don't think we need it, but this
	# is one way you could tell.
	for key in normal_methods:
		if(abstract_methods.has(key)):
			abstract_methods.erase(key)
			normal_methods[key].implemented = true
		else:
			normal_methods[key].implemented = false

	return {
		"normal":normal_methods,
		"abstract":abstract_methods
	}


func evaluate_abstractness(klass):
	print(klass)
	if(typeof(klass) == TYPE_STRING):
		klass = get_script().get_script_constant_map()[klass]
	print('  abstract = ', klass.is_abstract())

	var results = parse_methods(klass)

	for key in results.abstract:
		print('  [abstract] ', key)

	for key in results.normal:
		if( results.normal[key].implemented):
			print('  [implmeented]  ', key)
		else:
			print('  [normal]  ', key)



# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
func _init() -> void:
	var inspector = ObjIns.new()
	inspector.include_method_flags = true
	inspector.include_property_usage = true
	# inspector.include_meta = true
	# inspector.pretty_meta = true
	inspector.include_native = true
	# evaluate_abstractness(Extends_BaseButton)
	# inspector.print_script(Extends_BaseButton, "Extends_BaseButton")


	evaluate_abstractness("JustSomeClass")
	evaluate_abstractness("AbstractClass")
	evaluate_abstractness("Extends_Abstract")
	evaluate_abstractness("Extends_Abstract_DoesNotImplement")
	evaluate_abstractness("Extends_Abstract_IsAbstract")
	evaluate_abstractness("Extends_AbstractAndIsAbstract_IsNotAbstract")

	# inspector.print_script(Extends_AbstractAndIsAbstract_IsNotAbstract, "Extends_AbstractAndIsAbstract_IsNotAbstract")

	# inspector.print_script(get_script(), "this script")
	# inspector.print_script(AbstractClass, 'Abstract')
	# inspector.print_script(ExtendsAbstractClass, 'ExtendsAbstractClass')
	# inspector.print_script(ExtendsAbstractAndIsAbstract, 'ExtendsAbstractAndIsAbstract')
	# inspector.print_script(ExtendsAbstractAndIsAbstract_IsNotAbstract, 'ExtendsAbstractAndIsAbstract_IsNotAbstract')
	# inspector.print_script(JustSomeClass, 'JustSomeClass')
	# inspector.print_script(JustAbstract, 'JustAbstract')
	# inspector.print_script(ExtendsJustAbstract, 'ExtendsJustAbstract')

	quit()