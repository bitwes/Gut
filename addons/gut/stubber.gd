var returns = {}


# need to be able to look up based on path and instance
# when path found, return the path
# if instance, return instance
# if instance not found return path
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

func set_return(obj, method, value):
    var key = _get_path_from_variant(obj)
    if(_is_instance(obj)):
        key = obj
    if(!returns.has(key)):
        returns[key] = {}
    returns[key][method] = value

func get_return(obj, method):
    var key = _get_path_from_variant(obj)
    if(_is_instance(obj) and returns.has(obj)):
        key = obj
    if(returns.has(key) and returns[key].has(method)):
        return returns[key][method]
    else:
        return null
