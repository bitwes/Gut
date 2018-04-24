var return_val = null
var stub_target = null
var parameters = null
var stub_method = null
const NOT_SET = '|_1_this_is_not_set_1_|'

func _init(target=null, method=null):
	stub_target = target
	stub_method = method

func to_return(val):
	return_val = val
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
