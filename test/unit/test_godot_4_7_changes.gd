extends GutInternalTester

class SomeDoubleStuff:
	func int_return()->int:
		return 10


class ReturnTypes:
	func inferred_void():
		pass

func before_all():
	register_inner_classes(get_script())
	register_inner_classes(InnerClasses)

# SEE test_method_maker.gd.TestReturnTypes

# SEE test_abstract_class_doubling


func test_no_error_when_stub_to_return_on_methods_with_inferred_void_return_type():
	stub(DoubleMe, 'inferred_void_return').to_return(7)
	assert_engine_error_count(0)
	assert_tracked_gut_error(self, 0)


func test_error_when_stubbing_a_method_on_an_instance_to_return_a_different_invalid_data_type():
	var n = autofree(DoubleMe.new())
	var sp = GutUtils.StubParams.new(n.explicit_int_return)
	sp.to_return('asdf')

	var result = sp.validate()
	assert_false(result)
	assert_tracked_gut_error(self, 1)

func test_error_when_stubbing_a_method_on_a_script_to_return_a_different_invalid_data_type():
	var sp = GutUtils.StubParams.new(DoubleMe, 'explicit_int_return')
	sp.to_return('asdf')

	var result = sp.validate()
	assert_false(result)
	assert_tracked_gut_error(self, 1)


func test_error_when_stubbing_to_return_null_when_return_type_cannot_be_null():
	pending("int, String, etc..maybe only Object and Variant can be null?  IDK.")


func test_cannot_double_something_when_it_has_invalid_stubs():
	pending("The runtime errors are confusing, so this would cut down on that.")


# func test_warn_when_methods_that_have_return_types_are_not_stubbed():
# 	pending("This could be at the time of doubling or when the method is called.  " + \
# 		"Something needs to happen to make the runtime error clearer.")


func test_warn_when_non_stubbed_method_is_called():
	pending("Warning should include what is being returned.  " + \
		"Right now, it's always null, but if other defaults are implemented then " +\
		"the value is included in the message.")


func test_stubbing_to_do_nothing_prevents_non_stubbed_warning_when_method_is_called():
	pending()


var default_values = [1]
func test_default_values_are_returned_by_default(vals = use_parameters(default_values)):
	pending(str(vals))


func test_can_call_method_that_has_an_inferred_int_return():
	var dbl = double(DoubleMe).new()
	assert_eq(dbl.inferred_int_return(), null)


func test_can_call_method_that_has_an_int_return():
	var dbl = double(DoubleMe).new()
	assert_eq(dbl.explicit_int_return(), 0)


func test_can_call_method_that_has_a_string_return():
	var dbl = double(DoubleMe).new()
	assert_eq(dbl.return_string_plus_a('a'), '')

func test_call_method_that_has_an_int_return_for_an_inner_class_in_this_script():
	var dbl = double(SomeDoubleStuff).new()
	assert_eq(dbl.int_return(), 0)


func test_call_method_that_has_an_int_return_for_an_external_inner_class():
	var dbl = double(InnerClasses.InnerA).new()
	assert_eq(dbl.int_return(), 0)


var spot_check_params = ParameterFactory.named_parameters(
	['method', 'value', 'valid'],
	[
		['explicit_int_return', 1, true],
		['explicit_int_return', 'adsf', false],
		['explicit_int_return', null, false],

		['inferred_int_return', 8, true],
		['inferred_int_return', 'asdf', true],
		['inferred_int_return', null, true],

		['inferred_variant_return', 8, true],
		['inferred_variant_return', 'asdf', true],
		['inferred_variant_return', null, true],

		['return_string_plus_a', 8, false],
		['return_string_plus_a', 'asdf', true],
		['return_string_plus_a', null, false],

		['explict_variant_return', 8, true],
		['explict_variant_return', GutTest, true],
		['explict_variant_return', null, true],
	]
)
func test_using_double_me_stubs(p = use_parameters(spot_check_params)):
	var dbl = double(DoubleMe).new()
	var c = Callable(dbl, p.method)
	stub(c).to_return(p.value)

	dbl.call(p.method)
	if(p.valid):
		assert_engine_error_count(0)
	else:
		assert_tracked_gut_error(self, 1)
		assert_engine_error("Trying to return a value")



class TestReturnTypes:
	extends GutInternalTester

	var _gut = null
	var _test = null


	func before_each():
		_gut = new_gut(verbose)

		_test = new_wired_test(_gut)

		add_child(_gut)
		add_child(_test)

	func after_each():
		_gut.free()
		_test.free()


	func test_can_call_all_methods_in_all_return_types():
		# Signals return values cause doubled methods to hang because they
		# all have await in them.  The methods end up awaiting the returned
		# signal and nothing ever ends.
		ignore_method_when_doubling(TestResourceAllReturnTypes, 'return_signal')

		var Dbl = double(TestResourceAllReturnTypes)
		var dbl = Dbl.new()

		# Don't use get_*method_list or it will include the __gutdbl_done and
		# mess things up when it gets called.
		for method_name in dbl.__gutdbl_values.doubled_methods:
			var result = dbl.call(method_name)
			assert_eq(result, GutConstants.get_default_return_value(typeof(result)),
				str(method_name, ' default return value'))

		assert_engine_error_count(0)


	func test_using_to_do_nothing_not_allowed_with_methods_that_have_return_type():
		var inst = _test.partial_double(Node2D).new()
		_test.stub(Node2D, 'get_position').to_do_nothing()
		autofree(inst)
		# Should get an error when stubbing get_position to_do_nothing.  Error
		# message should indicate that you must use to_return with a Vector2
		# value
		assert_tracked_gut_error(_gut, 1)
