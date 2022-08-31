# ------------------------------------------------------------------------------
# Combins the meta for the method with additional information.
# * flag for whether the method is local
# * adds a 'default' property to all parameters that can be easily checked per
#   parameter
# ------------------------------------------------------------------------------
class MethodParser:
	var _meta = {}
	var _parameters = []
	var is_local = false

	const NO_DEFAULT = '__no__default__'

	func _init(metadata):
		_meta = metadata
		var start_default = _meta.args.size() - _meta.default_args.size()
		for i in range(_meta.args.size()):
			var arg = _meta.args[i]
			# Add a "default" property to the metadata so we don't have to do
			# weird default position math again.
			if(i >= start_default):
				arg['default'] = _meta.default_args[start_default - i]
			else:
				arg['default'] = NO_DEFAULT
			_parameters.append(arg)


	func to_s():
		var s = _meta.name + "("

		for i in range(_meta.args.size()):
			var arg = _meta.args[i]
			if(str(arg.default) != NO_DEFAULT):
				var val = str(arg.default)
				if(val == ''):
					val = '""'
				s += str(arg.name, ' = ', val)
			else:
				s += str(arg.name)

			if(i != _meta.args.size() -1):
				s += ', '

		s += ")"
		return s




# ------------------------------------------------------------------------------
# Doesn't know if a method is local and in super, but not sure if that will
# ever matter.
# ------------------------------------------------------------------------------
class ScriptParser:
	# All methods indexed by name.
	var _methods_by_name = {}

	var _script_path = null
	var script_path = _script_path :
		get: return _script_path
		set(val): return;

	func _init(thing):
		var to_load = thing

		if(!thing is Resource):
			to_load = load(thing.get_script().get_path())

		_script_path = to_load.resource_path
		_parse_methods(to_load)


	func _parse_methods(thing):
		var methods = thing.get_method_list()
		for m in methods:
			var meth = MethodParser.new(m)
			_methods_by_name[m.name] = meth

		# This loop will overwrite all entries in _methods_by_name with the local
		# method object so there is only ever one listing for a function with
		# the right "is_local" flag.
		methods = thing.get_script_method_list()
		for m in methods:
			var meth = MethodParser.new(m)
			meth.is_local = true
			_methods_by_name[m.name] = meth


	func get_method(name):
		return _methods_by_name[name]


	func get_super_method(name):
		var to_return = get_method(name)
		if(to_return.is_local):
			to_return = null

		return to_return

	func get_local_method(name):
		var to_return = get_method(name)
		if(!to_return.is_local):
			to_return = null

		return to_return


	func get_sorted_method_names():
		var keys = _methods_by_name.keys()
		keys.sort()
		return keys


	func get_local_method_names():
		var names = []
		for method in _methods_by_name:
			if(_methods_by_name[method].is_local):
				names.append(method)

		return names


	func get_super_method_names():
		var names = []
		for method in _methods_by_name:
			if(!_methods_by_name[method].is_local):
				names.append(method)

		return names












	# func print_it():
	# 	var names = _methods_by_name.keys()
	# 	names.sort()
	# 	for n in names:
	# 		print(_methods_by_name[n].to_s())

	# func print_super():
	# 	var names = _methods_by_name.keys()
	# 	names.sort()
	# 	for n in names:
	# 		if(!_methods_by_name[n].is_local):
	# 			print(_methods_by_name[n].to_s())

	# func print_local():
	# 	var names = _methods_by_name.keys()
	# 	names.sort()
	# 	for n in names:
	# 		if(_methods_by_name[n].is_local):
	# 			print(_methods_by_name[n].to_s())

# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
var scripts = {}


func _get_path(thing):
	var path = null
	if(thing is Resource):
		path = thing.resource_path
	else:
		path = thing.get_script().get_path()

	return path


func parse(thing):
	var path = _get_path(thing)
	var parsed = null

	if(!scripts.has(path)):
		parsed = ScriptParser.new(thing)
		scripts[path] = parsed
	else:
		parsed = scripts[path]

	return parsed


