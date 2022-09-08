# ------------------------------------------------------------------------------
# List of methods that should not be overloaded when they are not defined
# in the class being doubled.  These either break things if they are
# overloaded or do not have a "super" equivalent so we can't just pass
# through.
const BLACKLIST = [
	'has_method',
	'get_script',
	'get',
	'_notification',
	'get_path',
	'_enter_tree',
	'_exit_tree',
	'_process',
	'_draw',
	'_physics_process',
	'_input',
	'_unhandled_input',
	'_unhandled_key_input',
	'_set',
	'_get', # probably
	'emit_signal', # can't handle extra parameters to be sent with signal.
	'draw_mesh', # issue with one parameter, value is `Null((..), (..), (..))``
	'_to_string', # nonexistant function super._to_string
	'_get_minimum_size', # Nonexistent function _get_minimum_size
]


# ------------------------------------------------------------------------------
# Combins the meta for the method with additional information.
# * flag for whether the method is local
# * adds a 'default' property to all parameters that can be easily checked per
#   parameter
# ------------------------------------------------------------------------------
class ParsedMethod:
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


	func is_black_listed():
		return BLACKLIST.find(_meta.name) != -1


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
class ParsedScript:
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
			_methods_by_name[m.name] = ParsedMethod.new(m)

		# This loop will overwrite all entries in _methods_by_name with the local
		# method object so there is only ever one listing for a function with
		# the right "is_local" flag.
		methods = thing.get_script_method_list()
		for m in methods:
			var parsed_method = ParsedMethod.new(m)
			parsed_method.is_local = true
			_methods_by_name[m.name] = parsed_method


	func get_method(name):
		return _methods_by_name[name]


	func is_method_blacklisted(m_name):
		if(_methods_by_name.has(m_name)):
			return _methods_by_name[m_name].is_black_listed()


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
var _file = File.new()


func _get_instance_id(thing):
	var inst_id = null

	if(typeof(thing) == TYPE_STRING):
		if(_file.file_exists(thing)):
			inst_id = load(thing).get_instance_id()
	else:
		inst_id = thing.get_instance_id()

	return inst_id


func parse(thing):
	var inst_id = _get_instance_id(thing)
	var parsed = null

	if(inst_id != null):
		var obj = instance_from_id(inst_id)
		if(scripts.has(inst_id)):
			parsed = scripts[inst_id]
		else:
			if(obj is Resource):
				parsed = ParsedScript.new(obj)
				scripts[inst_id] = parsed

	return parsed


func size():
	return


