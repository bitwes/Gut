extends 'res://addons/gut/compare_result.gd'

# ------------------------------------------------------------------------------
# This class will diff two arrays.  It provides a text summary of the differences
# or you can use get_different_indexes to get an array of the indexes that are
# different between the two arrays.
# ------------------------------------------------------------------------------
const INDENT = '    '
var _utils = load('res://addons/gut/utils.gd').get_instance()
var _a1 = null
var _a2 =  null
var _strutils = _utils.Strutils.new()
var _max_string_length = 100
var _diff_type = null

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

func get_different_count():
	return differences.size()

func get_total_count():
	return  max(_a1.size(), _a2.size())

func get_short_summary():
	var text = str(_strutils.truncate_string(str(_a1), 50),
		' ',  _compare.get_compare_symbol(are_equal()), ' ',
		 _strutils.truncate_string(str(_a2), 50))
	if(!are_equal()):
		text += str('  ', get_different_count(), ' of ', get_total_count(), ' indexes do not match.')
	return text

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
		differences[index] = result


func _find_diff_indexes():
	for i in range(_a1.size()):
		var result = null
		if(i < _a2.size()):
			if(_diff_type == DEEP):
				result = _compare.deep(_a1[i], _a2[i])
				result.max_differences = 20
			else:
				result = _compare.simple(_a1[i], _a2[i])
		else:
			result = _compare.simple(_a1[i], _compare.MISSING, 'index')

		_add_if_different(i, result)

	if(_a1.size() < _a2.size()):
		for i in range(_a1.size(), _a2.size()):
			_add_if_different(i, _compare.simple(_compare.MISSING, _a2[i], 'index'))


func _array_to_s(d=differences, depth=0):
	var keys = d.keys()
	var limit = min(keys.size(), max_differences)

	var to_return = ""

	for i in range(limit):
		var key = keys[i]
		var key_title = str(key, ': ')
		if(d[key] is _utils.DictionaryDiff):
			var diff = _strutils.indent_text(str(d[key].differences_to_string()), depth, INDENT)
			to_return += str(key_title, d[key].get_short_summary(), "\n", diff)
		elif(d[key] is _utils.ArrayDiff):
			var open = "[\n"
			var sub_desc = _array_to_s(d[key].differences, depth)
			var close = _strutils.indent_text("\n]", depth, INDENT)
			to_return += str(key_title, d[key].get_short_summary(), "\n", open,
				_strutils.indent_text(sub_desc, depth + 1, INDENT), close)
		else:
			to_return += _strutils.indent_text(str(key_title, d[key]), depth, INDENT)

		if(i != limit -1):
			to_return += "\n"

	return to_return


func _make_diff_description(max_differences=max_differences):
	max_differences = max_differences
	var text = _array_to_s(differences, 0)

	return str("[\n", _strutils.indent_text(text, 1, INDENT), "\n]")

func differences_to_string():
	return _make_diff_description()

# -------------------------
# Public
# -------------------------

# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
func are_equal():
	return differences.size() == 0


# ------------------------------------------------------------------------------
# Returns all the indexes that are different between the two arrays.  Includes
# indexes that are missing from one of the arrays.
# ------------------------------------------------------------------------------
func get_different_indexes():
	return differences.keys()


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
		var count_summary = str('- ', differences.size(), ' of ', total_indexes, ' indexes do not match.')
		if(differences.size() > max_differences):
			count_summary += str("  Showing ", max_differences, " of ", differences.size(), " differences.")
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