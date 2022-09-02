# ##############################################################################
# Start Script
# ##############################################################################
extends 'res://test/resources/doubler_test_objects/double_extends_node2d.gd'




# ------------------------------------------------------------------------------
# GUT Double properties and methods
# ------------------------------------------------------------------------------
var __gut_metadata_ = {
	path = 'res://test/resources/doubler_test_objects/double_extends_node2d.gd',
	subpath = '',
	stubber = __gut_instance_from_id(-9223372002713139859),
	spy = __gut_instance_from_id(-1),
	gut = __gut_instance_from_id(30635197677),
	from_singleton = '',
	is_partial = false
}

func __gut_instance_from_id(inst_id):
	if(inst_id ==  -1):
		return null
	else:
		return instance_from_id(inst_id)

func __gut_should_call_super(method_name, called_with):
	if(__gut_metadata_.stubber != null):
		return __gut_metadata_.stubber.should_call_super(self, method_name, called_with)
	else:
		return false

var __gut_utils_ = load('res://addons/gut/utils.gd').get_instance()

func __gut_spy(method_name, called_with):
	if(__gut_metadata_.spy != null):
		__gut_metadata_.spy.add_call(self, method_name, called_with)

func __gut_get_stubbed_return(method_name, called_with):
	if(__gut_metadata_.stubber != null):
		return __gut_metadata_.stubber.get_return(self, method_name, called_with)
	else:
		return null

func __gut_default_val(method_name, p_index):
	if(__gut_metadata_.stubber != null):
		return __gut_metadata_.stubber.get_default_value(self, method_name, p_index)
	else:
		return null

func __gut_init():
	if(__gut_metadata_.gut != null):
		__gut_metadata_.gut.get_autofree().add_free(self)

# ------------------------------------------------------------------------------
# Methods start here
# ------------------------------------------------------------------------------
func get_value():
	__gut_spy('get_value', [])
	if(__gut_should_call_super('get_value', [])):
		return await super.get_value()
	else:
		return __gut_get_stubbed_return('get_value', [])

func set_value(p_val=__gut_default_val("set_value",0)):
	__gut_spy('set_value', [p_val])
	if(__gut_should_call_super('set_value', [p_val])):
		return await super.set_value(p_val)
	else:
		return __gut_get_stubbed_return('set_value', [p_val])

func has_one_param(p_one=__gut_default_val("has_one_param",0)):
	__gut_spy('has_one_param', [p_one])
	if(__gut_should_call_super('has_one_param', [p_one])):
		return await super.has_one_param(p_one)
	else:
		return __gut_get_stubbed_return('has_one_param', [p_one])

func has_two_params_one_default(p_one=__gut_default_val("has_two_params_one_default",0), p_two=null):
	__gut_spy('has_two_params_one_default', [p_one, p_two])
	if(__gut_should_call_super('has_two_params_one_default', [p_one, p_two])):
		return await super.has_two_params_one_default(p_one, p_two)
	else:
		return __gut_get_stubbed_return('has_two_params_one_default', [p_one, p_two])

func get_position():
	__gut_spy('get_position', [])
	if(__gut_should_call_super('get_position', [])):
		return await super.get_position()
	else:
		return __gut_get_stubbed_return('get_position', [])
