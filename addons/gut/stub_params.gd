var return_val = null
var stub_target = null
var parameters = null

func _init(target=null):
    stub_target = target

func to_return(val):
    return_val = val
    return self

func when_passed(params):
    parameters = params
    return self
