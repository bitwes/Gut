# ------------------------------------------------------------------------------
# this class is used by test_stubber and represents a doubled object.
# This top section must be kept in line with script_template.txt
# ------------------------------------------------------------------------------
var __gutdbl_values = {
	thepath = 'res://test/resources/stub_test_objects/to_stub.gd',
	subpath = '',
	stubber = -1,
	spy = -1,
	gut = -1,
	singleton_name = '',
	singleton = -1,
	is_partial = false,
}
var __gutdbl = load('res://addons/gut/double_tools.gd').new(self)

# Here so other things can check for a method to know if this is a double.
func __gutdbl_check_method__():
	pass


# Cleanup called by GUT after tests have finished.  Important for RefCounted
# objects.  Nodes are freed, and won't have this method called on them.
func __gutdbl_done():
	__gutdbl = null
	__gutdbl_values.clear()

# ------------------------------------------------------------------------------
# These are some methods and vars to be used in tests.
# ------------------------------------------------------------------------------
var value = 4
func get_value():
	return value

func set_value(val):
	value = val


func default_value_method(p1='a'):
	pass
