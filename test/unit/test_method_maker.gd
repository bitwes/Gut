extends "res://addons/gut/test.gd"


class BaseTest:
	extends "res://addons/gut/test.gd"

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

class TestGetDecleration:
	extends BaseTest

	var _mm = null

	func before_each():
		_mm = MethodMaker.new()

	func test_get_function_text_no_params():
		assert_string_contains(_mm.get_function_text(make_meta('dummy')), 'func dummy():')

	func test_if_unknown_param_type_specified_it_does_not_blow_up():
		var params = [make_param('value1', 999)]
		var meta = make_meta('dummy', params)
		meta.default_args.append(1)
		var _txt = _mm.get_function_text(meta)
		assert_true(true, 'we got here')

	func test_if_unknonw_param_type_function_text_is_null():
		var params = [make_param('value1', 999)]
		var meta = make_meta('dummy', params)
		meta.default_args.append(1)
		var txt = _mm.get_function_text(meta)
		assert_eq(txt, null)

	func test_parameters_get_prefix_and_default_to_call_stubber():
		var params = [make_param('value1', TYPE_INT), make_param('value2', TYPE_INT)]
		var meta = make_meta('dummy', params)
		var txt = _mm.get_function_text(meta)
		assert_string_contains(txt, 'func dummy(p_value1=__gut_default_val("dummy",0), p_value2=__gut_default_val("dummy",1)):')

	func test_default_only_param():
		var params = [make_param('value1', TYPE_INT)]
		var meta = make_meta('dummy', params)
		meta.default_args.append(1)
		var txt = _mm.get_function_text(meta)
		assert_string_contains(txt, 'func dummy(p_value1=1):')

	func test_default_2nd_param():
		var params = [make_param('value1', TYPE_INT), make_param('value2', TYPE_INT)]
		var meta = make_meta('dummy', params)
		meta.default_args.append(1)
		var txt = _mm.get_function_text(meta)
		assert_string_contains(txt, 'func dummy(p_value1=__gut_default_val("dummy",0), p_value2=1):')

	func test_vector2_default():
		var params = [make_param('value1', TYPE_VECTOR2)]
		var meta = make_meta('dummy', params)
		meta.default_args.append('(0,0)')
		var txt = _mm.get_function_text(meta)
		assert_string_contains(txt, 'func dummy(p_value1=Vector2(0,0)):')

	func test_rect2_default():
		var params = [make_param('value1', TYPE_RECT2)]
		var meta = make_meta('dummy', params)
		meta.default_args.append('(0,0,0,0)')
		var txt = _mm.get_function_text(meta)
		assert_string_contains(txt, 'func dummy(p_value1=Rect2(0,0,0,0)):')

	func test_string_default():
		var params = [make_param('value1', TYPE_STRING)]
		var meta = make_meta('dummy', params)
		meta.default_args.append('aSDf')
		var txt = _mm.get_function_text(meta)
		assert_string_contains(txt, 'func dummy(p_value1=\'aSDf\'):')

	func test_vector3_default():
		var params = [make_param('value1', TYPE_VECTOR3)]
		var meta = make_meta('dummy', params)
		meta.default_args.append('(0,0,0)')
		var txt = _mm.get_function_text(meta)
		assert_string_contains(txt, 'func dummy(p_value1=Vector3(0,0,0)):')

	func test_color_default():
		var params = [make_param('value1', TYPE_COLOR)]
		var meta = make_meta('dummy', params)
		meta.default_args.append('1,1,1,1')
		var txt = _mm.get_function_text(meta)
		assert_string_contains(txt, 'func dummy(p_value1=Color(1,1,1,1)):')

class TestSuperCall:
	extends BaseTest

	var _mm = null

	func before_each():
		_mm = MethodMaker.new()

	func test_super_call_works_with_no_parameters():
		var meta = make_meta('dummy')
		var text = _mm.get_super_call_text(meta)
		assert_eq(text, '.dummy()')

	func test_super_call_contains_all_parameters():
		var params = [
			make_param('value1', TYPE_COLOR),
			make_param('value2', TYPE_INT),
			make_param('value3', TYPE_STRING)
		]
		var meta = make_meta('dummy', params)
		var text = _mm.get_super_call_text(meta)
		assert_eq(text, '.dummy(p_value1, p_value2, p_value3)')


class TestOverrideParameterList:
	extends BaseTest

	var _mm = null

	func before_each():
		_mm = MethodMaker.new()


	func test_has_override_is_false_by_default():
		assert_false(_mm.has_override('res://nothing.gd', 'foo'))

	func test_can_add_override():
		_mm.add_parameter_override('res://nothing.gd', 'foo', 10)
		assert_true(_mm.has_override('res://nothing.gd', 'foo'))

	func test_get_function_text_includes_override_paramters():
		var path = 'res://nothing.gd'
		_mm.add_parameter_override(path, 'foo', 1)
		var meta = make_meta('foo', [])
		var text = _mm.get_function_text(meta, path)
		assert_string_contains(text, 'p_gut_param_override_1__')

	func test_get_function_text_includes_multiple_override_paramters():
		var path = 'res://nothing.gd'
		_mm.add_parameter_override(path, 'foo', 5)
		var meta = make_meta('foo', [])
		var text = _mm.get_function_text(meta, path)
		assert_string_contains(text, 'p_gut_param_override_1__')
		assert_string_contains(text, 'p_gut_param_override_5__')

	func test_can_clear_parameter_overrides():
		var path = 'res://nothing.gd'
		_mm.add_parameter_override(path, 'foo', 10)
		_mm.clear_overrides()
		var meta = make_meta('foo', [make_param('value1', TYPE_INT),])
		var text = _mm.get_function_text(meta, path)
		assert_eq(text.find('p_gut_param_'), -1, text)

	func test_super_call_uses_overrides():
		var path = 'res://nothing.gd'
		var meta = make_meta('foo', [make_param('value1', TYPE_INT),])
		var text = _mm.get_function_text(meta, path, 2)
		assert_string_contains(text, '.foo(p_value1, p_arg1)')

	func test_spy_paramters_include_overrides():
		var path = 'res://nothing.gd'
		var meta = make_meta('foo', [make_param('value1', TYPE_INT),])
		var text = _mm.get_function_text(meta, path, 2)
		assert_string_contains(text, "__gut_spy('foo', [p_value1, p_arg1]")

	func test_all_parameters_are_defaulted_to_null():
		var path = 'res://nothing.gd'
		var meta = make_meta('foo', [])
		var text = _mm.get_function_text(meta, path, 5)
		assert_string_contains(text, 'p_arg0=__gut_default_val("foo",0)')
		assert_string_contains(text, 'p_arg4=__gut_default_val("foo",4)')