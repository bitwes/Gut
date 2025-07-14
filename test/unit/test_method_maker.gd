extends GutTest


class BaseTest:
	extends GutInternalTester

	var MethodMaker = load('res://addons/gut/method_maker.gd')

	func make_meta(fname, params = [], flags = 65):
		var to_return = {
			name = fname,
			args = params,
			default_args = [],
			flags = flags
		}
		return to_return

	func make_param(pname, ptype):
		var to_return = {
			name = pname,
			type = ptype
		}
		return to_return



class TestGetDecleration:
	extends BaseTest

	var _mm = null

	func before_each():
		_mm = MethodMaker.new()


	func test_get_function_text_no_params():
		assert_string_contains(_mm.get_function_text(make_meta('dummy')), 'func dummy():')

	# func test_default_vararg_arg_count_default_value():
	# 	assert_eq(_mm.default_vararg_arg_count, -1, 'count size no longer used')

	func test_parameters_get_prefix_and_default_to_call_stubber():
		var params = [make_param('value1', TYPE_INT), make_param('value2', TYPE_INT)]
		var meta = make_meta('dummy', params)
		var txt = _mm.get_function_text(meta)
		assert_string_contains(txt, 'func dummy(p_value1=__gutdbl.default_val("dummy",0), p_value2=__gutdbl.default_val("dummy",1)):')

	# func test_vararg_methods_get_extra_parameters():
	# 	_mm.default_vararg_arg_count = 100
	# 	var meta = make_meta('foo', [make_param('value1', TYPE_INT)], METHOD_FLAG_VARARG)
	# 	var txt = _mm.get_function_text(meta)
	# 	assert_string_contains(txt, 'p_arg99')

	func test_vararg_methods_without_overrides_get_vararg_warning():
		var warning_call = "__gutdbl.vararg_warning()"
		var meta = make_meta('foo', [make_param('value1', TYPE_INT)], METHOD_FLAG_VARARG)
		var txt = _mm.get_function_text(meta)
		assert_string_contains(txt, warning_call)

	func test_vararg_methods_with_overrides_do_not_get_warning():
		var warning_call = "__gutdbl.vararg_warning()"
		var meta = make_meta('foo', [make_param('value1', TYPE_INT)], METHOD_FLAG_VARARG)
		var txt = _mm.get_function_text(meta, 5)
		assert_eq(txt.find(warning_call), -1)


class TestSuperCall:
	extends BaseTest

	var _mm = null

	func before_each():
		_mm = MethodMaker.new()

	func test_super_call_works_with_no_parameters():
		var meta = make_meta('dummy')
		var text = _mm.get_function_text(meta)
		assert_string_contains(text, 'return await super()')

	func test_super_call_contains_all_parameters():
		var params = [
			make_param('value1', TYPE_COLOR),
			make_param('value2', TYPE_INT),
			make_param('value3', TYPE_STRING)
		]
		var meta = make_meta('dummy', params)
		var text = _mm.get_function_text(meta)
		assert_string_contains(text, 'return await super(p_value1, p_value2, p_value3)')




class TestVarargMethods:
	extends BaseTest

	func test_rpc():
		var mm = MethodMaker.new()

		var n = autofree(Node.new())
		var meta = find_method_meta(n.get_method_list(), 'rpc')
		var func_def = mm.get_function_text(meta)

		assert_string_contains(func_def, ", ...args: Array")
		assert_string_contains(func_def, "__gutdbl.spy_on('rpc', [p_method, args])")

	func test_rpc_id():
		var mm = MethodMaker.new()

		var n = autofree(Node.new())
		var meta = find_method_meta(n.get_method_list(), 'rpc_id')
		var func_def = mm.get_function_text(meta)

		assert_string_contains(func_def, ", ...args: Array")
		assert_string_contains(func_def, "__gutdbl.spy_on('rpc_id', [p_peer_id, p_method, args])")


class TestOverrideParameterList:
	extends BaseTest

	var _mm = null

	func should_skip_script():
		return "Overriding the parameter list is no longer necessary...I think."

	func before_each():
		_mm = MethodMaker.new()


	func test_get_function_text_includes_override_paramters():
		var meta = make_meta('foo', [])
		var text = _mm.get_function_text(meta, 1)
		assert_string_contains(text, 'p_arg0=')

	func test_get_function_text_includes_multiple_override_paramters():
		var meta = make_meta('foo', [])
		var text = _mm.get_function_text(meta, 5)
		assert_string_contains(text, 'p_arg0=')
		assert_string_contains(text, 'p_arg4=')

	func test_super_call_uses_overrides():
		var meta = make_meta('foo', [make_param('value1', TYPE_INT),])
		var text = _mm.get_function_text(meta, 2)
		assert_string_contains(text, 'super(p_value1, p_arg1)')

	func test_spy_paramters_include_overrides():
		var meta = make_meta('foo', [make_param('value1', TYPE_INT),])
		var text = _mm.get_function_text(meta, 2)
		assert_string_contains(text, "_gutdbl.spy_on('foo', [p_value1, p_arg1]")

	func test_all_parameters_are_defaulted_to_null():
		var meta = make_meta('foo', [])
		var text = _mm.get_function_text(meta, 5)
		assert_string_contains(text, 'p_arg0=__gutdbl.default_val("foo",0)')
		assert_string_contains(text, 'p_arg4=__gutdbl.default_val("foo",4)')

	func test_overriding_parameter_count_overrides_default_vararg_arg_count():
		_mm.default_vararg_arg_count = 100
		var meta = make_meta('foo', [make_param('value1', TYPE_INT)], METHOD_FLAG_VARARG)
		var text = _mm.get_function_text(meta, 10)
		assert_string_contains(text, 'p_arg9=')
		assert_eq(text.find('p_arg10'), -1)

