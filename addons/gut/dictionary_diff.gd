var _d1 = null
var _d2 = null
var _size_diff_threshold = 30
var strutils = load('res://addons/gut/utils.gd').get_instance().Strutils.new()
var _max_string_length = 100
var _different_keys = null


func _init(d1, d2):
	_d1 = d1
	_d2 = d2
	_different_keys = _generate_different_keys()


func _do_datatypes_match(got, expected):
	var got_type = typeof(got)
	var expect_type = typeof(expected)
	return !(got_type != expect_type and got != null and expected != null)


func _make_diff_description(max_differences=_size_diff_threshold):
	var limit = min(_different_keys.size(), max_differences)

	var to_return = str(_different_keys.size(), ' different keys')
	if(_different_keys.size() > limit):
		to_return += str(" (", limit, ' shown)')
	to_return += ":\n"

	for key in _different_keys:
		var d1_str = '<key missing>'
		if(_d1.has(key)):
			d1_str = strutils.type2str(_d1[key])

		var d2_str = '<key missing>'
		if(_d2.has(key)):
			d2_str = strutils.type2str(_d2[key])

		to_return += str('  ', strutils.type2str(key), ': ', d1_str, ' != ', d2_str, "\n")

	to_return = to_return.substr(0, to_return.length() -1)

	return to_return


func are_equal():
	return _different_keys.size() == 0


func get_different_keys():
	return _different_keys.duplicate()


func _generate_different_keys():
	var diff_keys = []
	var d1_keys = _d1.keys()
	d1_keys.sort()
	var d2_keys = _d2.keys()
	d2_keys.sort()

	for key in d1_keys:
		if(!_d2.has(key)):
			diff_keys.append(key)
		else:
			if(!_do_datatypes_match(_d1[key], _d2[key]) or _d1[key] != _d2[key]):
				diff_keys.append(key)
			d2_keys.remove(d2_keys.find(key))

	for i in range(d2_keys.size()):
		diff_keys.append(d2_keys[i])

	return diff_keys


func summarize():
	var summary = ''
	var d1_str = strutils.truncate_string(str(_d1), _max_string_length)
	var d2_str = strutils.truncate_string(str(_d2), _max_string_length)

	if(_d1 == _d2):
		summary = str(d1_str, ' == ', d2_str)
	else:
		if(abs(_d1.size() - _d2.size()) > _size_diff_threshold):
			summary =  str(d1_str, ' != ', d2_str, "\n",  \
				'Dictionary sizes are too different to compare:  dictionary_1.size = ',\
				_d1.keys().size(), ', dictionary_2.size = ', _d2.keys().size())
		else:
			var diff_str = _make_diff_description()
			var size_compare = str("- Dictionaris are the same size:  ", _d1.size(), ".")
			if(_d1.size() != _d2.size()):
				size_compare = str("- Dictionary sizes are different:  ", _d1.size(), "/", _d2.size())
			summary = str(d1_str, ' != ', d2_str, "\n", size_compare, "\n- ", diff_str)

	return summary
