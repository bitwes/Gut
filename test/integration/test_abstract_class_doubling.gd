extends GutInternalTester


@abstract
class AbstractClass:

	@abstract func abstract_method()


@abstract
class ExtendsAbstractClass:
	extends AbstractClass

	func abstract_method():
		return "implemented"

	@abstract
	func another_abstract_method()


func before_all():
	register_inner_classes(get_script())


# Our implementaiton assumes that the order of get_script_method_list() is
# from child to parents. The following test will show when future godot
# versions change the behavior.
func test_method_order_assumption():
	var method_list = (ExtendsAbstractClass as Variant).get_script_method_list()

	assert_eq(method_list[0].name, "abstract_method")
	assert_eq(method_list[0].flags, 1)

	assert_eq(method_list[1].name, "another_abstract_method")

	assert_eq(method_list[2].name, "abstract_method")
	assert_eq(method_list[2].flags, 129)


func test_can_double_abstract():
	var dbl = double(AbstractClass)
	assert_not_null(dbl)


func test_can_stub_to_return_for_abstract_method_at_sctipt_level():
	stub(AbstractClass, 'abstract_method').to_return('a')
	var inst = double(AbstractClass).new()
	assert_eq(inst.abstract_method(), 'a')


func test_can_stub_to_return_for_abstract_method_at_double_level():
	var Dbl = double(AbstractClass)
	stub(Dbl, 'abstract_method').to_return(9)
	var inst = Dbl.new()
	assert_eq(inst.abstract_method(), 9)


func test_can_stub_to_return_for_abstract_method_at_instance_level():
	var inst = double(AbstractClass).new()
	stub(inst.abstract_method).to_return(7)
	assert_eq(inst.abstract_method(), 7)


func test_error_when_stubbing_to_call_super_at_script_level():
	stub(AbstractClass, 'abstract_method').to_call_super()
	pass_test("no errors")


func test_error_when_stubbing_to_call_super_at_instance_level():
	# Arrange
	var doubled = autofree(double(AbstractClass).new())
	stub(doubled.abstract_method).to_call_super()

	# Act
	var result = doubled.abstract_method()

	# Assert
	assert_null(result)
	assert_tracked_gut_error()
	assert_eq(get_logger().get_errors()[0], "Cannot call super() because method abstract_method is abstract.")


func test_can_stub_implemented_abstract_to_call_super():
	var inst = double(ExtendsAbstractClass).new()
	stub(inst.abstract_method).to_call_super()
	assert_eq(inst.abstract_method(), 'implemented')
