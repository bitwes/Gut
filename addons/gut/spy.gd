# {
#   instance_id_or_path1:{
#       method1:[ [p1, p2], [p1, p2] ],
#       method2:[ [p1, p2], [p1, p2] ]
#   },
#   instance_id_or_path1:{
#       method1:[ [p1, p2], [p1, p2] ],
#       method2:[ [p1, p2], [p1, p2] ]
#   },
# }
var _calls = {}

func add_call(variant, method_name, parameters=null):
	if(!_calls.has(variant)):
		_calls[variant] = {}

	if(!_calls[variant].has(method_name)):
		_calls[variant][method_name] = []

	_calls[variant][method_name].append(parameters)

func was_called(variant, method_name, parameters=null):
	var to_return = false
	if(_calls.has(variant) and _calls[variant][method_name]):
		if(parameters):
			to_return =  _calls[variant][method_name].has(parameters)
		else:
			to_return = true
	return to_return

func call_count(instance, method_name, parameters=null):
	var to_return = 0

	if(was_called(instance, method_name)):
		if(parameters):
			for i in range(_calls[instance][method_name].size()):
				if(_calls[instance][method_name][i] == parameters):
					to_return += 1
		else:
			to_return = _calls[instance][method_name].size()
	return to_return
