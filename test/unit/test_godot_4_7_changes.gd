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


func test_what_you_got():
	var methods = [
		'inferred_void_return', 'inferred_variant_return', 'void_return'
	]

	for m in methods:
		var sp = GutUtils.StubParams.new(DoubleMe, m)
		print('--- ', m, ' ---')
		print('return type ', sp.return_type)
		print('return_val ', sp.return_val)
		print(sp._method_meta.return.usage && PROPERTY_USAGE_NIL_IS_VARIANT)
		GutUtils.pretty_print(sp._method_meta)


func test_error_when_stubbing_a_method_on_a_script_to_return_a_different_invalid_data_type():
	var sp = GutUtils.StubParams.new(DoubleMe, 'explicit_int_return')
	sp.to_return('asdf')

	var result = sp.validate()
	assert_false(result)
	assert_tracked_gut_error(self, 1)


# This isn't that helpful since it only matters when stubbing at the class level
func test_cannot_double_something_when_it_has_invalid_stubs():
	pending("The runtime errors are confusing, so this would cut down on that.")


func test_stubbing_to_do_nothing_prevents_non_stubbed_warning_when_method_is_called():
	pending()


func test_what_should_happen_when_you_stub_to_do_nothing_on_something_that_has_an_explicit_return():
	var dbl = partial_double(DoubleMe).new()
	stub(dbl.explicit_int_return).to_do_nothing()
	var result = dbl.explicit_int_return()
	assert_eq(result, GutConstants.get_default_return_value(TYPE_INT))


var default_values = [
	['explicit_int_return']
]
func test_default_values_are_returned_by_default(p = use_parameters(default_values)):
	var dbl = double(DoubleMe).new()
	var result = dbl.call(p[0])
	assert_eq(result, GutConstants.DEFAULT_RETURNS[typeof(result)])


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
	['method', 'value', 'valid', 'special'],
	[
		['explicit_int_return', 1, true],
		['explicit_int_return', 'adsf', false],
		['explicit_int_return', null, false],

		['inferred_int_return', 8, true],
		['inferred_int_return', 'asdf', true],
		['inferred_int_return', null, true],

		['return_string_plus_a', 8, false],
		['return_string_plus_a', 'asdf', true],
		['return_string_plus_a', null, false],

		['inferred_variant_return', 8, true],
		['inferred_variant_return', 'asdf', true],
		['inferred_variant_return', null, true],

		['explict_variant_return', 8, true],
		['explict_variant_return', GutTest, true],
		['explict_variant_return', null, true],

		# It looks like you can return values from explicit void methods but
		# null will always be returned and an error is not generated.  Probably
		# some compromise that had to be made for non-typed code.  The parser
		# can catch it, but it appears it cannot in the case of a generated
		# double.
		['void_return', 8, true, 		'special'],
		['void_return', null, true],

		['inferred_void_return', 8, true],
		['inferred_void_return', null, true],
	]
)
func test_using_double_me_stubs(p = use_parameters(spot_check_params)):
	var dbl = double(DoubleMe).new()
	var c = Callable(dbl, p.method)
	stub(c).to_return(p.value)
	var result = dbl.call(p.method)

	if(p.special != null):
		# In the case of explicit void return, no parser or script error is
		# generated, but null is returned instead of any value.  We also expect
		# StubParams to have generated an error.
		if(p.method == 'void_return'):
			assert_tracked_gut_error(self, 1)
			assert_null(result)
	else:
		if(p.valid):
			assert_engine_error_count(0)
			assert_eq(result, p.value, 'Expected value was returned')
		else:
			assert_tracked_gut_error(self, 1)
			assert_engine_error("Trying to return a value")


func test_stubbing_to_call_with_valid_return_is_fine():
	var dbl = double(DoubleMe).new()
	stub(dbl.explicit_int_return).to_call(func(): return -10)

	assert_eq(dbl.explicit_int_return(), -10)


func test_stubbing_to_call_with_invalid_return_causes_engine_error():
	var dbl = double(DoubleMe).new()
	stub(dbl.explicit_int_return).to_call(func(): return 'asdf')

	assert_ne(dbl.explicit_int_return(), -10)
	assert_engine_error("Trying to return a value ")


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
