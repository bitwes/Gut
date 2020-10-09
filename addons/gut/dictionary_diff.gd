var _d1 = null
var _d2 = null

func _init(d1, d2):
	_d1 = d1
	_d2 = d2


func _do_datatypes_match(got, expected):
	var got_type = typeof(got)
	var expect_type = typeof(expected)
	return !(got_type != expect_type and got != null and expected != null)


func get_different_keys():
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