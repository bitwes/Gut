{extends}

var __gut_metadata_ = {
	path = '{path}',
	subpath = '{subpath}',
	stubber = __gut_instance_from_id({stubber_id}),
	spy = __gut_instance_from_id({spy_id}),
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

var __gut_utils_ = load('res://addons/gut/utils.gd').new()

func __gut_spy(method_name, called_with):
	if(__gut_metadata_.spy != null):
		__gut_metadata_.spy.add_call(self, method_name, called_with)

func __gut_get_stubbed_return(method_name, called_with):
	if(__gut_metadata_.stubber != null):
		return __gut_metadata_.stubber.get_return(self, method_name, called_with)
	else:
		return null

# ------------------------------------------------------------------------------
# Methods start here
# ------------------------------------------------------------------------------
