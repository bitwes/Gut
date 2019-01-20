var _output_dir = null
var _stubber = null
var _double_count = 0
var _use_unique_names = true
var _spy = null
var _lgr = load('res://addons/gut/logger.gd').new()

const PARAM_PREFIX = 'p_'
const NAME = 'name'
const ARGS = 'args'
const FLAGS = 'flags'
const TYPE = 'type'
const DEFAULT_ARGS = 'default_args'
const NOT_SUPPORTED_PARAMS = '__not_supported_param_types_found__'


var supported_types = {
	TYPE_BOOL=null,
	TYPE_INT=null,
	TYPE_REAL=null,
	TYPE_OBJECT=null,
	TYPE_ARRAY=null,

	TYPE_VECTOR2 = 'Vector2',
	TYPE_RECT2 = 'Rect2',

}

# TYPE_NIL = 0 — Variable is of type nil (only applied for null).
	# TYPE_BOOL = 1 — Variable is of type bool.
	# TYPE_INT = 2 — Variable is of type int.
	# TYPE_REAL = 3 — Variable is of type float/real.
# TYPE_STRING = 4 — Variable is of type String.
# TYPE_VECTOR2 = 5 — Variable is of type Vector2.
	# TYPE_RECT2 = 6 — Variable is of type Rect2.
# TYPE_VECTOR3 = 7 — Variable is of type Vector3.
# TYPE_TRANSFORM2D = 8 — Variable is of type Transform2D.
# TYPE_PLANE = 9 — Variable is of type Plane.
# TYPE_QUAT = 10 — Variable is of type Quat.
# TYPE_AABB = 11 — Variable is of type AABB.
# TYPE_BASIS = 12 — Variable is of type Basis.
# TYPE_TRANSFORM = 13 — Variable is of type Transform.
# TYPE_COLOR = 14 — Variable is of type Color.
# TYPE_NODE_PATH = 15 — Variable is of type NodePath.
# TYPE_RID = 16 — Variable is of type RID.
	# TYPE_OBJECT = 17 — Variable is of type Object.
# TYPE_DICTIONARY = 18 — Variable is of type Dictionary.
# TYPE_ARRAY = 19 — Variable is of type Array.
# TYPE_RAW_ARRAY = 20 — Variable is of type PoolByteArray.
# TYPE_INT_ARRAY = 21 — Variable is of type PoolIntArray.
# TYPE_REAL_ARRAY = 22 — Variable is of type PoolRealArray.
# TYPE_STRING_ARRAY = 23 — Variable is of type PoolStringArray.
# TYPE_VECTOR2_ARRAY = 24 — Variable is of type PoolVector2Array.
# TYPE_VECTOR3_ARRAY = 25 — Variable is of type PoolVector3Array.
# TYPE_COLOR_ARRAY = 26 — Variable is of type PoolColorArray.
# TYPE_MAX = 27 — Marker for end of type constants.




# Utility class to hold the local and built in methods seperately.  Add all local
# methods FIRST, then add built ins.
class ScriptMethods:

	var _blacklist = [
		# # from Object
		# 'add_user_signal',
		# 'has_user_signal',
		# 'emit_signal',
		# 'get_signal_connection_list',
		# 'connect',
		# 'disconnect',
		# 'is_connected',
		#
		# # from Node2D
		# 'draw_char',
		#
		# # found during other testing.
		# 'call',
		# '_ready',

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
		'_unhandled_key_input'
	]

	var built_ins = []
	var local_methods = []
	var _method_names = []
	const NAME = 'name'

	func is_blacklisted(method_meta):
		return _blacklist.find(method_meta[NAME]) != -1

	func _add_name_if_does_not_have(method_name):
		var should_add = _method_names.find(method_name) == -1
		if(should_add):
			_method_names.append(method_name)
		return should_add

	func add_built_in_method(method_meta):
		var did_add = _add_name_if_does_not_have(method_meta[NAME])
		if(did_add and !is_blacklisted(method_meta)):
			built_ins.append(method_meta)

	func add_local_method(method_meta):
		var did_add = _add_name_if_does_not_have(method_meta[NAME])
		if(did_add):
			local_methods.append(method_meta)

	func to_s():
		var text = "Locals\n"
		for i in range(local_methods.size()):
			text += str("  ", local_methods[i][NAME], "\n")
		text += "Built-Ins\n"
		for i in range(built_ins.size()):
			text += str("  ", built_ins[i][NAME], "\n")
		return text

# ###############
# Private
# ###############
func _supports_type(type_flag):
	return supported_types.keys().has(type_flag)

func _get_indented_line(indents, text):
	var to_return = ''
	for i in range(indents):
		to_return += "\t"
	return str(to_return, text, "\n")

func _write_file(target_path, dest_path, override_path=null):
	var script_methods = _get_methods(target_path)

	var metadata = _get_stubber_metadata_text(target_path)
	if(override_path):
		metadata = _get_stubber_metadata_text(override_path)

	var f = File.new()
	f.open(dest_path, f.WRITE)
	f.store_string(str("extends '", target_path, "'\n"))
	f.store_string(metadata)
	for i in range(script_methods.local_methods.size()):
		f.store_string(_get_func_text(script_methods.local_methods[i]))
	for i in range(script_methods.built_ins.size()):
		f.store_string(_get_super_func_text(script_methods.built_ins[i]))
	f.close()

func _double_scene_and_script(target_path, dest_path):
	var dir = Directory.new()
	dir.copy(target_path, dest_path)

	var inst = load(target_path).instance()
	var script_path = null
	if(inst.get_script()):
		script_path = inst.get_script().get_path()
	inst.free()

	if(script_path):
		var double_path = _double(script_path, target_path)
		var dq = '"'
		var f = File.new()
		f.open(dest_path, f.READ)
		var source = f.get_as_text()
		f.close()

		source = source.replace(dq + script_path + dq, dq + double_path + dq)

		f.open(dest_path, f.WRITE)
		f.store_string(source)
		f.close()

	return script_path

func _get_methods(target_path):
	var obj = load(target_path).new()
	# any mehtod in the script or super script
	var script_methods = ScriptMethods.new()
	var methods = obj.get_method_list()

	# first pass is for local mehtods only
	for i in range(methods.size()):
		# 65 is a magic number for methods in script, though documentation
		# says 64.  This picks up local overloads of base class methods too.
		if(methods[i][FLAGS] == 65):
			script_methods.add_local_method(methods[i])

	# second pass is for anything not local
	for i in range(methods.size()):
		# 65 is a magic number for methods in script, though documentation
		# says 64.  This picks up local overloads of base class methods too.
		if(methods[i][FLAGS] != 65):
			script_methods.add_built_in_method(methods[i])

	return script_methods

func _get_inst_id_ref_str(inst):
	var ref_str = 'null'
	if(inst):
		ref_str = str('instance_from_id(', inst.get_instance_id(),')')
	return ref_str

func _get_stubber_metadata_text(target_path):
	return "var __gut_metadata_ = {\n" + \
           "\tpath='" + target_path + "',\n" + \
		   "\tstubber=" + _get_inst_id_ref_str(_stubber) + ",\n" + \
		   "\tspy=" + _get_inst_id_ref_str(_spy) + "\n" + \
           "}\n"

func _get_callback_parameters(method_hash):
	var called_with = 'null'
	if(method_hash[ARGS].size() > 0):
		called_with = '['
		for i in range(method_hash[ARGS].size()):
			called_with += str(PARAM_PREFIX, method_hash[ARGS][i][NAME])
			if(i < method_hash[ARGS].size() - 1):
				called_with += ', '
		called_with += ']'
	return called_with

func _get_func_text(method_hash):
	var ftxt = str('func ', method_hash[NAME], '(')
	ftxt += str(_get_arg_text(method_hash), "):\n")

	var called_with = _get_callback_parameters(method_hash)
	if(_spy):
		ftxt += "\t__gut_metadata_.spy.add_call(self, '" + method_hash[NAME] + "', " + called_with + ")\n"

	if(_stubber):
		ftxt += "\treturn __gut_metadata_.stubber.get_return(self, '" + method_hash[NAME] + "', " + called_with + ")\n"
	else:
		ftxt += "\tpass\n"

	return ftxt

func _get_super_call_parameters(method_hash):
	var params = ''
	var all_supported = true

	for i in range(method_hash[ARGS].size()):
		params += PARAM_PREFIX + method_hash[ARGS][i][NAME]
		if(!_supports_type(method_hash[ARGS][i][TYPE])):
			_lgr.warn(str('Unsupported type ', method_hash[ARGS][i][TYPE]))
			all_supported = false

		if(method_hash[ARGS].size() > 1 and i != method_hash[ARGS].size() -1):
			params += ', '
	if(all_supported):
		return params
	else:
		return NOT_SUPPORTED_PARAMS

func _get_super_func_text(method_hash):
	var params = _get_super_call_parameters(method_hash)

	var call_super_text = str(
		"return .",
		method_hash[NAME],
		"(",
		_get_super_call_parameters(method_hash),
		")\n")
	var ftxt = str('func ', method_hash[NAME], '(')
	ftxt += str(_get_arg_text(method_hash), "):\n")
	ftxt += _get_indented_line(1, call_super_text)

	if(params == NOT_SUPPORTED_PARAMS):
		return ''
	else:
		return ftxt

func _get_arg_text(method_meta):
	var text = ''
	var args = method_meta[ARGS]
	var defaults = []

	# fill up the defaults with null defaults for everything that doesn't have
	# a default in the meta data
	for i in range(args.size() - method_meta[DEFAULT_ARGS].size()):
		defaults.append('null')

	# Add meta-data defaults.
	for i in range(method_meta[DEFAULT_ARGS].size()):
		var t = args[defaults.size()]['type']
		if([TYPE_BOOL, TYPE_INT, TYPE_REAL, TYPE_OBJECT, TYPE_ARRAY].has(t)):
			defaults.append(str(method_meta[DEFAULT_ARGS][i]).to_lower())
		elif(t == TYPE_VECTOR2):
			defaults.append(str('Vector2', method_meta[DEFAULT_ARGS][i]))
		elif(t == TYPE_RECT2):
			defaults.append(str('Rect2', method_meta[DEFAULT_ARGS][i]))
		else:
			_lgr.warn(str(
				'Unsupported default parameter type:  ',method_meta[NAME], ' ', args[defaults.size()][NAME], ' ', t, ' = ', method_meta[DEFAULT_ARGS][i]))
			defaults.append(str('dunno=',t))

	# construct the string of parameters
	for i in range(args.size()):
		text += str(PARAM_PREFIX, args[i][NAME], ' = ', defaults[i])
		if(i != args.size() -1):
			text += ', '
	return text

func _get_temp_path(path):
	var file_name = path.get_file()
	if(_use_unique_names):
		file_name = file_name.get_basename() + \
		            str('__dbl', _double_count, '__.') + file_name.get_extension()
	var to_return = _output_dir.plus_file(file_name)
	return to_return

func _double(obj, override_path=null):
	var temp_path = _get_temp_path(obj)
	_write_file(obj, temp_path, override_path)
	_double_count += 1
	return temp_path

# ###############
# Public
# ###############
func get_output_dir():
	return _output_dir

func set_output_dir(output_dir):
	_output_dir = output_dir
	var d = Directory.new()
	d.make_dir_recursive(output_dir)

func get_spy():
	return _spy

func set_spy(spy):
	_spy = spy

func get_stubber():
	return _stubber

func set_stubber(stubber):
	_stubber = stubber

func double_scene(path):
	var temp_path = _get_temp_path(path)
	_double_scene_and_script(path, temp_path)
	return load(temp_path)

func double(path):
	return load(_double(path))

func clear_output_directory():
	var did = false
	if(_output_dir.find('user://') == 0):
		var d = Directory.new()
		var result = d.open(_output_dir)
		# BIG GOTCHA HERE.  If it cannot open the dir w/ erro 31, then the
		# directory becomes res:// and things go on normally and gut clears out
		# out res:// which is SUPER BAD.
		if(result == OK):
			d.list_dir_begin(true)
			var files = []
			var f = d.get_next()
			while(f != ''):
				d.remove(f)
				f = d.get_next()
				did = true
	return did

func delete_output_directory():
	var did = clear_output_directory()
	if(did):
		var d = Directory.new()
		d.remove(_output_dir)

func set_use_unique_names(should):
	_use_unique_names = should

func get_logger():
	return _lgr

func set_logger(logger):
	_lgr = logger
