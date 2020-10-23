extends 'res://addons/gut/compare_result.gd'


const INDENT = '    '
enum {
	DEEP,
	SHALLOW
}

var _utils = load('res://addons/gut/utils.gd').get_instance()
var strutils = _utils.Strutils.new()
var compare = _utils.Comparator.new()

var MISSING_KEY = compare.MISSING

var _d1 = null
var _d2 = null

var _max_string_length = 100
var _different_keys = null
var _num_shown = 0

var _total_key_count = 0
var _total_different = 0

var _diff_type = SHALLOW

# -------- comapre_result.gd "interface" ---------------------
var different_keys = null setget set_different_keys ,get_different_keys

func  set_are_equal(val):
	_block_set('are_equal', val)

func get_are_equal():
	return are_equal()

func set_summary(val):
	_block_set('summary', val)

func get_summary():
	return summarize()

func set_different_keys(val):
	_block_set('different_keys', val)

func get_different_count():
	return _total_different

func  get_total_count():
	return _total_key_count

func get_short_summary():
	var text = str(strutils.truncate_string(str(_d1), 50),
		' ', compare.get_compare_symbol(are_equal()), ' ',
		strutils.truncate_string(str(_d2), 50))
	if(!are_equal()):
		text += _do_not_match_clause()
	return text
# -------- comapre_result.gd "interface" ---------------------


func _do_not_match_clause():
	return str('  ', get_different_count(), ' of ', get_total_count(), ' keys do not match.')

func _showing_clause():
	var to_return = ''
	if(_total_different > max_differences):
		to_return += str("  Showing ", max_differences, " of ", _total_different, " differences.")
	return to_return

func _init(d1, d2, diff_type=DEEP):
	_d1 = d1
	_d2 = d2
	_diff_type = diff_type
	compare.set_should_compare_int_to_float(false)
	_different_keys = _find_different_keys()


func _find_different_keys():
	var diff_keys = {}
	var d1_keys = _d1.keys()
	var d2_keys = _d2.keys()

	# Process all the keys in d1
	_total_key_count += d1_keys.size()
	for key in d1_keys:
		if(!_d2.has(key)):
			diff_keys[key] = compare.simple(_d1[key], compare.MISSING, 'key')
			_total_different += 1
		else:
			d2_keys.remove(d2_keys.find(key))

			var result = null
			if(_diff_type == DEEP):
				result = compare.deep(_d1[key], _d2[key])
			else:
				result = compare.simple(_d1[key], _d2[key])

			if(result is _utils.DictionaryDiff):
				_total_key_count += result.get_total_count()
				_total_different += result.get_different_count()
				if(!result.are_equal):
					_total_different += 1
					diff_keys[key] = result
			else:
				if(!result.are_equal):
					_total_different += 1
					diff_keys[key] = result

	# Process all the keys in d2 that didn't exist in d1
	_total_key_count += d2_keys.size()
	_total_different += d2_keys.size()
	for i in range(d2_keys.size()):
		diff_keys[d2_keys[i]] = compare.simple(compare.MISSING, _d2[d2_keys[i]], 'key').summary

	return diff_keys


func _dictionary_to_s(d, depth):
	var to_return = ''
	var keys = d.keys()
	keys.sort()
	var idx = 0
	while(idx < keys.size() and _num_shown < max_differences):
		var key = keys[idx]
		if(d[key] is _utils.DictionaryDiff):
			var open = str(strutils.type2str(key), ':', d[key].get_short_summary(), "\n{\n")
			var sub_desc = _dictionary_to_s(d[key].different_keys, depth + 1)
			if(_total_key_count > max_differences):
				sub_desc += "...\n"
			var close = "}\n"
			to_return +=  str(open, strutils.indent_text(sub_desc, depth + 1, INDENT), close)
		elif(d[key] is _utils.ArrayDiff):
			var diff = strutils.indent_text(d[key].differences_to_string(), depth, INDENT)
			diff.max_differences = 20
			to_return += str(strutils.type2str(key), ":  ", d[key].get_short_summary(), "\n", diff)
		else:
			to_return += str(strutils.type2str(key), ":  ", d[key], "\n")
		_num_shown += 1
		idx += 1

	return to_return


func differences_to_string():
	_num_shown = 0
	var text = _dictionary_to_s(_different_keys, 0)
	if(_total_key_count > max_differences):
		text += "...\n"

	return str("{\n", strutils.indent_text(text, 1, INDENT), "\n}")


func summarize():
	var summary = ''
	var d1_str = strutils.truncate_string(str(_d1), _max_string_length)
	var d2_str = strutils.truncate_string(str(_d2), _max_string_length)

	if(are_equal()):
		summary = str(d1_str, ' == ', d2_str)
	else:
		var diff_str = differences_to_string()
		var size_compare = str("- ", _do_not_match_clause())
		size_compare += _showing_clause()
		summary = str(d1_str, ' != ', d2_str, "\n", size_compare, "\n", diff_str)
	return summary


func are_equal():
	return _different_keys.size() == 0


func get_different_keys():
	return _different_keys.duplicate()


func  get_total_key_count():
	return


func get_total_different_count():
	return


func get_diff_type():
	return _diff_type