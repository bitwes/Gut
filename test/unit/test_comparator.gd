extends 'res://addons/gut/test.gd'


class TestTheBasics:
	extends 'res://addons/gut/test.gd'

	func test_can_make_one():
		var c = _utils.Comparator.new()
		assert_not_null(c)

	func test_get_set_should_compare_int_float():
		var c = _utils.Comparator.new()
		assert_accessors(c, 'should_compare_int_to_float', true, false)


class TestMissing:
	extends 'res://addons/gut/test.gd'

	func test_when_first_value_is_missing_it_uses_missing_string_in_summary():
		var c = _utils.Comparator.new()
		var other = 'asdf'
		var result = c.simple(c.MISSING, other, 'not here')
		assert_string_contains(result.summary, 'not here')
		assert_string_contains(result.summary, '!=')
		assert_string_contains(result.summary, other)
		assert_not_null(result.are_equal)
		assert_false(result.are_equal)

	func test_when_second_value_is_missing_it_uses_missing_string_in_summary():
		var c = _utils.Comparator.new()
		var other  = 'asdf'
		var result = c.simple(other, c.MISSING, 'not here')
		assert_string_contains(result.summary, 'not here')
		assert_string_contains(result.summary, '!=')
		assert_string_contains(result.summary, other)
		assert_not_null(result.are_equal)
		assert_false(result.are_equal)

	func test_missing_code_works_with_non_strings():
		var c = _utils.Comparator.new()
		var result = c.simple(1, 1)
		assert_true(result.are_equal)



class TestSimpleCompare:
	extends 'res://addons/gut/test.gd'

	var _comparator  = null

	func before_each():
		_comparator = _utils.Comparator.new()

	var primitive_equal_values = [[1, 1], [3, 3.0], ['a', 'a'], [true, true], [null, null]]
	func test_compare_equal_primitives(p=use_parameters(primitive_equal_values)):
		var result = _comparator.simple(p[0], p[1])
		assert_true(result.are_equal,  result.summary)

	func test_all_primitives_have_a_summary(p=use_parameters(primitive_equal_values)):
		var result = _comparator.simple(p[0], p[1])
		assert_string_contains(result.summary, '==', 'equals')
		assert_string_contains(result.summary, str(p[0]), 'zero value')

	var primitive_not_equal_values = [[1, 2], ['a', 'b'], [true, false], [null, 1]]
	func test_compare_not_equal_primitives(p=use_parameters(primitive_not_equal_values)):
		var result = _comparator.simple(p[0], p[1])
		assert_false(result.are_equal,  result.summary)

	func test_all_not_equal_primitives_have_a_summary(p=use_parameters(primitive_not_equal_values)):
		var result = _comparator.simple(p[0], p[1])
		assert_string_contains(result.summary, '!=', 'equals')
		assert_string_contains(result.summary, str(p[0]), 'zero value')
		assert_string_contains(result.summary, str(p[1]), 'one value')

	var incompatible_types = [[1, 'a'], ['text', Node], [false, []], [{}, []]]
	func test_incompatible_types(p=use_parameters(incompatible_types)):
		var result = _comparator.simple(p[0], p[1])
		assert_not_null(result.are_equal,  result.summary)
		assert_false(result.are_equal,  result.summary)

	func test_incompatible_types_summary(p=use_parameters(incompatible_types)):
		var result = _comparator.simple(p[0], p[1])
		assert_string_contains(result.summary, 'Cannot')
		assert_string_contains(result.summary, '!=')

	func test_comparing_equal_dictionaries_includes_disclaimer():
		var d1 = {}
		var d2 = d1
		var result = _comparator.simple(d1, d2)
		assert_true(result.are_equal, result.summary)
		assert_string_contains(result.summary, _comparator.DICTIONARY_DISCLAIMER)

	func test_comparing_different_dictionaries_includes_disclaimer():
		var result = _comparator.simple({}, {})
		assert_false(result.are_equal, result.summary)
		assert_string_contains(result.summary, _comparator.DICTIONARY_DISCLAIMER)

	func test_comparing_arrays_returns_array_diff_simple_summary():
		var result = _comparator.simple([1, 2], [3, 4])
		assert_string_contains(result.summary, '[1, 2] != [3, 4]')


class TestShouldCompareIntToFloat:
	extends 'res://addons/gut/test.gd'

	var _comparator  = null

	func before_each():
		_comparator = _utils.Comparator.new()

	func test_when_enabled_float_and_int_are_equal():
		_comparator.set_should_compare_int_to_float(true)
		var result = _comparator.simple(1, 1.0)
		assert_true(result.are_equal, result.summary)

	func  test_when_disabled_float_and_int_are_not_equal():
		_comparator.set_should_compare_int_to_float(false)
		var result = _comparator.simple(1, 1.0)
		assert_false(result.are_equal, result.summary)

	func test_when_enabled_does_not_change_how_arrays_treat_float_int():
		_comparator.set_should_compare_int_to_float(true)
		var result = _comparator.simple([1], [1.0])
		assert_false(result.are_equal, result.summary)

	func test_when_enabled_does_not_change_how_dicts_treat_float_int():
		_comparator.set_should_compare_int_to_float(true)
		var result = _comparator.shallow({'a':1}, {'a':1.0})
		assert_false(result.are_equal, result.summary)


class TestShallowCompare:
	extends 'res://addons/gut/test.gd'

	var _comparator  = null

	func before_each():
		_comparator = _utils.Comparator.new()

	func test_comparing_arrays_are_equal_true_when_equal():
		var result = _comparator.shallow([1], [1])
		assert_true(result.are_equal)

	func test_comparing_arrays_sets_summary():
		var result = _comparator.shallow([2], [3])
		assert_not_null(result.summary)

	func test_comparing_dictionaries_populates_different_keys():
		var result = _comparator.shallow({'a':1}, {'b':2})
		assert_true(result.differences.size() == 2)

	func test_comparing_dictionaries_populates_are_equal():
		var result = _comparator.shallow({}, {})
		assert_true(result.are_equal)

	func test_comparing_dictionaries_populates_summary():
		var result = _comparator.shallow({}, {'a':1})
		assert_not_null(result.summary)

	func test_comparing_dictionaries_does_not_include_sub_dictionaries():
		var result = _comparator.shallow({'a':{}}, {'a':{}})
		assert_false(result.are_equal)

	func test_comparing_arrays_does_not_include_sub_dictionaries():
		var result = _comparator.shallow([{'a':1}], [{'a':1}])
		assert_false(result.are_equal)

	func test_works_with_different_datatypes():
		var result = _comparator.shallow({}, [])
		assert_false(result.are_equal)

	func test_works_with_primitives():
		var result =  _comparator.shallow(1, 1)
		assert_true(result.are_equal)


class TestDeepCompare:
	extends 'res://addons/gut/test.gd'

	var _comparator  = null

	func before_each():
		_comparator = _utils.Comparator.new()

	func test_comparing_arrays_are_equal_true_when_equal():
		var result = _comparator.deep([1], [1])
		assert_true(result.are_equal)

	func test_comparing_arrays_sets_summary():
		var result = _comparator.deep([2], [3])
		assert_not_null(result.summary)

	func test_comparing_dictionaries_populates_different_keys():
		var result = _comparator.deep({'a':1}, {'b':2})
		assert_true(result.differences.size() == 2)

	func test_comparing_dictionaries_populates_are_equal():
		var result = _comparator.deep({}, {})
		assert_true(result.are_equal)

	func test_comparing_dictionaries_populates_summary():
		var result = _comparator.deep({}, {'a':1})
		assert_not_null(result.summary)

	func test_comparing_dictionaries_does_not_include_sub_dictionaries():
		var result = _comparator.deep({'a':{}}, {'a':{}})
		assert_true(result.are_equal)

	func test_comparing_arrays_does_not_include_sub_dictionaries():
		var result = _comparator.deep([{'a':1}], [{'a':1}])
		assert_true(result.are_equal)

	func test_works_with_different_datatypes():
		var result = _comparator.deep({}, [])
		assert_false(result.are_equal)

	func test_works_with_primitives():
		var result =  _comparator.deep(1, 1)
		assert_true(result.are_equal)