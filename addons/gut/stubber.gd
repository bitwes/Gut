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

func set_return(obj, method, value):
    var key = _get_path_from_variant(obj)
    if(_is_instance(obj)):
        key = obj
    if(!returns.has(key)):
        returns[key] = {}
    returns[key][method] = value

func get_return(obj, method):
    var key = _get_path_from_variant(obj)
    if(_is_instance(obj)):
        if(returns.has(obj) and returns[obj].has(method)):
            key = obj
        elif(obj.get('__gut_metadata_')):
            key = obj.__gut_metadata_.path
    if(returns.has(key) and returns[key].has(method)):
        return returns[key][method]
    else:
        return null
