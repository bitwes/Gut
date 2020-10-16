const MISSING_KEY = '<key missing>'
const INDENT = '    '
enum {
	DEEP,
	SHALLOW
}

var _utils = load('res://addons/gut/utils.gd').get_instance()
var strutils = _utils.Strutils.new()
var compare = _utils.Compare.new()

var _d1 = null
var _d2 = null

var _size_diff_threshold = 30
var _max_string_length = 100
var _different_keys = null
var _num_shown = 0

var _total_key_count = 0
var _total_different = 0

var _diff_type = SHALLOW

# -------- comapre_result.gd "interface" ---------------------
var are_equal = null setget ,are_equal
var different_indexes = null
var summary = null setget ,summarize
var different_keys = null setget ,get_different_keys

func _init(d1, d2, diff_type=DEEP):
	_d1 = d1
	_d2 = d2
	_diff_type = diff_type
	compare._compare_float_to_int = false
	_different_keys = _find_different_keys()



func _do_datatypes_match(got, expected):
	return !(typeof(got) != typeof(expected) and got != null and expected != null)


func _find_different_keys():
	var diff_keys = {}
	var d1_keys = _d1.keys()
	var d2_keys = _d2.keys()

	# Process all the keys in d1
	_total_key_count += d1_keys.size()
	for key in d1_keys:
		if(!_d2.has(key)):
			diff_keys[key] = str(strutils.type2str(_d1[key]), ' != ', MISSING_KEY)
			_total_different += 1
		else:
			d2_keys.remove(d2_keys.find(key))

			var result = null
			if(_diff_type == DEEP):
				result = compare.deep(_d1[key], _d2[key])
			else:
				result = compare.simple(_d1[key], _d2[key])

			if(result.diff_object is _utils.DictionaryDiff):
				_total_key_count += result.diff_object.get_total_key_count()
				_total_different += result.diff_object.get_total_different_count()
				if(!result.are_equal):
					_total_different += 1
					# access directly b/c get_different_keys() calls duplicate()
					diff_keys[key] = result.diff_object._different_keys
			else:
				if(!result.are_equal):
					_total_different += 1
					diff_keys[key] = result.summary

	# Process all the keys in d2 that didn't exist in d1
	_total_key_count += d2_keys.size()
	_total_different += d2_keys.size()
	for i in range(d2_keys.size()):
		diff_keys[d2_keys[i]] = str(MISSING_KEY, ' != ', compare.format_value(_d2[d2_keys[i]]))

	return diff_keys

func _dictionary_to_s(d, depth):
	var to_return = ''
	var keys = d.keys()
	keys.sort()
	var idx = 0
	while(idx < keys.size() and _num_shown < _size_diff_threshold):
		var key = keys[idx]
		if(typeof(d[key]) == TYPE_DICTIONARY):
			var open = str(strutils.type2str(key), ':', "{\n")
			var sub_desc = _dictionary_to_s(d[key], depth + 1)
			if(_total_key_count > _size_diff_threshold):
				sub_desc += "...\n"
			var close = "}\n"
			to_return +=  str(open, strutils.indent_text(sub_desc, depth + 1, INDENT), close)
		else:
			to_return += str(strutils.type2str(key), ":  ", d[key], "\n")
		_num_shown += 1
		idx += 1

	return to_return


func _make_diff_description():
	_num_shown = 0
	var text = _dictionary_to_s(_different_keys, 0)
	if(_total_key_count > _size_diff_threshold):
		text += "...\n"

	return str("{\n", strutils.indent_text(text, 1, INDENT), "}")


func summarize():
	var summary = ''
	var d1_str = strutils.truncate_string(str(_d1), _max_string_length)
	var d2_str = strutils.truncate_string(str(_d2), _max_string_length)

	if(are_equal()):
		summary = str(d1_str, ' == ', d2_str)
	else:
		if(abs(_d1.size() - _d2.size()) > _size_diff_threshold):
			summary =  str(d1_str, ' != ', d2_str, "\n",  \
				'Dictionary sizes are too different to compare:  dictionary_1.size = ',\
				_d1.keys().size(), ', dictionary_2.size = ', _d2.keys().size())
		else:
			var diff_str = _make_diff_description()
			var size_compare = str("- ", _total_different, ' of ', _total_key_count, ' keys do not match.')
			if(_total_different > _size_diff_threshold):
				size_compare += str("  Showing ", _size_diff_threshold, " of ", _total_different, " differences.")
			summary = str(d1_str, ' != ', d2_str, "\n", size_compare, "\n", diff_str)
	return summary


func are_equal():
	return _different_keys.size() == 0


func get_different_keys():
	return _different_keys.duplicate()


func  get_total_key_count():
	return _total_key_count


func get_total_different_count():
	return _total_different


func get_diff_type():
	return _diff_type