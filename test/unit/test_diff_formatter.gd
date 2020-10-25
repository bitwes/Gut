extends 'res://addons/gut/test.gd'

class TestFormatter:
	extends 'res://addons/gut/test.gd'

	var Formatter = load('res://addons/gut/diff_formatter.gd')

	func test_equal_arrays():
		gut.p(Formatter.new().make_it(ArrayDiff.new([1, 2, 3], [1, 2, 3])))

	func test_equal_dictionaries():
		gut.p(Formatter.new().make_it(DictionaryDiff.new({}, {})))

	func test_when_shallow_ditionaries_in_arrays_are_not_checked_for_values():
		# var d1 = {'a':2, 'b':{'a':98}}
		# var d2 = {'a':1, 'b':{'a':99}}
		var d1 = {'a': 1, 'dne_in_d2':{'x':'x', 'y':'y', 'z':'z'}, 'r':1}
		var d2 = {'a': 2, 'dne_in_d1':{'xx':'x', 'yy':'y', 'zz':'z'}, 'r':2}

		var diff = DictionaryDiff.new(d1, d2, DIFF_TYPE.DEEP)
		#var diff = DictionaryDiff.new({'a':1, 'b':2, 'c':3}, {'a':'a', 'b':2, 'c':'c'}, _utils.DIFF.DEEP)
		gut.p(Formatter.new().make_it(diff))


	func test_works_with_strings_and_numbers():
		var a1 = [0, 1, 2, 3, 4]
		var a2 = [0, 'one', 'two', 'three', '4']
		var diff = ArrayDiff.new(a1, a2)
		gut.p(Formatter.new().make_it(diff))


	func test_complex_real_use_output():
		var d1 = {'a':1, 'dne_in_d2':'asdf', 'b':{'c':88, 'd':22, 'f':{'g':1, 'h':200}}, 'i':[1, 2, 3], 'z':{}}
		var d2 = {'a':1, 'b':{'c':99, 'e':'letter e', 'f':{'g':1, 'h':2}}, 'i':[1, 'two', 3], 'z':{}}
		var diff = DictionaryDiff.new(d1, d2)
		gut.p(Formatter.new().make_it(diff))

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

		var diff = DictionaryDiff.new(d1, d2)
		var formatter = Formatter.new()
		formatter.set_max_to_display(20)
		gut.p(formatter.make_it(diff))


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
		gut.p(Formatter.new().make_it(diff))


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
		gut.p(Formatter.new().make_it(diff))

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

		var diff = ArrayDiff.new(a1, a2)
		var formatter = Formatter.new()
		gut.p(formatter.make_it(diff))


	func test_absolute_max():
		var a1 = []
		var a2 = []
		for i in range(11000):
			a1.append(i)

		var diff = ArrayDiff.new(a1, a2)
		var formatter = Formatter.new()
		#formatter.set_max_to_display(formatter.UNLIMITED)
		gut.p(formatter.make_it(diff))

	func test_nested_difference():
		var v1 = {'a':{'b':{'c':{'d':1}}}}
		var v2 = {'a':{'b':{'c':{'d':2}}}}
		var diff = DictionaryDiff.new(v1, v2)
		var formatter = Formatter.new()
		gut.p(formatter.make_it(diff))

