extends 'res://addons/gut/test.gd'


class TestCompareResultInterace:
	extends 'res://addons/gut/test.gd'

	func test_cannot_set_summary():
		var ad = ArrayDiff.new([], [])
		ad.summary = 'the summary'
		assert_ne(ad.summary,  'the summary')

	func test_summary_prop_returns_summarize():
		var ad =  ArrayDiff.new([], [1])
		assert_not_null(ad.summary)

	func test_cannot_set_are_equal():
		var ad = ArrayDiff.new([], [])
		ad.are_equal = 'asdf'
		assert_eq(ad.are_equal, true)

	func test_are_equal_prop_returns_result_of_diff():
		var ad = ArrayDiff.new([], [])
		assert_eq(ad.are_equal, true)

	func test_get_total_different_returns_correct_count():
		var diff = ArrayDiff.new([1, 2, 3], [1, 'two', 99, 'four'])
		assert_eq(diff.get_different_count(), 3)

	var _total_count_vars = [
		[[1, 2, 3], [1, 2, 3, 4], 4],
		[[1, 2, 3, 4], [1, 2, 3], 4],
		[[1, 2], [1, 2], 2]
	]
	func test_get_total_count_returns_correct_count(p=use_parameters(_total_count_vars)):
		var diff = ArrayDiff.new(p[0], p[1])
		assert_eq(diff.get_total_count(), p[2])

	func test_get_short_summary_includes_x_of_y_keys_when_different():
		var diff = ArrayDiff.new([1, 2, 3, 4], [1, 'a', 'b', 'c', 'd'], _utils.DIFF.DEEP)
		assert_string_contains(diff.get_short_summary(), '4 of 5')

	func test_get_short_summary_does_not_include_x_of_y_when_equal():
		var diff = ArrayDiff.new([], [], _utils.DIFF.DEEP)
		assert_eq(diff.get_short_summary().find(' of '), -1, diff.get_short_summary())
		assert_string_contains(diff.get_short_summary(), '==')

	func test_brackets():
		var diff = ArrayDiff.new([], [])
		assert_eq(diff.get_brackets().open, '[', 'open')
		assert_eq(diff.get_brackets().close, ']', 'close')


class TestTheRest:
	extends 'res://addons/gut/test.gd'


	func test_can_instantiate_with_two_arrays():
		var ad  = ArrayDiff.new([], [])
		assert_not_null(ad)

	func test_constructor_defaults_diff_type_to_deep():
		var diff = ArrayDiff.new([], [])
		assert_eq(diff.get_diff_type(), _utils.DIFF.DEEP)

	func test_constructor_sets_diff_type():
		var diff = ArrayDiff.new([], [], _utils.DIFF.SHALLOW)
		assert_eq(diff.get_diff_type(), _utils.DIFF.SHALLOW)

	func test_is_equal_is_true_when_all_elements_match():
		var ad = ArrayDiff.new([1, 2, 3], [1, 2, 3])
		assert_true(ad.are_equal())

	func test_is_equal_returns_false_when_one_element_does_not_match():
		var ad = ArrayDiff.new([1, 2, 3], [1, 2, 99])
		assert_false(ad.are_equal(), 'should be false but is ' + str(ad.are_equal()))

	# func test_can_get_list_of_different_indexes():
	# 	var ad = ArrayDiff.new([1, 2, 3], [3, 2, 1])
	# 	assert_eq(ad.get_different_indexes(), [0, 2])

	# func test_get_different_indexes_works_when_a1_smaller():
	# 	var ad = ArrayDiff.new([1, 2, 3], [3, 2, 1, 98, 99])
	# 	assert_eq(ad.get_different_indexes(), [0, 2, 3 ,4])

	func test_lists_indexes_as_missing_in_first_array():
		var ad = ArrayDiff.new([1, 2, 3], [1, 2, 3, 4, 5])
		assert_string_contains(ad.summarize(), '<missing index> !=')

	# func test_get_different_indexes_works_when_a2_smaller():
	# 	var ad = ArrayDiff.new([3, 2, 1, 98, 99], [1, 2, 3])
	# 	assert_eq(ad.get_different_indexes(), [0, 2, 3, 4])

	func test_get_summary_text_lists_both_arrays():
		var ad = ArrayDiff.new([3, 2, 1, 98, 99], [1, 2, 3])
		assert_string_contains(ad.summarize(), '[3, 2, 1, 98, 99] != [1, 2, 3]')

	func test_get_summary_text_lists_differences():
		var ad = ArrayDiff.new([3, 2, 1, 98, 99], [1, 2, 3])
		assert_string_contains(ad.summarize(), '0:  3 !=')

	func test_when_arrays_are_large_then_summarize_truncates():
		var a1 = []
		var a2 = []
		for i in range(100):
			a1.append(i)
			if(i%2 == 0):
				a2.append(str(i))
			else:
				if(i < 90):
					a2.append(i)

		var ad = ArrayDiff.new(a1, a2)
		var summary = ad.summarize()
		assert_lt(summary.split("\n").size(), 40, summary)

	func test_works_with_strings_and_numbers():
		var a1 = [0, 1, 2, 3, 4]
		var a2 = [0, 'one', 'two', 'three', '4']
		var ad = ArrayDiff.new(a1, a2)
		gut.p(ad.summarize())
		pass_test('we got here')

	func test_when_arrays_are_equal_summarize_says_so():
		var ad = ArrayDiff.new(['a', 'b', 'c'], ['a', 'b', 'c'])
		assert_string_contains(ad.summarize(), ' == ')

	func test_diff_display_with_classes():
		var d_test = double('res://addons/gut/test.gd').new()
		var a1 = [gut, d_test]
		var a2 = [d_test, gut]
		var ad  = ArrayDiff.new(a1, a2)
		assert_string_contains(ad.summarize(), '(gut.gd)')
		assert_string_contains(ad.summarize(), 'double of test.gd')

	func test_diff_display_with_classes2():
		var d_test_1 = double('res://addons/gut/test.gd').new()
		var d_test_2 = double('res://addons/gut/test.gd').new()
		var a1 = [d_test_1, d_test_2]
		var a2 = [d_test_2, d_test_1]
		var ad  = ArrayDiff.new(a1, a2)
		assert_string_contains(ad.summarize(), 'double of test.gd')


	func test_diff_with_dictionaries_fails_when_not_same_reference_but_same_values():
		var a1 = [{'a':1}, {'b':2}]
		var a2 = [{'a':1}, {'b':2}]
		var diff = ArrayDiff.new(a1, a2, DIFF_TYPE.SHALLOW)
		assert_false(diff.are_equal(), diff.summarize())


	func test_dictionaries_in_sub_arrays():
		var a1 = [[{'a': 1}]]
		var a2 = [[{'a': 1}]]
		var diff = ArrayDiff.new(a1, a2, DIFF_TYPE.SHALLOW)
		assert_false(diff.are_equal(), diff.summarize())


class TestDeepDiff:
	extends 'res://addons/gut/test.gd'

	func test_diff_with_dictionaries_passes_when_not_same_reference_but_same_values():
		var a1 = [{'a':1}, {'b':2}]
		var a2 = [{'a':1}, {'b':2}]
		var diff = ArrayDiff.new(a1, a2, DIFF_TYPE.DEEP)
		assert_true(diff.are_equal(), diff.summarize())

	func test_diff_with_dictionaries_fails_when_different_values():
		var a1 = [{'a':1}, {'b':1}, {'c':1}, {'d':1}]
		var a2 = [{'a':1}, {'b':2}, {'c':2}, {'d':2}]
		var diff = ArrayDiff.new(a1, a2, DIFF_TYPE.DEEP)
		assert_false(diff.are_equal(), diff.summarize())

	func test_matching_dictionaries_in_sub_arrays():
		var a1 = [[{'a': 1}]]
		var a2 = [[{'a': 1}]]
		var diff = ArrayDiff.new(a1, a2, DIFF_TYPE.DEEP)
		assert_true(diff.are_equal(), diff.summarize())

	func test_non_matching_dictionaries_in_sub_arrays():
		var a1 = [[{'a': 1}], [{'b': 1}], [{'c': 1}]]
		var a2 = [[{'a': 1}], [{'b': 2}], [{'c': 2}]]
		var diff = ArrayDiff.new(a1, a2, DIFF_TYPE.DEEP)
		assert_false(diff.are_equal(), diff.summarize())

	func test_when_deep_compare_non_equal_dictionaries_do_not_contain_disclaimer():
		var a1 = [[{'a': 2}], [{'b': 3}], [{'c': 4}]]
		var a2 = [[{'a': 1}], [{'b': 2}], [{'c': 2}]]
		var diff = ArrayDiff.new(a1, a2, DIFF_TYPE.DEEP)
		assert_eq(diff.summary.find('reference'), -1, diff.summary)



class TestComplicatedDisplay:
	extends 'res://addons/gut/test.gd'

	func test_mix_of_array_and_dictionaries():
		var a1 = [
			'a', 'b', 'c',
			[1, 2, 3, 4],
			{'a':1, 'b':2, 'c':3},
			[{'a':1}, {'b':2}]
		]
		var a2 = [
			'a', 2, 'c',
			['a', 2, 3, 'd'],
			{'a':11, 'b':12, 'c':13},
			[{'a':'diff'}, {'b':2}]
		]
		var diff = ArrayDiff.new(a1, a2, DIFF_TYPE.DEEP)
		fail_test(diff.summary  + "\n this fails")


	func test_multiple_sub_arrays():
		var a1 = [
			[1, 2, 3],
			[[4, 5, 6], ['same'], [7, 8, 9]]
		]
		var a2 = [
			[11, 12, 13],
			[[14, 15, 16], ['same'], [17, 18, 19]]
		]
		var diff = ArrayDiff.new(a1, a2, DIFF_TYPE.DEEP)
		fail_test(diff.summary  + "\n this fails")


