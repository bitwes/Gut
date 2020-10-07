extends 'res://addons/gut/test.gd'

var ArrayDiff = load('res://addons/gut/array_diff.gd')

func test_can_make_one():
	var ad = ArrayDiff.new()
	assert_not_null(ad)

func test_can_instantiate_with_two_arrays():
	var ad  = ArrayDiff.new([], [])
	assert_not_null(ad)

func test_a1_accessors():
	var ad  = ArrayDiff.new()
	assert_accessors(ad, 'a1', null, [1, 2,  3])

func test_a2_accessors():
	var ad  = ArrayDiff.new()
	assert_accessors(ad, 'a2', null, [1, 2,  3])

func test_two_array_constructor_sets_a1_and_a2():
	var a1 = [1, 2, 3]
	var a2 = [3, 4, 5]
	var ad = ArrayDiff.new(a1, a2)
	assert_eq(ad.get_a1(), a1, 'a1')
	assert_eq(ad.get_a2(), a2, 'a2')

func test_is_equal_is_true_when_all_elements_match():
	var ad = ArrayDiff.new([1, 2, 3], [1, 2, 3])
	assert_true(ad.are_equal())

func test_is_equal_returns_false_when_one_element_does_not_match():
	var ad = ArrayDiff.new([1, 2, 3], [1, 2, 99])
	assert_false(ad.are_equal(), 'should be false but is ' + str(ad.are_equal()))

func test_can_get_list_of_different_indexes():
	var ad = ArrayDiff.new([1, 2, 3], [3, 2, 1])
	assert_eq(ad.get_different_indexes(), [0, 2])

func test_get_different_indexes_works_when_a1_smaller():
	var ad = ArrayDiff.new([1, 2, 3], [3, 2, 1, 98, 99])
	assert_eq(ad.get_different_indexes(), [0, 2, 3 ,4])


func test_lists_indexes_as_missing_in_first_array():
	var ad = ArrayDiff.new([1, 2, 3], [1, 2, 3, 4, 5])
	assert_string_contains(ad.summarize(), '[missing] !=')

func test_get_different_indexes_works_when_a2_smaller():
	var ad = ArrayDiff.new([3, 2, 1, 98, 99], [1, 2, 3])
	assert_eq(ad.get_different_indexes(), [0, 2, 3, 4])

func test_get_summary_text_lists_both_arrays():
	var ad = ArrayDiff.new([3, 2, 1, 98, 99], [1, 2, 3])
	assert_string_contains(ad.summarize(), '[3, 2, 1, 98, 99] != [1, 2, 3]')

func test_get_summary_text_lists_differences():
	var ad = ArrayDiff.new([3, 2, 1, 98, 99], [1, 2, 3])
	assert_string_contains(ad.summarize(), '0: 3 !=')

func test_when_sizes_do_not_match_and_threshold_exceeded_then_summarize_tells_you():
	var ad = ArrayDiff.new([3, 2, 1, 98, 99], [1, 2, 3])
	ad._size_diff_threshold = 1
	assert_string_contains(ad.summarize(), 'Arrays sizes are')
	assert_string_contains(ad.summarize(), '(5)', 'a1 size')
	assert_string_contains(ad.summarize(), '(3)', 'a2 size')

func test_when_arrays_are_large_then_summarize_truncates():
	var a1 = []
	var a2 = []
	for i in range(100):
		a1.append(i)
		a2.append(i + 20)

	var ad = ArrayDiff.new(a1, a2)
	var summary = ad.summarize()
	assert_lt(summary.length(), 700, summary)


func test_works_with_strings_and_numbers():
	var a1 = [0, 1, 2, 3, 4]
	var a2 = [0, 'one', 'two', 'three', '4']
	var ad = ArrayDiff.new(a1, a2)
	gut.p(ad.summarize())
	pass_test('we got here')