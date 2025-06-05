extends Object
var _registry = {}
var _registered_scripts = {}

func _create_reg_entry(base_path, subpath):
	var to_return = {
		"base_path":base_path,
		"subpath":subpath,
		"base_resource":load(base_path),
		"full_path":str("'", base_path, "'", subpath)
	}
	return to_return

func _print_obj_const_map(const_map):
	for key in const_map:
		var val = const_map[key]
		var text = str(key, '::', val)
		if(typeof(val) == TYPE_OBJECT):
			text += str(' ', val.get_class())
			if(val is GDScript):
				text += str(' gn="', val.get_global_name(), '"')
		print('    ', text)



func _register_inners(base_path, obj, prev_inner = ''):
	var const_map = obj.get_script_constant_map()
	var consts = const_map.keys()
	var const_idx = 0

	while(const_idx < consts.size()):
		var key = consts[const_idx]
		var thing = const_map[key]

		if(GutUtils.is_inner_class(thing)):
			var cur_inner = str(prev_inner, ".", key)
			_registry[thing] = _create_reg_entry(base_path, cur_inner)
			_register_inners(base_path, thing, cur_inner)

		const_idx += 1


func register(thing):
	var klass = thing
	if(thing is PackedScene):
		klass = GutUtils.get_scene_script_object(thing)

	if(!is_script_registered(klass)):
		var base_path = klass.resource_path
		_registered_scripts[klass] = true
		_register_inners(base_path, klass)


func get_extends_path(inner_class):
	if(_registry.has(inner_class)):
		return _registry[inner_class].full_path
	else:
		return null


# returns the subpath for the inner class.  This includes the leading "." in
# the path.
func get_subpath(inner_class):
	if(_registry.has(inner_class)):
		return _registry[inner_class].subpath
	else:
		return ''


func get_base_path(inner_class):
	if(_registry.has(inner_class)):
		return _registry[inner_class].base_path


func get_base_resource(inner_class):
	if(_registry.has(inner_class)):
		return _registry[inner_class].base_resource


func do_the_thing_i_want_it_to_do(thing):
	var klass = thing

	if(thing is PackedScene):
		klass = GutUtils.get_scene_script_object(thing)
	elif(GutUtils.is_instance(klass)):
		klass = klass.get_script()

	if(_registry.has(klass)):
		var entry = _registry[klass]
		return str(entry.base_path.get_file(), entry.subpath.replace('.', '/'))
	else:
		if(GutUtils.is_inner_class(klass)):
			return 'unknown inner-class'
		else:
			return klass.resource_path.get_file()


func get_registry_data() -> Dictionary:
	return _registry.duplicate()


func is_script_registered(klass):
	return _registered_scripts.has(klass)


func has(inner_class):
	return _registry.has(inner_class)


func to_s():
	var text = ""
	for key in _registry:
		text += str(key, ": ", do_the_thing_i_want_it_to_do(key), "\n")
	return text
