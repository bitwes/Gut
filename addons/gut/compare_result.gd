var are_equal = null setget set_are_equal, get_are_equal
var summary = null setget set_summary, get_summary

func _block_set(which, val):
	push_error(str('cannot set ', which, ', value [', val, '] ignored.'))

func get_are_equal():
	return are_equal

func set_are_equal(r_eq):
	are_equal = r_eq

func get_summary():
	return summary

func set_summary(smry):
	summary = smry
