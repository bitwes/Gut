# This class will generate method decleration lines based on method meta
# data.  It will create defaults that match the method data.
#
# --------------------
# function meta data
# --------------------
# name:
# flags:
# args: [{
# 	(class_name:),
# 	(hint:0),
# 	(hint_string:),
# 	(name:),
# 	(type:4),
# 	(usage:7)
# }]
# default_args []






var _lgr = load('res://addons/gut/logger.gd').new()
const NOT_SUPPORTED_PARAMS = '__not_supported_param_types_found__'

const NAME = 'name'
const ARGS = 'args'
const FLAGS = 'flags'
const TYPE = 'type'
const DEFAULT_ARGS = 'default_args'

const PARAM_PREFIX = 'p_'


func _get_arg_text(method_meta):
	var text = ''
	var args = method_meta[ARGS]
	var defaults = []

	# fill up the defaults with null defaults for everything that doesn't have
	# a default in the meta data
	for i in range(args.size() - method_meta.default_args.size()):
		defaults.append('null')

	# Add meta-data defaults.
	for i in range(method_meta.default_args.size()):
		var t = args[defaults.size()]['type']
		if(_is_type_supported(t)):
			defaults.append(str(_supported_types[t], str(method_meta.default_args[i]).to_lower()))
		else:
			_lgr.warn(str(
				'Unsupported default parameter type:  ',method_meta[NAME], ' ', args[defaults.size()][NAME], ' ', t, ' = ', method_meta[DEFAULT_ARGS][i]))
			defaults.append(str('unsupported=',t))


		# if([TYPE_BOOL, TYPE_INT, TYPE_REAL, TYPE_OBJECT, TYPE_ARRAY].has(t)):
		# 	defaults.append(str(method_meta.default_args[i]).to_lower())
		# elif(t == TYPE_VECTOR2):
		# 	defaults.append(str('Vector2', method_meta[DEFAULT_ARGS][i]))
		# elif(t == TYPE_RECT2):
		# 	defaults.append(str('Rect2', method_meta[DEFAULT_ARGS][i]))
		# else:
		# 	_lgr.warn(str(
		# 		'Unsupported default parameter type:  ',method_meta[NAME], ' ', args[defaults.size()][NAME], ' ', t, ' = ', method_meta[DEFAULT_ARGS][i]))
		# 	defaults.append(str('unsupported=',t))

	# construct the string of parameters
	for i in range(args.size()):
		text += str(PARAM_PREFIX, args[i].name, '=', defaults[i])
		if(i != args.size() -1):
			text += ', '
	return text

func get_decleration(meta):
	return str('func ', meta.name, '(', _get_arg_text(meta), '):')



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
var _supported_types = []

func _init():
	for i in range(TYPE_MAX):
		_supported_types.append(null)

	_supported_types[TYPE_BOOL] = ''
	_supported_types[TYPE_INT] = ''
	_supported_types[TYPE_REAL] = ''
	_supported_types[TYPE_OBJECT] = ''
	_supported_types[TYPE_ARRAY] = ''

	_supported_types[TYPE_VECTOR2] = 'Vector2'
	_supported_types[TYPE_RECT2] = 'Rect2'

# ###############
# Private
# ###############
func _is_type_supported(type_flag):
	return _supported_types[type_flag] != null


# func _get_methods(target_path):
# 	var obj = load(target_path).new()
# 	# any mehtod in the script or super script
# 	var script_methods = ScriptMethods.new()
# 	var methods = obj.get_method_list()
#
# 	# first pass is for local mehtods only
# 	for i in range(methods.size()):
# 		# 65 is a magic number for methods in script, though documentation
# 		# says 64.  This picks up local overloads of base class methods too.
# 		if(methods[i][FLAGS] == 65):
# 			script_methods.add_local_method(methods[i])
#
# 	# second pass is for anything not local
# 	for i in range(methods.size()):
# 		# 65 is a magic number for methods in script, though documentation
# 		# says 64.  This picks up local overloads of base class methods too.
# 		if(methods[i][FLAGS] != 65):
# 			script_methods.add_built_in_method(methods[i])
#
# 	return script_methods



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

# func _get_func_text(method_hash):
# 	var ftxt = str('func ', method_hash[NAME], '(')
# 	ftxt += str(_get_arg_text(method_hash), "):\n")
#
# 	var called_with = _get_callback_parameters(method_hash)
# 	if(_spy):
# 		ftxt += "\t__gut_metadata_.spy.add_call(self, '" + method_hash[NAME] + "', " + called_with + ")\n"
#
# 	if(_stubber):
# 		ftxt += "\treturn __gut_metadata_.stubber.get_return(self, '" + method_hash[NAME] + "', " + called_with + ")\n"
# 	else:
# 		ftxt += "\tpass\n"
#
# 	return ftxt

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


func get_logger():
	return _lgr

func set_logger(logger):
	_lgr = logger
