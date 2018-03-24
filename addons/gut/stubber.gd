class MethodStub:
    var parameters = []
    var value = null

    func _init(v, p):
        value = v
        parameters = p

var returns = {}


func _is_instance(obj):
    return typeof(obj) == TYPE_OBJECT and !obj.has_method('new')

func _get_path_from_variant(obj):
    var to_return = null

    match typeof(obj):
        TYPE_STRING:
            to_return = obj
        TYPE_OBJECT:
            if(_is_instance(obj)):
                to_return = obj.get_script().get_path()
            else:
                to_return = obj.resource_path
    return to_return

func set_return(obj, method, value, parameters = null):
    var key = _get_path_from_variant(obj)
    if(_is_instance(obj)):
        key = obj

    if(!returns.has(key)):
        returns[key] = {}
    if(!returns[key].has(method)):
        returns[key][method] = []

    returns[key][method].append(MethodStub.new(value, parameters))

func get_return(obj, method, parameters = null):
    var key = _get_path_from_variant(obj)
    var to_return = null
    if(_is_instance(obj)):
        if(returns.has(obj) and returns[obj].has(method)):
            key = obj
        elif(obj.get('__gut_metadata_')):
            key = obj.__gut_metadata_.path

    if(returns.has(key) and returns[key].has(method)):
        var param_idx = -1
        var null_idx = -1

        for i in range(returns[key][method].size()):
            if(returns[key][method][i].parameters == parameters):
                param_idx = i
            if(returns[key][method][i].parameters == null):
                null_idx = i

        if(param_idx != -1):
            to_return = returns[key][method][param_idx].value
        elif(null_idx != -1):
            to_return = returns[key][method][null_idx].value

    return to_return
