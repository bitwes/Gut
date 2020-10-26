extends 'res://addons/gut/compare_result.gd'

# func _init(v1, v2, diff_type=DEEP).(v1, v2, diff_type):
# 	# seems we have to call super via decleration for
# 	# some odd reason.  Causes runtime error where
# 	# it says new expects 0 args.
# 	pass

# # -------- comapre_result.gd "interface" ---------------------

# func get_short_summary():
# 	var text = str(_strutils.truncate_string(str(_value_1), 50),
# 		' ',  _compare.get_compare_symbol(are_equal()), ' ',
# 		 _strutils.truncate_string(str(_value_2), 50))
# 	if(!are_equal()):
# 		text += str('  ', get_different_count(), ' of ', get_total_count(), ' indexes do not match.')
# 	return text

# func get_brackets():
# 	return {'open':'[', 'close':']'}

# # -------- comapre_result.gd "interface" ---------------------

