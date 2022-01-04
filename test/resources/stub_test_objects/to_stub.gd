# this class is used by test_stubber and represents a doubled object
# which is why we have __gut_metadata_ in here.
var value = 4
var __gut_metadata_ = {
	path='res://test/resources/stub_test_objects/to_stub.gd',
	subpath='',
	stubber=null,
	spy=null,
	from_singleton = "",
}
func get_value():
	return value

func set_value(val):
	value = val
