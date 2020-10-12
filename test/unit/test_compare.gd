extends 'res://addons/gut/test.gd'


var Compare = load('res://addons/gut/compare.gd')
var _compare = Compare.new()
var SIMPLE = 2

func p_simple_compare(v1, v2):
	gut.p(_compare.simple(v1, v2).summary)

func p_shallow_compare(v1, v2):
	gut.p(_compare.shallow(v1, v2).summary)

func p_deep_compare(v1, v2):
	gut.p(_compare.deep(v1, v2).summary)

func repeat_str(text, times):
	var to_return = ''
	for i in range(times):
		to_return += text
	return to_return


func test_simple():
	p_simple_compare(1, 1)
	p_simple_compare(5.0, 5)
	p_simple_compare(1, 2)
	p_simple_compare('a', 'a')
	p_simple_compare('a', 'b')
	p_simple_compare(repeat_str('z', 200), repeat_str('r', 300))
	p_simple_compare({'a':1}, {'a':1})
	var d1 = {'b':2}
	p_simple_compare(d1, d1)
	p_simple_compare(1, 1.0)
	p_simple_compare(1, '1')


func test_shallow():
	p_shallow_compare({'a':1}, {'b':2})
	p_shallow_compare([1, 2, 3], ['a', 'b','c'])