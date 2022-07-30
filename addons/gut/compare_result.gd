var are_equal = null :
	get:
		return are_equal # TODOConverter40 Copy here content of get_are_equal
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of set_are_equal
var summary = null :
	get:
		return summary # TODOConverter40 Copy here content of get_summary
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of set_summary
var max_differences = 30 :
	get:
		return max_differences # TODOConverter40 Copy here content of get_max_differences
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of set_max_differences
var differences = {} :
	get:
		return differences # TODOConverter40 Copy here content of get_differences
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of set_differences

func _block_set(which, val):
	push_error(str('cannot set ', which, ', value [', val, '] ignored.'))

func _to_string():
	return str(get_summary()) # could be null, gotta str it.

func get_are_equal():
	return are_equal

func set_are_equal(r_eq):
	are_equal = r_eq

func get_summary():
	return summary

func set_summary(smry):
	summary = smry

func get_total_count():
	pass

func get_different_count():
	pass

func get_short_summary():
	return summary

func get_max_differences():
	return max_differences

func set_max_differences(max_diff):
	max_differences = max_diff

func get_differences():
	return differences

func set_differences(diffs):
	_block_set('differences', diffs)

func get_brackets():
	return null

