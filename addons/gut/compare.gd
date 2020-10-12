class CompareResult:
	var are_equal = null
	var summary = null

	func _init(r_eq=null, smry=null):
		are_equal = r_eq
		summary = smry


var _utils = load('res://addons/gut/utils.gd').get_instance()
var strutils = _utils.Strutils.new()

var _value1 =  null
var _value2 = null

var _summary = ''
var _max_length = 100

var _are_equal = null
var _diff_type = null

enum {
	DEEP,
	SHALLOW,
	SIMPLE
}

func _init(val1, val2, diff_type):
	_value1 = val1
	_value2 = val2
	_diff_type =  diff_type
	if(_diff_type ==  SIMPLE):
		var result = _compare_simple(_value1, _value2)
		_are_equal = result.are_equal
		_summary = result.summary
	elif(_diff_type == SHALLOW):
		var result = _compare_shallow(_value1, _value2)
		_are_equal = result.are_equal
		_summary = result.summary

	elif(_diff_type == DEEP):
		pass

func _format_value(val):
	return strutils.truncate_string(strutils.type2str(val), _max_length)

func _compare_dictionary_simple(v1, v2):
	var result = CompareResult.new(false, '')
	result.are_equal = v1 == v2
	if(result.are_equal):
		result.summary = 'Values point to the same dictionary:  ' + _format_value(v1)
	else:
		result.summary = 'Values point to different dictionaries:  '
		result.summary += str(_format_value(v1), ' != ', _format_value(v2))

	return result

func _compare_dictionary_shallow(v1, v2):
	var diff = _utils.DictionaryDiff.new(v1, v2, SHALLOW)
	var result = CompareResult.new(diff.are_equal(), diff.summarize())
	return result

func _compare_dictionary_deep(v1, v2):
	var diff = _utils.DictionaryDiff.new(v1, v2, DEEP)
	var result = CompareResult.new(diff.are_equal(), diff.summarize())
	return result

func _compare_array_shallow(v1, v2):
	var diff = _utils.ArrayDiff.new(v1, v2, SHALLOW)
	var result = CompareResult.new(diff.are_equal(), diff.summarize())
	return result

func _compare_array_deep(v1, v2):
	var diff = _utils.ArrayDiff.new(v1, v2, DEEP)
	var result = CompareResult.new(diff.are_equal(), diff.summarize())
	return result

func _compare_simple(v1, v2):
	var to_return = CompareResult.new(true,
		str(_format_value(v2), ' == ', _format_value(v1)))

	if(_utils.are_datatypes_same(v1, v2)):
		if(typeof(_value1) == TYPE_DICTIONARY):
			to_return = _compare_dictionary_simple(v1, v2)
		elif(v1 != v2):
			to_return.summary = str(_format_value(v1), ' != ', _format_value(v2))
			to_return.are_equal = false
	else:
		to_return.summary = str(_format_value(v1), ' != ', _format_value(v2))
		to_return.are_equal = false

	return to_return


func _compare_shallow(v1, v2):
	var result = _compare_simple(v1, v2)

	if(_utils.are_datatypes_same(v1, v2)):
		if(typeof(v1) == TYPE_DICTIONARY):
			result = _compare_dictionary_shallow(v1, v2)
		if(typeof(v1) == TYPE_ARRAY):
			result = _compare_array_shallow(v1, v2)

	return result


func _compare_deep(v1, v2):
	var result = _compare_simple(v1, v2)

	if(_utils.are_datatypes_same(v1, v2)):
		if(typeof(v1) == TYPE_DICTIONARY):
			result = _compare_dictionary_deep(v1, v2)
		if(typeof(v1) == TYPE_ARRAY):
			result = _compare_array_deep(v1, v2)

	return result

func are_equal():
	return _are_equal

func summary():
	return _summary