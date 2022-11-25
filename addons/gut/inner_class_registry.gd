var _registry = {}


func _register_inners(base_path, obj, prev_inner = ''):
	var const_map = obj.get_script_constant_map()
	var consts = const_map.keys()
	var const_idx = 0

	while(const_idx < consts.size()):
		var key = consts[const_idx]
		var thing = const_map[key]

		if(typeof(thing) == TYPE_OBJECT):
			var cur_inner = str(prev_inner, ".", key)
			_registry[thing] = str("'", base_path, "'", cur_inner)
			_register_inners(base_path, thing, cur_inner)

		const_idx += 1


func add_inner_classes(base_script):
	var base_path = base_script.resource_path
	_register_inners(base_path, base_script)


func get_extends_path(inner_class):
	if(_registry.has(inner_class)):
		return _registry[inner_class]
	else:
		return null

func has(inner_class):
	return _registry.has(inner_class)

func to_s():
	var text = ""
	for key in _registry:
		text += str(key, ": ", _registry[key], "\n")
	return text