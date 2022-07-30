extends Node

# -------------------------------------------------
var no_setget = 1

# -------------------------------------------------
var has_setter = 2 :
	get:
		return has_setter # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of set_has_setter
func set_has_setter(val):
	has_setter = val

# -------------------------------------------------
var has_getter = 3 :
	get:
		return has_getter # TODOConverter40 Copy here content of get_has_getter 
	set(mod_value):
		mod_value  # TODOConverter40  Non existent set function
func get_has_getter():
	return has_getter

# -------------------------------------------------
var has_both = 4 :
	get:
		return has_both # TODOConverter40 Copy here content of get_has_both
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of set_has_both
func get_has_both():
	return has_both

func set_has_both(val):
	has_both = val

# -------------------------------------------------
var non_default_both = 5 :
	get:
		return non_default_both # TODOConverter40 Copy here content of __get_default_both
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of __set_default_both
func __set_default_both(val):
	non_default_both = val

func __get_default_both():
	return non_default_both

# -------------------------------------------------
var non_default_setter = 6 :
	get:
		return non_default_setter # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of __set_non_default_setter
func __set_non_default_setter(val):
	non_default_setter = val

# -------------------------------------------------
var non_default_getter = 7 :
	get:
		return non_default_getter # TODOConverter40 Copy here content of __get_non_default_getter 
	set(mod_value):
		mod_value  # TODOConverter40  Non existent set function
func __get_non_default_getter():
	return non_default_getter

# -------------------------------------------------
# dnu = "does not use"
var has_both_dnu_setget = 8
func get_has_both_dnu_setget():
	return has_both_dnu_setget

func set_has_both_dnu_setget(val):
	has_both_dnu_setget = val

# -------------------------------------------------
var typed_setter = 9 :
	get:
		return typed_setter # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of set_typed_setter
func set_typed_setter(val: int) -> void:
	typed_setter = val

