var _a1 = null
var _a2 =  null
var _size_diff_threshold = 30
var strutils = load('res://addons/gut/utils.gd').get_instance().Strutils.new()
var _max_string_length = 100

var _different_indexes = null

func _init(a1 = null, a2=null):
	_a1 = a1
	_a2 = a2

func _do_datatypes_match(got, expected):
	var got_type = typeof(got)
	var expect_type = typeof(expected)
	return !(got_type != expect_type and got != null and expected != null)

func _populate_diff_indexes():
	_different_indexes = []
	for i in range(_a1.size()):
		if(i < _a2.size()):
			if(!_do_datatypes_match(_a1[i], _a2[i]) or _a1[i] != _a2[i]):
					_different_indexes.append(i)
		else:
			_different_indexes.append(i)

	if(_a1.size() < _a2.size()):
		for i in range(_a1.size(), _a2.size()):
			_different_indexes.append(i)

func _make_diff_description(max_differences=_size_diff_threshold):
	var to_return = ''
	var limit = min(_different_indexes.size(), max_differences)

	for i in range(limit):
		var idx = _different_indexes[i]

		var a1_str = '[missing]'
		if(idx < _a1.size()):
			a1_str = strutils.type2str(_a1[idx])

		var a2_str = '[missing]'
		if(idx < _a2.size()):
			a2_str = strutils.type2str(_a2[idx])

		to_return += str('  ', idx, ': ', a1_str, ' != ', a2_str, "\n")

	if(_different_indexes.size() > limit):
		to_return += str(limit, ' of  ', _different_indexes.size(), ' differences shown.')

	return to_return

func get_a1():
	return _a1

func set_a1(a1):
	_a1 = a1

func get_a2():
	return _a2

func set_a2(a2):
	_a2 = a2

func are_equal():
	return _a1 == _a2

func get_different_indexes():
	_populate_diff_indexes()
	return _different_indexes

# ------------------------------------------------------------------------------
# Generates a summary of the differences in two arrays.
# * When arrays and diff is small enough then  both arrays  and all differences
#   are listed.
# * Each array is trunated to 100 chars
# * Up to _size_diff_threshold different indexes will be listed.
# * If the difference in sizes is > _size_diff_threshold then the arrays are
# ------------------------------------------------------------------------------
func summarize():
	_populate_diff_indexes()
	var a1_str = strutils.truncate_string(str(_a1), _max_string_length)
	var a2_str = strutils.truncate_string(str(_a2), _max_string_length)
	var diff_str = _make_diff_description()

	if(abs(_a1.size() - _a2.size()) > _size_diff_threshold):
		return str(a1_str, ' != ', a2_str, "\n",  'Arrays sizes are too different to diff:  a1(', _a1.size(), ') a2(', _a2.size(), ')')

	return str(a1_str, ' != ', a2_str, ".\nDifferent indexes = \n", diff_str)