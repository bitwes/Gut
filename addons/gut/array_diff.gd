# ------------------------------------------------------------------------------
# This class will diff two arrays.  It provides a text summary of the differences
# or you can use get_different_indexes to get an array of the indexes that are
# different between the two arrays.
# ------------------------------------------------------------------------------
var _a1 = null
var _a2 =  null
var _size_diff_threshold = 30
var strutils = load('res://addons/gut/utils.gd').get_instance().Strutils.new()
var _max_string_length = 100

# -------------------------
# Private
# -------------------------
func _init(array_1, array_2):
	_a1 = array_1
	_a2 = array_2


func _do_datatypes_match(got, expected):
	return !(typeof(got) != typeof(expected) and got != null and expected != null)


func _get_diff_indexes():
	var different_indexes = []
	for i in range(_a1.size()):
		if(i < _a2.size()):
			if(!_do_datatypes_match(_a1[i], _a2[i]) or _a1[i] != _a2[i]):
					different_indexes.append(i)
		else:
			different_indexes.append(i)

	if(_a1.size() < _a2.size()):
		for i in range(_a1.size(), _a2.size()):
			different_indexes.append(i)

	return  different_indexes


func _make_diff_description(max_differences=_size_diff_threshold):
	var diff_indexes = _get_diff_indexes()
	var limit = min(diff_indexes.size(), max_differences)

	var to_return = str(diff_indexes.size(), ' different indexes')
	if(diff_indexes.size() > limit):
		to_return += str(" (", limit, ' shown)')
	to_return += ":\n"

	for i in range(limit):
		var idx = diff_indexes[i]

		var a1_str = '<index missing>'
		if(idx < _a1.size()):
			a1_str = strutils.type2str(_a1[idx])

		var a2_str = '<index missing>'
		if(idx < _a2.size()):
			a2_str = strutils.type2str(_a2[idx])

		to_return += str('  ', idx, ': ', a1_str, ' != ', a2_str)
		if(i != limit -1):
			to_return += "\n"

	return to_return

# -------------------------
# Public
# -------------------------

# ------------------------------------------------------------------------------
# I thought this was going to be more complicated originally.  Still could
# maybe.  Just returns result of ==
# ------------------------------------------------------------------------------
func are_equal():
	return _a1 == _a2

# ------------------------------------------------------------------------------
# Returns all the indexes that are different between the two arrays.  Includes
# indexes that are missing from one of the arrays.
# ------------------------------------------------------------------------------
func get_different_indexes():
	return _get_diff_indexes()


# ------------------------------------------------------------------------------
# Generates a summary of the differences in two arrays.
# * When arrays and diff is small enough then  both arrays  and all differences
#   are listed.
# * Each array is trunated to 100 chars
# * Up to _size_diff_threshold different indexes will be listed.
# * If the difference in sizes is > _size_diff_threshold then the arrays are
# ------------------------------------------------------------------------------
func summarize():
	var summary = ''
	var a1_str = strutils.truncate_string(str(_a1), _max_string_length)
	var a2_str = strutils.truncate_string(str(_a2), _max_string_length)

	if(are_equal()):
		summary = str(a1_str, ' == ', a2_str)
	else:
		if(abs(_a1.size() - _a2.size()) > _size_diff_threshold):
			summary =  str(a1_str, ' != ', a2_str, "\n",  \
				'Array sizes are too different to compare:  array_1.size = ', \
				_a1.size(), ', array_2.size = ', _a2.size())
		else:
			var diff_str = _make_diff_description()
			var size_compare = str("- Arrays are the same size:  ", _a1.size(), ".")
			if(_a1.size() != _a2.size()):
				size_compare = str("- Array sizes are different:  ", _a1.size(), "/", _a2.size())
			summary = str(a1_str, ' != ', a2_str, "\n", size_compare, "\n- ", diff_str)

	return summary

# -------------------------
# Accessors
# -------------------------
func get_a1():
	return _a1


func get_a2():
	return _a2
