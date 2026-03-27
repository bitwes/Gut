extends GutTest


class BaseTest:
	extends GutInternalTester

	var MethodMaker = load('res://addons/gut/method_maker.gd')

	func make_meta(fname, params = [], flags = 65):
		var to_return = {
			"name" : fname,
			"args" : params,
			"default_args": [],
			"flags": flags,
			"return" :{
				"type":0,
				"usage":0
			}
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


	func test_parameters_get_prefix_and_default_to_call_stubber():
		var params = [make_param('value1', TYPE_INT), make_param('value2', TYPE_INT)]
		var meta = make_meta('dummy', params)
		var txt = _mm.get_function_text(meta)
		assert_string_contains(txt, 'func dummy(p_value1=__gutdbl.default_val("dummy",0), p_value2=__gutdbl.default_val("dummy",1)):')



class TestSuperCall:
	extends BaseTest

	var _mm = null

	func before_each():
		_mm = MethodMaker.new()

	func test_super_call_works_with_no_parameters():
		var meta = make_meta('dummy')
		meta.return.type = TYPE_BOOL
		var text = _mm.get_function_text(meta)
		assert_string_contains(text, 'return await super()')

	func test_super_call_contains_all_parameters():
		var params = [
			make_param('value1', TYPE_COLOR),
			make_param('value2', TYPE_INT),
			make_param('value3', TYPE_STRING)
		]
		var meta = make_meta('dummy', params)
		meta.return.type = TYPE_COLOR
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


class TestReturnTypes:
	extends BaseTest

	func test_void_return_type_does_not_include_return_super():
		var mm = MethodMaker.new()

		var meta = make_meta('fake_method')
		meta.return.type = 0
		meta.usage = 6

		var func_def = mm.get_function_text(meta)
		print(func_def)

		assert_eq(func_def.find("return await super"), -1)


	func test_void_return_type_does_not_include_return_stub_call():
		var mm = MethodMaker.new()

		var meta = make_meta('fake_method')
		meta.return.type = 0
		meta.usage = 6

		var func_def = mm.get_function_text(meta)
		print(func_def)

		assert_eq(func_def.find("return await __gut"), -1)

	func test_something():
		var mm = MethodMaker.new()
		var s = autofree(DoubleMeScene.instantiate())
		var meta = find_method_meta(s.get_method_list(), 'get_instance_shader_parameter')
		var func_def = mm.get_function_text(meta)
		assert_string_contains(func_def, "return await __gut")


	func test_class_name_from_metadata_used_as_return_type():
		pending()

