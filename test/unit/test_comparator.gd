extends 'res://addons/gut/test.gd'


class TestTheBasics:
	extends 'res://addons/gut/test.gd'

	func test_can_make_one():
		var c = _utils.Comparator.new()
		assert_not_null(c)


class TestSimpleCompare:
	extends 'res://addons/gut/test.gd'

	var _compare  = _utils.Comparator.new()

	var primitive_equal_values = [[1, 1], ['a', 'a'], [true, true], [null, null]]
	func test_compare_equal_primitives(p=use_parameters(primitive_equal_values)):
		var result = _compare.simple(p[0], p[1])
		assert_true(result.are_equal,  result.summary)

	func test_all_primitives_have_a_summary(p=use_parameters(primitive_equal_values)):
		var result = _compare.simple(p[0], p[1])
		assert_string_contains(result.summary, '==', 'equals')
		assert_string_contains(result.summary, str(p[0]), 'zero value')

	var primitive_not_equal_values = [[1, 2], ['a', 'b'], [true, false], [null, 1]]
	func test_compare_not_equal_primitives(p=use_parameters(primitive_not_equal_values)):
		var result = _compare.simple(p[0], p[1])
		assert_false(result.are_equal,  result.summary)

	func test_all_not_equal_primitives_have_a_summary(p=use_parameters(primitive_not_equal_values)):
		var result = _compare.simple(p[0], p[1])
		assert_string_contains(result.summary, '!=', 'equals')
		assert_string_contains(result.summary, str(p[0]), 'zero value')
		assert_string_contains(result.summary, str(p[1]), 'one value')

	var incompatible_types = [[1, 'a'], [2.0, 2], [false, []], [{}, []]]
	func test_incompatible_types(p=use_parameters(incompatible_types)):
		var result = _compare.simple(p[0], p[1])
		assert_not_null(result.are_equal,  result.summary)
		assert_false(result.are_equal,  result.summary)

	func test_incompatible_types_summary(p=use_parameters(incompatible_types)):
		var result = _compare.simple(p[0], p[1])
		assert_string_contains(result.summary, 'Cannot')
		assert_string_contains(result.summary, '!=')

	func test_comparing_equal_dictionaries_includes_disclaimer():
		var d1 = {}
		var d2 = d1
		var result = _compare.simple(d1, d2)
		assert_true(result.are_equal, result.summary)
		assert_string_contains(result.summary, 'reference')

	func test_comparing_different_dictionaries_includes_disclaimer():
		var result = _compare.simple({}, {})
		assert_false(result.are_equal, result.summary)
		assert_string_contains(result.summary, 'reference')

	func test_comparing_arrays_returns_array_diff_summary():
		var result = _compare.simple([1, 2], [3, 4])
		assert_string_contains(result.summary, '1 != 3')


class TestShallowCompare:
	extends 'res://addons/gut/test.gd'

	var _compare  = _utils.Comparator.new()

	func test_comparing_arrays_populates_different_indexes():
		var a1  = [1, 2, 3]
		var a2  = ['a', 2, 'c']
		var result = _compare.shallow(a1, a2)
		assert_true(result.different_indexes == [0, 2])

	func test_comparing_arrays_are_equal_true_when_equal():
		var result = _compare.shallow([1], [1])
		assert_true(result.are_equal)

	func test_comparing_arrays_sets_summary():
		var result = _compare.shallow([2], [3])
		assert_not_null(result.summary)

	func test_comparing_dictionaries_populates_different_keys():
		var result = _compare.shallow({'a':1}, {'b':2})
		assert_true(result.different_keys.size() == 2)

	func test_comparing_dictionaries_populates_are_equal():
		var result = _compare.shallow({}, {})
		assert_true(result.are_equal)

	func test_comparing_dictionaries_populates_summary():
		var result = _compare.shallow({}, {'a':1})
		assert_not_null(result.summary)

	func test_comparing_dictionaries_does_not_include_sub_dictionaries():
		var result = _compare.shallow({'a':{}}, {'a':{}})
		assert_false(result.are_equal)

	func test_comparing_arrays_does_not_include_sub_dictionaries():
		var result = _compare.shallow([{'a':1}], [{'a':1}])
		assert_false(result.are_equal)

	func test_works_with_different_datatypes():
		var result = _compare.shallow({}, [])
		assert_false(result.are_equal)

	func test_works_with_primitives():
		var result =  _compare.shallow(1, 1)
		assert_true(result.are_equal)

class TestDeepCompare:
	extends 'res://addons/gut/test.gd'

	var _compare  = _utils.Comparator.new()

	func test_comparing_arrays_populates_different_indexes():
		var a1  = [1, 2, 3]
		var a2  = ['a', 2, 'c']
		var result = _compare.deep(a1, a2)
		assert_true(result.different_indexes == [0, 2])

	func test_comparing_arrays_are_equal_true_when_equal():
		var result = _compare.deep([1], [1])
		assert_true(result.are_equal)

	func test_comparing_arrays_sets_summary():
		var result = _compare.deep([2], [3])
		assert_not_null(result.summary)

	func test_comparing_dictionaries_populates_different_keys():
		var result = _compare.deep({'a':1}, {'b':2})
		assert_true(result.different_keys.size() == 2)

	func test_comparing_dictionaries_populates_are_equal():
		var result = _compare.deep({}, {})
		assert_true(result.are_equal)

	func test_comparing_dictionaries_populates_summary():
		var result = _compare.deep({}, {'a':1})
		assert_not_null(result.summary)

	func test_comparing_dictionaries_does_not_include_sub_dictionaries():
		var result = _compare.deep({'a':{}}, {'a':{}})
		assert_true(result.are_equal)

	func test_comparing_arrays_does_not_include_sub_dictionaries():
		var result = _compare.deep([{'a':1}], [{'a':1}])
		assert_true(result.are_equal)

	func test_works_with_different_datatypes():
		var result = _compare.deep({}, [])
		assert_false(result.are_equal)

	func test_works_with_primitives():
		var result =  _compare.deep(1, 1)
		assert_true(result.are_equal)