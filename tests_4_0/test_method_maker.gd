extends GutTest


class BaseTest:
	extends GutTest

	var MethodMaker = load('res://addons/gut/method_maker.gd')

	func make_meta(fname, params = [], _flags = 65):
		var to_return = {
			name = fname,
			args = params,
			default_args = []
		}
		return to_return

	func make_param(pname, ptype):
		var to_return = {
			name = pname,
			type = ptype
		}
		return to_return

	func find_method_meta(methods, method_name):
		var meta = null
		var idx = 0
		while (idx < methods.size() and meta == null):
			var m = methods[idx]
			if(m.name == method_name):
				meta = m
			idx += 1

		return meta


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


	# func test_vector2_default():
	# 	var params = [make_param('value1', TYPE_VECTOR2)]
	# 	var meta = make_meta('dummy', params)
	# 	meta.default_args.append('(0,0)')
	# 	var txt = _mm.get_function_text(meta)
	# 	assert_string_contains(txt, 'func dummy(p_value1=Vector2(0,0)):')

	# func test_rect2_default():
	# 	var params = [make_param('value1', TYPE_RECT2)]
	# 	var meta = make_meta('dummy', params)
	# 	meta.default_args.append('(0,0,0,0)')
	# 	var txt = _mm.get_function_text(meta)
	# 	assert_string_contains(txt, 'func dummy(p_value1=Rect2(0,0,0,0)):')

	# func test_string_default():
	# 	var params = [make_param('value1', TYPE_STRING)]
	# 	var meta = make_meta('dummy', params)
	# 	meta.default_args.append('aSDf')
	# 	var txt = _mm.get_function_text(meta)
	# 	assert_string_contains(txt, 'func dummy(p_value1=\'aSDf\'):')

	# func test_TYPE_STRING_NAME_default():
	# 	var params = [make_param('value1', TYPE_STRING_NAME)]
	# 	var meta = make_meta('dummy', params)
	# 	meta.default_args.append('aSDf')
	# 	var txt = _mm.get_function_text(meta)
	# 	assert_string_contains(txt, 'func dummy(p_value1=\'aSDf\'):')


	# func test_vector3_default():
	# 	var params = [make_param('value1', TYPE_VECTOR3)]
	# 	var meta = make_meta('dummy', params)
	# 	meta.default_args.append('(0,0,0)')
	# 	var txt = _mm.get_function_text(meta)
	# 	assert_string_contains(txt, 'func dummy(p_value1=Vector3(0,0,0)):')

	# func test_color_default():
	# 	var params = [make_param('value1', TYPE_COLOR)]
	# 	var meta = make_meta('dummy', params)
	# 	meta.default_args.append('(1,1,1,1)')
	# 	var txt = _mm.get_function_text(meta)
	# 	assert_string_contains(txt, 'func dummy(p_value1=Color(1,1,1,1)):')

	# func test_when_default_type_is_TYPE_NIL_null_is_used():
	# 	var params = [make_param('value1', TYPE_NIL)]
	# 	var meta = make_meta('dummy', params)
	# 	meta.default_args.append('asdf')
	# 	var txt = _mm.get_function_text(meta)
	# 	assert_string_contains(txt, 'func dummy(p_value1=null):')

	# func test_draw_primitive():
	# 	var inst = autofree(Button.new())
	# 	var meta = find_method_meta(inst.get_method_list(), 'draw_primitive')
	# 	var txt = _mm.get_function_text(meta)
	# 	assert_string_contains(txt, 'p_texture=null')
	# 	if(is_failing()):
	# 		_utils.pretty_print(meta)

	# func test_popup_TYPE_RECT2I():
	# 	var inst = autofree(Window.new())
	# 	var meta = find_method_meta(inst.get_method_list(), 'popup')
	# 	var txt = _mm.get_function_text(meta)
	# 	print('!! the type is: ', typeof(meta.default_args[0]))
	# 	assert_string_contains(txt, 'Rect2i[p: (0, 0), s: (0, 0)]')



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




class TestOverrideParameterList:
	extends BaseTest

	var _mm = null

	func before_each():
		_mm = MethodMaker.new()


	func test_get_function_text_includes_override_paramters():
		var path = 'res://nothing.gd'

		var meta = make_meta('foo', [])
		var text = _mm.get_function_text(meta, path, 1)
		assert_string_contains(text, 'p_arg0=')

	func test_get_function_text_includes_multiple_override_paramters():
		var path = 'res://nothing.gd'
		var meta = make_meta('foo', [])
		var text = _mm.get_function_text(meta, path, 5)
		assert_string_contains(text, 'p_arg0=')
		assert_string_contains(text, 'p_arg4=')

	func test_super_call_uses_overrides():
		var path = 'res://nothing.gd'
		var meta = make_meta('foo', [make_param('value1', TYPE_INT),])
		var text = _mm.get_function_text(meta, path, 2)
		assert_string_contains(text, 'super(p_value1, p_arg1)')

	func test_spy_paramters_include_overrides():
		var path = 'res://nothing.gd'
		var meta = make_meta('foo', [make_param('value1', TYPE_INT),])
		var text = _mm.get_function_text(meta, path, 2)
		assert_string_contains(text, "_gutdbl.spy_on('foo', [p_value1, p_arg1]")

	func test_all_parameters_are_defaulted_to_null():
		var path = 'res://nothing.gd'
		var meta = make_meta('foo', [])
		var text = _mm.get_function_text(meta, path, 5)
		assert_string_contains(text, 'p_arg0=__gutdbl.default_val("foo",0)')
		assert_string_contains(text, 'p_arg4=__gutdbl.default_val("foo",4)')
