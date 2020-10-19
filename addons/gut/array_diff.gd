extends 'res://addons/gut/compare_result.gd'

# ------------------------------------------------------------------------------
# This class will diff two arrays.  It provides a text summary of the differences
# or you can use get_different_indexes to get an array of the indexes that are
# different between the two arrays.
# ------------------------------------------------------------------------------
var _utils = load('res://addons/gut/utils.gd').get_instance()
var _a1 = null
var _a2 =  null
var _size_diff_threshold = 30
var _strutils = _utils.Strutils.new()
var _max_string_length = 100
var _diff_type = null
var _different_indexes = []
var _different_descriptions = []

var _compare = _utils.Comparator.new()

# -------- comapre_result.gd "interface" ---------------------
var different_indexes = null setget set_different_indexes ,get_different_indexes

func  set_are_equal(val):
	_block_set('are_equal', val)

func get_are_equal():
	return are_equal()

func set_summary(val):
	_block_set('summary', val)

func  get_summary():
	return summarize()

func set_different_indexes(val):
	_block_set('different_indexes', val)
# -------- comapre_result.gd "interface" ---------------------

enum {
	DEEP,
	SHALLOW,
	SIMPLE
}

# -------------------------
# Private
# -------------------------
func _init(array_1, array_2, diff_type=SHALLOW):
	_a1 = array_1
	_a2 = array_2
	_diff_type = diff_type
	_compare.set_should_compare_int_to_float(false)
	_find_diff_indexes()


func _add_if_different(index, result):
	if(!result.are_equal):
		_different_indexes.append(index)
		var desc = result.summary
		if(result is _utils.DictionaryDiff and _diff_type == DEEP):
			desc = str(_compare.format_value(_a1[index], 25), ' != ',
				_compare.format_value(_a2[index], 25), '  Some keys have different values.')
		elif(result is _utils.ArrayDiff and _diff_type == DEEP):
			desc = str(_compare.format_value(_a1[index], 25), ' != ',
			_compare.format_value(_a2[index], 25), '  Some indexes have different values.')

		_different_descriptions.append(desc)


func _find_diff_indexes():
	for i in range(_a1.size()):
		var result = null
		if(i < _a2.size()):
			if(_diff_type == DEEP):
				result = _compare.deep(_a1[i], _a2[i])
			else:
				result = _compare.simple(_a1[i], _a2[i])
		else:
			result = _compare.simple(_a1[i], _compare.MISSING, 'index')

		_add_if_different(i, result)

	if(_a1.size() < _a2.size()):
		for i in range(_a1.size(), _a2.size()):
			_add_if_different(i, _compare.simple(_compare.MISSING, _a2[i], 'index'))


func _make_diff_description(max_differences=_size_diff_threshold):
	var limit = min(_different_indexes.size(), max_differences)

	var to_return = ""

	for i in range(limit):
		var idx = _different_indexes[i]
		to_return += str('  ', idx, ': ', _different_descriptions[i])
		if(i != limit -1):
			to_return += "\n"

	return to_return

# -------------------------
# Public
# -------------------------

# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
func are_equal():
	return _different_indexes.size() == 0


# ------------------------------------------------------------------------------
# Returns all the indexes that are different between the two arrays.  Includes
# indexes that are missing from one of the arrays.
# ------------------------------------------------------------------------------
func get_different_indexes():
	return _different_indexes


# ------------------------------------------------------------------------------
# Generates a summary of the differences in two arrays.
# ------------------------------------------------------------------------------
func summarize():
	var summary = ''
	var a1_str = _strutils.truncate_string(str(_a1), _max_string_length)
	var a2_str = _strutils.truncate_string(str(_a2), _max_string_length)

	var total_indexes = max(_a1.size(), _a2.size())
	if(are_equal()):
		summary = str(a1_str, ' == ', a2_str)
	else:
		var diff_str = _make_diff_description()
		var count_summary = str('- ', _different_indexes.size(), ' of ', total_indexes, ' indexes do not match.')
		if(_different_indexes.size() > _size_diff_threshold):
			count_summary += str("  Showing ", _size_diff_threshold, " of ", _different_indexes.size(), " differences.")
		summary = str(a1_str, ' != ', a2_str, "\n", count_summary, "\n", diff_str)

	return summary

# -------------------------
# Accessors
# -------------------------
func get_a1():
	return _a1


func get_a2():
	return _a2


func get_diff_type():
	return _diff_type