extends 'res://addons/gut/test.gd'


func test_can_init_with_two_dictionaries():
	var dd = DictionaryDiff.new({}, {})
	assert_not_null(dd)

func test_get_different_keys_returns_empty_array_when_matching():
	var dd = DictionaryDiff.new({'a':'asdf'}, {'a':'asdf'})
	assert_eq(dd.get_different_keys().keys(), [])

func test_get_different_keys_returns_non_matching_keys():
	var dd = DictionaryDiff.new({'a':'asdf', 'b':1}, {'a':'asdf', 'b':2})
	assert_eq(dd.get_different_keys().keys(), ['b'])

func test_get_differetn_keys_returns_missing_indexes_in_d2():
	var dd = DictionaryDiff.new({'a':'asdf', 'b':1}, {'a':'asdf'})
	assert_eq(dd.get_different_keys().keys(), ['b'])

func test_get_differetn_keys_returns_missing_indexes_in_d1():
	var dd = DictionaryDiff.new({'a':'asdf'}, {'a':'asdf', 'b':1})
	assert_eq(dd.get_different_keys().keys(), ['b'])

func test_get_different_keys_works_with_different_datatypes():
	var d1 = {'a':1, 'b':'two', 'c':autofree(Node2D.new())}
	var d2 = {'a':1.0, 'b':2, 'c':_utils.Strutils.new()}
	var dd = DictionaryDiff.new(d1, d2)
	assert_eq(dd.get_different_keys().keys(), ['a', 'b', 'c'])

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
			if(key == 'BB'):
				d1[key] = d1.duplicate()
				d2[key] = d2.duplicate()
			else:
				d1[key] = (i + 1) * j
				d2[key] = one_char

	var dd = DictionaryDiff.new(d1, d2)
	gut.p(dd.summarize())
	assert_lt(dd.summarize().split("\n").size(), 40)

func test_with_obj_as_keys():
	var d1 = {}
	var d2 = {}
	var node_1 = autofree(Node2D.new())
	var node_2 = autofree(Node2D.new())
	var other_1 = autofree(_utils.Strutils.new())
	var other_2 = autofree(_utils.Strutils.new())
	for i in range(6):
		var key = autofree(_utils.Strutils.new())

		if(i%2 == 0):
			d1[key] = node_1
			d2[key] = node_2
		else:
			d1[key] = other_1
			d2[key] = other_2

	var dd =  DictionaryDiff.new(d1, d2)
	gut.p(dd.summarize())

func test_sub_dictionary_compare_when_equal():
	var d1 = {'a':1, 'b':{'a':99}}
	var d2 = {'a':1, 'b':{'a':99}}
	var dd = DictionaryDiff.new(d1, d2)
	assert_true(dd.are_equal(), dd.summarize())

func test_sub_dictionary_compare_when_not_equal():
	var d1 = {'a':1, 'dne_in_d2':'asdf', 'b':{'c':88, 'd':22, 'f':{'g':1, 'h':200}}, 'z':{}}
	var d2 = {'a':1, 'b':{'c':99, 'e':'letter e', 'f':{'g':1, 'h':2}}, 'z':{}}
	var dd = DictionaryDiff.new(d1, d2)
	assert_false(dd.are_equal(), dd.summarize())
	assert_eq(dd.get_total_key_count(), 10, 'total key count')
	assert_eq(dd.get_total_different_count(), 7, 'total different count')

func test_sub_dictionary_missing_in_other():
	var d1 = {'a': 1, 'dne_in_d2':{'x':'x', 'y':'y', 'z':'z'}, 'r':1}
	var d2 = {'a': 2, 'dne_in_d1':{'xx':'x', 'yy':'y', 'zz':'z'}, 'r':2}
	var diff = DictionaryDiff.new(d1, d2)
	var summary = diff.summarize()
	assert_string_contains(summary, diff.MISSING_KEY + ' !=')
	assert_string_contains(summary, ' != ' + diff.MISSING_KEY)

func test_get_different_keys_returns_a_copy_of_the_keys():
	var dd = DictionaryDiff.new({'a':1}, {})
	var keys = dd.get_different_keys()
	keys.erase('a')
	assert_eq(dd.get_different_keys().size(), 1)


func test_complex_real_use_output():
	var d1 = {'a':1, 'dne_in_d2':'asdf', 'b':{'c':88, 'd':22, 'f':{'g':1, 'h':200}}, 'z':{}}
	var d2 = {'a':1, 'b':{'c':99, 'e':'letter e', 'f':{'g':1, 'h':2}}, 'z':{}}
	var dd = DictionaryDiff.new(d1, d2)
	assert_true(dd.are_equal(), dd.summarize() + "\n\n this should fail")
