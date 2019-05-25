extends 'res://test/resources/doubler_test_objects/double_me.gd'
var __gut_metadata_ = {
	path='res://test/resources/doubler_test_objects/double_me.gd',
	subpath='',
	stubber=instance_from_id(4048),
	spy=null
}
func get_position():
	if(__gut_metadata_.stubber.should_call_super(self, 'get_position', null)):
		return .get_position()
	else:
		return __gut_metadata_.stubber.get_return(self, 'get_position', null)
func set_value(p_arg0=null):
	if(__gut_metadata_.stubber.should_call_super(self, 'set_value', [p_arg0])):
		return .set_value(p_arg0)
	else:
		return __gut_metadata_.stubber.get_return(self, 'set_value', [p_arg0])
func get_value():
	if(__gut_metadata_.stubber.should_call_super(self, 'get_value', null)):
		return .get_value()
	else:
		return __gut_metadata_.stubber.get_return(self, 'get_value', null)
func _init():
	pass
func has_two_params_one_default(p_arg0=null, p_arg1=null):
	if(__gut_metadata_.stubber.should_call_super(self, 'has_two_params_one_default', [p_arg0, p_arg1])):
		return .has_two_params_one_default(p_arg0, p_arg1)
	else:
		return __gut_metadata_.stubber.get_return(self, 'has_two_params_one_default', [p_arg0, p_arg1])
func has_one_param(p_arg0=null):
	if(__gut_metadata_.stubber.should_call_super(self, 'has_one_param', [p_arg0])):
		return .has_one_param(p_arg0)
	else:
		return __gut_metadata_.stubber.get_return(self, 'has_one_param', [p_arg0])
func has_string_and_array_defaults(p_arg0=null, p_arg1=null):
	if(__gut_metadata_.stubber.should_call_super(self, 'has_string_and_array_defaults', [p_arg0, p_arg1])):
		return .has_string_and_array_defaults(p_arg0, p_arg1)
	else:
		return __gut_metadata_.stubber.get_return(self, 'has_string_and_array_defaults', [p_arg0, p_arg1])
