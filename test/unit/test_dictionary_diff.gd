extends 'res://addons/gut/test.gd'

var DictionaryDiff = load('res://addons/gut/dictionary_diff.gd')

func test_can_init_with_two_dictionaries():
	var dd = DictionaryDiff.new({}, {})
	assert_not_null(dd)

func test_get_different_keys_returns_empty_array_when_matching():
	var dd = DictionaryDiff.new({'a':'asdf'}, {'a':'asdf'})
	assert_eq(dd.get_different_keys(), [])

func test_get_different_keys_returns_non_matching_keys():
	var dd = DictionaryDiff.new({'a':'asdf', 'b':1}, {'a':'asdf', 'b':2})
	assert_eq(dd.get_different_keys(), ['b'])

func test_get_differetn_keys_returns_missing_indexes_in_d2():
	var dd = DictionaryDiff.new({'a':'asdf', 'b':1}, {'a':'asdf'})
	assert_eq(dd.get_different_keys(), ['b'])

func test_get_differetn_keys_returns_missing_indexes_in_d1():
	var dd = DictionaryDiff.new({'a':'asdf'}, {'a':'asdf', 'b':1})
	assert_eq(dd.get_different_keys(), ['b'])

func test_get_different_keys_works_with_different_datatypes():
	var d1 = {'a':1, 'b':'two', 'c':autofree(Node2D.new())}
	var d2 = {'a':1.0, 'b':2, 'c':_utils.Strutils.new()}
	var dd = DictionaryDiff.new(d1, d2)
	assert_eq(dd.get_different_keys(), ['a', 'b', 'c'])

func test_are_equal_true_for_matching_dictionaries():
	assert_true(DictionaryDiff.new({}, {}).are_equal(), 'empty')
	assert_true(DictionaryDiff.new({'a':1}, {'a':1}).are_equal(), 'same')
	assert_true(DictionaryDiff.new({'a':1, 'b':2}, {'b':2, 'a':1}).are_equal(), 'different order')

func test_summarize():
	var d1 = {'aa':'asdf', 'a':1, 'b':'two', 'c':autofree(Node2D.new())}
	var d2 = {'a':1.0, 'b':2, 'c':_utils.Strutils.new(), 'cc':'adsf'}
	var dd = DictionaryDiff.new(d1, d2)
	gut.p(dd.summarize())

func test_large_dictionary_summary():
	var d1 = {}
	var d2 = {}
	for i in range(3):
		for j in range(65, 91):
			var one_char = PoolByteArray([j]).get_string_from_ascii()
			var key = ''
			for x in range(i + 1):
				key += one_char
			d1[key] = (i + 1) * j
			d2[key] = one_char

	var dd = DictionaryDiff.new(d1, d2)
	gut.p(dd.summarize())

func test_get_different_keys_returns_a_copy_of_the_keys():
	var dd = DictionaryDiff.new({'a':1}, {})
	var keys = dd.get_different_keys()
	keys.remove(0)
	assert_eq(dd.get_different_keys().size(), 1)