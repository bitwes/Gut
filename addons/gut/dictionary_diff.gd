extends 'res://addons/gut/compare_result.gd'


var _utils = load('res://addons/gut/utils.gd').get_instance()
var _strutils = _utils.Strutils.new()
var _compare = _utils.Comparator.new()

var _d1 = null
var _d2 = null

var _total_key_count = 0

var _diff_type = null

# -------- comapre_result.gd "interface" ---------------------
func set_are_equal(val):
	_block_set('are_equal', val)

func get_are_equal():
	return are_equal()

func set_summary(val):
	_block_set('summary', val)

func get_summary():
	return summarize()

func get_different_count():
	return differences.size()

func  get_total_count():
	return _total_key_count

func get_short_summary():
	var text = str(_strutils.truncate_string(str(_d1), 50),
		' ', _compare.get_compare_symbol(are_equal()), ' ',
		_strutils.truncate_string(str(_d2), 50))
	if(!are_equal()):
		text += str('  ', get_different_count(), ' of ', get_total_count(), ' keys do not match.')
	return text

func get_brackets():
	return {'open':'{', 'close':'}'}

# -------- comapre_result.gd "interface" ---------------------


func _init(d1, d2, diff_type=DEEP):
	_d1 = d1
	_d2 = d2
	_diff_type = diff_type
	_compare.set_should_compare_int_to_float(false)
	differences = _find_differences()


func _find_differences():
	var diff_keys = {}
	var d1_keys = _d1.keys()
	var d2_keys = _d2.keys()

	# Process all the keys in d1
	_total_key_count += d1_keys.size()
	for key in d1_keys:
		if(!_d2.has(key)):
			diff_keys[key] = _compare.simple(_d1[key], _compare.MISSING, 'key')
		else:
			d2_keys.remove(d2_keys.find(key))

			var result = null
			if(_diff_type == DEEP):
				result = _compare.deep(_d1[key], _d2[key])
			else:
				result = _compare.simple(_d1[key], _d2[key])

			#diff_keys[key] = result

			if(result is _utils.DictionaryDiff):
				_total_key_count += result.get_total_count()
				if(!result.are_equal):
					diff_keys[key] = result
			else:
				if(!result.are_equal):
					diff_keys[key] = result

	# Process all the keys in d2 that didn't exist in d1
	_total_key_count += d2_keys.size()
	for i in range(d2_keys.size()):
		diff_keys[d2_keys[i]] = _compare.simple(_compare.MISSING, _d2[d2_keys[i]], 'key')

	return diff_keys


func summarize():
	var summary = ''

	if(are_equal()):
		summary = get_short_summary()
	else:
		var formatter = load('res://addons/gut/diff_formatter.gd').new()
		formatter.set_max_to_display(max_differences)
		summary = formatter.make_it(self)

	return summary


func are_equal():
	return differences.size() == 0


func get_diff_type():
	return _diff_type