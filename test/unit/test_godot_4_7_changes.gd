extends GutInternalTester

# SEE test_method_maker.gd.TestReturnTypes

# SEE test_abstract_class_doubling

func test_error_when_stub_to_return_on_methods_with_inferred_void_return_type():
	pending()


func test_error_when_stubbing_a_method_to_return_a_different_invalid_data_type():
	pending()


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


	func test_using_to_do_nothing_not_allowed_with_methods_that_have_return_type():
		var inst = _test.partial_double(Node2D).new()
		_test.stub(Node2D, 'get_position').to_do_nothing()
		autofree(inst)
		# Should get an error when stubbing get_position to_do_nothing.  Error
		# message should indicate that you must use to_return with a Vector2
		# value
		assert_tracked_gut_error(_gut, 1)

