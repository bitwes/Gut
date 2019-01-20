extends "res://addons/gut/test.gd"

class TestBasics:
	extends "res://addons/gut/test.gd"

	var MethodMaker = load('res://addons/gut/method_maker.gd')
	var _mm = null

	func make_meta(fname, params = [], flags = 65):
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

	func before_each():
		_mm = MethodMaker.new()

	func test_get_decleration_no_params():
		assert_eq(_mm.get_decleration(make_meta('dummy')), 'func dummy():')

	func test_if_unknown_param_type_specified_it_does_not_blow_up():
		var params = [make_param('value1', 999)]
		var meta = make_meta('dummy', params)
		meta.default_args.append(1)
		var txt = _mm.get_decleration(meta)
		assert_ne(txt, null)


	func test_parameters_get_prefix_and_default_null():
		var params = []
		params.append(make_param('value1', TYPE_INT))
		params.append(make_param('value2', TYPE_INT))
		var meta = make_meta('dummy', params)
		var txt = _mm.get_decleration(meta)
		assert_eq(txt, 'func dummy(p_value1=null, p_value2=null):')

	func test_default_only_param():
		var params = [make_param('value1', TYPE_INT)]
		var meta = make_meta('dummy', params)
		meta.default_args.append(1)
		var txt = _mm.get_decleration(meta)
		assert_eq(txt, 'func dummy(p_value1=1):')

	func test_default_2nd_param():
		var params = [make_param('value1', TYPE_INT), make_param('value2', TYPE_INT)]
		var meta = make_meta('dummy', params)
		meta.default_args.append(1)
		var txt = _mm.get_decleration(meta)
		assert_eq(txt, 'func dummy(p_value1=null, p_value2=1):')

	func test_vector2_default():
		var params = [make_param('value1', TYPE_VECTOR2)]
		var meta = make_meta('dummy', params)
		meta.default_args.append('(0,0)')
		var txt = _mm.get_decleration(meta)
		assert_eq(txt, 'func dummy(p_value1=Vector2(0,0)):')

	func test_rect2_default():
		var params = [make_param('value1', TYPE_RECT2)]
		var meta = make_meta('dummy', params)
		meta.default_args.append('(0,0,0,0)')
		var txt = _mm.get_decleration(meta)
		assert_eq(txt, 'func dummy(p_value1=Rect2(0,0,0,0)):')

	func test_string_default():
		var params = [make_param('value1', TYPE_STRING)]
		var meta = make_meta('dummy', params)
		meta.default_args.append('aSDf')
		var txt = _mm.get_decleration(meta)
		assert_eq(txt, 'func dummy(p_value1=\'aSDf\'):')
