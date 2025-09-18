extends SceneTree


"""-----------------------------------------------------------------------------
I'm thinking that ignore_method_when_doubling should check the meta to
see if it is an abstract method.  If it is, then it will make a different stub
for that method that generates an error if it is called.

No easy way to tell which abstract methods have been implmented in an abstract
class that extends an abstract class.

We can check `is_abstract` and warn/error/customize script generation error
message.
-----------------------------------------------------------------------------"""

"""-----------------------------------------------------------------------------
What if we had "add_abstract_method" that would add a method to the object with the
given name.  It would only work for methods that do not exist or are abstract.
This suffers from the same issue of not really being sure if a method is
actually implemented locally.
-----------------------------------------------------------------------------"""

"""-----------------------------------------------------------------------------
I'm also thinking...so what?  You can't make an instance of an abstract class,
why should you be able to make a double of it?  I know why one would want to,
and I kinda do too...but should you be able to do that?  Maybe if other
testing frameworks do it.
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
	# inspector.include_method_flags = true
	# inspector.include_property_usage = true
	# inspector.include_meta = true
	# inspector.pretty_meta = true
	# inspector.include_native = true

	inspector.print_script(get_script(), "this script")
	inspector.print_script(AbstractClass, 'Abstract')
	inspector.print_script(ExtendsAbstractClass, 'ExtendsAbstractClass')
	# inspector.print_script(ExtendsAbstractAndIsAbstract, 'ExtendsAbstractAndIsAbstract')
	# inspector.print_script(ExtendsAbstractAndIsAbstract_IsNotAbstract, 'ExtendsAbstractAndIsAbstract_IsNotAbstract')
	# inspector.print_script(JustSomeClass, 'JustSomeClass')
	# inspector.print_script(JustAbstract, 'JustAbstract')
	# inspector.print_script(ExtendsJustAbstract, 'ExtendsJustAbstract')

	quit()