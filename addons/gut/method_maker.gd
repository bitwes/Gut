# This class will generate method declaration lines based on method meta
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

var _utils = load('res://addons/gut/utils.gd').new()
var _lgr = _utils.get_logger()
const PARAM_PREFIX = 'p_'

# ------------------------------------------------------
# _supported_defaults
#
# This array contains all the data types that are supported for default values.
# If a value is supported it will contain either an empty string or a prefix
# that should be used when setting the parameter default value.
# For example int, real, bool do not need anything func(p1=1, p2=2.2, p3=false)
# but things like Vectors and Colors do since only the parameters to create a
# new Vector or Color are included in the metadata.
# ------------------------------------------------------
	# TYPE_NIL = 0 — Variable is of type nil (only applied for null).
	# TYPE_BOOL = 1 — Variable is of type bool.
	# TYPE_INT = 2 — Variable is of type int.
	# TYPE_REAL = 3 — Variable is of type float/real.
	# TYPE_STRING = 4 — Variable is of type String.
	# TYPE_VECTOR2 = 5 — Variable is of type Vector2.
	# TYPE_RECT2 = 6 — Variable is of type Rect2.
	# TYPE_VECTOR3 = 7 — Variable is of type Vector3.
	# TYPE_COLOR = 14 — Variable is of type Color.
	# TYPE_OBJECT = 17 — Variable is of type Object.
	# TYPE_DICTIONARY = 18 — Variable is of type Dictionary.
	# TYPE_ARRAY = 19 — Variable is of type Array.
	# TYPE_VECTOR2_ARRAY = 24 — Variable is of type PoolVector2Array.



# TYPE_TRANSFORM2D = 8 — Variable is of type Transform2D.
# TYPE_PLANE = 9 — Variable is of type Plane.
# TYPE_QUAT = 10 — Variable is of type Quat.
# TYPE_AABB = 11 — Variable is of type AABB.
# TYPE_BASIS = 12 — Variable is of type Basis.
# TYPE_TRANSFORM = 13 — Variable is of type Transform.
# TYPE_NODE_PATH = 15 — Variable is of type NodePath.
# TYPE_RID = 16 — Variable is of type RID.
# TYPE_RAW_ARRAY = 20 — Variable is of type PoolByteArray.
# TYPE_INT_ARRAY = 21 — Variable is of type PoolIntArray.
# TYPE_REAL_ARRAY = 22 — Variable is of type PoolRealArray.
# TYPE_STRING_ARRAY = 23 — Variable is of type PoolStringArray.
# TYPE_VECTOR3_ARRAY = 25 — Variable is of type PoolVector3Array.
# TYPE_COLOR_ARRAY = 26 — Variable is of type PoolColorArray.
# TYPE_MAX = 27 — Marker for end of type constants.
# ------------------------------------------------------
var _supported_defaults = []

func _init():
	for i in range(TYPE_MAX):
		_supported_defaults.append(null)

	# These types do not require a prefix for defaults
	_supported_defaults[TYPE_NIL] = ''
	_supported_defaults[TYPE_BOOL] = ''
	_supported_defaults[TYPE_INT] = ''
	_supported_defaults[TYPE_REAL] = ''
	_supported_defaults[TYPE_OBJECT] = ''
	_supported_defaults[TYPE_ARRAY] = ''
	_supported_defaults[TYPE_STRING] = ''
	_supported_defaults[TYPE_DICTIONARY] = ''
	_supported_defaults[TYPE_VECTOR2_ARRAY] = ''

	# These require a prefix for whatever default is provided
	_supported_defaults[TYPE_VECTOR2] = 'Vector2'
	_supported_defaults[TYPE_RECT2] = 'Rect2'
	_supported_defaults[TYPE_VECTOR3] = 'Vector3'
	_supported_defaults[TYPE_COLOR] = 'Color'

# ###############
# Private
# ###############

func _is_supported_default(type_flag):
	return type_flag >= 0 and type_flag < _supported_defaults.size() and [type_flag] != null

# Creates a list of parameters with defaults of null unless a default value is
# found in the metadata.  If a default is found in the meta then it is used if
# it is one we know how support.
#
# If a default is found that we don't know how to handle then this method will
# return null.
func _get_arg_text(method_meta):
	var text = ''
	var args = method_meta.args
	var defaults = []
	var has_unsupported_defaults = false

	# fill up the defaults with null defaults for everything that doesn't have
	# a default in the meta data.  default_args is an array of default values
	# for the last n parameters where n is the size of default_args so we only
	# add nulls for everything up to the first parameter with a default.
	for i in range(args.size() - method_meta.default_args.size()):
		defaults.append('null')

	# Add meta-data defaults.
	for i in range(method_meta.default_args.size()):
		var t = args[defaults.size()]['type']
		var value = ''
		if(_is_supported_default(t)):
			# strings are special, they need quotes around the value
			if(t == TYPE_STRING):
				value = str("'", str(method_meta.default_args[i]), "'")
			# Colors need the parens but things like Vector2 and Rect2 don't
			elif(t == TYPE_COLOR):
				value = str(_supported_defaults[t], '(', str(method_meta.default_args[i]), ')')
			elif(t == TYPE_OBJECT):
				if(str(method_meta.default_args[i]) == "[Object:null]"):
					value = str(_supported_defaults[t], 'null')
				else:
					value = str(_supported_defaults[t], str(method_meta.default_args[i]).to_lower())

			# Everything else puts the prefix (if one is there) form _supported_defaults
			# in front.  The to_lower is used b/c for some reason the defaults for
			# null, true, false are all "Null", "True", "False".
			else:
				value = str(_supported_defaults[t], str(method_meta.default_args[i]).to_lower())
		else:
			_lgr.warn(str(
				'Unsupported default param type:  ',method_meta.name, '-', args[defaults.size()].name, ' ', t, ' = ', method_meta.default_args[i]))
			value = str('unsupported=',t)
			has_unsupported_defaults = true

		defaults.append(value)

	# construct the string of parameters
	for i in range(args.size()):
		text += str(PARAM_PREFIX, args[i].name, '=', defaults[i])
		if(i != args.size() -1):
			text += ', '

	# if we don't know how to make a default then we have to return null b/c
	# it will cause a runtime error and it's one thing we could return to let
	# callers know it didn't work.
	if(has_unsupported_defaults):
		text = null

	return text

# ###############
# Public
# ###############

# Creates a delceration for a function based off of function metadata.  All
# types whose defaults are supported will have their values.  If a datatype
# is not supported and the parameter has a default, a warning message will be
# printed and the declaration will return null.
func get_decleration_text(meta):
	var param_text = _get_arg_text(meta)
	var text = null
	if(param_text != null):
		text = str('func ', meta.name, '(', param_text, '):')
	return text

# creates a call to the function in meta in the super's class.
func get_super_call_text(meta):
	var params = ''
	var all_supported = true

	for i in range(meta.args.size()):
		params += PARAM_PREFIX + meta.args[i].name
		if(meta.args.size() > 1 and i != meta.args.size() -1):
			params += ', '

	return str('.', meta.name, '(', params, ')')

func get_spy_call_parameters_text(meta):
	var called_with = 'null'
	if(meta.args.size() > 0):
		called_with = '['
		for i in range(meta.args.size()):
			called_with += str(PARAM_PREFIX, meta.args[i].name)
			if(i < meta.args.size() - 1):
				called_with += ', '
		called_with += ']'
	return called_with

func get_logger():
	return _lgr

func set_logger(logger):
	_lgr = logger
