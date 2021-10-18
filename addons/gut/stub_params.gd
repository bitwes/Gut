var return_val = null
var stub_target = null
var target_subpath = null
# the parameter values to match method call on.
var parameters = null
var stub_method = null
var call_super = false
var parameter_count = -1
var parameter_defaults = null

const NOT_SET = '|_1_this_is_not_set_1_|'

func _init(target=null, method=null, subpath=null):
	stub_target = target
	stub_method = method
	target_subpath = subpath

func to_return(val):
	return_val = val
	call_super = false
	return self

func to_do_nothing():
	return to_return(null)

func to_call_super():
	call_super = true
	return self

func when_passed(p1=NOT_SET,p2=NOT_SET,p3=NOT_SET,p4=NOT_SET,p5=NOT_SET,p6=NOT_SET,p7=NOT_SET,p8=NOT_SET,p9=NOT_SET,p10=NOT_SET):
	parameters = [p1,p2,p3,p4,p5,p6,p7,p8,p9,p10]
	var idx = 0
	while(idx < parameters.size()):
		if(str(parameters[idx]) == NOT_SET):
			parameters.remove(idx)
		else:
			idx += 1
	return self

func param_count(x):
	parameter_count = x
	return self

func param_defaults(values):
	parameter_count = values.size()
	parameter_defaults = values
	return self

func has_param_override():
	return parameter_count != -1

func to_s():
	var base_string = str(stub_target, '[', target_subpath, '].', stub_method)
	if(has_param_override()):
		base_string += str(' (params ', parameter_count, ' def=', parameter_defaults, ') ')

	if(call_super):
		base_string += " to call SUPER"
	else:
		base_string += str(' with params (', parameters, ') returns ', return_val)
	return base_string
