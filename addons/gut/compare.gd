class CompareResult:
	var are_equal = null
	var summary = null
	var diff_object = null

	func _init(r_eq=null, smry=null):
		are_equal = r_eq
		summary = smry

const DICTIONARY_DISCLAIMER = "Use DictionaryDiff class to compare values.  See GUT wiki for more information."

var _utils = load('res://addons/gut/utils.gd').get_instance()
var strutils = _utils.Strutils.new()

var _max_length = 100
var _compare_float_to_int = true

enum {
	DEEP,
	SHALLOW,
	SIMPLE
}

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
	result.summary += '.  ' + DICTIONARY_DISCLAIMER
	return result

func _compare_dictionary_shallow(v1, v2):
	var diff = _utils.DictionaryDiff.new(v1, v2, SHALLOW)
	var result = CompareResult.new(diff.are_equal(), diff.summarize())
	result.diff_object = diff
	return result

func _compare_dictionary_deep(v1, v2):
	var diff = _utils.DictionaryDiff.new(v1, v2, DEEP)
	var result = CompareResult.new(diff.are_equal(), diff.summarize())
	result.diff_object = diff
	return result

func _compare_array_shallow(v1, v2):
	var diff = _utils.ArrayDiff.new(v1, v2, SHALLOW)
	var result = CompareResult.new(diff.are_equal(), diff.summarize())
	result.diff_object = diff
	return result

func _compare_array_deep(v1, v2):
	var diff = _utils.ArrayDiff.new(v1, v2, DEEP)
	var result = CompareResult.new(diff.are_equal(), diff.summarize())
	result.diff_object = diff
	return result

func simple(v1, v2):
	var to_return = CompareResult.new(true,
		str(_format_value(v2), ' == ', _format_value(v1)))

	if(_utils.are_datatypes_same(v1, v2)):
		if(typeof(v1) == TYPE_DICTIONARY):
			to_return = _compare_dictionary_simple(v1, v2)
		elif(v1 != v2):
			to_return.summary = str(_format_value(v1), ' != ', _format_value(v2))
			to_return.are_equal = false
	else:
		var v1_type = typeof(v1)
		var v2_type = typeof(v2)
		if(_compare_float_to_int and [2, 3].has(v1_type) and [2, 3].has(v2_type)):
			if(v1 != v2):
				to_return.summary = str(_format_value(v1), ' != ', _format_value(v2))
				to_return.are_equal = false
		else:
			to_return.summary = str(_format_value(v1), ' != ', _format_value(v2))
			to_return.are_equal = false

	return to_return


func shallow(v1, v2):
	var result = simple(v1, v2)

	if(_utils.are_datatypes_same(v1, v2)):
		if(typeof(v1) == TYPE_DICTIONARY):
			result = _compare_dictionary_shallow(v1, v2)
		if(typeof(v1) == TYPE_ARRAY):
			result = _compare_array_shallow(v1, v2)

	return result


func deep(v1, v2):
	var result = simple(v1, v2)

	if(_utils.are_datatypes_same(v1, v2)):
		if(typeof(v1) == TYPE_DICTIONARY):
			result = _compare_dictionary_deep(v1, v2)
		if(typeof(v1) == TYPE_ARRAY):
			result = _compare_array_deep(v1, v2)

	return result


func format_value(val):
	return _format_value(val)