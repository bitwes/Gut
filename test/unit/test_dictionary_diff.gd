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
	var d1 = {'a':1, 'b':'two', 'c':Node2D.new()}
	var d2 = {'a':1.0, 'b':2, 'c':_utils.Strutils.new()}
	var dd = DictionaryDiff.new(d1, d2)
	assert_eq(dd.get_different_keys(), ['a', 'b', 'c'])