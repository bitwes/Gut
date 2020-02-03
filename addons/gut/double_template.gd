{extends}

func __gut_instance_from_id(thing_id):
	if(thing_id ==  -1):
		return null
	else:
		return instance_from_id(thing_id)

var __gut_metadata_ = {
	path = '{path}',
	subpath = '{subpath}',
	stubber = null, #__gut_instance_from_id({stubber_id}),
	spy = null #__gut_instance_from_id({spy_id}),
}

var __gut_utils_ = load('res://addons/gut/utils.gd').new()

func __gut_run_method(method_name, called_with):
	if(__gut_metadata_.spy != null):
		__gut_metadata_.spy.add_call(self, method_name, called_with)

	if(__gut_metadata_.stubber != null):
		if(__gut_metadata_.stubber.should_call_super(self, method_name, called_with)):
			return .callv(method_name, called_with)
		else:
			return __gut_metadata_.stubber.get_return(self, method_name, called_with)


# Other stuff goes here.
