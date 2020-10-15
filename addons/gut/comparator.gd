var _utils = load('res://addons/gut/utils.gd').get_instance()
var _strutils = _utils.Strutils.new()


func _format_value(value):
	return _strutils.truncate_string(_strutils.type2str(value), 100)


func _cannot_comapre_text(v1, v2):
	return str('Cannot compare ', _strutils.types[typeof(v1)], ' with ',
		_strutils.types[typeof(v2)], '.')


func simple(v1, v2):
	var result = _utils.CompareResult.new()
	var cmp_str = null
	var extra = ''

	if(_utils.are_datatypes_same(v1, v2)):
		result.are_equal = v1 == v2
		if(typeof(v1) == TYPE_DICTIONARY):
			if(result.are_equal):
				extra = '.  Values point to the same dictionary.  '
			else:
				extra = '.  Values point to different dictionaries.  '
			extra += 'Dictionaries are compared by reference.'

		if(result.are_equal):
			cmp_str = '=='
		else:
			cmp_str = '!='
	else:
		cmp_str = '!='
		result.are_equal = false
		extra = str('.  ', _cannot_comapre_text(v1, v2))

	result.summary = str(_format_value(v2), ' ', cmp_str, ' ', _format_value(v1), extra)

	return result

