# ------------------------------------------------------------------------------
# this class is used by test_stubber and represents a doubled object
# which is why we have __gutdbl in here.
# ------------------------------------------------------------------------------
var __gutdbl = load('res://addons/gut/double_tools.gd').new()

func __gutdbl_init_vals():
		__gutdbl.double = self
		__gutdbl.thepath = 'res://test/resources/stub_test_objects/to_stub.gd'
		__gutdbl.subpath = ''
		__gutdbl.stubber = null
		__gutdbl.spy = null
		__gutdbl.gut = null
		__gutdbl.from_singleton = ''
		__gutdbl.is_partial = false


func _init():
		__gutdbl_init_vals()
		__gutdbl.init()
# ------------------------------------------------------------------------------

var value = 4
func get_value():
	return value

func set_value(val):
	value = val



