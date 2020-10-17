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
var _different_indexes = null

var _compare = _utils.Comparator.new()

# -------- comapre_result.gd "interface" ---------------------
var are_equal = null setget ,are_equal
var different_indexes = null setget ,get_different_indexes
var summary = null setget ,summarize
var different_keys = null

enum {
	DEEP,
	SHALLOW
}

# -------------------------
# Private
# -------------------------
func _init(array_1, array_2, diff_type=SHALLOW):
	_a1 = array_1
	_a2 = array_2
	_diff_type = diff_type
	_different_indexes = _find_diff_indexes()


func _are_indexes_equal(i):
	var to_return = [true, null]
	if(_utils.are_datatypes_same(_a1[i], _a2[i])):
		if(_diff_type == DEEP):
			to_return = _compare.deep(_a1[i], _a2[i]).are_equal
		else:
			to_return = _compare.simple(_a1[i], _a2[i]).are_equal
	else:
		to_return = false

	return to_return


func _find_diff_indexes():
	var different_indexes = []
	for i in range(_a1.size()):
		if(i < _a2.size()):
			if(!_are_indexes_equal(i)):
				different_indexes.append(i)
		else:
			different_indexes.append(i)

	if(_a1.size() < _a2.size()):
		for i in range(_a1.size(), _a2.size()):
			different_indexes.append(i)

	return  different_indexes


func _make_diff_description(max_differences=_size_diff_threshold):
	var diff_indexes = _different_indexes
	var limit = min(diff_indexes.size(), max_differences)

	var to_return = ""

	for i in range(limit):
		var idx = diff_indexes[i]

		var a1_str = '<index missing>'
		if(idx < _a1.size()):
			a1_str = _strutils.truncate_string(_strutils.type2str(_a1[idx]), _max_string_length)

		var a2_str = '<index missing>'
		if(idx < _a2.size()):
			a2_str = _strutils.truncate_string(_strutils.type2str(_a2[idx]), _max_string_length)

		to_return += str('  ', idx, ': ', a1_str, ' != ', a2_str)
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