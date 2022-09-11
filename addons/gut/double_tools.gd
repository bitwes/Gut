var thepath = ''
var subpath = ''
var stubber = null
var spy = null
var gut = null
var from_singleton = null
var is_partial = null
var double = null

func from_id(inst_id):
	if(inst_id ==  -1):
		return null
	else:
		return instance_from_id(inst_id)

func should_call_super(method_name, called_with):
	if(stubber != null):
		return stubber.should_call_super(double, method_name, called_with)
	else:
		return false

func spy_on(method_name, called_with):
	if(spy != null):
		spy.add_call(double, method_name, called_with)

func get_stubbed_return(method_name, called_with):
	if(stubber != null):
		return stubber.get_return(double, method_name, called_with)
	else:
		return null

func default_val(method_name, p_index):
	if(stubber != null):
		return stubber.get_default_value(double, method_name, p_index)
	else:
		return null

func init():
	if(gut != null):
		gut.get_autofree().add_free(double)

